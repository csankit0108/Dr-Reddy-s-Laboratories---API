/*******************************************************************************************************
* 
* @ Name            :   DRL_updatePotentialAtLaunchBatch
* @ Purpose         :   Update Potential at Launch value on Legacy data.
* @ Author          :   Subhodeep Sarkar
* @ Usage           :   Opportunity Amount (Potential at Launch) to be calculated
* @ Test Class Name :   DRL_updatePotentialAtLaunchBatchTest
*
*   Date            |  Developer Name                |  Version    |    Changes    
* ======================================================================================================        
*  10-11-2022       |  subhodeep.sarkar@absyz.com    |  1.0        |    Initial Version   
*******************************************************************************************************/
public class DRL_updatePotentialAtLaunchBatch implements Database.Batchable<sObject>,Database.Stateful, Database.RaisesPlatformEvents {  
    //List of Opportunities to update
    List<Opportunity> list_OpportunitiesToUpdate = new List<Opportunity>();
    //List of all the Errors occurred during DML operation
    List<String> list_ConsolidatedDMLErrors = new List<String>();
    public Database.QueryLocator start(Database.BatchableContext bc){
        String strOpportunityQuery = 'SELECT Id, Amount, CloseDate, Name, Planned_Price_at_Launch__c, Planned_Qty_at_launch__c, StageName FROM Opportunity';
        return Database.getQueryLocator(strOpportunityQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity> list_Opportunities) {
        
        try {
            if (list_Opportunities!=null && list_Opportunities.size()>0) {
                
                for (Opportunity objOpportunity : list_Opportunities) {
                    if (objOpportunity.Planned_Price_at_Launch__c != null && objOpportunity.Planned_Qty_at_launch__c!=null) {
                        objOpportunity.Amount = objOpportunity.Planned_Price_at_Launch__c * objOpportunity.Planned_Qty_at_launch__c;
                    }
                    
                    list_OpportunitiesToUpdate.add(objOpportunity);            
                }
                
                if (list_OpportunitiesToUpdate != null && list_OpportunitiesToUpdate.size()>0) {
                    if (Test.isRunningTest() && DRL_updatePotentialAtLaunchBatchTest.blnThrowException) {
                        throw new DMLException();
                    }
                    
                    List<Database.SaveResult> list_UpdateResults = Database.update(list_OpportunitiesToUpdate, false);
                    list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_UpdateResults, 'Update'));
                }
            }
            if (!list_ConsolidatedDMLErrors.isEmpty()) {
                DRLUtil.logDMLException(
                    'DRL_updatePotentialAtLaunchBatch',
                    'execute',
                    list_ConsolidatedDMLErrors
                );
            }
        }
        catch(Exception objException) {
            DRLUtil.logException(
                'DRL_updatePotentialAtLaunchBatch',
                'execute',
                objException,
                true
            );
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
    
    }
}