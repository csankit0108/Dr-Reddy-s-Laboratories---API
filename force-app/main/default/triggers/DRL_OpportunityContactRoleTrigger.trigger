trigger DRL_OpportunityContactRoleTrigger on OpportunityContactRole (before insert,after insert) {
    if (DRL_OpportunityContactRoleTriggerHelper.blnSkipOpportunityContactRoleTrigger) {
        return;
    }

    
    if(trigger.isBefore && trigger.isInsert) {
        DRL_OpportunityContactRoleTriggerHelper.duplicatecontactValidation(Trigger.new);
    }
    if(trigger.isAfter && trigger.isInsert) {
        DRL_OpportunityContactRoleTriggerHelper.calculateCampaignInfluence(Trigger.new);
    }

}