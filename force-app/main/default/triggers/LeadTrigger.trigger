trigger LeadTrigger on Lead (before insert, after insert, before update, after update) {
    /*
    * Please Do not comment this code on Line.no 8. 
    * Commenting this leads to exceptions. 
    */
    if (
        !Disable_Trigger__c.getInstance().Disable_LeadTrigger__c &&
        !DRL_LeadTriggerHelper.blnSkipTrigger
    ) {
        new LeadTriggerHandler().run();
    }
}