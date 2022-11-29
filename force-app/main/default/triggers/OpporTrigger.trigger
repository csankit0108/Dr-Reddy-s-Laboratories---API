trigger OpporTrigger on Opportunity (after insert,after update) {

    if(trigger.isAfter && trigger.isInsert) {
        DRL_OpportunityTriggerHelper.createCampaignInfluence(Trigger.newMap);
        DRL_OpportunityTriggerHelper.createLeadCampaignInfluence(Trigger.newMap);
    }

    if(trigger.isAfter && trigger.isUpdate) {
        DRL_OpportunityTriggerHelper.createCampaignInfluence(Trigger.newMap);
        DRL_OpportunityTriggerHelper.createLeadCampaignInfluence(Trigger.newMap);
    }
}