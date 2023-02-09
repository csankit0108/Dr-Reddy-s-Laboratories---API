public class DRL_OpportunityContactRoleTriggerHelper {
     public static boolean blnSkipOpportunityContactRoleTrigger = false;
	//Custom Label with Value 'DRL_APICampaignsDistributionModel'
	public static String strModelDeveloperName = Label.CLDRL00001;
	//Map of Opportunity By Id
	public static Map<Id, Opportunity> map_OpportunityById = new Map<Id, Opportunity>();
	//Map of Contact By Id
	public static Map<Id, Contact> map_ContactById = new Map<Id, Contact>();
	//Map of Leads By Id
	public static Map<Id, Lead> map_LeadsById = new Map<Id, Lead>();
	//Map of CampaignInfluence record by combinaation of Opp Id+Contact Id+Campaign Id
	public static Map<String, CampaignInfluence> map_CampaignInfluenceByUniqueKey = new Map<String, CampaignInfluence>();
	//Map of OpportunityContactRoleWrapper by OpportunityId+ContactId combination
	public static Map<String, OpportunityContactRoleWrapper> map_OpportunityContactRoleWrapperByContactId = new Map<String, OpportunityContactRoleWrapper>();
	//Map of CampaignIds with ContactIds
	public static Map<Id, Id> map_CampaignIdByContactId = new Map<Id, Id>();
	//Quering the Value of DeveloperName 
	public static CampaignInfluenceModel objCampaignInfluenceModel = [SELECT 
																	  Id,
																	  DeveloperName 
																	  FROM CampaignInfluenceModel 
																	  WHERE DeveloperName = :strModelDeveloperName];
	
	
	public class OpportunityContactRoleWrapper {
		public OpportunityContactRole objOpportunityContactRole;
		public Campaign objSourceCampaign;
		public Campaign objLastTouchCampaign;
	}
	
	public static void calculateCampaignInfluence (List<OpportunityContactRole> list_OpportunityContactRole) {
		 //Set of OpportunityIds 
	 	Set<Id> set_OpportunityIds = new Set<Id>();
	 	//Set of ContactIds
	 	Set<Id> set_ContactIds = new Set<Id>();
		//Set of ContactIds
	 	Set<Id> set_IncomingContactIds = new Set<Id>();
	 	// Set of LeadIds
	 	Set<Id> set_LeadIds = new Set<Id>();
	 	//Set of ProspectIds
	 	Set<Id> set_ProspectIds = new Set<Id>();
		// Set of CampaignIds
	 	Set<Id> set_CampaignIds = new Set<Id>();
	 	//Map of SourceCampaignIds By LeadIds
	 	Map<Id, Id> map_SourceCampaignIdByLeadId = new Map<Id, Id>();
		Map<Id,CampaignMember> map_CampaignMemberByContactId = new Map<Id,CampaignMember>();
		Map<Id, Campaign> map_CampaignById = new Map<Id, Campaign>();
		List<OpportunityContactRole> list_AllContactRoles = new list<OpportunityContactRole>();
		//Map of CampaignInfluence to insert
		Map<String, CampaignInfluence> map_CampaignInfluenceToInsert = new Map<String, CampaignInfluence>();
		Map<Id, Contact> map_IncomingContactById;
		
		
		for (OpportunityContactRole objOpportunityContactRole : list_OpportunityContactRole) {
			set_IncomingContactIds.add(objOpportunityContactRole.ContactId);
			set_OpportunityIds.add(objOpportunityContactRole.OpportunityId);
		}
		system.debug('set_OpportunityIds'+set_OpportunityIds);
		map_IncomingContactById = new Map<Id, Contact>([SELECT
														Id,
														(SELECT
														 Id,
														 HasResponded
														 FROM CampaignMembers
														 ORDER BY CreatedDate DESC
														 LIMIT 1)
														 FROM Contact
														 WHERE Id IN :set_IncomingContactIds]);
		
		system.debug('set_IncomingContactIds'+set_IncomingContactIds);
		system.debug('map_IncomingContactById'+map_IncomingContactById);
		

		
		map_OpportunityById = new Map<Id, Opportunity>([SELECT 
														Id, 
														Name,
														CampaignId,
														StageName,
														ContactId,
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
														WHERE Id IN :set_OpportunityIds]);
		
		for (Opportunity objOpportunity : map_OpportunityById.values()) {
			if(!objOpportunity.OpportunityContactRoles.isEmpty()) {
				list_AllContactRoles.addAll(objOpportunity.OpportunityContactRoles);  
			}
			
			if (!objOpportunity.CampaignInfluences.isEmpty()) {
				for (CampaignInfluence objCampaignInfluence : objOpportunity.CampaignInfluences) {
					String strUniqueKey = objCampaignInfluence.OpportunityId + '' + objCampaignInfluence.ContactId + '' + objCampaignInfluence.CampaignId;
					map_CampaignInfluenceByUniqueKey.put(strUniqueKey, objCampaignInfluence);
				}
			}
		}
		
		system.debug('list_AllContactRoles'+list_AllContactRoles);
		
		for (OpportunityContactRole objOpportunityContactRole : list_AllContactRoles) {
		   if (String.isNotBlank(objOpportunityContactRole.ContactId)) {
				set_ContactIds.add(objOpportunityContactRole.ContactId);
			} 
		}
		
		map_ContactById = new Map<Id, Contact>([SELECT 
								   				Id, 
								  				Name,
								   				Campaign_Id__c ,
												Lead_Converted_From__c
								   				FROM Contact 
								   				WHERE Id IN :set_ContactIds]);
		
		if (!map_ContactById.isEmpty()) {
			for ( Contact objContact : map_ContactById.values()) {
				if (objContact.Lead_Converted_From__c!=null) {
					set_LeadIds.add(objContact.Lead_Converted_From__c);
				}                
			}
		}
		
		system.debug('map_ContactById'+map_ContactById);
		
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
				if(!map_CampaignMemberByContactId.containsKey(objCampaignMember.ContactId)){
					set_CampaignIds.add(objCampaignMember.CampaignId);
					map_CampaignMemberByContactId.put(objCampaignMember.ContactId, objCampaignMember);
					map_CampaignIdByContactId.put(objCampaignMember.ContactId,objCampaignMember.CampaignId);
				}
				
			}
		system.debug('map_CampaignIdByContactId'+map_CampaignIdByContactId);
		
		Map<String, CampaignMember> map_CampaignMemberByUniqueKey = new Map<String, CampaignMember>();
		for (CampaignMember objCampaignMember : [SELECT 
												 CampaignId,
												 ContactId,
												 LeadId,
												 CreatedDate,
												 FirstRespondedDate,
												 HasResponded
												 FROM CampaignMember
												 WHERE LeadId IN :set_ProspectIds
												 AND CampaignId IN :map_SourceCampaignIdByLeadId.values()
												 AND HasResponded = true]
			) {
				set_CampaignIds.add(objCampaignMember.CampaignId);
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
				map_ContactById.containsKey(objOpportunityContactRole.ContactId) &&
				map_LeadsById.containsKey(map_ContactById.get(objOpportunityContactRole.ContactId).Lead_Converted_From__c)
			) {
				Lead objConvertedLead = map_LeadsById.get(map_ContactById.get(objOpportunityContactRole.ContactId).Lead_Converted_From__c);
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
		
		for (OpportunityContactRole objOpportunityContactRole : list_OpportunityContactRole) {
	 		Opportunity objOpportunity = map_OpportunityById.containsKey(objOpportunityContactRole.OpportunityId)
				? map_OpportunityById.get(objOpportunityContactRole.OpportunityId)
				: new Opportunity();
			Integer intCountofContactsWithSourceCampaign = 0;
			Integer intCountofContactsWithLastTouchCampaign = 0;
			for (OpportunityContactRole objExistingOpportunityContactRole : objOpportunity.OpportunityContactRoles) {
				String strWrapperKey = objExistingOpportunityContactRole.OpportunityId + '' + objExistingOpportunityContactRole.ContactId;
				system.debug('strWrapperKey'+strWrapperKey);
				OpportunityContactRoleWrapper objWrapper;
				if (map_OpportunityContactRoleWrapperByContactId.containsKey(strWrapperKey)) {
					system.debug('map_OpportunityContactRoleWrapperByContactId'+map_OpportunityContactRoleWrapperByContactId);
					objWrapper = map_OpportunityContactRoleWrapperByContactId.get(strWrapperKey);
				}

				if (objExistingOpportunityContactRole.Id != objOpportunityContactRole.Id) {
					//update intCountofContactsWithSourceCampaign & intCountofContactsWithLastTouchCampaign here
					if (objWrapper != null) {
			   			system.debug('hi');
						system.debug('objWrapper.objLastTouchCampaign'+objWrapper.objLastTouchCampaign);
						if (objWrapper.objSourceCampaign != null) {
							//intCountofContactsWithSourceCampaign++; 
						}
						if (objWrapper.objLastTouchCampaign != null) {
							system.debug('objWrapper'+objWrapper.objOpportunityContactRole.ContactId);
							intCountofContactsWithLastTouchCampaign++;
							
							
						}
						
					}
				}  
			}
			
			/*if (
				map_IncomingContactById.containsKey(objOpportunityContactRole.ContactId) && 
				!map_IncomingContactById.get(objOpportunityContactRole.ContactId).CampaignMembers.isEmpty() && 
				map_IncomingContactById.get(objOpportunityContactRole.ContactId).CampaignMembers[0].HasResponded == true
			) {
				intCountofContactsWithLastTouchCampaign++;
			}*/
			
			system.debug('intCountofContactsWithSourceCampaign'+intCountofContactsWithSourceCampaign);
			system.debug('intCountofContactsWithLastTouchCampaign'+intCountofContactsWithLastTouchCampaign);
			
			String strWrapperKey = objOpportunityContactRole.OpportunityId + '' + objOpportunityContactRole.ContactId;
			OpportunityContactRoleWrapper objWrapper = map_OpportunityContactRoleWrapperByContactId.containsKey(strWrapperKey)
				? map_OpportunityContactRoleWrapperByContactId.get(strWrapperKey)
				: null;
			
			if (objWrapper != null) {
				CampaignInfluence objCampaignInfluence;
				String strSourceCampaignId = (objWrapper.objSourceCampaign != null) 
                    ? objWrapper.objSourceCampaign.Id 
                    : null;
				String strLastTouchCampaignId = (objWrapper.objLastTouchCampaign != null) 
                    ? objWrapper.objLastTouchCampaign.Id : 
                	null;
				system.debug('strSourceCampaignId'+strSourceCampaignId);
				String strUniqueKeyWithSourceCampaign = objWrapper.objOpportunityContactRole.OpportunityId + '' + objOpportunityContactRole.ContactId + '' + strSourceCampaignId;
				String strUniqueKeyWithLastTouchCampaignId = objWrapper.objOpportunityContactRole.OpportunityId + '' + objOpportunityContactRole.ContactId + '' + strLastTouchCampaignId; 
				system.debug('strUniqueKeyWithSourceCampaign'+strUniqueKeyWithSourceCampaign);
				if (String.isNotBlank(strLastTouchCampaignId)) {
					intCountofContactsWithLastTouchCampaign++;
				}
				
				if (
					objWrapper.objSourceCampaign != null && 
					objWrapper.objLastTouchCampaign != null &&
					objWrapper.objSourceCampaign.Id == objWrapper.objLastTouchCampaign.Id
				) {
					//create 1 CI record
					//use map_CampaignInfluenceByUniqueKey to upsert based on unique key
					if (map_CampaignInfluenceByUniqueKey.containsKey(strUniqueKeyWithSourceCampaign)) {
						system.debug('Update Campaign Influence');
						objCampaignInfluence = map_CampaignInfluenceByUniqueKey.get(strUniqueKeyWithSourceCampaign);
						objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
						objCampaignInfluence.Stage_Updated_On__c = System.now();
						objCampaignInfluence.Influence = 20;
		 				system.debug('1.map value on update:: ' +  map_CampaignInfluenceByUniqueKey.get(strUniqueKeyWithSourceCampaign));
					} else {
						objCampaignInfluence = new CampaignInfluence();
						objCampaignInfluence.ContactId = objOpportunityContactRole.ContactId;
						objCampaignInfluence.CampaignId = strSourceCampaignId;
						objCampaignInfluence.OpportunityId = objWrapper.objOpportunityContactRole.OpportunityId;
						objCampaignInfluence.Influence = 20;
						objCampaignInfluence.ModelId = objCampaignInfluenceModel.Id;
						objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
						objCampaignInfluence.Stage_Updated_On__c = System.now();
						map_CampaignInfluenceByUniqueKey.put(strUniqueKeyWithSourceCampaign, objCampaignInfluence);
						system.debug('2.map value on insert:: '+map_CampaignInfluenceByUniqueKey.get(strUniqueKeyWithSourceCampaign));
					}  
				} else {
					Decimal decSourceCampaignInfluence = 0;
					//Give influence to Source Campaign
					if (objWrapper.objSourceCampaign != null) {
						decSourceCampaignInfluence = 10;
						//create CI for source campaign
						//use map_CampaignInfluenceByUniqueKey to upsert based on unique key
						if (map_CampaignInfluenceByUniqueKey.containsKey(strUniqueKeyWithSourceCampaign)) {
							system.debug('Update Campaign Influence');
							objCampaignInfluence = map_CampaignInfluenceByUniqueKey.get(strUniqueKeyWithSourceCampaign);
							objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
							objCampaignInfluence.Stage_Updated_On__c = System.now();
							objCampaignInfluence.Influence = decSourceCampaignInfluence;
		 					system.debug('3.map value on update:: ' +  map_CampaignInfluenceByUniqueKey.get(strUniqueKeyWithSourceCampaign));
						} else {
							objCampaignInfluence = new CampaignInfluence();
							objCampaignInfluence.ContactId = objOpportunityContactRole.ContactId;
							objCampaignInfluence.CampaignId = strSourceCampaignId;
							objCampaignInfluence.OpportunityId = objWrapper.objOpportunityContactRole.OpportunityId;
							objCampaignInfluence.Influence = decSourceCampaignInfluence;
							objCampaignInfluence.ModelId = objCampaignInfluenceModel.Id;
							objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
							objCampaignInfluence.Stage_Updated_On__c = System.now();
							map_CampaignInfluenceByUniqueKey.put(strUniqueKeyWithSourceCampaign, objCampaignInfluence);
							system.debug('4.map value on insert:: '+map_CampaignInfluenceByUniqueKey.get(strUniqueKeyWithSourceCampaign));
							system.debug('objWrapper.objOpportunityContactRole'+objWrapper.objOpportunityContactRole);
						}
					}
					
					//Give influence to Last Touch Campaign
					if (objWrapper.objLastTouchCampaign != null) {
						Decimal decLastTouchInfluence = 0;
						if (decSourceCampaignInfluence != 0) {
							decLastTouchInfluence = 10;
						} else if (decSourceCampaignInfluence == 0) {
							decLastTouchInfluence = 20;
						}
						
						if (map_CampaignInfluenceByUniqueKey.containsKey(strUniqueKeyWithLastTouchCampaignId)) {
								system.debug('Update Campaign Influence');
								objCampaignInfluence = map_CampaignInfluenceByUniqueKey.get(strUniqueKeyWithLastTouchCampaignId);
								objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
								objCampaignInfluence.Stage_Updated_On__c = System.now();
								objCampaignInfluence.Influence = decLastTouchInfluence;
								system.debug('5.map value on update:: ' +  objCampaignInfluence);
							} else {
								objCampaignInfluence = new CampaignInfluence();
								objCampaignInfluence.ContactId = objOpportunityContactRole.ContactId;
								objCampaignInfluence.CampaignId = strLastTouchCampaignId;
								objCampaignInfluence.OpportunityId = objWrapper.objOpportunityContactRole.OpportunityId;
								objCampaignInfluence.Influence = decLastTouchInfluence;
								objCampaignInfluence.ModelId = objCampaignInfluenceModel.Id;
								objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
								objCampaignInfluence.Stage_Updated_On__c = System.now();
								map_CampaignInfluenceByUniqueKey.put(strUniqueKeyWithLastTouchCampaignId, objCampaignInfluence);
								system.debug('6.map value on insert:: '+map_CampaignInfluenceByUniqueKey.get(strUniqueKeyWithLastTouchCampaignId));
							}
						
						/*if (decSourceCampaignInfluence != 0) {
							//influence will be 10% for last touch campaign
							if (map_CampaignInfluenceByUniqueKey.containsKey(strUniqueKeyWithLastTouchCampaignId)) {
								system.debug('Update Campaign Influence');
								objCampaignInfluence = map_CampaignInfluenceByUniqueKey.get(strUniqueKeyWithLastTouchCampaignId);
								objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
								objCampaignInfluence.Stage_Updated_On__c = System.now();
								objCampaignInfluence.Influence = decSourceCampaignInfluence;
								system.debug('5.map value on update:: ' +  objCampaignInfluence);
							} else {
								objCampaignInfluence = new CampaignInfluence();
								objCampaignInfluence.ContactId = objOpportunityContactRole.ContactId;
								objCampaignInfluence.CampaignId = strLastTouchCampaignId;
								objCampaignInfluence.OpportunityId = objWrapper.objOpportunityContactRole.OpportunityId;
								objCampaignInfluence.Influence = decSourceCampaignInfluence;
								objCampaignInfluence.ModelId = objCampaignInfluenceModel.Id;
								objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
								objCampaignInfluence.Stage_Updated_On__c = System.now();
								map_CampaignInfluenceByUniqueKey.put(strUniqueKeyWithLastTouchCampaignId, objCampaignInfluence);
								system.debug('6.map value on insert:: '+map_CampaignInfluenceByUniqueKey.get(strUniqueKeyWithLastTouchCampaignId));
							}
						} else {
							//create CI for last touch campaign
							//influence will be 20%
							
							if (map_CampaignInfluenceByUniqueKey.containsKey(strUniqueKeyWithLastTouchCampaignId)) {
								system.debug('Update Campaign Influence');
								objCampaignInfluence = map_CampaignInfluenceByUniqueKey.get(strUniqueKeyWithLastTouchCampaignId);
								objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
								objCampaignInfluence.Stage_Updated_On__c = System.now();
								objCampaignInfluence.Influence = 20;
								system.debug('7.map value on update:: ' +  objCampaignInfluence);
							}
							else {
								objCampaignInfluence = new CampaignInfluence();
								objCampaignInfluence.ContactId = objOpportunityContactRole.ContactId;
								objCampaignInfluence.CampaignId = strLastTouchCampaignId;
								objCampaignInfluence.OpportunityId = objWrapper.objOpportunityContactRole.OpportunityId;
								objCampaignInfluence.Influence = 20;
								objCampaignInfluence.ModelId = objCampaignInfluenceModel.Id;
								objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
								objCampaignInfluence.Stage_Updated_On__c = System.now();
								map_CampaignInfluenceByUniqueKey.put(strUniqueKeyWithLastTouchCampaignId, objCampaignInfluence);
								system.debug('8.map value on insert:: '+map_CampaignInfluenceByUniqueKey.get(strUniqueKeyWithLastTouchCampaignId));
							}
						}*/
					} 
				}
			}
		}
		
		if (!map_CampaignInfluenceByUniqueKey.isEmpty()) {
			upsert map_CampaignInfluenceByUniqueKey.values();
		}
		
		system.debug('map_OpportunityById'+map_OpportunityById);
	}

	public static void duplicatecontactValidation (List<OpportunityContactRole> list_OpportunityContactRole) {
		//Set of ContactIds
		Set<Id> set_ContactIds = new Set<Id>();
		//Set of OpportunityIds
		Set<Id> set_OpportunityIds;
		//Map of Set of Opportunity Id with Contact Id
		Map<Id, Set<Id>> map_opportunityIdsByContactId = new Map<Id, Set<Id>>();
		
		//Fetch all the contact Ids into Set
		for (OpportunityContactRole objOpportunityContactRole : list_OpportunityContactRole) {
			set_ContactIds.add(objOpportunityContactRole.ContactId);
		}
 
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
				if(!map_opportunityIdsByContactId.containsKey(objOpportunityContactRole.ContactId)){
					map_opportunityIdsByContactId.put(objOpportunityContactRole.ContactId, new set<Id>{objOpportunityContactRole.OpportunityId});
				} else {
					map_opportunityIdsByContactId.get(objOpportunityContactRole.ContactId).add(objOpportunityContactRole.OpportunityId);
				}
		}
		
		//Check if ID exist in the Map and display Error message
		for (OpportunityContactRole objOpportunityContactRole : list_OpportunityContactRole) {
			if (map_opportunityIdsByContactId.containsKey(objOpportunityContactRole.ContactId) && map_opportunityIdsByContactId.get(objOpportunityContactRole.ContactId).contains(objOpportunityContactRole.OpportunityId)) {
				objOpportunityContactRole.addError(system.label.Contact_Role_Validation_Message);
			}
		}
	}

	private CampaignInfluence createCampaignInfluence(
		CampaignInfluence objCampaignInfluence,
		Id idCampaignId, 
		Decimal decInfluence,
		Opportunity objOpportunity,
		OpportunityContactRole objOpportunityContactRole
	) {
		objCampaignInfluence.ContactId = objOpportunityContactRole.ContactId;
		objCampaignInfluence.CampaignId = idCampaignId;
		objCampaignInfluence.OpportunityId = objOpportunity.Id;
		objCampaignInfluence.Influence = decInfluence;
		objCampaignInfluence.ModelId = objCampaignInfluenceModel.Id;
		objCampaignInfluence.Stage_Name__c = objOpportunity.StageName;
		objCampaignInfluence.Stage_Updated_On__c = System.now();
		return objCampaignInfluence;
	}
}