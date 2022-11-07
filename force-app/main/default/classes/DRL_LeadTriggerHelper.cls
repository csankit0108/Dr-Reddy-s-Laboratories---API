/*******************************************************************************************************
* 
* @ Name            :   DRL_LeadTriggerHelper
* @ Purpose         :   Apex class for prospect creation and field updation.
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
        Schema.DescribeSObjectResult strDescription = Lead.sObjectType.getDescribe();
        Map<String, Lead> map_LeadByEmail = new Map<String, Lead>();
        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
        Map<String, Lead> map_LeadsToInsert = new Map<String, Lead>();
        List<String> list_ConsolidatedDMLErrors = new List<String>();
        Map<String, Schema.FieldSet> map_LeadFieldSet = strDescription.fieldSets.getMap();
        List<FieldSetMember> list_LeadFieldSetMember = map_LeadFieldSet.get('DRL_ProspectFields').getFields();
        List<Schema.sObjectField> list_LeadsObjectField = new List<Schema.sObjectField>();
        List<Lead> list_ChildLeads = new List<Lead>();
        List<Lead> list_LeadsToUpdate = new List<Lead>();
        for (FieldSetMember objFields : list_LeadFieldSetMember) {
            list_LeadsObjectField.add(objFields.getSObjectField()); 
        }

        for (Lead objLead : [SELECT 
                             Id,
                             Email
                             FROM
                             Lead
                             WHERE RecordTypeId = :map_RecordTypeIdByDeveloperName.get('DRL_Prospect')
                             AND Id NOT IN :list_Leads
                             AND Email !=null
                             ]
        ) {
            map_LeadByEmail.put(objLead.Email, objLead);                    
        }
        
        try {
            for (Lead objLead : list_Leads) {
                if (!map_LeadByEmail.containsKey(objLead.Email)) {
                    //create prospect fields
                    Map<String, Object> map_LeadFieldByName = objLead.getPopulatedFieldsAsMap();
                    Lead objProspect = new Lead();
                    for ( Schema.sObjectField objField : list_LeadsObjectField) {
                        Schema.DescribeFieldResult dfr = objField.getDescribe();
                        string APIName = dfr.getName();
                        objProspect.put(APIName,map_LeadFieldByName.get(APIName));
                    }

                    objProspect.RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Prospect');
                    map_LeadsToInsert.put(objProspect.Email, objProspect);
                    list_ChildLeads.add(objLead);
                } else {
                    Lead objLeadToUpdate = new Lead(Id = objLead.Id);
                    objLeadToUpdate.DRL_Prospect__c = map_LeadByEmail.get(objLead.Email).Id;
                    objLeadToUpdate.DRL_Email__c = objLead.Email;
                    objLeadToUpdate.Email = null;
                    objLeadToUpdate.RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Lead');
                    list_LeadsToUpdate.add(objLeadToUpdate);
                }
            }
            
            DRL_LeadTriggerHelper.blnSkipTrigger = true;
            
            for (Lead objLead : list_ChildLeads) {
                Lead objLeadToUpdate = new Lead(Id = objLead.Id);
                objLeadToUpdate.DRL_Email__c = objLead.Email;
                objLeadToUpdate.Email = null;
                objLeadToUpdate.RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Lead');
                list_LeadsToUpdate.add(objLeadToUpdate);
            }

            if (!list_LeadsToUpdate.isEmpty()) {
                if (Test.isRunningTest() && DRL_LeadTriggerHelperTest.blnThrowException) {
                    throw new DMLException();
                } 
                
                //Update Email field
                List<Database.SaveResult> list_EmailUpdateResults = Database.update(list_LeadsToUpdate, false);
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_EmailUpdateResults, 'Update Email'));
            }
            
            //Create Parent Prospect Record
            if (!map_LeadsToInsert.isEmpty()) {
                List<Database.SaveResult> list_InsertResults = Database.insert(map_LeadsToInsert.values(), false);
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_InsertResults, 'Insert'));
            }

            for (Lead objLead : list_LeadsToUpdate) {
                if (objLead.DRL_Prospect__c == null && map_LeadsToInsert.containsKey(objLead.DRL_Email__c)) {
                    objLead.DRL_Prospect__c = map_LeadsToInsert.get(objLead.DRL_Email__c).Id;
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