/*******************************************************************************************************
* 
* @ Name            :   DRL_CampaignInfluenceTriggerHelper
* @ Purpose         :   Helper class for CampaignInfluenceAttributes.Trigger to handle all the operations on CampaignInfluence
* @ Author          :   Dinesh Chandra 
* @ Usage           :   1) Calculate Revenue Share on Campaign Object on Creation of CampaignInfluence.
                         
* @ Test Class Name :   DRL_CampaignInfluenceTriggerHelperTest
*
*   Date            |  Developer Name                       |  Version      |    Changes    
* ======================================================================================================        
*  07-11-2022       |  dinesh.chandra@absyz.com            |  1.0          |    Initial Version            
*******************************************************************************************************/
public with sharing class DRL_CampaignInfluenceTriggerHelper {
    public static void calculateValueOfBioBatch(List<CampaignInfluence> list_CampaignInfluences) {
        //List of all the Errors occurred during DML operation
        List<String> list_ConsolidatedDMLErrors = new List<String>();
        //Map of ValueOfBioBatch by CampaignId
        Map<Id, Decimal> map_ValueOfBioBatchByCampaignId = new Map<Id, Decimal>();
        //List of all Campaign 
        List<Campaign> list_Campaigns = new List<Campaign>();
        //Set of all CampaignIds
        Set<Id> set_CampaignIds = new Set<Id>();
        try {
            for (CampaignInfluence objCampaignInfluence : list_CampaignInfluences) {
                set_CampaignIds.add(objCampaignInfluence.CampaignId);
            }

            List<AggregateResult> list_AggregateResults = [SELECT
                                                          CampaignId,
                                                          SUM(RevenueShare) RevenueShareSum
                                                          FROM CampaignInfluence 
                                                          WHERE CampaignId 
                                                          IN :set_CampaignIds GROUP BY CampaignId];
            for (AggregateResult objAggregateResult : list_AggregateResults) {
                map_ValueOfBioBatchByCampaignId.put(
                    (Id)objAggregateResult.get('CampaignId'),
                    (Decimal)objAggregateResult.get('RevenueShareSum')
                );
            }

            list_Campaigns = [SELECT 
                             Id,
                             DRL_ValueBioBatchOrderedOpportunities__c
                             FROM Campaign  
                             WHERE Id IN :set_CampaignIds];

            for (Campaign objCampaign : list_Campaigns) {
                if (map_ValueOfBioBatchByCampaignId.containsKey(objCampaign.Id)) {
                    objCampaign.DRL_ValueBioBatchOrderedOpportunities__c = map_ValueOfBioBatchByCampaignId.get(objCampaign.Id);
                }
            }

            if (!list_Campaigns.isEmpty()) {
                if (Test.isRunningTest() && DRL_CampaignInfluenceHelperTest.blnThrowException) {
                    throw new DMLException();
                } 

                List<Database.SaveResult> list_Results = Database.update(list_Campaigns, false);
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_Results,'Update'));
            }

            if (!list_ConsolidatedDMLErrors.isEmpty()) {
                DRLUtil.logDMLException(
                    'DRL_CampaignInfluenceTriggerHelper',
                    'calculateValueOfBioBatch',
                    list_ConsolidatedDMLErrors
                );
            }
        } catch(Exception objException) {
            DRLUtil.logException(
                'DRL_CampaignInfluenceTriggerHelper',
                'calculateValueOfBioBatch',
                 objException,
                 true
            );
        }
    } 
}
