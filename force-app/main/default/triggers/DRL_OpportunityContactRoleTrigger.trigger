trigger DRL_OpportunityContactRoleTrigger on OpportunityContactRole (before insert,after insert) {
    
    if(trigger.isBefore && trigger.isInsert) {
        DRL_OpportunityContactRoleTriggerHelper.duplicatecontactValidation(Trigger.new);
    }
    

}