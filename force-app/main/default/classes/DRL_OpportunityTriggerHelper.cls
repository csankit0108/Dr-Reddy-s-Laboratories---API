/*********************************************************************************************************
* 
* @ Name            :   DRL_OpportunityTriggerHelper
* @ Author          :   Kishore Pedireddy
* @ Usage           :   To Calculate Influence Percentage in Campaign Influence Record.
* @ Test Class Name :   DRL_OpportunityTriggerHelperTest
*
*   Date            |  Developer Name                |  Version      |  Changes
* ========================================================================================================
*  10-02-2023       |  Kishore pedireddy             |  1.0          |  Initial version
*********************************************************************************************************/

public with sharing class DRL_OpportunityTriggerHelper {    
    public static boolean blnSkipOpportunityTrigger = false;
    //List of all the Errors occurred during DML operation
    public static List<String> list_ConsolidatedDMLErrors = new List<String>();
    //Map of Custom Metadata DRL_CampaignInfluenceConfiguration__mdt By Label
    public static Map<String, DRL_CampaignInfluenceConfiguration__mdt> map_CampaignInfluenceConfigurationByLabel = new Map<String, DRL_CampaignInfluenceConfiguration__mdt>();
    //Map of Custom Metadata DRL_CampaignInfluenceConfiguration__mdt By Sort Order
    public static Map<Integer, DRL_CampaignInfluenceConfiguration__mdt> map_CampaignInfluenceConfigurationBySortOrder = new Map<Integer, DRL_CampaignInfluenceConfiguration__mdt>();
    //Custom Label with Value 'DRL_APICampaignsDistributionModel'
	public static String strModelDeveloperName = Label.CLDRL00001;
    //Quering the Value of DeveloperName 
	public static CampaignInfluenceModel objCampaignInfluenceModel = [SELECT 
                                                                      Id,
                                                                      DeveloperName 
                                                                      FROM CampaignInfluenceModel 
                                                                      WHERE DeveloperName = :strModelDeveloperName];
    //Map of OpportunityIds by List Of Influences
    public static Map<Id, Boolean> map_HasInfluenceByOpportunityId = new Map<Id, Boolean>();
    /**
	* @ author       :  Kishore Pedireddy
	* @ description  :  This method handles all the logic that should be performed in the beforeInsert trigger contaxt.
	* @ params       :  list_Opportunities - List of Opportunity from trigger.new
                        map_OldOpportunities - Map of Id to opportunity from trigger.oldMap
	* @ return       :  N/A
	**/
	public static void onAfterUpdate(List<Opportunity> list_Opportunities,Map<Id, Opportunity> map_OldOpportunities) {
		createCampaignInfluence(list_Opportunities, map_OldOpportunities);
	}
    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  Create Campaign Influence records
    * @ params       :  list_Opportunities - Trigger.new list of Opportunity
                        map_OldOpportunities - Trigger.oldMap map of Opportunity
    * @ return       :  N/A
    **/
    public static void createCampaignInfluence(List<Opportunity> list_Opportunities, Map<Id,Opportunity> map_OldOpportunities) {
        //Set of OpportunityIds 
        Set<Id> set_OpportunityIds = new Set<Id>();
        //Set of ContactIds
        Set<Id> set_ContactIds = new Set<Id>();
        //Set of ContactIds
        Set<Id> set_ContactIdsWithRespondedCampaigns = new Set<Id>();
        //Map of CampaignIds with ContactIds
        Map<Id, Id> map_CampaignIdByContactId = new Map<Id, Id>();     
        //List of CampaignIds with ContactIds
        List<CampaignInfluence> list_CampaignInfluencesToUpsert = new List<CampaignInfluence>();    
        //Map of CampaignInfluence record by combinaation of Opp Id+Contact Id+Campaign Id
        Map<String, CampaignInfluence> map_CampaignInfluenceByUniqueKey = new Map<String, CampaignInfluence>();
        map_HasInfluenceByOpportunityId = new Map<Id, Boolean>();
        try {
            for (Opportunity objOpportunity : list_Opportunities) {
                if (objOpportunity.StageName != map_OldOpportunities.get(objOpportunity.Id).StageName) {
                    set_OpportunityIds.add(objOpportunity.Id);                
                }   
            }   
            if (set_OpportunityIds.isEmpty()) {
                return;
            }
            for (DRL_CampaignInfluenceConfiguration__mdt objCampaignInfluenceConfiguration : DRL_CampaignInfluenceConfiguration__mdt.getAll().values()) {
                map_CampaignInfluenceConfigurationByLabel.put(
                    objCampaignInfluenceConfiguration.Label, 
                    objCampaignInfluenceConfiguration
                );
                if (String.isNotBlank(String.valueOf(objCampaignInfluenceConfiguration.SortOrder__c))) {
                    map_CampaignInfluenceConfigurationBySortOrder.put(
                        Integer.valueOf(objCampaignInfluenceConfiguration.SortOrder__c), 
                        objCampaignInfluenceConfiguration
                    );
                }
            }
            
            list_Opportunities = [SELECT Id, 
                                  Name,
                                  CampaignId,
                                  StageName,
                                  ContactId,
                                  DRL_SourceCampaignId__c,
                                  DRL_SourceLastTouchMatch__c,
                                  (SELECT 
                                  Id,
                                  OpportunityId,
                                  ContactId,
                                  Role,
                                  IsPrimary
                                  FROM OpportunityContactRoles),
                                  (SELECT 
                                  OpportunityId,
                                  CampaignId,
                                  ContactId,
                                  Influence,
                                  ModelId 
                                  FROM CampaignInfluences
                                  WHERE ModelId = :objCampaignInfluenceModel.Id 
                                  )
                                  FROM Opportunity 
                                  WHERE Id IN :set_OpportunityIds];

            for (Opportunity objOpportunity : list_Opportunities) {
                if (!objOpportunity.OpportunityContactRoles.isEmpty()) {
                    for (OpportunityContactRole objOpportunityContactRole:objOpportunity.OpportunityContactRoles){
                        set_ContactIds.add(objOpportunityContactRole.ContactId);
                    }                    
                }            
            }

            for (CampaignMember objCampaignMember : [SELECT 
												 Id, 
												 Name,
												 FirstRespondedDate,
												 HasResponded,
												 ContactId,
												 CampaignId
												 FROM CampaignMember 
												 WHERE ContactId IN :set_ContactIds
												 AND HasResponded = true
												 ORDER BY FirstRespondedDate DESC,
												 CreatedDate DESC]
			) {            
                if (!map_CampaignIdByContactId.containsKey(objCampaignMember.ContactId)) {
                    map_CampaignIdByContactId.put(objCampaignMember.ContactId, objCampaignMember.CampaignId);               
                }                    
            }

            for (Opportunity objOpportunity : list_Opportunities) {
                if (objOpportunity.StageName != map_OldOpportunities.get(objOpportunity.Id).StageName) {
                    Integer intNumberOfContactRolesToDistribute = 0;
                    List<OpportunityContactRole> list_OpportunityContactRoles = new List<OpportunityContactRole>();

                    if(!objOpportunity.OpportunityContactRoles.isEmpty()) {
                            for (OpportunityContactRole objOpportunityContactRole:objOpportunity.OpportunityContactRoles){
                                if (map_CampaignIdByContactId.containsKey(objOpportunityContactRole.ContactId)) {
                                    intNumberOfContactRolesToDistribute += 1;       
                                    list_OpportunityContactRoles.add(objOpportunityContactRole);                                      
                                }
                            }                                          
                    } else {
                        continue;
                    }	

                    Decimal decInfluenceWeightage = 0;
                    if (!objOpportunity.CampaignInfluences.isEmpty()) {
                        for (CampaignInfluence objCampaignInfluence : objOpportunity.CampaignInfluences) {
                            String strUniqueKey = objCampaignInfluence.OpportunityId + '' + objCampaignInfluence.ContactId + '' + objCampaignInfluence.CampaignId;
                            map_CampaignInfluenceByUniqueKey.put(strUniqueKey, objCampaignInfluence);
                            decInfluenceWeightage += objCampaignInfluence.Influence;
                            map_HasInfluenceByOpportunityId.put(objOpportunity.Id, true);
                        }
                    }
                    Decimal decInfluenceWeightageToAdd = CalculateInfluencePercentage(objOpportunity,map_OldOpportunities.get(objOpportunity.Id));
                    if (decInfluenceWeightageToAdd == 0 || decInfluenceWeightage+decInfluenceWeightageToAdd>100) {
                        continue;                    
                    }
                    Decimal decInfluenceWeightageToAddForEachCampaign = (decInfluenceWeightageToAdd/intNumberOfContactRolesToDistribute).setScale(2,System.RoundingMode.DOWN);
                    for (OpportunityContactRole objOpportunityContactRole : list_OpportunityContactRoles) {
                        CampaignInfluence objCampaignInfluence = new CampaignInfluence();                    
                        String strUniqueKey = objOpportunity.Id + '' + objOpportunityContactRole.ContactId + '' + map_CampaignIdByContactId.get(objOpportunityContactRole.ContactId);
                        if (map_CampaignInfluenceByUniqueKey.containsKey(strUniqueKey)) {      
                            objCampaignInfluence = map_CampaignInfluenceByUniqueKey.get(strUniqueKey);         
                            objCampaignInfluence.Influence += decInfluenceWeightageToAddForEachCampaign;       
                            
                        } else {
                            objCampaignInfluence.OpportunityId = objOpportunity.Id;
                            objCampaignInfluence.ContactId = objOpportunityContactRole.ContactId;
                            objCampaignInfluence.CampaignId = map_CampaignIdByContactId.get(objOpportunityContactRole.ContactId);
                            objCampaignInfluence.Influence = decInfluenceWeightageToAddForEachCampaign;
                            objCampaignInfluence.ModelId = objCampaignInfluenceModel.Id;
                        }
                        objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
                        objCampaignInfluence.Stage_Updated_On__c = System.now();
                        list_CampaignInfluencesToUpsert.add(objCampaignInfluence);                  
                    }                
                }
                if (!list_CampaignInfluencesToUpsert.isEmpty()) {
                    blnSkipOpportunityTrigger = true;
                    List<Database.UpsertResult> list_Results = Database.upsert(list_CampaignInfluencesToUpsert, false);
                    blnSkipOpportunityTrigger = false;
                    list_ConsolidatedDMLErrors.addAll(DRLUtil.processUpsertResult(list_Results));
                }
                if (!list_ConsolidatedDMLErrors.isEmpty()) {
                    DRLUtil.logDMLException('DRL_OpportunityTriggerHelper', 'createCampaignInfluence', list_ConsolidatedDMLErrors);
                }
		    } 
        } catch (Exception objException) {
            DRLUtil.logException(
                'DRL_OpportunityTriggerHelper',
                'createCampaignInfluence',
                 objException,
                 true
            );
        }
    }



    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  Calculate Influence Percentage field on Campaign Influence Record
    * @ params       :  objOpportunity - Tiggered new Opportunity
                        objOldOpportunity - Triggered old Opportunity
    * @ return       :  decInfluenceWeightageToAdd - Influence Weightage Decimal
    **/    
    public static Decimal CalculateInfluencePercentage(Opportunity objOpportunity, Opportunity objOldOpportunity) {
        Decimal decInfluenceWeightageToAdd = 0;
        Integer intStartSortOrder;
        if (!map_HasInfluenceByOpportunityId.containsKey(objOpportunity.Id)) {
            intStartSortOrder = 1;
        } else if (map_CampaignInfluenceConfigurationByLabel.containsKey(objOldOpportunity.StageName)){
            intStartSortOrder = Integer.valueOf(map_CampaignInfluenceConfigurationByLabel.get(objOldOpportunity.StageName).SortOrder__c) + 1;
        }

        if (map_CampaignInfluenceConfigurationByLabel.containsKey(objOldOpportunity.StageName)) {
            if (map_CampaignInfluenceConfigurationByLabel.containsKey(objOpportunity.StageName)) {
                for (Integer intSortOrder = intStartSortOrder; intSortOrder <= map_CampaignInfluenceConfigurationByLabel.get(objOpportunity.StageName).SortOrder__c; intSortOrder++) {
                    decInfluenceWeightageToAdd = decInfluenceWeightageToAdd + Integer.valueof(map_CampaignInfluenceConfigurationBySortOrder.get(intSortOrder).Weightage__c);
                }  
            } else {
                for (Integer intSortOrder = intStartSortOrder; intSortOrder <= map_CampaignInfluenceConfigurationBySortOrder.size(); intSortOrder++ ) {
                    decInfluenceWeightageToAdd = decInfluenceWeightageToAdd + Integer.valueof(map_CampaignInfluenceConfigurationBySortOrder.get(intSortOrder).Weightage__c);
                }
            }
        }        
        return decInfluenceWeightageToAdd;
    }
}