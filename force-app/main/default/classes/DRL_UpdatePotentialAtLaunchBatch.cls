/*******************************************************************************************************
* 
* @ Name            :   DRL_UpdatePotentialAtLaunchBatch
* @ Purpose         :   Update Potential at Launch value on Legacy data.
* @ Author          :   Subhodeep Sarkar
* @ Usage           :   Opportunity Amount (Potential at Launch) to be calculated
* @ Test Class Name :   DRL_UpdatePotentialAtLaunchBatchTest
*
*   Date            |  Developer Name                |  Version    |    Changes    
* ======================================================================================================        
*  10-11-2022       |  subhodeep.sarkar@absyz.com    |  1.0        |    Initial Version   
*******************************************************************************************************/
public class DRL_UpdatePotentialAtLaunchBatch implements Database.Batchable<sObject> {  
    //List of Opportunities to update
    List<Opportunity> list_OpportunitiesToUpdate = new List<Opportunity>();
    //List of all the Errors occurred during DML operation
    List<String> list_ConsolidatedDMLErrors = new List<String>();
    Id IdRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API').getRecordTypeId();
    public Database.QueryLocator start(Database.BatchableContext objBatchableContext) {
        String strOpportunityQuery = 'SELECT Id, Amount, CloseDate, Name, Planned_Price_at_Launch__c, Planned_Qty_at_launch__c, StageName FROM Opportunity WHERE RecordTypeId =: IdRecordTypeId';
        return Database.getQueryLocator(strOpportunityQuery);
    }
    
    public void execute(Database.BatchableContext objBatchableContext, List<Opportunity> list_Opportunities) {
        
        try {
            if (!list_Opportunities.isEmpty()) {
                for (Opportunity objOpportunity : list_Opportunities) {
                    if (objOpportunity.Planned_Price_at_Launch__c != null && objOpportunity.Planned_Qty_at_launch__c != null) {
                        objOpportunity.Amount = objOpportunity.Planned_Price_at_Launch__c * objOpportunity.Planned_Qty_at_launch__c;
                    }
                    
                    list_OpportunitiesToUpdate.add(objOpportunity);            
                }
                
                if (!list_OpportunitiesToUpdate.isEmpty()) {
                    if (Test.isRunningTest() && DRL_UpdatePotentialAtLaunchBatchTest.blnThrowException) {
                        throw new DMLException();
                    }
                    
                    List<Database.SaveResult> list_UpdateResults = Database.update(list_OpportunitiesToUpdate, false);
                    list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_UpdateResults, 'Update'));
                }
            }

            if (!list_ConsolidatedDMLErrors.isEmpty()) {
                DRLUtil.logDMLException(
                    'DRL_UpdatePotentialAtLaunchBatch',
                    'execute',
                    list_ConsolidatedDMLErrors
                );
            }
        }
        catch(Exception objException) {
            DRLUtil.logException(
                'DRL_UpdatePotentialAtLaunchBatch',
                'execute',
                objException,
                true
            );
        }
    }
    
    public void finish(Database.BatchableContext objBatchableContext) {
    }
}
