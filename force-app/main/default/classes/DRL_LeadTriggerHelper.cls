/*******************************************************************************************************
* 
* @ Name            :   DRL_LeadTriggerHelper
* @ Purpose         :   Helper class for LeadTrigger to handle all the operations on Lead
* @ Author          :   Deeksha Suvarna
* @ Usage           :   1) If Prospect exist - link it to child lead.
                        2) If Prospect does not exist - Create prospect and link it to child.
* @ Test Class Name :   DRL_LeadTriggerHelperTest
*
*   Date            |  Developer Name                       |  Version      |    Changes    
* ======================================================================================================        
*  02-11-2022       |  deeksha.suvarna@absyz.com            |  1.0          |    Initial Version   
*  07-11-2022       |  mahalakshmi.sadhanantham@absyz.com   |  1.1          |    Process Before Trigger          
*******************************************************************************************************/
public without sharing class DRL_LeadTriggerHelper {
    public static Boolean blnSkipTrigger = false;
    public static void processAfterInsert(List<Lead> list_Leads) {
        Schema.DescribeSObjectResult objDescribeSObjectResult = Lead.sObjectType.getDescribe();
        // Map of existing Leads by Email
        Map<String, Lead> map_ExistingLeadByEmail = new Map<String, Lead>();
        //Map of Record Type Id by Developer Name
        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
        //Map of Lead(Prospect) by their Email to be inserted
        Map<String, Lead> map_LeadByEmailToInsert = new Map<String, Lead>();
        //List of all the Errors occurred during DML operation
        List<String> list_ConsolidatedDMLErrors = new List<String>();
        //Map of Lead Field Set by their Name
        Map<String, Schema.FieldSet> map_LeadFieldSetByName = objDescribeSObjectResult.fieldSets.getMap();
        //List of Lead Field Set Members
        List<FieldSetMember> list_LeadFieldSetMembers = map_LeadFieldSetByName.containsKey('DRL_ProspectFields')
                                                            ? map_LeadFieldSetByName.get('DRL_ProspectFields').getFields()
                                                            : new List<FieldSetMember>();
        //List of Fields in the Field Set
        List<Schema.SObjectField> list_LeadObjectFields = new List<Schema.SObjectField>();
        //List of Incoming Lead with no existing Prospect
        List<Lead> list_ChildLeads = new List<Lead>();
        //List of Lead to be updated
        List<Lead> list_LeadsToUpdate = new List<Lead>();
        //List of Campaign Members to be created.
        List<CampaignMember> list_CampaignMembers = new List<CampaignMember>();

        for (FieldSetMember objFieldSetMember : list_LeadFieldSetMembers) {
            list_LeadObjectFields.add(objFieldSetMember.getSObjectField()); 
        }

        for (Lead objLead : [SELECT 
                             Id,
                             Email
                             FROM
                             Lead
                             WHERE RecordTypeId = :map_RecordTypeIdByDeveloperName.get('DRL_Prospect')
                             AND Id NOT IN :list_Leads
                             AND Email != null
                             ]
        ) {
            map_ExistingLeadByEmail.put(objLead.Email, objLead);                    
        }
        
        try {
            for (Lead objLead : list_Leads) {
                if (!map_ExistingLeadByEmail.containsKey(objLead.Email)) {
                    //Creating Prospect if it's not existing in the system
                    Map<String, Object> map_LeadFieldByName = objLead.getPopulatedFieldsAsMap();
                    Lead objProspect = new Lead();
                    for (Schema.SObjectField objSObjectField : list_LeadObjectFields) {
                        Schema.DescribeFieldResult objDescribeFieldResult = objSObjectField.getDescribe();
                        String strFieldAPIName = objDescribeFieldResult.getName();
                        if (map_LeadFieldByName.containsKey(strFieldAPIName)) {
                            objProspect.put(strFieldAPIName, map_LeadFieldByName.get(strFieldAPIName));
                        }
                    }

                    if (map_RecordTypeIdByDeveloperName.containsKey('DRL_Prospect')) {
                        objProspect.RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Prospect'); 
                    }

                    map_LeadByEmailToInsert.put(objProspect.Email, objProspect);
                    list_ChildLeads.add(objLead);
                } else {
                    Lead objLeadToUpdate = new Lead(Id = objLead.Id);
                    objLeadToUpdate.DRL_Prospect__c = map_ExistingLeadByEmail.get(objLead.Email).Id;
                    objLeadToUpdate.DRL_Email__c = objLead.Email;
                    objLeadToUpdate.Email = null;

                    if (map_RecordTypeIdByDeveloperName.containsKey('DRL_Lead')) {
                        objLeadToUpdate.RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Lead');
                    }

                    list_LeadsToUpdate.add(objLeadToUpdate);
                }
            }
            
            DRL_LeadTriggerHelper.blnSkipTrigger = true;
            
            for (Lead objLead : list_ChildLeads) {
                Lead objLeadToUpdate = new Lead(Id = objLead.Id);
                objLeadToUpdate.DRL_Email__c = objLead.Email;
                objLeadToUpdate.Email = null;

                if (map_RecordTypeIdByDeveloperName.containsKey('DRL_Lead')) {
                    objLeadToUpdate.RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Lead');
                }

                list_LeadsToUpdate.add(objLeadToUpdate);
            }

            if (!list_LeadsToUpdate.isEmpty()) {
                if (Test.isRunningTest() && DRL_LeadTriggerHelperTest.blnThrowException) {
                    throw new DMLException();
                } 

                //Update Email field
                List<Database.SaveResult> list_UpdateLeadResults = Database.update(list_LeadsToUpdate, false);
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_UpdateLeadResults, 'Update'));
            }
            
            //Create Parent Prospect Record
            if (!map_LeadByEmailToInsert.isEmpty()) {
                List<Database.SaveResult> list_InsertResults = Database.insert(map_LeadByEmailToInsert.values(), false);
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_InsertResults, 'Insert'));
            }

            for (Lead objLead : list_LeadsToUpdate) {
                if (objLead.DRL_Prospect__c == null && map_LeadByEmailToInsert.containsKey(objLead.DRL_Email__c)) {
                    objLead.DRL_Prospect__c = map_LeadByEmailToInsert.get(objLead.DRL_Email__c).Id;
                }
            }

            if (!list_LeadsToUpdate.isEmpty()) {
                //Link it to Child
                List<Database.SaveResult> list_UpdateResults = Database.update(list_LeadsToUpdate, false);
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_UpdateResults, 'Update'));
            }

            /*
              * DRL-50:When a Source Campaign record is linked to the Child lead record, create a Campaign member record.
            */
            list_LeadsToUpdate = [SELECT 
                                  Id,
                                  RecordTypeId,
                                  DRL_Prospect__c,
                                  DRL_SourceCampaign__c 
                                  FROM Lead 
                                  WHERE Id IN :list_LeadsToUpdate];
            for (Lead objLead : list_LeadsToUpdate) {
                if ( 
                    objLead.RecordTypeId == map_RecordTypeIdByDeveloperName.get('DRL_Lead') &&
                    objLead.DRL_SourceCampaign__c != null &&
                    objLead.DRL_Prospect__c != null
                ) {
                    CampaignMember objCampaignMember = new CampaignMember();
                    objCampaignMember.CampaignId = objLead.DRL_SourceCampaign__c;
                    objCampaignMember.LeadId = objLead.DRL_Prospect__c; 
                    list_CampaignMembers.add(objCampaignMember);
                }
            }

            if (!list_CampaignMembers.isEmpty()) {
                List<Database.SaveResult> list_Results = Database.insert(list_CampaignMembers, false);
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_Results, 'Insert'));
            }

            if (!list_ConsolidatedDMLErrors.isEmpty()) {
                DRLUtil.logDMLException('DRL_LeadTriggerHelper', 'processAfterInsert', list_ConsolidatedDMLErrors);
            }
            
            DRL_LeadTriggerHelper.blnSkipTrigger = false;
        } catch(Exception objException) {
            DRLUtil.logException(
                'DRL_LeadTriggerHelper',
                'processAfterInsert',
                objException,
                true
            );
        }
    } 

    /**
    * @ author       :  Mahalakshmi Sadhananthan
    * @ description  :  1. This method is used to Check if the utm Source Campaign code on incoming lead record is matching with Campaign code on Campaign records.
    *                   If the match exist then update the Source Campaign field on the (child) lead record with the matched Campaign record.
	*                   2. Check if the utm Source code on incoming lead record is matching with the custom metadata UTM Source records with parameter Lable.
    *                   If the match exist then the matched record Lead Source value to be updated on the Lead record Lead Source field.
    * @ params       :  set_CampaignCodes - To fetch campaign codes from Lead records in a SET
    *                   map_CampaignCodeWithCampaignID - Fetch campaign records which are in the set_CampaignCodes in a MAP
    *                   set_SourceCodes - To fetch source codes from Lead records in a SET
    *                   map_UtmSourcelablewithLeadSource - Fetch Lable and LeadSource__c from UTM Source metadata records in a MAP
    * @ return       :  N/A
    **/
    public static void processBeforeInsert(List<Lead> list_Leads) {
        //Set of Campaign Codes 
        Set<String> set_CampaignCodes = new Set<String>();
        //Map of Campaign code with Campaign ID 
        Map<String, Id> map_CampaignIdByCampaignCode = new Map<String, Id>();
        //Set of Source Codes
        Set<String> set_SourceCodes = new Set<String>();
        //Map of UTM source lable with Lead source
        Map<String, String> map_LeadSourceByUtmSource = new Map<String, String>();
        
        //Fetch campaign codes from Lead records in a SET(set_CampaignCodes)
        for (Lead objLead : list_Leads) {
            if (String.isNotBlank(objLead.DRL_UTMCampaign__c)) {
               set_CampaignCodes.add(objLead.DRL_UTMCampaign__c);
            }
            
            //Fetch source codes from Lead records in a SET(set_SourceCodes)
            if (String.isNotBlank(objLead.DRL_UTMSource__c)) {
                set_SourceCodes.add(objLead.DRL_UTMSource__c);
            }
        }
        
        //Fetch campaign records which are in the set_CampaignCodes in a MAP(map_CampaignCodeWithCampaignID)
        for (Campaign objCampaign : [SELECT 
                                     Id, 
                                     Name,
                                     DRL_CampaignCode__c 
                                     FROM Campaign 
                                     WHERE DRL_CampaignCode__c IN :set_CampaignCodes 
                                     AND IsActive = true]
        ) {
            if(!map_CampaignIdByCampaignCode.containsKey(objCampaign.DRL_CampaignCode__c)) {
                map_CampaignIdByCampaignCode.put(objCampaign.DRL_CampaignCode__c, objCampaign.Id);
            }
        }
        
        //Fetch active Lable and LeadSource__c from UTM Source metadata records in a MAP(map_UtmSourcelablewithLeadSource)
        List<DRL_UTMSource__mdt> list_UTMSourceMappings = DRL_UTMSource__mdt.getAll().values();
        
        for (DRL_UTMSource__mdt objUTMSourceMapping : list_UTMSourceMappings) {
            if (
                !map_LeadSourceByUtmSource.containsKey(objUTMSourceMapping.DeveloperName) && 
                set_SourceCodes.contains(objUTMSourceMapping.DeveloperName) && 
                (objUTMSourceMapping.IsActive__c)
            ) {
                map_LeadSourceByUtmSource.put(objUTMSourceMapping.DeveloperName, objUTMSourceMapping.LeadSource__c);
            }
        }
        
        //Assign the fetched campaign records to the Source campaign field on the Lead records
        for (Lead objLead : list_Leads) {
            if (map_CampaignIdByCampaignCode.containsKey(objLead.DRL_UTMCampaign__c)) {
                objLead.DRL_SourceCampaign__c = map_CampaignIdByCampaignCode.get(objLead.DRL_UTMCampaign__c);
            }
            
            //DRL-49 Assign the fetched Lead source to the Lead record LeadSource field
            if (map_LeadSourceByUtmSource.containsKey(objLead.DRL_UTMSource__c)) {
                objLead.LeadSource = map_LeadSourceByUtmSource.get(objLead.DRL_UTMSource__c);
            }
        }
    }

    /*
    * @ author       : Wafa Shaikh
    * @ description  : Updating the prosepct record with the Status value based on the Lead records status value
    * @ params       : list_Leads - List of Lead records
    * @ return       : N/A
    */
    public static void processAfterUpdate(List<Lead> list_Leads) {
        //Set to store the Prospect Ids
        Set<Id> set_ProspectIds = new Set<Id>();
        //map to get the weightage of Status value  
        Map<String, DRL_ProspectLeadStatusMapping__mdt> map_StatusMappingByLeadStatus 
            = new Map<String, DRL_ProspectLeadStatusMapping__mdt>();
        //List of Prospect records to update
        List<Lead> list_ProspectsToUpdate  = new List<Lead>();
        //list of DRL_ProspectLeadStatusMapping__mdt records
        List<DRL_ProspectLeadStatusMapping__mdt> list_ProspectLeadStatusMappings 
            = new List<DRL_ProspectLeadStatusMapping__mdt>();
        //List of all the Errors occurred during DML operation
        List<String> list_ConsolidatedDMLErrors = new List<String>();

        for (Lead objLead : list_Leads) {
            if (String.isNotBlank(objLead.DRL_Prospect__c)) {
                set_ProspectIds.add(objLead.DRL_Prospect__c);
            }
        }

        //Map of Prospect records by Id
        Map<Id, Lead> map_LeadById = new Map<Id, Lead>([
            SELECT Id, Status
            FROM Lead
            WHERE Id IN :set_ProspectIds
        ]);

        list_ProspectLeadStatusMappings = DRL_ProspectLeadStatusMapping__mdt.getAll().values();
        //Fetch the records from Custom metadata and form a map of metadata record by status value
        for (DRL_ProspectLeadStatusMapping__mdt objProspectLeadStatusMapping : list_ProspectLeadStatusMappings) {
            if (objProspectLeadStatusMapping.Active__c) {
                map_StatusMappingByLeadStatus.put(
                    objProspectLeadStatusMapping.LeadStatus__c, 
                    objProspectLeadStatusMapping
                );
            }
        }

        for (Lead objLead : list_Leads) {
            if (String.isBlank(objLead.DRL_Prospect__c)) {
                continue;
            }
            
            Lead objProspect = map_LeadById.containsKey(objLead.DRL_Prospect__c) 
                ? map_LeadById.get(objLead.DRL_Prospect__c)
                : new Lead();
            //New status value of the Lead
            String strLeadStatus = objLead.Status;
            //Current status value of the Prospect
            String strProspectStatus = objProspect?.Status;
            //Weightage of the new Lead status value
            Integer intNewStatusWeightage = map_StatusMappingByLeadStatus.containsKey(strLeadStatus)
                ? (Integer)map_StatusMappingByLeadStatus.get(strLeadStatus).Weightage__c
                : 0;
            //Weightage of the current status value of the Prospect
            Integer intOldStatusWeightage = (String.isNotBlank(strProspectStatus) && map_StatusMappingByLeadStatus.containsKey(strProspectStatus))
                ? (Integer)map_StatusMappingByLeadStatus.get(strProspectStatus).Weightage__c
                : 0;
            
            /*Check if the new Lead status weightage > current status of Prospect and
              old Lead status is not same as the new Prospect status that needs to be updated
            */
            if (
                (intNewStatusWeightage > intOldStatusWeightage) &&
                map_StatusMappingByLeadStatus.containsKey(strLeadStatus) && 
                (strProspectStatus != map_StatusMappingByLeadStatus.get(strLeadStatus).ProspectStatus__c)
            ) {
                objProspect.Status = map_StatusMappingByLeadStatus.get(strLeadStatus).ProspectStatus__c;
                list_ProspectsToUpdate.add(objProspect);
            }
        }

        if (!list_ProspectsToUpdate.isEmpty()) {
            DRL_LeadTriggerHelper.blnSkipTrigger = true;
            List<Database.SaveResult> list_Results = Database.update(list_ProspectsToUpdate, false);
            DRL_LeadTriggerHelper.blnSkipTrigger = false;
            list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_Results, 'Update'));
        }

        if (!list_ConsolidatedDMLErrors.isEmpty()) {
            DRLUtil.logDMLException('DRL_LeadTriggerHelper', 'processAfterUpdate', list_ConsolidatedDMLErrors);
        }   
    }  
}