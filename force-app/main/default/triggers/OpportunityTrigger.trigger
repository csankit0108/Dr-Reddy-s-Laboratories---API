trigger OpportunityTrigger on Opportunity (after update) {
    
    if (
        !DRL_OpportunityTriggerHelper.blnSkipOpportunityTrigger && 
        !Disable_Trigger__c.getInstance().DisableOpportunityTrigger__c
    ) {
        new DRL_OpportunityTriggerHandler().run();
    }
}