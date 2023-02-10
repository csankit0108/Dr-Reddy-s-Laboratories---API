/*******************************************************************************************************
* @ Name            :   DRL_OpportunityContactRoleTriggerHelper
* @ Purpose         :   Helper class for DRL_OpportunityContactRoleTrigger
* @ Author          :   Ankit C
* @ Test Class Name :   DRL_OpportunityContactRoleTriggerHelperTest
*
*   Date            |  Developer Name                       |  Version      |    Changes    
* ======================================================================================================        
*  10-01-2023       |  Ankit C                              |  1.0          |    Initial Version          
*******************************************************************************************************/
public class DRL_OpportunityContactRoleTriggerHelper {
	//Flag to skip this trigger
	public static boolean blnSkipOpportunityContactRoleTrigger = false;

	/**
	* @ author       :  Ankit C
	* @ description  :  This method handles all the logic that should be performed in the beforeInsert trigger contaxt.
	* @ params       :  list_OpportunityContactRoles - List of OpportunityContactRole from trigger.new
	* @ return       :  N/A
	**/
	public static void onBeforeInsert(List<OpportunityContactRole> list_OpportunityContactRoles) {
		duplicateContactValidation(list_OpportunityContactRoles);
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
		
		//Fetch all the contact Ids into Set
		for (OpportunityContactRole objOpportunityContactRole : list_OpportunityContactRoles) {
			String.isNotBlank(objOpportunityContactRole.ContactId) {
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
						new set<Id>{ objOpportunityContactRole.OpportunityId }
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
	}
}