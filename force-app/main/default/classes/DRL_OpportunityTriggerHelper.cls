/*********************************************************************************************************
* 
* @ Name            :   DRL_OpportunityTriggerHelper
* @ Author          :   Deeksha Suvarna
* @ Usage           :   To Calculate Influence Percentage in Campaign Influence Record.
* @ Test Class Name :   DRL_OpportunityTriggerHelperTest
*
*   Date            |  Developer Name                |  Version      |  Changes
* ========================================================================================================
*  21-11-2022       |  deeksha.suvarna@absyz.com     |  1.0          |  Initial version
*  28-11-2022       |  dinesh.chandra@absyz.com      |  2.0          |  Initial version
*********************************************************************************************************/
public class DRL_OpportunityTriggerHelper { 
    public static boolean blnSkipOpportunityTrigger = false;
    //List of all the Errors occurred during DML operation
    public static List<String> list_ConsolidatedDMLErrors = new List<String>();
    //Map of Leads By Id
    public static Map<Id,Lead> map_LeadsById = new Map<Id,Lead>();
    //Map of Custom Metadata DRL_CampaignInfluenceConfiguration__mdt By Label
    public static Map<String, DRL_CampaignInfluenceConfiguration__mdt> map_CampaignInfluenceConfigurationByLabel = new Map<String, DRL_CampaignInfluenceConfiguration__mdt>();
    //Map of Custom Metadata DRL_CampaignInfluenceConfiguration__mdt By Sort Order
    public static Map<Integer, DRL_CampaignInfluenceConfiguration__mdt> map_CampaignInfluenceConfigurationBySortOrder = new Map<Integer, DRL_CampaignInfluenceConfiguration__mdt>();
    //Custom Label with Value 'DRL_APICampaignsDistributionModel'
    public static String strModelDeveloperName = Label.CLDRL00001;
    //Map of CampaignIds with ContactIds
    public static Map<Id,Id> map_CampaignIdByContactId = new Map<Id,Id>();
    //Quering the Value of DeveloperName 
    public static CampaignInfluenceModel objCampaignInfluenceModel = [SELECT 
                                                                      Id,
                                                                      DeveloperName 
                                                                      FROM CampaignInfluenceModel 
                                                                      WHERE DeveloperName = :strModelDeveloperName];
    /**
    * @ author       :  Dinesh Chandra
    * @ description  :  DRL-83-Create Campaign Influence records with Contacts with Campaign Members
    * @ params       :  list_Opportunities - Trigger.new list on Opportunity
    * @ return       :  N/A
    **/
    public static void createCampaignInfluence(List<Opportunity> list_Opportunities, Map<Id,Opportunity> map_OldOpportunities) {
        //Set of ContactIds
        Set<Id> set_ContactIds = new Set<Id>();
        //Set of OpportunityIds 
        Set<Id> set_OpportunityIds = new Set<Id>();
        //List of CampaignMembers in CampaignId
        List<CampaignMember> list_CampaignMembers = new List<CampaignMember>();
        //Map of Record Type Id by Developer Name
        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Opportunity');
        //List of previous CampaignInfluences
        List<CampaignInfluence> list_CampaignInfluences = new List<CampaignInfluence>();
        //List of CampaignInfluences during DML operation
        List<CampaignInfluence> list_InsertCampaignInfluences = new List<CampaignInfluence>();
        // Set of LeadIds
        Set<Id> set_LeadIds = new Set<Id>();
        //Map of SourceCampaignIds By LeadIds
        Map<Id,Id> map_SourceCampaignIdByLeadId =new Map<Id,Id>();
        //Map of CampaignInfluence record by combinaation of Opp Id+Contact Id+Campaign Id
        Map<String, CampaignInfluence> map_CampaignInfluenceByUniqueKey = new Map<String, CampaignInfluence>();

        try{
            for (DRL_CampaignInfluenceConfiguration__mdt objCampaignInfluenceConfiguration : DRL_CampaignInfluenceConfiguration__mdt.getAll().values()) {
                map_CampaignInfluenceConfigurationByLabel.put(
                    objCampaignInfluenceConfiguration.Label, 
                    objCampaignInfluenceConfiguration
                    );
                if (String.isNotBlank(String.valueOf(objCampaignInfluenceConfiguration.SortOrder__c))) {
                    map_CampaignInfluenceConfigurationBySortOrder.put(
                        Integer.valueOf(objCampaignInfluenceConfiguration.SortOrder__c), 
                        objCampaignInfluenceConfiguration);

                }
            }

            for (Opportunity objOpportunity : list_Opportunities) {
                if (objOpportunity.RecordTypeId == map_RecordTypeIdByDeveloperName.get('API')) {
                    set_OpportunityIds.add(objOpportunity.Id);
                    if (String.isNotBlank(objOpportunity.Contact__c)) {
                        set_ContactIds.add(objOpportunity.Contact__c);
                    }

                    if (String.isNotBlank(objOpportunity.Lead_Converted_From__c)) {
                        set_LeadIds.add(objOpportunity.Lead_Converted_From__c);
                    }
                }
            }
        
            if (!set_LeadIds.isEmpty()) {
                map_LeadsById = new Map<Id, Lead>([SELECT 
                                                   Id,
                                                   DRL_SourceCampaign__c,
                                                   CreatedDate
                                                   FROM Lead 
                                                   WHERE Id IN :set_LeadIds]);
            }

            if (!map_LeadsById.isEmpty()) {
                for (Lead objLead : map_LeadsById.values()) {
                    map_SourceCampaignIdByLeadId.put(objLead.Id, objLead.DRL_SourceCampaign__c);
                }
            }

            list_CampaignMembers = [SELECT 
                                    CampaignId,
                                    ContactId,
                                    CreatedDate 
                                    FROM CampaignMember
                                    WHERE ContactId IN :set_contactIds
                                    ORDER BY CreatedDate];
            
            if (!list_CampaignMembers.isEmpty()) {
                for (CampaignMember objCampaignMember : list_CampaignMembers) {
                    map_CampaignIdByContactId.put(objCampaignMember.ContactId, objCampaignMember.CampaignId);
                }
            }

            list_CampaignInfluences = [SELECT 
                                      OpportunityId,
                                      CampaignId,
                                      ContactId,
                                      Influence,
                                      ModelId 
                                      FROM CampaignInfluence 
                                      WHERE OpportunityId IN :set_OpportunityIds AND ModelId = : objCampaignInfluenceModel.Id
                                      AND ContactId IN :set_ContactIds];
                                
            if (!list_CampaignInfluences.isEmpty()) {
                for (CampaignInfluence objCampaignInfluence : list_CampaignInfluences) {
                    String strUniqueKey = objCampaignInfluence.OpportunityId + '' + objCampaignInfluence.ContactId + '' + objCampaignInfluence.CampaignId;
                    map_CampaignInfluenceByUniqueKey.put(strUniqueKey, objCampaignInfluence);
                }
            }
            
            for (Opportunity objOpportunity : list_Opportunities) {
                //Create CampaignInfluence for the Campaign from the Contact
                if (
                    String.isNotBlank(objOpportunity.Contact__c) && 
                    map_CampaignIdByContactId.containsKey(objOpportunity.Contact__c)
                ) {
                    CampaignInfluence objCampaignInfluence;
                    String strUniqueKey = objOpportunity.Id + '' + objOpportunity.Contact__c + '' + map_CampaignIdByContactId.get(objOpportunity.Contact__c);
                    //Update existing campaign influence
                    if (map_CampaignInfluenceByUniqueKey.containsKey(strUniqueKey)) {
                        objCampaignInfluence = map_CampaignInfluenceByUniqueKey.get(strUniqueKey);
                        objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
                        objCampaignInfluence.Stage_Updated_On__c = System.now();
                        objCampaignInfluence = DRL_OpportunityTriggerHelper.CalculateInfluencePercentage(objOpportunity,map_OldOpportunities?.get(objOpportunity.Id), objCampaignInfluence);
                    } else {
                        objCampaignInfluence = new CampaignInfluence();
                        objCampaignInfluence.ContactId = objOpportunity.Contact__c;
                        objCampaignInfluence.CampaignId = map_CampaignIdByContactId.get(objOpportunity.Contact__c);
                        objCampaignInfluence.OpportunityId = objOpportunity.Id;
                        objCampaignInfluence.Influence = 0;
                        objCampaignInfluence = DRL_OpportunityTriggerHelper.CalculateInfluencePercentage(objOpportunity,map_OldOpportunities?.get(objOpportunity.Id), objCampaignInfluence);
                        objCampaignInfluence.ModelId = objCampaignInfluenceModel.Id;
                        objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
                        objCampaignInfluence.Stage_Updated_On__c = System.now();
                    }
                    list_InsertCampaignInfluences.add(objCampaignInfluence);
                }

                //Create CampaignInfluence for the Campaign from the Lead
                if (
                    String.isNotBlank(objOpportunity.Lead_Converted_From__c) && 
                    map_SourceCampaignIdByLeadId.containsKey(objOpportunity.Lead_Converted_From__c)
                ) {
                    String strUniqueKey = objOpportunity.Id + '' + objOpportunity.Contact__c + '' + map_SourceCampaignIdByLeadId.get(objOpportunity.Lead_Converted_From__c); 
                    if (!map_CampaignInfluenceByUniqueKey.containsKey(strUniqueKey)) {
                        CampaignInfluence objCampaignInfluence = new CampaignInfluence();
                        objCampaignInfluence.ContactId = objOpportunity.Contact__c;
                        objCampaignInfluence.CampaignId = map_SourceCampaignIdByLeadId.get(objOpportunity.Lead_Converted_From__c);
                        objCampaignInfluence.OpportunityId = objOpportunity.Id;
                        objCampaignInfluence.Influence = Integer.valueOf(map_CampaignInfluenceConfigurationByLabel.get('Source Campaign').Weightage__c);
                        objCampaignInfluence.ModelId = objCampaignInfluenceModel.Id;
                        objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
                        objCampaignInfluence.Stage_Updated_On__c = System.now();
                        list_InsertCampaignInfluences.add(objCampaignInfluence);
                    }
                }
            }
            
            if (!list_InsertCampaignInfluences.isEmpty()) {
                if (Test.isRunningTest() && DRL_OpportunityTriggerHelperTest.blnThrowException) {
                    throw new DMLException();
                } 
                
                CaseStaticVars.allowInfluenceInTrigger = false;
                blnSkipOpportunityTrigger = true;
                List<Database.UpsertResult> list_Results = Database.upsert(list_InsertCampaignInfluences, false);
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processUpsertResult(list_Results));
            }
            
            if (!list_ConsolidatedDMLErrors.isEmpty()) {
                DRLUtil.logDMLException(
                    'DRL_OpportunityTriggerHelper',
                    'createCampaignInfluence',
                    list_ConsolidatedDMLErrors
                );
            }

        }  catch(Exception objException) {
            DRLUtil.logException(
                'DRL_OpportunityTriggerHelper',
                'createCampaignInfluence',
                 objException,
                 true
            );
        }
    }
    
    /**
    * @ author       :  Deeksha Suvarna
    * @ description  :  Calculate Influence Percentage field on Campaign Influence Record
    * @ params       :  objOpportunity - Tigger newMap on Opportunity
    * @ return       :  decTempInfluenceWeightage - Influence Weightage
    **/    
    public static CampaignInfluence CalculateInfluencePercentage(Opportunity objOpportunity, Opportunity objOldOpportunity, CampaignInfluence objCampaignInfluence) {
        Decimal decTempInfluenceWeightage = 0;
        decTempInfluenceWeightage = objCampaignInfluence.Influence;
        if (objOldOpportunity == null) {
            
            
            //If Stage is present in Metadata
            if (map_CampaignInfluenceConfigurationByLabel.containsKey(objOpportunity.StageName)) {
            Integer intStageSortOrder = Integer.valueof(map_CampaignInfluenceConfigurationByLabel.get(objOpportunity.StageName).SortOrder__c);
                
                for (Integer intSortOrder = 1; intSortOrder <= intStageSortOrder; intSortOrder++) {
                    //If Stage selected On Opportunity is present in Metadata(Lead Converted Opportunity & Source Campaign is Present on Lead)
                    if (objOpportunity.Lead_Converted_From__c!=null && 
                       (map_LeadsById.get(objOpportunity.Lead_Converted_From__c).DRL_SourceCampaign__c)!= null && 
                        map_CampaignInfluenceConfigurationBySortOrder.get(intSortOrder).Label == 'Lead Generation' ) {                  
                        continue;
                    }
                    //If Stage selected On Opportunity is present in Metadata
                    decTempInfluenceWeightage = decTempInfluenceWeightage + Integer.valueof(map_CampaignInfluenceConfigurationBySortOrder.get(intSortOrder).Weightage__c);
                }
            }
            else {
                
                //If Stage is beyond the Metadata
                for (Integer intSortOrder = 1; intSortOrder <= map_CampaignInfluenceConfigurationBySortOrder.size(); intSortOrder++) {
                    //If Stage selected On Opportunity is beyond Metadata - Bio Batch Ordered(Lead Converted Opportunity & Source Campaign is Present on Lead)
                    if (objOpportunity.Lead_Converted_From__c!=null &&
                       (map_LeadsById.get(objOpportunity.Lead_Converted_From__c).DRL_SourceCampaign__c)!= null && 
                       map_CampaignInfluenceConfigurationBySortOrder.get(intSortOrder)?.Label == 'Lead Generation') {
                        continue;
                    }
                    
                    //If Stage selected On Opportunity is beyond Metadata - Bio Batch Ordered
                    if ((map_CampaignInfluenceConfigurationBySortOrder.get(intSortOrder))!=null) {
                        decTempInfluenceWeightage = decTempInfluenceWeightage + Integer.valueof(map_CampaignInfluenceConfigurationBySortOrder.get(intSortOrder).Weightage__c);
                    }
                }
            }
        }
        else {

            if (map_CampaignInfluenceConfigurationByLabel.containsKey(objOldOpportunity.StageName)) {
                if (map_CampaignInfluenceConfigurationByLabel.containsKey(objOpportunity.StageName)) {
                    for (Integer intSortOrder = Integer.valueOf(map_CampaignInfluenceConfigurationByLabel.get(objOldOpportunity.StageName).SortOrder__c)+1 ; intSortOrder <= map_CampaignInfluenceConfigurationByLabel.get(objOpportunity.StageName).SortOrder__c; intSortOrder++) {
                        decTempInfluenceWeightage = decTempInfluenceWeightage + Integer.valueof(map_CampaignInfluenceConfigurationBySortOrder.get(intSortOrder).Weightage__c);
                    }  
                }
                else {
                    for ( Integer intSortOrder = Integer.valueOf(map_CampaignInfluenceConfigurationByLabel.get(objOldOpportunity.StageName).SortOrder__c)+1; intSortOrder <= map_CampaignInfluenceConfigurationBySortOrder.size(); intSortOrder++ ) {
                        decTempInfluenceWeightage = decTempInfluenceWeightage + Integer.valueof(map_CampaignInfluenceConfigurationBySortOrder.get(intSortOrder).Weightage__c);
                    }
                }
            }
        }
        objCampaignInfluence.Influence = decTempInfluenceWeightage;
    return objCampaignInfluence;
    }
}