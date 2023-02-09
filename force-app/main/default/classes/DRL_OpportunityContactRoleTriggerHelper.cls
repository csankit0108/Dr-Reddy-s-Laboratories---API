public class DRL_OpportunityContactRoleTriggerHelper {
	
	/**
    * @ author       :  Mahalakshmi Sadhananthan
    * @ description  :  Validation to prevent duplicate contacts from being added to the same opportunity
    * @ params       :  list_OpportunityContactRole
    * @ return       :  N/A
    **/
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

	
}