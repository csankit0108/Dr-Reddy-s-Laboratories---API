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
    public static Map<Id, Lead> map_LeadsById = new Map<Id, Lead>();
    //Map of Custom Metadata DRL_CampaignInfluenceConfiguration__mdt By Label
    public static Map<String, DRL_CampaignInfluenceConfiguration__mdt> map_CampaignInfluenceConfigurationByLabel = new Map<String, DRL_CampaignInfluenceConfiguration__mdt>();
    //Map of Custom Metadata DRL_CampaignInfluenceConfiguration__mdt By Sort Order
    public static Map<Integer, DRL_CampaignInfluenceConfiguration__mdt> map_CampaignInfluenceConfigurationBySortOrder = new Map<Integer, DRL_CampaignInfluenceConfiguration__mdt>();
    //Custom Label with Value 'DRL_APICampaignsDistributionModel'
    public static String strModelDeveloperName = Label.CLDRL00001;
    //Map of CampaignIds with ContactIds
    public static Map<Id, Id> map_CampaignIdByContactId = new Map<Id, Id>();
    //Map of OpportunityIds by List Of Influences
    public static Map<Id, List<CampaignInfluence>> map_OpportunityIdByListOfInfluences = new Map<Id, List<CampaignInfluence>>();
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
        // Set of LeadIds
        Set<Id> set_LeadIds = new Set<Id>();
        //Map of SourceCampaignIds By LeadIds
        Map<Id, Id> map_SourceCampaignIdByLeadId =new Map<Id, Id>();
        //Map of CampaignInfluence record by combinaation of Opp Id+Contact Id+Campaign Id
        Map<String, CampaignInfluence> map_CampaignInfluenceByUniqueKey = new Map<String, CampaignInfluence>();
        //Map of CampaignInfluence to insert
        Map<String, CampaignInfluence> map_CampaignInfluenceToInsert = new Map<String, CampaignInfluence>();
        //Set of ProspectIds
        Set<Id> set_ProspectIds = new Set<Id>();

                
        map_OpportunityIdByListOfInfluences = new Map<Id, List<CampaignInfluence>>();
        map_CampaignIdByContactId = new Map<Id, Id>();
        list_ConsolidatedDMLErrors = new List<String>();
        map_LeadsById = new Map<Id, Lead>();

        try{
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
                                                   DRL_Prospect__c,
                                                   CreatedDate
                                                   FROM Lead 
                                                   WHERE Id IN :set_LeadIds]);
            }

            if (!map_LeadsById.isEmpty()) {
                for (Lead objLead : map_LeadsById.values()) {
                    if (String.isNotBlank(objLead.DRL_Prospect__c)) {
                        set_ProspectIds.add(objLead.DRL_Prospect__c);
                    }

                    map_SourceCampaignIdByLeadId.put(objLead.Id, objLead.DRL_SourceCampaign__c);
                }
            }

            Map<Id, CampaignMember> map_CampaignMemberByProspect = new Map<Id, CampaignMember>();
            for (CampaignMember objCampaignMember : [SELECT 
                                                     CampaignId,
                                                     ContactId,
                                                     LeadId,
                                                     CreatedDate 
                                                     FROM CampaignMember
                                                     WHERE LeadId IN :set_ProspectIds
                                                     ORDER BY CreatedDate]
            ) {
                map_CampaignMemberByProspect.put(objCampaignMember.LeadId, objCampaignMember);
            }

            list_CampaignMembers = [SELECT 
                                    CampaignId,
                                    ContactId,
                                    LeadId,
                                    CreatedDate 
                                    FROM CampaignMember
                                    WHERE ContactId IN :set_contactIds
                                    ORDER BY CreatedDate];
            
            if (!list_CampaignMembers.isEmpty()) {
                for (CampaignMember objCampaignMember : list_CampaignMembers) {
                    if (objCampaignMember.ContactId != null) {
                    	map_CampaignIdByContactId.put(objCampaignMember.ContactId, objCampaignMember.CampaignId);
                    }
                }
            }

            list_CampaignInfluences = [SELECT 
                                      OpportunityId,
                                      CampaignId,
                                      ContactId,
                                      Influence,
                                      ModelId 
                                      FROM CampaignInfluence 
                                      WHERE OpportunityId IN :set_OpportunityIds 
                                      AND ModelId = :objCampaignInfluenceModel.Id
                                      AND ContactId IN :set_ContactIds];

            if (!list_CampaignInfluences.isEmpty()) {
                for (CampaignInfluence objCampaignInfluence : list_CampaignInfluences) {
                    String strUniqueKey = objCampaignInfluence.OpportunityId + '' + objCampaignInfluence.ContactId + '' + objCampaignInfluence.CampaignId;
                    map_CampaignInfluenceByUniqueKey.put(strUniqueKey, objCampaignInfluence);
                    if (map_OpportunityIdByListOfInfluences.containsKey(objCampaignInfluence.OpportunityId)) {
                        map_OpportunityIdByListOfInfluences.get(objCampaignInfluence.OpportunityId).add(objCampaignInfluence);
                    }
                    else {
                        map_OpportunityIdByListOfInfluences.put(objCampaignInfluence.OpportunityId, new List<CampaignInfluence>{ objCampaignInfluence });
                    }
                }
            }
            
            for (Opportunity objOpportunity : list_Opportunities) {
                Boolean blnContactCampaignAdded = false ;
                if (map_OpportunityIdByListOfInfluences.containskey(objOpportunity.Id)) {
                    Integer intCampaignInfluencePercentage = 0;
                    for (CampaignInfluence objCampaignInfluence : map_OpportunityIdByListOfInfluences.get(objOpportunity.Id)) {
                        intCampaignInfluencePercentage +=  Integer.valueOf(objCampaignInfluence.Influence);
                    }
                    
                    if (intCampaignInfluencePercentage==100) {
                    	continue;
                    }
                }
                
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
                        blnContactCampaignAdded = true;
                    } else {
                        objCampaignInfluence = new CampaignInfluence();
                        objCampaignInfluence.ContactId = objOpportunity.Contact__c;
                        objCampaignInfluence.CampaignId = map_CampaignIdByContactId.get(objOpportunity.Contact__c);
                        objCampaignInfluence.OpportunityId = objOpportunity.Id;
                        objCampaignInfluence.Influence = 0;
                        objCampaignInfluence = DRL_OpportunityTriggerHelper.CalculateInfluencePercentage(objOpportunity,map_OldOpportunities?.get(objOpportunity.Id), objCampaignInfluence);
                        blnContactCampaignAdded = true;
                        objCampaignInfluence.ModelId = objCampaignInfluenceModel.Id;
                        objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
                        objCampaignInfluence.Stage_Updated_On__c = System.now();
                    }
                    map_CampaignInfluenceToInsert.put(strUniqueKey, objCampaignInfluence);
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
                        if (
                            map_SourceCampaignIdByLeadId.containskey(objOpportunity.Lead_Converted_From__c) && 
                            map_SourceCampaignIdByLeadId.get(objOpportunity.Lead_Converted_From__c) != null
                        ) {
                            objCampaignInfluence.CampaignId = map_SourceCampaignIdByLeadId.get(objOpportunity.Lead_Converted_From__c);
                        } else if (map_CampaignIdByContactId.containsKey(objOpportunity.Contact__c)) {
                            objCampaignInfluence.CampaignId = map_CampaignIdByContactId.get(objOpportunity.Contact__c);
                        } else if (
                            map_LeadsById.containsKey(objOpportunity.Lead_Converted_From__c) &&
                            map_CampaignMemberByProspect.containsKey(map_LeadsById.get(objOpportunity.Lead_Converted_From__c).DRL_Prospect__c)
                        ) {
                            objCampaignInfluence.CampaignId = map_CampaignMemberByProspect.get(map_LeadsById.get(objOpportunity.Lead_Converted_From__c).DRL_Prospect__c).CampaignId;
                        }
                        
                        objCampaignInfluence.OpportunityId = objOpportunity.Id;
                        if (objOpportunity.StageName == 'Lead Generation' && blnContactCampaignAdded) {
                            objCampaignInfluence.Influence = 10 ;
                        } else if (
                            map_LeadsById.containsKey(objOpportunity.Lead_Converted_From__c) &&
                            map_LeadsById.get(objOpportunity.Lead_Converted_From__c).DRL_SourceCampaign__c != null
                        ) {
                            objCampaignInfluence.Influence = Integer.valueOf(map_CampaignInfluenceConfigurationByLabel.get('Source Campaign').Weightage__c);
                        }

                        if (!blnContactCampaignAdded) {
                            objCampaignInfluence = DRL_OpportunityTriggerHelper.CalculateInfluencePercentage(
                                objOpportunity,
                                map_OldOpportunities?.get(objOpportunity.Id), 
                                objCampaignInfluence
                            );
                        }

                        objCampaignInfluence.ModelId = objCampaignInfluenceModel.Id;
                        objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
                        objCampaignInfluence.Stage_Updated_On__c = System.now();

                        if (map_CampaignInfluenceToInsert.containskey(strUniqueKey)) {
                            CampaignInfluence objExistingCampaignInfluence = map_CampaignInfluenceToInsert.get(strUniqueKey);
                            objExistingCampaignInfluence.Influence += objCampaignInfluence.Influence;
                            map_CampaignInfluenceToInsert.put(strUniqueKey, objExistingCampaignInfluence);
                        }
                        else {
                            map_CampaignInfluenceToInsert.put(strUniqueKey, objCampaignInfluence);
                        }
                    }
                }
            }
        
            if (!map_CampaignInfluenceToInsert.isEmpty()) {
                if (Test.isRunningTest() && DRL_OpportunityTriggerHelperTest.blnThrowException) {
                    throw new DMLException();
                } 
                
                CaseStaticVars.allowInfluenceInTrigger = false;
                blnSkipOpportunityTrigger = true;
                List<Database.UpsertResult> list_Results = Database.upsert(map_CampaignInfluenceToInsert.values(), false);
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
        if(objCampaignInfluence.Influence!=null) {
            decTempInfluenceWeightage = objCampaignInfluence.Influence;
        }
        if (objOldOpportunity == null) {
            //Influence will be 0
            if (
                objOpportunity.StageName == 'Lead Generation' && 
                objOpportunity.Lead_Converted_From__c!=null && 
                (map_LeadsById.get(objOpportunity.Lead_Converted_From__c).DRL_SourceCampaign__c) != null &&
                decTempInfluenceWeightage == 0) {
            	decTempInfluenceWeightage = 10 ;
            } else {
              
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
        }
        else {
            integer intStartSortOrder;
            if(!map_OpportunityIdByListOfInfluences.containsKey(objOpportunity.Id)) {
                intStartSortOrder = 1;
            }
            else {
                intStartSortOrder = Integer.valueOf(map_CampaignInfluenceConfigurationByLabel.get(objOldOpportunity.StageName).SortOrder__c)+1;
            }
            if (map_CampaignInfluenceConfigurationByLabel.containsKey(objOldOpportunity.StageName)) {
                if (map_CampaignInfluenceConfigurationByLabel.containsKey(objOpportunity.StageName)) {
                    for (Integer intSortOrder = intStartSortOrder ; intSortOrder <= map_CampaignInfluenceConfigurationByLabel.get(objOpportunity.StageName).SortOrder__c; intSortOrder++) {
                        decTempInfluenceWeightage = decTempInfluenceWeightage + Integer.valueof(map_CampaignInfluenceConfigurationBySortOrder.get(intSortOrder).Weightage__c);
                    }  
                }
                else {
                    for ( Integer intSortOrder = intStartSortOrder ; intSortOrder <= map_CampaignInfluenceConfigurationBySortOrder.size(); intSortOrder++ ) {
                        decTempInfluenceWeightage = decTempInfluenceWeightage + Integer.valueof(map_CampaignInfluenceConfigurationBySortOrder.get(intSortOrder).Weightage__c);
                    }
                }
            }
        }
        objCampaignInfluence.Influence = decTempInfluenceWeightage;
    return objCampaignInfluence;
    }
}