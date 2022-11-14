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

    if(trigger.isInsert && trigger.isBefore){
        for(Lead ld : trigger.new){
              if(ld.Status == 'Open'){
                ld.Open_Date__c = System.today();
                
            }
           else if(ld.Status == 'Unqualified'){
                ld.Unqualified_Date__c = System.today();
                
            }
            else if(ld.Status == 'Qualified'){
                ld.Qualified_Date__c = System.today();
               
            }
            else if(ld.Status == 'Contacted'){
                ld.Contacted_Date__c = System.today();
               
            }
            else if(ld.Status == 'On Hold/Postponed'){
                ld.On_Hold_Postponed_Date__c = System.today();
               
            }
            
            else if(ld.Status == 'Declined'){
                ld.Declined_Date__c = System.today();
               
            }
              else if(ld.Status == 'Converted'){
                ld.Converted_Date__c = System.today();
               
            }
        } 
    }
    
     if(trigger.isUpdate && trigger.isBefore){
         for(Lead ld : trigger.new){
             if(ld.Status == 'Open' && ld.Status != trigger.oldMap.get(ld.Id).Status){
                ld.Open_Date__c = System.today();
                
            }
           else if(ld.Status == 'Unqualified' && ld.Status != trigger.oldMap.get(ld.Id).Status){
                ld.Unqualified_Date__c = System.today();
                
            }
            else if(ld.Status == 'Qualified' && ld.Status != trigger.oldMap.get(ld.Id).Status){
                ld.Qualified_Date__c = System.today();
               
            }
            else if(ld.Status == 'Contacted' && ld.Status != trigger.oldMap.get(ld.Id).Status){
                ld.Contacted_Date__c = System.today();
               
            }
            else if(ld.Status == 'On Hold/Postponed' && ld.Status != trigger.oldMap.get(ld.Id).Status){
                ld.On_Hold_Postponed_Date__c = System.today();
               
            }
            
            else if(ld.Status == 'Declined' && ld.Status != trigger.oldMap.get(ld.Id).Status){
                ld.Declined_Date__c = System.today();
               
            }
              else if(ld.Status == 'Converted' && ld.Status != trigger.oldMap.get(ld.Id).Status){
                ld.Converted_Date__c = System.today();
               
            }
              
        
         }
    }   
}