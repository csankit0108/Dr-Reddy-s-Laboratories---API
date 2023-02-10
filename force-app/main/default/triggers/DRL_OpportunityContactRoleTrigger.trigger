trigger DRL_OpportunityContactRoleTrigger on OpportunityContactRole(before insert) {
	if (
		!DRL_OpportunityContactRoleTriggerHelper.blnSkipOpportunityContactRoleTrigger &&
		!Disable_Trigger__c.getInstance().DisableOpportunityContactRoleTrigger__c
	) {
		new DRL_OpportunityContactRoleTriggerHandler().run();
	}
}