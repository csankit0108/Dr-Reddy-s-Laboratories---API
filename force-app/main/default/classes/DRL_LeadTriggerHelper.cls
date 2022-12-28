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
*  27-12-2022       |  kishore.pedireddy@absyz.com          |  1.2          |    Populate Prospect on Lead on Email update and create Campaign member        
*******************************************************************************************************/
public without sharing class DRL_LeadTriggerHelper {
    public static Boolean blnSkipTrigger = false;   
    //map to get the weightage of Status value  
    public static Map<String, DRL_ProspectLeadStatusMapping__mdt> map_StatusMappingByLeadStatus = new Map<String, DRL_ProspectLeadStatusMapping__mdt>();
    //Map of Record Type Id by Developer Name
    public static Map<String, Id> map_RecordTypeIdByDeveloperName = new Map<String, Id>();
    /**
    * @ author       :  Ankit C
    * @ description  :  This method handles all the logic that needs to be performed in the afterInsert context
    * @ params       :  list_Leads - List of Leads from trigger.new
    * @ return       :  N/A
    **/
    public static void processAfterInsert(List<Lead> list_Leads) {
        map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
        addProspectOnLead(list_Leads, null);
        addProspectAsCampaignMember(list_Leads, null, null);        
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
            //If Lead has product info assign Lead record type, else assign Prospect record type
            if (String.isNotBlank(objLead.Product_Lookup__c) || String.isNotBlank(objLead.Product__c)) {
                objLead.RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Lead');
            } else if (objLead.RecordTypeId != map_RecordTypeIdByDeveloperName.get('DRL_Lead')) {
                objLead.RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Prospect');
            }

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
    * @ description  : This method handles all the logic that needs to performed in the afterUpdate context.
    * @ params       : map_NewMap - Map of Leads from trigger.newMap
    *                  map_OldMap - map_NewMap - Map of Leads from trigger.oldMap
    * @ return       : N/A
    */
    public static void processAfterUpdate(Map<Id, Lead> map_NewMap, Map<Id, Lead> map_OldMap) {
        map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
        addProspectOnLead(map_NewMap.values(), map_OldMap);
        addProspectAsCampaignMember(map_NewMap.values(), map_NewMap, map_OldMap);        
    }
    
    /*
    * @ author       : Kishore Pedireddy
    * @ description  : This method creates a CampaignMember for the Prospect of a Lead
    * @ params       : list_Leads - List of Lead records
                       map_NewMap - Map of leads from trigger.newMap
                       map_OldMap - Map of leads from trigger.oldMap
    * @ return       : N/A
    */
    public static void addProspectAsCampaignMember(List<Lead> list_Leads, Map<Id, Lead> map_NewMap, Map<Id, Lead> map_OldMap) {
        try {
            if (Test.isRunningTest() && DRL_LeadTriggerHelperTest.blnThrowExceptionWhileAddingCampaignMember) {
                throw new DMLException();
            }

            //Set to store the Prospect Ids
            Set<Id> set_ProspectIds = new Set<Id>();
            //List of Campaign Members to be created.
            List<CampaignMember> list_CampaignMembers = new List<CampaignMember>();         
            //List of all the Errors occurred during DML operation
            List<String> list_ConsolidatedDMLErrors = new List<String>();   

            list<Lead> list_LeadsToUpdate = [SELECT 
                                             Id,
                                             RecordTypeId,
                                             DRL_Prospect__c,
                                             DRL_SourceCampaign__c ,
                                             Email
                                             FROM Lead 
                                             WHERE Id IN :list_Leads];

            for (Lead objLead : list_LeadsToUpdate) {
                if (String.isNotBlank(objLead.DRL_Prospect__c)) {
                    set_ProspectIds.add(objLead.DRL_Prospect__c);
                }
            }

            Map<Id, Lead> map_ProspectById = new Map<Id, Lead>([
                SELECT Id, IsConverted, Converted_Contact__c 
                FROM Lead 
                WHERE Id IN :set_ProspectIds
            ]);

            for (Lead objLead : list_LeadsToUpdate) {
                if (
                    objLead.RecordTypeId == map_RecordTypeIdByDeveloperName.get('DRL_Lead') &&
                    objLead.DRL_Prospect__c != null &&
                    (                        
                        objLead.DRL_SourceCampaign__c != null &&
                        map_OldMap == null 
                    ) || 
                    (
                        map_OldMap != null &&
                        objLead.DRL_SourceCampaign__c != null && (
                            (
                                map_OldMap.get(objLead.Id).DRL_SourceCampaign__c == null || (
                                map_NewMap.get(objLead.Id).Email != null &&
                                map_OldMap.get(objLead.Id).Email == null
                                )
                            )
                        )
                    )                   
                ) {
                    CampaignMember objCampaignMember = new CampaignMember();
                    objCampaignMember.CampaignId = objLead.DRL_SourceCampaign__c;
                    objCampaignMember.LeadId = objLead.DRL_Prospect__c;
                    if (
                        map_ProspectById.containsKey(objLead.DRL_Prospect__c) &&
                        map_ProspectById.get(objLead.DRL_Prospect__c).IsConverted &&
                        String.isNotBlank(map_ProspectById.get(objLead.DRL_Prospect__c).Converted_Contact__c)
                    ) {
                        objCampaignMember.ContactId = map_ProspectById.get(objLead.DRL_Prospect__c).Converted_Contact__c;
                    } 

                    list_CampaignMembers.add(objCampaignMember);
                }
            }

            if (!list_CampaignMembers.isEmpty()) {
                List<Database.SaveResult> list_Results = Database.insert(list_CampaignMembers, false);
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_Results, 'Insert'));
            }

            if (!list_ConsolidatedDMLErrors.isEmpty()) {
                DRLUtil.logDMLException('DRL_LeadTriggerHelper', 'addProspectAsCampaignMember', list_ConsolidatedDMLErrors);
            }            
        } catch(Exception objException) {
            DRLUtil.logException(
                'DRL_LeadTriggerHelper',
                'addProspectAsCampaignMember',
                objException,
                true
            );
        }
    }

    /*
    * @ author       : Kishore Pedireddy
    * @ description  : Add Prospect on Lead
    * @ params       : list_Leads - List of Leads from trigger.new
                       map_OldMap - Map of leads from trigger.oldMap
    * @ return       : N/A
    */
    public static void addProspectOnLead(List<Lead> list_Leads, Map<Id, Lead> map_OldMap){
        try {
            if (Test.isRunningTest() && DRL_LeadTriggerHelperTest.blnThrowExceptionWhileAddingProspect) {
                throw new DMLException();
            }

            Schema.DescribeSObjectResult objDescribeSObjectResult = Lead.sObjectType.getDescribe();
            //Map of Lead Field Set by their Name
            Map<String, Schema.FieldSet> map_LeadFieldSetByName = objDescribeSObjectResult.fieldSets.getMap();
            //List of Lead Field Set Members
            List<FieldSetMember> list_LeadFieldSetMembers = map_LeadFieldSetByName.containsKey('DRL_ProspectFields')
                                                                ? map_LeadFieldSetByName.get('DRL_ProspectFields').getFields()
                                                                : new List<FieldSetMember>();
            //List of Fields in the Field Set
            List<Schema.SObjectField> list_LeadObjectFields = new List<Schema.SObjectField>();
            //Set of Lead Emails
            Set<String> set_LeadEmails = new Set<String>();
            //Set of Lead Emails
            Set<Id> set_Prospects = new Set<Id>();
            // Map of existing Leads by Email
            Map<String, Lead> map_ExistingLeadByEmail = new Map<String, Lead>();
            // Map of existing Leads by Id
            Map<String, Lead> map_ExistingLeadById = new Map<String, Lead>();
            //Map of Lead(Prospect) by their Email to be inserted
            Map<String, Lead> map_LeadByEmailToInsert = new Map<String, Lead>();
            //List of Prospects to be updated
            List<Lead> list_ProspectsToUpdate = new List<Lead>();
            //List of Lead to be updated
            List<Lead> list_LeadsToUpdate = new List<Lead>();
            //List of all the Errors occurred during DML operation
            List<String> list_ConsolidatedDMLErrors = new List<String>();

            for (FieldSetMember objFieldSetMember : list_LeadFieldSetMembers) {
                list_LeadObjectFields.add(objFieldSetMember.getSObjectField()); 
            }
            
            for (Lead objLead : list_Leads) {
                if (objLead.Email != null) {
                    set_LeadEmails.add(objLead.Email);                                            
                }

                if (objLead.DRL_Prospect__c != null) {
                    set_Prospects.add(objLead.DRL_Prospect__c);
                }
            }

            for (Lead objLead : [SELECT 
                                 Id,
                                 Email,
                                 Status
                                 FROM
                                 Lead
                                 WHERE RecordTypeId = :map_RecordTypeIdByDeveloperName.get('DRL_Prospect')
                                 AND (
                                     Email IN :set_LeadEmails 
                                     OR Id IN :set_Prospects 
                                )]
            ) {
                map_ExistingLeadByEmail.put(objLead.Email, objLead);                    
                map_ExistingLeadById.put(objLead.Id, objLead);  
            }

            for (DRL_ProspectLeadStatusMapping__mdt objProspectLeadStatusMapping : DRL_ProspectLeadStatusMapping__mdt.getAll().values()) {
                if (objProspectLeadStatusMapping.Active__c) {
                    map_StatusMappingByLeadStatus.put(
                        objProspectLeadStatusMapping.LeadStatus__c, 
                        objProspectLeadStatusMapping
                    );
                }
            }

            for (Lead objLead : list_Leads) {
                if (
                    objLead.RecordTypeId != map_RecordTypeIdByDeveloperName.get('DRL_Prospect') && 
                    (                        
                        String.isBlank(objLead.DRL_Prospect__c) && 
                        String.isNotBlank(objLead.Email) &&
                        map_OldMap == null

                    ) || (
                        map_OldMap != null &&
                        String.isNotBlank(objLead.Email) &&
                        String.isBlank(map_OldMap.get(objLead.Id).Email) 
                    )                    
                ) {
                    Lead objLeadToUpdate = new Lead(Id = objLead.Id);
                    objLeadToUpdate.DRL_Email__c = objLead.Email;
                    objLeadToUpdate.Email = null;
                    if (map_RecordTypeIdByDeveloperName.containsKey('DRL_Lead')) {
                        objLeadToUpdate.RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Lead');
                    }

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

                        if (map_StatusMappingByLeadStatus.containsKey(objLead.Status)) {
                            objProspect.Status = map_StatusMappingByLeadStatus.get(objLead.Status).ProspectStatus__c;
                        }

                        map_LeadByEmailToInsert.put(objProspect.Email, objProspect);
                    } else {                        
                        objLeadToUpdate.DRL_Prospect__c = map_ExistingLeadByEmail.get(objLead.Email).Id;                        
                        if (map_RecordTypeIdByDeveloperName.containsKey('DRL_Lead')) {
                            objLeadToUpdate.RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Lead');
                        }

                        Lead objProspectToUpdate = map_ExistingLeadByEmail.get(objLead.Email);
                        if (isProspectHasLowerWeightage(objProspectToUpdate.Status, objLead.Status)) {
                            objProspectToUpdate.Status = map_StatusMappingByLeadStatus.get(objLead.Status).ProspectStatus__c;
                            list_ProspectsToUpdate.add(objProspectToUpdate);
                        }
                    }   

                    list_LeadsToUpdate.add(objLeadToUpdate);
                } else if (
                    map_OldMap != null && 
                    objLead.Status != map_OldMap.get(objLead.Id).Status &&
                    objLead.RecordTypeId == map_RecordTypeIdByDeveloperName.get('DRL_Lead') &&
                    objLead.DRL_Prospect__c != null &&
                    map_ExistingLeadById.get(objLead.DRL_Prospect__c) != null
                ) {
                    Lead objProspectToUpdate = map_ExistingLeadById.get(objLead.DRL_Prospect__c);    
                    //Check if the weightage of the new Prospect > current weightage of Prospect status
                    if (isProspectHasLowerWeightage(objProspectToUpdate.Status, objLead.Status)) {
                        objProspectToUpdate.Status = map_StatusMappingByLeadStatus.get(objLead.Status).ProspectStatus__c;
                        list_ProspectsToUpdate.add(objProspectToUpdate);
                    }                    
                }
            }

            DRL_LeadTriggerHelper.blnSkipTrigger = true;

            if (!list_LeadsToUpdate.isEmpty()) {
                //Update Email field
                List<Database.SaveResult> list_UpdateResults = Database.update(list_LeadsToUpdate, false);
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_UpdateResults, 'Update'));
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

            if (!list_ProspectsToUpdate.isEmpty()) {
                //Update Status on Prospect
                List<Database.SaveResult> list_UpdateResults = Database.update(list_ProspectsToUpdate, false);
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_UpdateResults, 'Update'));
            }

            DRL_LeadTriggerHelper.blnSkipTrigger = false;
        } catch (Exception objException) {
            DRLUtil.logException(
                'DRL_LeadTriggerHelper',
                'addProspectOnLead',
                objException,
                true
            );            
        }
    }

    /*
    * @ author       : Kishore Pedireddy
    * @ description  : Method to check if the weightage of the new Lead status is greater than the weightage of the status of the Prospect.
    * @ params       : strProspectStatus - String Status of Prospect
                       strLeadStatus     - String Status of Child Lead
    * @ return       : Boolean value true if Prospect Status is lower than child Status
    */
    public static Boolean isProspectHasLowerWeightage(String strProspectStatus, String strLeadStatus) {
        String strNewStatus = map_StatusMappingByLeadStatus.get(strLeadStatus).ProspectStatus__c;
        Integer intNewStatusWeightage = map_StatusMappingByLeadStatus.containsKey(strNewStatus)
                                      ? (Integer)map_StatusMappingByLeadStatus.get(strNewStatus).Weightage__c
                                      : 0;
        //Weightage of the current status value of the Prospect
        Integer intOldStatusWeightage = (String.isNotBlank(strProspectStatus) && map_StatusMappingByLeadStatus.containsKey(strProspectStatus))
                                      ? (Integer)map_StatusMappingByLeadStatus.get(strProspectStatus).Weightage__c
                                      : 0;
        
        if (
            (intNewStatusWeightage > intOldStatusWeightage) &&
            (strProspectStatus != strNewStatus) 
        ) {
            return true;
        } else {
            return false;
        }
    }
}