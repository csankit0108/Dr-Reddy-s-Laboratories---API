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
*  07-11-2022       |  mahalakshmi.sadhanantham@absyz.com	|  2.0          |    Process Before Trigger          
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

    /*
     * DRL - 48
     * Check if the utm Source Campaign code on incoming lead record is matching with Campaign code on Campaign records.
     * If the match exist then update the Source Campaign field on the (child) lead record with the matched Campaign record.
	 *
     * DRL - 49
     * Check if the utm Source code on incoming lead record is matching with the custom metadata UTM Source records with parameter Lable.
     * If the match exist then the matched record Lead Source value to be updated on the Lead record Lead Source field.
	 */
    public static void processBeforeInsert(List<Lead> list_leads){
        //Attributes for DRL-48
        set<String> set_CampaignCodes = new set<String>();
        map<String,Id> map_CampaignCodeWithCampaignID = new map<String,Id>();
        //Attributes for DRL-49
        set<String> set_SourceCodes = new set<String>();
        map<String,String> map_UtmSourcelablewithLeadSource = new map<String,String>();
        
        //Fetch campaign codes from Lead records in a SET(set_CampaignCodes)
        for(Lead objLead : list_leads){
            if(objLead.DRL_UTM_Campaign__c!=null){
               set_CampaignCodes.add(objLead.DRL_UTM_Campaign__c);
            }
            
            //DRL-49 Fetch source codes from Lead records in a SET(set_SourceCodes)
            if(objLead.DRL_UTM_Source__c!=null ){
                set_SourceCodes.add(objLead.DRL_UTM_Source__c);
            }
        }
        
        //Fetch campaign records which are in the set_CampaignCodes in a MAP(map_CampaignCodeWithCampaignID)
        for(Campaign objCampaign : [SELECT 
                                    Id, 
                                    Name,
                                    DRL_CampaignCode__c 
                                    FROM Campaign 
                                    WHERE DRL_CampaignCode__c IN: set_CampaignCodes 
                                    AND IsActive = true]){
                                        if(!map_CampaignCodeWithCampaignID.containsKey(objCampaign.DRL_CampaignCode__c)){
                                            map_CampaignCodeWithCampaignID.put(objCampaign.DRL_CampaignCode__c,objCampaign.Id);
                                        }
                                    }
        //DRL-49 Fetch Lable and LeadSource__c from UTM Source metadata records in a MAP(map_UtmSourcelablewithLeadSource)
        for(DRL_UTMSource__mdt mdtUTMsource : [SELECT
                                               Id,
                                               label,
                                               LeadSource__c 
                                               FROM DRL_UTMSource__mdt 
                                               WHERE label IN: set_SourceCodes ]){
                                                   if(!map_UtmSourcelablewithLeadSource.containsKey(mdtUTMsource.Label)){
                                                       map_UtmSourcelablewithLeadSource.put(mdtUTMsource.Label,mdtUTMsource.LeadSource__c);

                                                   }
                                               }
        
        //Assign the fetched campaign records to the Source campaign field on the Lead records
        for(Lead objLead : list_leads){
            if(map_CampaignCodeWithCampaignID.containsKey(objLead.DRL_UTM_Campaign__c)){
                objLead.DRL_Source_Campaign__c = map_CampaignCodeWithCampaignID.get(objLead.DRL_UTM_Campaign__c);
            }
            
            //DRL-49 Assign the fetched Lead source to the Lead record LeadSource field
            if(map_UtmSourcelablewithLeadSource.containsKey(objLead.DRL_UTM_Source__c)){
                objLead.LeadSource = map_UtmSourcelablewithLeadSource.get(objLead.DRL_UTM_Source__c);
            }
        }
    }  
}