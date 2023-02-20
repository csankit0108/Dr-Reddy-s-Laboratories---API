/*******************************************************************************************************
* @ Name            :   DRL_OpportunityContactRoleTriggerHelper
* @ Purpose         :   Helper class for DRL_OpportunityContactRoleTrigger
* @ Author          :   Ankit C
* @ Test Class Name :   DRL_OppContactRoleTriggerHelperTest
*
*   Date            |  Developer Name                       |  Version      |    Changes    
* ======================================================================================================        
*  10-01-2023       |  Ankit C                              |  1.0          |    Initial Version 
*  07-02-2023		|  Deeksha 								|  2.0			|    Campaign Influence Split Percentage Calculation & 
																				 Creation of Campaign Influence Record on Insert of Opportunity Contact Role
*  08-02-2023       |  Mahalakshmi Sadhananthan             |  3.0          |    Process on Recalculating after Contact is Deleted from Contact role
*******************************************************************************************************/
public class DRL_OpportunityContactRoleTriggerHelper {
	//Flag to skip this trigger
	public static boolean blnSkipOpportunityContactRoleTrigger = false;
	//List of all the Errors occurred during DML operation
	public static List<String> list_ConsolidatedDMLErrors = new List<String>();
	//Custom Label with Value 'DRL_APICampaignsDistributionModel'
	public static String strModelDeveloperName = Label.CLDRL00001;
	//Map of Opportunity By Id
	public static Map<Id, Opportunity> map_OpportunityById = new Map<Id, Opportunity>();
	//Map of Leads By Id
	public static Map<Id, Lead> map_LeadsById = new Map<Id, Lead>();
	//Map of CampaignInfluence record by combinaation of Opp Id+Contact Id+Campaign Id
	public static Map<String, CampaignInfluence> map_CampaignInfluenceByUniqueKey = new Map<String, CampaignInfluence>();
	//Map of OpportunityContactRoleWrapper by OpportunityId+ContactId combination
	public static Map<String, OpportunityContactRoleWrapper> map_OpportunityContactRoleWrapperByContactId = 
		new Map<String, OpportunityContactRoleWrapper>();
	//Quering the Value of DeveloperName 
	public static CampaignInfluenceModel objCampaignInfluenceModel = [SELECT 
																	  Id,
																	  DeveloperName 
																	  FROM CampaignInfluenceModel 
																	  WHERE DeveloperName = :strModelDeveloperName];
	//Map of Custom Metadata DRL_CampaignInfluenceConfiguration__mdt By Label
	public static Map<String, DRL_CampaignInfluenceConfiguration__mdt> map_CampaignInfluenceConfigurationByLabel = 
		new Map<String, DRL_CampaignInfluenceConfiguration__mdt>();
	//Map of Custom Metadata DRL_CampaignInfluenceConfiguration__mdt By Sort Order
	public static Map<Integer, DRL_CampaignInfluenceConfiguration__mdt> map_CampaignInfluenceConfigurationBySortOrder = 
		new Map<Integer, DRL_CampaignInfluenceConfiguration__mdt>();
	//Map of Record Type Id by Developer Name
	public static Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Opportunity');
	
	/**
	* @ Name            :   OpportunityContactRoleWrapper
	* @ Purpose         :   Wrapper to store the contact's last touch & source campaign
	* @ Author          :   Ankit C
	*/
	public class OpportunityContactRoleWrapper {
		public OpportunityContactRole objOpportunityContactRole;
		public Campaign objSourceCampaign;
		public Campaign objLastTouchCampaign;
	}

	/**
	* @ author       :  Ankit C
	* @ description  :  This method handles all the logic that should be performed in the beforeInsert trigger context.
	* @ params       :  list_OpportunityContactRoles - List of OpportunityContactRole from trigger.new
	* @ return       :  N/A
	**/
	public static void onBeforeInsert(List<OpportunityContactRole> list_OpportunityContactRoles) {
		duplicateContactValidation(list_OpportunityContactRoles);
	}

	/**
	* @ author       :  Ankit C
	* @ description  :  This method handles all the logic that should be performed in the afterInsert trigger context.
	* @ params       :  list_OpportunityContactRoles - List of OpportunityContactRole from trigger.new
	* @ return       :  N/A
	**/
	public static void onAfterInsert(List<OpportunityContactRole> list_OpportunityContactRoles) {
		calculateCampaignInfluence(list_OpportunityContactRoles);
	}
	
	/**
	* @ author       :  Mahalakshmi Sadhananthan
	* @ description  :  This method handles all the logic that should be performed in the afterDelete trigger context.
	* @ params       :  list_OpportunityContactRoles - List of OpportunityContactRole from trigger.old
	* @ return       :  N/A
	**/
	public static void onAfterDelete(List<OpportunityContactRole> list_OpportunityContactRoles) {
		calculateCampaignInfluenceOnDelete(list_OpportunityContactRoles);
	}

	/**
	* @ author       :  Mahalakshmi Sadhananthan
	* @ description  :  This method prevents the creation of duplicate contact roles for the Opporutunity.
	* @ params       :  list_OpportunityContactRoles - List of OpportunityContactRole records
	* @ return       :  N/A
	**/
	public static void duplicateContactValidation(List<OpportunityContactRole> list_OpportunityContactRoles) {
		//Set of ContactIds
		Set<Id> set_ContactIds = new Set<Id>();
		//Map of Set of Opportunity Id with Contact Id
		Map<Id, Set<Id>> map_OpportunityIdsByContactId = new Map<Id, Set<Id>>();
		
		try {
			//Fetch all the contact Ids into Set
			for (OpportunityContactRole objOpportunityContactRole : list_OpportunityContactRoles) {
				if (String.isNotBlank(objOpportunityContactRole.ContactId)) {
					set_ContactIds.add(objOpportunityContactRole.ContactId);
				}
			}
			
			if (!set_ContactIds.isEmpty()) {
				//Map Contact ID with set of Opportunity IDs
				for (OpportunityContactRole objOpportunityContactRole : [SELECT 
																		 Id,
																		 OpportunityId,
																		 ContactId,
																		 Role,
																		 IsPrimary
																		 FROM OpportunityContactRole
																		 WHERE ContactId IN :set_ContactIds]
				) {
					if(!map_OpportunityIdsByContactId.containsKey(objOpportunityContactRole.ContactId)) {
						map_OpportunityIdsByContactId.put(
							objOpportunityContactRole.ContactId, 
							new set<Id> { objOpportunityContactRole.OpportunityId }
						);
					} else {
						map_OpportunityIdsByContactId.get(objOpportunityContactRole.ContactId).add(objOpportunityContactRole.OpportunityId);
					}
				}
			}
			
			//Check if ID exist in the Map and display Error message
			for (OpportunityContactRole objOpportunityContactRole : list_OpportunityContactRoles) {
				if (
					map_OpportunityIdsByContactId.containsKey(objOpportunityContactRole.ContactId) && 
					map_OpportunityIdsByContactId.get(objOpportunityContactRole.ContactId).contains(objOpportunityContactRole.OpportunityId)
				) {
					objOpportunityContactRole.addError(System.Label.CLDRL00025);
				}
			} 
		} catch(Exception objException) {
			DRLUtil.logException(
				'DRL_OpportunityContactRoleTriggerHelper',
				'duplicateContactValidation',
				objException,
				true
			);
		}
	}

	/**
	* @ author       :  Deeksha Suvarna
	* @ description  :  This method calculates the influence percentage on Contact Role insertion.
	* @ params       :  list_OpportunityContactRoles - List of OpportunityContactRole records
	* @ return       :  N/A
	**/
	public static void calculateCampaignInfluence(List<OpportunityContactRole> list_OpportunityContactRoles) {
		//Set of OpportunityIds 
	 	Set<Id> set_OpportunityIds = new Set<Id>();
	 	//Set of ContactIds
	 	Set<Id> set_ContactIds = new Set<Id>();
	 	// Set of LeadIds
	 	Set<Id> set_LeadIds = new Set<Id>();
	 	//Set of ProspectIds
	 	Set<Id> set_ProspectIds = new Set<Id>();
		// Set of CampaignIds
	 	Set<Id> set_CampaignIds = new Set<Id>();
		//List of Opportunity Contact Roles
		List<OpportunityContactRole> list_AllContactRoles = new list<OpportunityContactRole>();
	 	//Map of SourceCampaignIds By LeadIds
	 	Map<Id, Id> map_SourceCampaignIdByLeadId = new Map<Id, Id>();
		//Map of CampaignMember by ContactId
		Map<Id,CampaignMember> map_CampaignMemberByContactId = new Map<Id,CampaignMember>();
		//Map of Campaign by Id
		Map<Id, Campaign> map_CampaignById = new Map<Id, Campaign>();
		//Map of CampaignMember by CampaignId + LeadId key combination
		Map<String, CampaignMember> map_CampaignMemberByUniqueKey = new Map<String, CampaignMember>();
		//Map of Opportunity by Id
		Map<Id, Opportunity> map_OpportunitiesToUpdate = new Map<Id, Opportunity>();

		try {
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
			
			for (OpportunityContactRole objOpportunityContactRole : list_OpportunityContactRoles) {
				set_OpportunityIds.add(objOpportunityContactRole.OpportunityId);
			}
	
			map_OpportunityById = new Map<Id, Opportunity>([SELECT 
															Id, 
															Name,
															CampaignId,
															StageName,
															ContactId,
															DRL_SourceCampaignId__c,
															DRL_SourceLastTouchMatch__c,
															DRL_SourceCampaignContactId__c,
															Lead_Converted_From__c,
															RecordTypeId,
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
															 ORDER BY CreatedDate DESC
															)
															FROM Opportunity 
															WHERE Id IN :set_OpportunityIds
															AND RecordTypeId = :map_RecordTypeIdByDeveloperName.get('API')]);
			if (!map_OpportunityById.isEmpty()) {
				for (Opportunity objOpportunity : map_OpportunityById.values()) {
					if(!objOpportunity.OpportunityContactRoles.isEmpty()) {
						list_AllContactRoles.addAll(objOpportunity.OpportunityContactRoles);
						
					}
					if(objOpportunity.Lead_Converted_From__c!=null) {
						set_LeadIds.add(objOpportunity.Lead_Converted_From__c);
					}
					
					if (!objOpportunity.CampaignInfluences.isEmpty()) {
						for (CampaignInfluence objCampaignInfluence : objOpportunity.CampaignInfluences) {
							String strUniqueKey = objCampaignInfluence.OpportunityId + '' + objCampaignInfluence.ContactId + '' + objCampaignInfluence.CampaignId;
							map_CampaignInfluenceByUniqueKey.put(strUniqueKey, objCampaignInfluence);
						}
					}
				}
			}
		
			for (OpportunityContactRole objOpportunityContactRole : list_AllContactRoles) {
			   if (String.isNotBlank(objOpportunityContactRole.ContactId)) {
					set_ContactIds.add(objOpportunityContactRole.ContactId);
				} 
			}
			
			if(!set_LeadIds.isEmpty()) {
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
	
			for (CampaignMember objCampaignMember : [SELECT 
													 Id, 
													 Name,
													 LeadId,
													 FirstRespondedDate,
													 HasResponded,
													 ContactId,
													 CampaignId
													 FROM CampaignMember 
													 WHERE (ContactId IN :set_ContactIds
													 OR (LeadId IN :set_ProspectIds
													 AND CampaignId IN :map_SourceCampaignIdByLeadId.values()))
													 AND HasResponded = true
													 ORDER BY FirstRespondedDate DESC,
													 CreatedDate DESC]
			) {
				set_CampaignIds.add(objCampaignMember.CampaignId);
				if (!map_CampaignMemberByContactId.containsKey(objCampaignMember.ContactId)) {
					map_CampaignMemberByContactId.put(objCampaignMember.ContactId, objCampaignMember);
				}  
					
				String strKey = objCampaignMember.CampaignId + '' + objCampaignMember.LeadId;
				map_CampaignMemberByUniqueKey.put(strKey, objCampaignMember);
			}
			
			map_CampaignById = new Map<Id, Campaign>([SELECT 
													  Id,
													  Name
													  FROM 
													  Campaign
													  WHERE Id IN :set_CampaignIds]);
			
			for (OpportunityContactRole objOpportunityContactRole : list_AllContactRoles ) {
				OpportunityContactRoleWrapper objWrapper = new OpportunityContactRoleWrapper();
				objWrapper.objOpportunityContactRole = objOpportunityContactRole;
				//Update Source Campaign
				if (
					String.isNotBlank(objOpportunityContactRole.ContactId) &&
					map_LeadsById.containsKey(map_OpportunityById.get(objOpportunityContactRole.OpportunityId).Lead_Converted_From__c)
				) {
					Lead objConvertedLead = map_LeadsById.get(map_OpportunityById.get(objOpportunityContactRole.OpportunityId).Lead_Converted_From__c);
					String strCampaignUniqueKey = objConvertedLead.DRL_SourceCampaign__c + '' + objConvertedLead.DRL_Prospect__c;
					if (
						String.isNotBlank(objConvertedLead.DRL_SourceCampaign__c) &&
						String.isNotBlank(objConvertedLead.DRL_Prospect__c) &&
						map_CampaignMemberByUniqueKey.containsKey(strCampaignUniqueKey)
					) {
						objWrapper.objSourceCampaign = map_CampaignById.containsKey(map_CampaignMemberByUniqueKey.get(strCampaignUniqueKey).CampaignId)
							? map_CampaignById.get(map_CampaignMemberByUniqueKey.get(strCampaignUniqueKey).CampaignId)
							: null;
					}
				}
			
				//Update Last Touch Campaign
				if (
					String.isNotBlank(objOpportunityContactRole.ContactId) &&
					map_CampaignMemberByContactId.containsKey(objOpportunityContactRole.ContactId) 
				) {
					objWrapper.objLastTouchCampaign = map_CampaignById.containsKey(map_CampaignMemberByContactId.get(objOpportunityContactRole.ContactId).CampaignId)
						? map_CampaignById.get(map_CampaignMemberByContactId.get(objOpportunityContactRole.ContactId).CampaignId)
						: null;
				}
				
				String strUniqueWrapperKey = objOpportunityContactRole.OpportunityId + '' + objOpportunityContactRole.ContactId;
				map_OpportunityContactRoleWrapperByContactId.put(strUniqueWrapperKey, objWrapper);
			}
			
			for (OpportunityContactRole objOpportunityContactRole : list_OpportunityContactRoles) {
				Opportunity objOpportunity = map_OpportunityById.containsKey(objOpportunityContactRole.OpportunityId)
					? map_OpportunityById.get(objOpportunityContactRole.OpportunityId)
					: new Opportunity();
				if (objOpportunity.Id == null) {
					continue;
				}

				Decimal decTotalInfluenceSum = 0.0;
				Map<Id, CampaignInfluence> map_LastTouchCampaignInfluenceByContactId = new Map<Id, CampaignInfluence>();
				
				Decimal decExistingInfluenceCombined = 0.0;
				CampaignInfluence objSourceCampaignInfluence;
				
				String strNewContactRoleWrapperKey = objOpportunityContactRole.OpportunityId + '' + objOpportunityContactRole.ContactId;
				OpportunityContactRoleWrapper objNewContactRoleWrapper = map_OpportunityContactRoleWrapperByContactId.containsKey(strNewContactRoleWrapperKey)
					? map_OpportunityContactRoleWrapperByContactId.get(strNewContactRoleWrapperKey)
					: null;
	
				//Updating Opportunity fields
				if (
					objOpportunity.OpportunityContactRoles.size() == 1 &&
					objNewContactRoleWrapper != null &&
					map_SourceCampaignIdByLeadId.containsKey(objOpportunity.Lead_Converted_From__c) &&
					(
					 String.isBlank(objOpportunity.DRL_SourceCampaignId__c) || 
					 objOpportunity.DRL_SourceCampaignId__c == null
					)
				) {
					objOpportunity.DRL_SourceCampaignId__c = map_SourceCampaignIdByLeadId.get(objOpportunity.Lead_Converted_From__c);
					objOpportunity.DRL_SourceCampaignContactId__c = objOpportunityContactRole.ContactId;
					map_OpportunitiesToUpdate.put(objOpportunity.Id, objOpportunity);
				}
	
				Integer intCountofContactsWithLastTouchCampaign = 1;
			
				for (CampaignInfluence objCampaignInfluence : objOpportunity.CampaignInfluences) {
					decTotalInfluenceSum += objCampaignInfluence.Influence;
					if (
						String.isNotBlank(objOpportunity.DRL_SourceCampaignId__c) &&
						!objOpportunity.DRL_SourceLastTouchMatch__c
					) {
						if (
							(objCampaignInfluence.CampaignId != objOpportunity.DRL_SourceCampaignId__c ||
							(objCampaignInfluence.CampaignId == objOpportunity.DRL_SourceCampaignId__c &&
							objCampaignInfluence.ContactId != objOpportunity.DRL_SourceCampaignContactId__c)) &&
							!map_LastTouchCampaignInfluenceByContactId.containsKey(objCampaignInfluence.ContactId)
						) {
							map_LastTouchCampaignInfluenceByContactId.put(objCampaignInfluence.ContactId, objCampaignInfluence);
							decExistingInfluenceCombined += objCampaignInfluence.Influence;
						} 
					} else if (!map_LastTouchCampaignInfluenceByContactId.containsKey(objCampaignInfluence.ContactId)) {
						map_LastTouchCampaignInfluenceByContactId.put(objCampaignInfluence.ContactId, objCampaignInfluence);
						decExistingInfluenceCombined += objCampaignInfluence.Influence;
					}   
				} 
	
				if (decTotalInfluenceSum > 99.0) {
					continue;
				}
				
				intCountofContactsWithLastTouchCampaign = map_LastTouchCampaignInfluenceByContactId.keySet().size();
				
				if (objNewContactRoleWrapper != null) {
					String strSourceCampaignId = (objNewContactRoleWrapper.objSourceCampaign != null)
						? objNewContactRoleWrapper.objSourceCampaign.Id 
						: null;
					String strLastTouchCampaignId = (objNewContactRoleWrapper.objLastTouchCampaign != null)
						? objNewContactRoleWrapper.objLastTouchCampaign.Id 
						: null;
					
					String strUniqueKeyWithSourceCampaign = objNewContactRoleWrapper.objOpportunityContactRole.OpportunityId + '' + objOpportunityContactRole.ContactId + '' + strSourceCampaignId;
					String strUniqueKeyWithLastTouchCampaignId = objNewContactRoleWrapper.objOpportunityContactRole.OpportunityId + '' + objOpportunityContactRole.ContactId + '' + strLastTouchCampaignId; 
					
					if (String.isNotBlank(strLastTouchCampaignId)) {
						intCountofContactsWithLastTouchCampaign++;
					}
	
					if (objOpportunity.OpportunityContactRoles.size() == 1) {
						if (
							objNewContactRoleWrapper.objSourceCampaign != null && 
							objNewContactRoleWrapper.objLastTouchCampaign != null &&
							objNewContactRoleWrapper.objSourceCampaign.Id == objNewContactRoleWrapper.objLastTouchCampaign.Id
						) {
							objOpportunity.DRL_SourceLastTouchMatch__c = true;
							map_OpportunitiesToUpdate.put(objOpportunity.Id, objOpportunity);
							
							CampaignInfluence objCampaignInfluence = map_CampaignInfluenceByUniqueKey.containsKey(strUniqueKeyWithSourceCampaign)
								? map_CampaignInfluenceByUniqueKey.get(strUniqueKeyWithSourceCampaign)
								: new CampaignInfluence();
							Decimal decStageInfluenceWeigtage = 0;
							Integer intStageSortOrder;
							intStageSortOrder = map_CampaignInfluenceConfigurationByLabel.containsKey(objOpportunity.StageName)
								? Integer.valueof(map_CampaignInfluenceConfigurationByLabel.get(objOpportunity.StageName).SortOrder__c)
								: map_CampaignInfluenceConfigurationBySortOrder.size();
							
							for (Integer intSortOrder = 1; intSortOrder <= intStageSortOrder; intSortOrder++) {
								if (map_CampaignInfluenceConfigurationBySortOrder.containsKey(intSortOrder)) {
									decStageInfluenceWeigtage = decStageInfluenceWeigtage + Integer.valueof(map_CampaignInfluenceConfigurationBySortOrder.get(intSortOrder).Weightage__c);
								}
							}
							
							objCampaignInfluence = createCampaignInfluence(
								objCampaignInfluence,
								strSourceCampaignId,
								decStageInfluenceWeigtage,
								objOpportunity,
								objOpportunityContactRole
							);
							
							map_CampaignInfluenceByUniqueKey.put(strUniqueKeyWithSourceCampaign, objCampaignInfluence);
						} else {
							Decimal decSourceCampaignInfluence = 0;
							//Creating Campaign influence for source campaign
							if (objNewContactRoleWrapper.objSourceCampaign != null) {
								decSourceCampaignInfluence = objOpportunity.StageName == 'Lead Generation'
									? 10.0
									: 20.0;
								CampaignInfluence objCampaignInfluence = map_CampaignInfluenceByUniqueKey.containsKey(strUniqueKeyWithSourceCampaign)
									? map_CampaignInfluenceByUniqueKey.get(strUniqueKeyWithSourceCampaign)
									: new CampaignInfluence();
								//Creating Campaign influence for source campaign
								objCampaignInfluence = createCampaignInfluence(
									objCampaignInfluence,
									strSourceCampaignId,
									decSourceCampaignInfluence,
									objOpportunity,
									objOpportunityContactRole
								);
								
								map_CampaignInfluenceByUniqueKey.put(strUniqueKeyWithSourceCampaign, objCampaignInfluence);
							}
							
							//Creating Campaign influence for Last Touch Campaign
							if (objNewContactRoleWrapper.objLastTouchCampaign != null) {
								Decimal decLastTouchInfluence = 0;
								Decimal decStageLastTouchInfluenceWeigtage = 0;
								Integer intStageSortOrder;
								intStageSortOrder = map_CampaignInfluenceConfigurationByLabel.containsKey(objOpportunity.StageName)
									? Integer.valueof(map_CampaignInfluenceConfigurationByLabel.get(objOpportunity.StageName).SortOrder__c)
									: map_CampaignInfluenceConfigurationBySortOrder.size();
								for (Integer intSortOrder = 1; intSortOrder <= intStageSortOrder; intSortOrder++) {
									if (map_CampaignInfluenceConfigurationBySortOrder.containsKey(intSortOrder)) {
										decStageLastTouchInfluenceWeigtage = decStageLastTouchInfluenceWeigtage + Integer.valueof(map_CampaignInfluenceConfigurationBySortOrder.get(intSortOrder).Weightage__c);
									}
								}
							  
								if (decSourceCampaignInfluence != 0) {
									decLastTouchInfluence = decStageLastTouchInfluenceWeigtage - decSourceCampaignInfluence; 
								} else if (decSourceCampaignInfluence == 0) {
									decLastTouchInfluence = decStageLastTouchInfluenceWeigtage;
								}
								
								CampaignInfluence objCampaignInfluence = map_CampaignInfluenceByUniqueKey.containsKey(strUniqueKeyWithLastTouchCampaignId)
									? map_CampaignInfluenceByUniqueKey.get(strUniqueKeyWithLastTouchCampaignId)
									: new CampaignInfluence();
								objCampaignInfluence = createCampaignInfluence(
									objCampaignInfluence,
									strLastTouchCampaignId,
									decLastTouchInfluence,
									objOpportunity,
									objOpportunityContactRole
								);
								
								map_CampaignInfluenceByUniqueKey.put(strUniqueKeyWithLastTouchCampaignId, objCampaignInfluence);
							} 
						}
					} else if (objOpportunity.OpportunityContactRoles.size() > 1) {
						Decimal decNewInfluenceValue = (decExistingInfluenceCombined/intCountofContactsWithLastTouchCampaign).setScale(2, System.RoundingMode.DOWN);
						//Give influence to Last Touch Campaign
						if (objNewContactRoleWrapper.objLastTouchCampaign != null) {
							CampaignInfluence objCampaignInfluence = map_CampaignInfluenceByUniqueKey.containsKey(strUniqueKeyWithLastTouchCampaignId)
								? map_CampaignInfluenceByUniqueKey.get(strUniqueKeyWithLastTouchCampaignId)
								: new CampaignInfluence();
							//Create CI for source campaign
							objCampaignInfluence = createCampaignInfluence(
								objCampaignInfluence,
								strLastTouchCampaignId,
								decNewInfluenceValue,
								objOpportunity,
								objOpportunityContactRole
							);
								
							map_CampaignInfluenceByUniqueKey.put(strUniqueKeyWithLastTouchCampaignId, objCampaignInfluence);
							for (CampaignInfluence objOldCampaignInfluence : map_LastTouchCampaignInfluenceByContactId.values()) {
								objOldCampaignInfluence.Influence = decNewInfluenceValue;
								map_CampaignInfluenceByUniqueKey.put(
									objOldCampaignInfluence.OpportunityId + '' + objOldCampaignInfluence.ContactId + '' + objOldCampaignInfluence.CampaignId,
									objOldCampaignInfluence
								);
							}
						}
					}
				}
			}
			
			if (!map_OpportunitiesToUpdate.isEmpty()) {
				DRL_OpportunityTriggerHelper.blnSkipOpportunityTrigger = true;
				List<Database.SaveResult> list_UpdateResults = Database.update(map_OpportunitiesToUpdate.values(), false);
				list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_UpdateResults, 'Update'));
				DRL_OpportunityTriggerHelper.blnSkipOpportunityTrigger = false;
			}
	
			if (!map_CampaignInfluenceByUniqueKey.isEmpty()) {
				CaseStaticVars.allowInfluenceInTrigger = false;
				List<Database.UpsertResult> list_UpsertResults = Database.upsert(map_CampaignInfluenceByUniqueKey.values(), false);
				list_ConsolidatedDMLErrors.addAll(DRLUtil.processUpsertResult(list_UpsertResults));
			}
			
			if (!list_ConsolidatedDMLErrors.isEmpty()) {
				DRLUtil.logDMLException(
					'DRL_OpportunityContactRoleTriggerHelper', 
					'createCampaignInfluence', 
					list_ConsolidatedDMLErrors
				);
			}             
		} catch(Exception objException) {
			DRLUtil.logException(
				'DRL_OpportunityContactRoleTriggerHelper',
				'createCampaignInfluence',
				 objException,
				 true
			);
		}
	}

	/**
	* @ author       :  Mahalakshmi Sadhananthan
	* @ description  :  This method recalculates the campaign influence percentage after associated contact record from Opportunity Contact Role is Deleted.
	* @ params       :  list_OpportunityContactRoles - List of OpportunityContactRole records
	* @ return       :  N/A
	**/
	public static void calculateCampaignInfluenceOnDelete(List<OpportunityContactRole> list_OpportunityContactRoles) {
		//Set of Opportunities
		Set<Id> set_OpportunityIds = new Set<Id>();
		//Set of deleted contacts
		Set<Id> set_DeletedContactIds = new Set<Id>();
		//Map of Opportunities by Ids
		Map<Id, Opportunity> map_OpportunityById = new Map<Id, Opportunity>();
		//Map of Campaign Influence by Opportunity Id
		Map<Id, Decimal> map_CampaignInfluenceByOpportunityId = new  Map<Id, Decimal>();
		//Map of Combined Influence by Opportunity Id
		Map<Id, Decimal> map_CombinedInfluenceByOpportunityId = new  Map<Id, Decimal>();
		//List of Campaign Influence to Delete
		List<CampaignInfluence> list_CampaignInfluencestoDelete = new List<CampaignInfluence>();
		//List of Campaign Influence to Update
		List<CampaignInfluence> list_CampaignInfluencesToUpdate = new List<CampaignInfluence>();
		//List of all the Errors occurred during DML operation
		List<String> list_ConsolidatedDMLErrors = new List<String>();
		//Map of List of Campaign Influence by Opportunity Id
		Map<Id, List<CampaignInfluence>> map_CampaignInfluencesByOpportunityId = new Map<Id, List<CampaignInfluence>>();
		//Map of latest campaign influence record by Contact Id
		Map<Id, CampaignInfluence> map_CampaignInfluenceByContactId = new Map<Id, CampaignInfluence>();
		
		try {
			for (OpportunityContactRole objOpportunityContactRole : list_OpportunityContactRoles) {
				set_OpportunityIds.add(objOpportunityContactRole.OpportunityId);
				set_DeletedContactIds.add(objOpportunityContactRole.ContactId);
			}
			
			map_OpportunityById = new Map<Id, Opportunity>([
				SELECT 
				Id, 
				ContactId,
				DRL_SourceCampaignId__c,
				DRL_SourceCampaignContactId__c,
				DRL_SourceLastTouchMatch__c,
				(SELECT 
				 Id, 
				 ContactId,
				 CampaignId,
				 OpportunityId, 
				 Influence 
				 FROM 
				 CampaignInfluences
				 WHERE ModelId = :objCampaignInfluenceModel.Id
				 ORDER BY CreatedDate DESC),
				(SELECT
				 Id,
				 ContactId,
				 OpportunityId 
				 FROM 
				 OpportunityContactRoles)
				FROM 
				Opportunity 
				WHERE Id IN :set_OpportunityIds
				AND RecordTypeId = :map_RecordTypeIdByDeveloperName.get('API')
			]);
			
			for (Opportunity objOpportunity : map_OpportunityById.values()) { 
				for (CampaignInfluence objCampaignInfluence : objOpportunity.CampaignInfluences) {
					if (!map_CampaignInfluenceByOpportunityId.containsKey(objCampaignInfluence.OpportunityId)) {
						map_CombinedInfluenceByOpportunityId.put(objCampaignInfluence.OpportunityId, objCampaignInfluence.Influence);
					} else {
						Decimal decExistingCampaignInfluenceWeitage = objCampaignInfluence.Influence + map_CombinedInfluenceByOpportunityId.get(objCampaignInfluence.OpportunityId);
						map_CombinedInfluenceByOpportunityId.put(objCampaignInfluence.OpportunityId, decExistingCampaignInfluenceWeitage);
					}

					if (set_DeletedContactIds.contains(objCampaignInfluence.ContactId)) {
						if (!map_CampaignInfluenceByOpportunityId.containsKey(objCampaignInfluence.OpportunityId)) {
							map_CampaignInfluenceByOpportunityId.put(objCampaignInfluence.OpportunityId, objCampaignInfluence.Influence);
						} else {
							Decimal decCampaignInfluenceWeitage = objCampaignInfluence.Influence + map_CampaignInfluenceByOpportunityId.get(objCampaignInfluence.OpportunityId);
							map_CampaignInfluenceByOpportunityId.put(objCampaignInfluence.OpportunityId, decCampaignInfluenceWeitage);
						}
						
						if (!map_CampaignInfluencesByOpportunityId.containsKey(objOpportunity.Id)) {
							map_CampaignInfluencesByOpportunityId.put(
								objOpportunity.Id, 
								new List<CampaignInfluence> { objCampaignInfluence }
							);
						} else {
							map_CampaignInfluencesByOpportunityId.get(objOpportunity.Id).add(objCampaignInfluence);
						}
					} else {
						if (
							String.isNotBlank(objOpportunity.DRL_SourceCampaignId__c) &&
							!objOpportunity.DRL_SourceLastTouchMatch__c
						) {
							if (!map_CampaignInfluenceByContactId.containsKey(objCampaignInfluence.ContactId) &&
								(objCampaignInfluence.CampaignId != objOpportunity.DRL_SourceCampaignId__c ||
								(objCampaignInfluence.CampaignId == objOpportunity.DRL_SourceCampaignId__c &&
								objCampaignInfluence.ContactId != objOpportunity.DRL_SourceCampaignContactId__c))
							) {
								map_CampaignInfluenceByContactId.put(objCampaignInfluence.ContactId, objCampaignInfluence);
							}
						} else if (!map_CampaignInfluenceByContactId.containsKey(objCampaignInfluence.ContactId)) {
							map_CampaignInfluenceByContactId.put(objCampaignInfluence.ContactId, objCampaignInfluence);
						}
					}
				}
			}
			
			for (OpportunityContactRole objOpportunityContactRole : list_OpportunityContactRoles) {
				Opportunity objOpportunity = map_OpportunityById.containsKey(objOpportunityContactRole.OpportunityId)
					? map_OpportunityById.get(objOpportunityContactRole.OpportunityId)
					: null;
				Integer intCountofContacts = objOpportunity.OpportunityContactRoles.size();
				if (
					objOpportunity == null ||
					(map_CombinedInfluenceByOpportunityId.containsKey(objOpportunity?.Id) &&
					 map_CombinedInfluenceByOpportunityId.get(objOpportunity?.Id) > 99.0) ||
					intCountofContacts == 0
				) {
					continue;
				}
				
				Decimal decExistingInfluenceValue = map_CampaignInfluenceByOpportunityId.containsKey(objOpportunity.Id)
					? map_CampaignInfluenceByOpportunityId.get(objOpportunity.Id)
					: 0.0;
				Decimal decNewInfluenceValue = (decExistingInfluenceValue/intCountofContacts).setScale(2, System.RoundingMode.DOWN);
				
				if (map_CampaignInfluencesByOpportunityId.containsKey(objOpportunity.Id)) {
					list_CampaignInfluencestoDelete.addAll(map_CampaignInfluencesByOpportunityId.get(objOpportunity.Id));
				}
				
				for (OpportunityContactRole objExistingOpportunityContactRole : objOpportunity.OpportunityContactRoles) {
					if (map_CampaignInfluenceByContactId.containsKey(objExistingOpportunityContactRole.ContactId)) {
						CampaignInfluence objCampaignInfluence = map_CampaignInfluenceByContactId.get(objExistingOpportunityContactRole.ContactId);
						objCampaignInfluence.Influence += decNewInfluenceValue;
						list_CampaignInfluencesToUpdate.add(objCampaignInfluence);
					}
				}
			}
			
			CaseStaticVars.allowInfluenceInTrigger = false;
			if (!list_CampaignInfluencesToUpdate.isEmpty()) {
				List<Database.SaveResult> list_UpdateResults = Database.update(list_CampaignInfluencesToUpdate, false);
				list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_UpdateResults, 'Update'));
			}
			
			if (!list_CampaignInfluencestoDelete.isEmpty()) {
				List<Database.DeleteResult> list_Results = Database.delete(list_CampaignInfluencestoDelete, false);
				list_ConsolidatedDMLErrors.addAll(DRLUtil.processDeleteResult(list_Results)); 
			}
			
			if (!list_ConsolidatedDMLErrors.isEmpty()) {
				DRLUtil.logDMLException(
					'DRL_OpportunityContactRoleTriggerHelper', 
					'calculateCampaignInfluenceOnDelete', 
					list_ConsolidatedDMLErrors
				);
			}
		} catch(Exception objException) {
			DRLUtil.logException(
				 'DRL_OpportunityContactRoleTriggerHelper',
				 'calculateCampaignInfluenceOnDelete',
				 objException,
				 true
			);
		}
	}

	/**
	* @ author       :  Deeksha Suvarna
	* @ description  :  This method creates the campaign influence record..
	* @ params       :  objCampaignInfluence, idCampaignId, decInfluence, objOpportunity, objOpportunityContactRole
	* @ return       :  objCampaignInfluence
	**/
	private static CampaignInfluence createCampaignInfluence(
		CampaignInfluence objCampaignInfluence,
		Id idCampaignId, 
		Decimal decInfluence,
		Opportunity objOpportunity,
		OpportunityContactRole objOpportunityContactRole
	) {
		if (objCampaignInfluence.Id == null) {
			objCampaignInfluence.ContactId = objOpportunityContactRole.ContactId;
			objCampaignInfluence.OpportunityId = objOpportunity.Id;
			objCampaignInfluence.CampaignId = idCampaignId;
			objCampaignInfluence.ModelId = objCampaignInfluenceModel.Id;
		}
			
		objCampaignInfluence.Influence = decInfluence;		
		objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
		objCampaignInfluence.Stage_Updated_On__c = System.now();
		return objCampaignInfluence;
	}
}