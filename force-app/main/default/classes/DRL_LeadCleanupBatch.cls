/*******************************************************************************************************
* 
* @ Name            :   DRL_LeadCleanupBatch
* @ Purpose         :   Lead Clean up 
* @ Author          :   Kishore Pedireddy
* @ Usage           :   Update recordtype information on Legacy data
* @ Test Class Name :   DRL_LeadCleanupBatchTest
*
*   Date            |  Developer Name                |  Version    |    Changes    
* ======================================================================================================        
*  29-12-2022       |  kishore.pedireddy@absyz.com   |  1.0        |    Initial Version   
*******************************************************************************************************/
public without sharing class DRL_LeadCleanupBatch implements Database.Batchable<sObject> {    
    public Database.QueryLocator start(Database.BatchableContext objBatchableContext) {    
        String Query = 'SELECT ' + DRLUtil.getsObjectFieds('Lead') + ' FROM Lead ORDER BY DRL_IsProspect__c DESC';
        return Database.getQueryLocator(Query);
    }

    public void execute(Database.BatchableContext objBatchableContext, List<Lead> list_Leads) {
        try {
            if (Test.isRunningTest() && DRL_LeadCleanupBatchTest.blnThrowException) {
                throw new DMLException();
            }
            DRL_LeadTriggerHelper.blnSkipTrigger = true;
            Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');        
            List<Lead> list_ProspectsToUpdate = new List<Lead>();
            List<Lead> list_LeadsToCreate = new List<Lead>();
            List<String> list_ConsolidatedDMLErrors = new List<String>();
            List<Lead> list_LeadsToUpdate = new List<Lead>();
            Set<String> set_LeadEmails = new Set<String>();
            Map<String, Lead> map_ProspectsByEmail = new Map<String, Lead>();      
            //map to get the led to prospect status mapping
            Map<String, DRL_ProspectLeadStatusMapping__mdt> map_StatusMappingByLeadStatus 
                                                            = new Map<String, DRL_ProspectLeadStatusMapping__mdt>();             

            for (DRL_ProspectLeadStatusMapping__mdt objProspectLeadStatusMapping : DRL_ProspectLeadStatusMapping__mdt.getAll().values()) {
                if (objProspectLeadStatusMapping.Active__c) {
                    map_StatusMappingByLeadStatus.put(
                        objProspectLeadStatusMapping.LeadStatus__c, 
                        objProspectLeadStatusMapping
                    );
                }
            }

            for (Lead objLead : list_Leads) {
                if (objLead.DRL_IsProspect__c && objLead.Email != null) {                    
                    //Create Lead    
                    Lead objClonedLead = objLead.clone(false, true, true, false);
                    objClonedLead.RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Lead');
                    objClonedLead.DRL_Email__c = objClonedLead.Email;
                    objClonedLead.Email = null;
                    objClonedLead.DRL_Prospect__c = objLead.Id;
                    objClonedLead.DRL_IsProspect__c = false;
                    list_LeadsToCreate.add(objClonedLead);    
                    
                    //Convert Lead to Prospect 
                    objLead.Status = map_StatusMappingByLeadStatus.get(objLead.Status).ProspectStatus__c;
                    objLead.RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Prospect');
                    objLead.Product_Lookup__c = null;
                    objLead.Product__c = null;
                    list_ProspectsToUpdate.add(objLead); 
                } else {
                    if (objLead.Email != null) {
                        set_LeadEmails.add(objLead.Email);
                    }

                    objLead.RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Lead');
                    list_LeadsToUpdate.add(objLead);
                }
            }
    
            if (!list_ProspectsToUpdate.isEmpty()) {
                List<Database.SaveResult> list_UpdateResults = Database.update(list_ProspectsToUpdate, false);
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_UpdateResults, 'Update'));
            }

            if (!list_LeadsToCreate.isEmpty()) {
                List<Database.SaveResult> list_CreateResults = Database.insert(list_LeadsToCreate, false);
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_CreateResults, 'Insert'));
            }

            for (Lead objProspect : [SELECT 
                                     Id,
                                     Email,
                                     Status 
                                     FROM Lead 
                                     WHERE Email IN :set_LeadEmails 
                                     AND RecordTypeId = :map_RecordTypeIdByDeveloperName.get('DRL_Prospect')]
            ) {
                map_ProspectsByEmail.put(objProspect.Email, objProspect);
            }
            
            Map<String, Lead> map_ProspectsToUpdate = new Map<String, Lead>();
            for (Lead objLead : list_LeadsToUpdate) {
                if (objLead.Email != null && map_ProspectsByEmail.containsKey(objLead.Email)) {
                    Lead objProspect = map_ProspectsByEmail.get(objLead.Email);
                    objLead.DRL_Prospect__c = objProspect.Id;
                    objLead.DRL_Email__c = objLead.Email;
                    objLead.Email = null;
                    Integer intNewStatusWeightage = map_StatusMappingByLeadStatus.containsKey(objLead.Status)
                                      ? (Integer)map_StatusMappingByLeadStatus.get(objLead.Status).Weightage__c
                                      : 0;
                    //Weightage of the current status value of the Prospect
                    Integer intOldStatusWeightage = (String.isNotBlank(objProspect.Status) && map_StatusMappingByLeadStatus.containsKey(objProspect.Status))
                                                ? (Integer)map_StatusMappingByLeadStatus.get(objProspect.Status).Weightage__c
                                                : 0;
                    if (
                        (intNewStatusWeightage > intOldStatusWeightage) &&
                        map_StatusMappingByLeadStatus.get(objLead.Status).ProspectStatus__c != objProspect.Status
                    ) {
                        objProspect.Status = map_StatusMappingByLeadStatus.get(objLead.Status).ProspectStatus__c;
                        map_ProspectsToUpdate.put(objLead.Email, objProspect);
                    } 
                }                
            }

            if (!map_ProspectsToUpdate.values().isEmpty()) {
                list_LeadsToUpdate.addAll(map_ProspectsToUpdate.values());
            }

            if (!list_LeadsToUpdate.isEmpty()) {
                List<Database.SaveResult> list_UpdateResults = Database.update(list_LeadsToUpdate, false);
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_UpdateResults, 'Update'));
            }              
            
            if (!list_ConsolidatedDMLErrors.isEmpty()) {
                DRLUtil.logDMLException(
                    'DRL_LeadCleanupBatch',
                    'execute',
                    list_ConsolidatedDMLErrors
                );
            }
        } catch (Exception objException) {
            DRLUtil.logException(
                'DRL_LeadCleanupBatch',
                'execute',
                objException,
                true
            );
        }
    }
       
    public void finish(Database.BatchableContext objBatchableContext) {
    }
}