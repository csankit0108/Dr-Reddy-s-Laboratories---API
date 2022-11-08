/*******************************************************************************************************
* 
* @ Name            :   DRL_LeadTriggerHelper
* @ Purpose         :   Helper class for LeadTrigger to handle all the operations on Lead
* @ Author          :   Deeksha Suvarna
* @ Usage           :   1) If Prospect exist - link it to child lead.
                        2) If Prospect does not exist - Create prospect and link it to child.
* @ Test Class Name :   
*
*   Date            |  Developer Name                |  Version    |    Changes    
* ======================================================================================================        
*  02-11-2022       |  deeksha.suvarna@absyz.com     |  1.0        |    Initial Version   
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
        Map<String, Schema.FieldSet> map_LeadFieldSet = objDescribeSObjectResult.fieldSets.getMap();
        //List of Lead Field Set Members
        List<FieldSetMember> list_LeadFieldSetMember = map_LeadFieldSet.get('DRL_ProspectFields').getFields();
        //List of Fields in the Field Set
        List<Schema.SObjectField> list_LeadObjectFields = new List<Schema.SObjectField>();
        //List of Incoming Lead with no existing Prospect
        List<Lead> list_ChildLeads = new List<Lead>();
        //List of Lead to be updated
        List<Lead> list_LeadsToUpdate = new List<Lead>();
        for (FieldSetMember objFieldSetMember : list_LeadFieldSetMember) {
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
                            objProspect.put(strFieldAPIName,map_LeadFieldByName.get(strFieldAPIName));
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
}