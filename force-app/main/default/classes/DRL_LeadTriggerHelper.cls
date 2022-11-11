/*******************************************************************************************************
* 
* @ Name            :   DRL_LeadTriggerHelper
* @ Purpose         :   Helper class for LeadTrigger to handle all the operations on Lead
* @ Author          :   Deeksha Suvarna
* @ Usage           :   1) If Prospect exist - link it to child lead.
                        2) If Prospect does not exist - Create prospect and link it to child.
* @ Test Class Name :   
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
                List<Database.SaveResult> list_UpdateResults = Database.update(list_LeadsToUpdate,false);
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_UpdateResults, 'Update'));
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
    * @ return       :  
    **/

    public static void processBeforeInsert(List<Lead> list_leads) {
        //Set of Campaign Codes 
        Set<String> set_CampaignCodes = new Set<String>();
        //Map of Campaign code with Campaign ID 
        Map<String, Id> map_CampaignIDByCampaignCode = new Map<String, Id>();
        //Set of Source Codes
        Set<String> set_SourceCodes = new Set<String>();
        //Map of UTM source lable with Lead source
        Map<String, String> map_LeadSourceByUtmSource = new Map<String, String>();
        
        //Fetch campaign codes from Lead records in a SET(set_CampaignCodes)
        for (Lead objLead : list_leads) {
            if (String.isNotBlank(objLead.DRL_UTMCampaign__c)) {
               set_CampaignCodes.add(objLead.DRL_UTMCampaign__c);
            }
            
            //Fetch source codes from Lead records in a SET(set_SourceCodes)
            if (String.isNotBlank(objLead.DRL_UTMSource__c) ) {
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
                                    AND IsActive = true]) {
                                        if(!map_CampaignIDByCampaignCode.containsKey(objCampaign.DRL_CampaignCode__c)) {
                                            map_CampaignIDByCampaignCode.put(objCampaign.DRL_CampaignCode__c, objCampaign.Id);
                                        }
                                    }
        
        //Fetch Lable and LeadSource__c from UTM Source metadata records in a MAP(map_UtmSourcelablewithLeadSource)
        List<DRL_UTMSource__mdt> list_utmSourceMetadata = DRL_UTMSource__mdt.getAll().values();
        
        for (DRL_UTMSource__mdt mdtUTMsource : list_utmSourceMetadata) {
            if (!map_LeadSourceByUtmSource.containsKey(mdtUTMsource.Label) && set_SourceCodes.contains(mdtUTMsource.Label)) {
                map_LeadSourceByUtmSource.put(mdtUTMsource.Label, mdtUTMsource.LeadSource__c);
            }
        }
        
        //Assign the fetched campaign records to the Source campaign field on the Lead records
        for (Lead objLead : list_leads) {
            if (map_CampaignIDByCampaignCode.containsKey(objLead.DRL_UTMCampaign__c)) {
                objLead.DRL_SourceCampaign__c = map_CampaignIDByCampaignCode.get(objLead.DRL_UTMCampaign__c);
            }
            
            //DRL-49 Assign the fetched Lead source to the Lead record LeadSource field
            if (map_LeadSourceByUtmSource.containsKey(objLead.DRL_UTMSource__c)) {
                objLead.LeadSource = map_LeadSourceByUtmSource.get(objLead.DRL_UTMSource__c);
            }
        }
    } 
    
    public static void processAfterUpdate(Set<String> set_oldProspectStatus,Set<String> set_newLeadStatus,Set<Id> set_prospectId){
        Set<String>  set_OldParentStatus = new Set<String>();
        Map<String,Double> map_getOldWeightage = new Map<String,Double>();
        Map<String,Double> Map_getNewWeightage = new Map<String,Double>();
        Double oldWeightage;
        Double newWeightage;
        String strnewParentStatus;
        List<Lead>  list_updateParentLead = new List<Lead>();
        for(Lead objparentLead : [select Id,
                               Status 
                               from Lead 
                               where Id In: set_prospectId]){
            set_OldParentStatus.add(objparentLead.Status);
                                   
            
        }
        
        for(Prospect_Lead_Status_Mapping__mdt objprospectLeadStatus :[Select Lead_Status__c,
                                                                   Weightage__c,
                                                                   Prospect_Status__c
                                                                   from Prospect_Lead_Status_Mapping__mdt
                                                                   where Lead_Status__c In:set_OldParentStatus]){
                                                                       map_getOldWeightage.put(objprospectLeadStatus.Lead_Status__c,objprospectLeadStatus.Weightage__c);
                                                                       oldWeightage = objprospectLeadStatus.Weightage__c;
                                                                       System.debug('old parent status' + oldWeightage );
                                                                   }
                                                                 
        
        for(Prospect_Lead_Status_Mapping__mdt objprospectLeadStatus :[Select Lead_Status__c,
                                                                   Weightage__c,
                                                                   Prospect_Status__c 
                                                                   from Prospect_Lead_Status_Mapping__mdt
                                                                   where Lead_Status__c In: set_newLeadStatus 
                                                                   ]){
                                                                      strnewParentStatus = objprospectLeadStatus.Prospect_Status__c;
                                                                      newWeightage = objprospectLeadStatus.Weightage__c;
                                                                  }
        
        
        for(Lead objparentLead : [select Id,
                               Status
                               from Lead
                               where Id In: set_prospectId]){
            if(newWeightage> oldWeightage  && strnewParentStatus != objparentLead.Status)
            {
                
                objparentLead.Status = strnewParentStatus;
                list_updateParentLead.add(objparentLead);
            }
            if(list_updateParentLead.size() > 0){
                DRL_LeadTriggerHelper.blnSkipTrigger = true;
                update list_updateParentLead;
                DRL_LeadTriggerHelper.blnSkipTrigger = false;
            }
        }
    }
        
    
        
        
        
        
        
        
        
}