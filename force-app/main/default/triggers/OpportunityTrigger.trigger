trigger OpportunityTrigger on Opportunity (after insert,after update) {
    if (DRL_OpportunityTriggerHelper.blnSkipOpportunityTrigger) {
        return;
    }

    if(trigger.isAfter && trigger.isInsert) {
        DRL_OpportunityTriggerHelper.createCampaignInfluence(Trigger.new);
    }

    if(trigger.isAfter && trigger.isUpdate) {
        List<Opportunity> list_Opportunities = new List<Opportunity>();
        for (Opportunity objOpportunity : Trigger.newMap.values()) {
            if (objOpportunity.StageName != Trigger.oldMap.get(objOpportunity.Id).StageName) {
                list_Opportunities.add(objOpportunity);
            }
        }

        if (!list_Opportunities.isEmpty()) {
            DRL_OpportunityTriggerHelper.createCampaignInfluence(list_Opportunities);
        }
    }
}