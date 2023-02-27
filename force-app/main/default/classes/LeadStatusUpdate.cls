public class LeadStatusUpdate {
    @AuraEnabled
    public static String updateLead(String status , String recordId){
        Lead ld = Database.query('SELECT ' + DRLUtil.getsObjectFieds('Lead')+ 'FROM Lead WHERE Id =:recordId');
        ld.Status =status ; 
        
        system.debug(ld.Status+'==='+ld.Reasons_for_Converting_Rejecting__c);
        //if(ld.Status=='Declined'&&(ld.Reasons_for_Converting_Rejecting__c==''||ld.Reasons_for_Converting_Rejecting__c==null))
        
        try
        {
            
            
            update ld ;
            return 'Success';
        }
        Catch(Exception e)
        {
            system.debug('==='+e+'==='+e.getLineNumber());
            return 'Fail';
        }
        
        
    }
    
    @AuraEnabled
    public static wrapperLeadStatus getStatus(String recordId,String objectType,String selectedField){
        wrapperLeadStatus wl=new wrapperLeadStatus();
        Lead ld = Database.query('SELECT ' + DRLUtil.getsObjectFieds('Lead')+ 'FROM Lead WHERE Id =:recordId'); 
        wl.ld=ld;
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        wl.statusList=pickListValuesList;
        return wl;
    }
    @AuraEnabled
    public static void updateLeadToQualified(Lead leadData){
        System.debug(leadData);
        update leadData;
    }
    public class wrapperLeadStatus{
        @AuraEnabled public List<String> statusList{get;set;}
        @AuraEnabled public Lead ld{get;set;}
    }
}