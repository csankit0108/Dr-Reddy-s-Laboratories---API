/*******************************************************************************************************
* 
* @ Name            :   DRL_CampaignInfluenceAttributesHelper
* @ Purpose         :   Helper class for CampaignInfluenceAttributes.Trigger to handle all the operations on CampaignInfluence
* @ Author          :   Dinesh Chandra 
* @ Usage           :   1) Calculate Revenue Share on Campaign Object on Creation of CampaignInfluence.
                        
* @ Test Class Name :   DRL_CampaignInfluenceHelperTest
*
*   Date            |  Developer Name                       |  Version      |    Changes    
* ======================================================================================================        
*  07-11-2022       |  dinesh.chandra@absyz.com            |  1.0          |    Initial Version            
*******************************************************************************************************/
public with sharing class DRL_CampaignInfluenceAttributesHelper {
    public static void calculateValueOfBioBatch(List<CampaignInfluence> list_campaignInfluence) {
        //List of all the Errors occurred during DML operation
        List<String> list_ConsolidatedDMLErrors = new List<String>();
        // Map of all CampaignIds with ValueOfBioBatch
        Map<Id,Decimal> map_campaignIdWithValueOfBioBatch = new Map<Id,Decimal>();
        //List of all Campaign
        List<Campaign> list_campaign = new List<Campaign>();
        //Set of all CampaignIds
        Set<Id> set_campaignIds = new Set<Id>();
        try {
            for(CampaignInfluence objCampaignInfluence : list_campaignInfluence) {
                set_campaignIds.add(objCampaignInfluence.CampaignId);
            }
            List<AggregateResult> list_aggregateResult = [SELECT
                                                          CampaignId,
                                                          SUM(RevenueShare)rev
                                                          FROM CampaignInfluence 
                                                          WHERE CampaignId 
                                                          IN : set_campaignIds group by CampaignId];
            for(AggregateResult objAgg:list_aggregateResult) {
            map_campaignIdWithValueOfBioBatch.put((Id)objAgg.get('CampaignId'),(decimal)objAgg.get('rev'));
           }
            list_campaign = [SELECT Id,
                             DRL_ValueBioBatchOrderedOpportunities__c
                             FROM Campaign];
            for(Campaign objCampaign : list_campaign) {
                objCampaign.DRL_ValueBioBatchOrderedOpportunities__c = map_campaignIdWithValueOfBioBatch.get(objCampaign.Id);
            }
            if (!list_campaign.isEmpty()) {
                if (Test.isRunningTest() && DRL_CampaignInfluenceHelperTest.blnThrowException) {
                    throw new DMLException();
                } 
                List<Database.SaveResult> list_Results = Database.update(list_campaign, false);
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_Results, 'Update'));
                }
             if (!list_ConsolidatedDMLErrors.isEmpty()) {
                    DRLUtil.logDMLException('DRL_CampaignInfluenceAttributesHelper', 'calculateValueOfBioBatch', list_ConsolidatedDMLErrors);
                }
        } catch(Exception objException) {
            DRLUtil.logException(
                'DRL_CampaignInfluenceAttributesHelper',
                'calculateValueOfBioBatch',
                 objException,
                 true
            );
        }
        
    }
}
