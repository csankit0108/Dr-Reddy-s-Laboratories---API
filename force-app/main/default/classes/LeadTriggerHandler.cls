public with sharing class LeadTriggerHandler extends TriggerHandler {
    public static final String finalMailer = 'Mailer 4';
    List<Lead> newList = new List<Lead>();
    Map<Id, Lead> newMap = new Map<Id, Lead>();
    List<Lead> oldList = new List<Lead>();
    Map<Id, Lead> oldMap = new Map<Id, Lead>();
    public LeadTriggerHandler(){
        this.newList = (List<Lead>)Trigger.new;
        this.newMap = (Map<Id, Lead>)Trigger.newMap;
        this.oldList = (List<Lead>)Trigger.old;
        this.oldMap = (Map<Id, Lead>)Trigger.oldMap;
    }
    
    public override void beforeInsert() {
        try {
            DRL_LeadTriggerHelper.processBeforeInsert(this.newList);
        } catch(Exception objException) {
            DRLUtil.logException(
                'DRL_LeadTriggerHelper',
                'beforeInsert',
                objException,
                true
            );
        }
        for(Lead ld : newList){
            if(ld.Status == 'Open'){
                ld.Open_Date__c = System.today();
                ld.Previous_Status__c = ld.Status;
                
            }
            else if(ld.Status == 'Unqualified'){
                ld.Unqualified_Date__c = System.today();
                ld.Previous_Status__c = ld.Status;
            }
            else if(ld.Status == 'Qualified'){
                ld.Qualified_Date__c = System.today();
                ld.Previous_Status__c = ld.Status;
            }
            else if(ld.Status == 'Contacted'){
                ld.Contacted_Date__c = System.today();
                ld.Previous_Status__c = ld.Status;
            }
            else if(ld.Status == 'On Hold/Postponed'){
                ld.On_Hold_Postponed_Date__c = System.today();
                ld.Previous_Status__c = ld.Status;
            }
            
            else if(ld.Status == 'Declined'){
                ld.Declined_Date__c = System.today();
                ld.Previous_Status__c = ld.Status;
            }
            else if(ld.Status == 'Converted'){
                ld.Converted_Date__c = System.today();
                ld.Previous_Status__c = ld.Status;
            }
            
            
        } 
    }

    public override void beforeUpdate(){
        for(Lead ld : newList){
            if(ld.Status == 'Open' && ld.Status != oldMap.get(ld.Id).Status){
                ld.Open_Date__c = System.today();
                ld.Previous_Status__c = oldMap.get(ld.Id).Status;
            }
            else if(ld.Status == 'Unqualified' && ld.Status != oldMap.get(ld.Id).Status){
                ld.Unqualified_Date__c = System.today();
                ld.Previous_Status__c = oldMap.get(ld.Id).Status;
            }
            else if(ld.Status == 'Qualified' && ld.Status != oldMap.get(ld.Id).Status){
                ld.Qualified_Date__c = System.today();
                ld.Previous_Status__c = oldMap.get(ld.Id).Status;
            }
            else if(ld.Status == 'Contacted' && ld.Status != oldMap.get(ld.Id).Status){
                ld.Contacted_Date__c = System.today();
                ld.Previous_Status__c = oldMap.get(ld.Id).Status;
            }
            else if(ld.Status == 'On Hold/Postponed' && ld.Status != oldMap.get(ld.Id).Status){
                ld.On_Hold_Postponed_Date__c = System.today();
                ld.Previous_Status__c = oldMap.get(ld.Id).Status;
            }
            
            else if(ld.Status == 'Declined' && ld.Status != oldMap.get(ld.Id).Status){
                ld.Declined_Date__c = System.today();
                ld.Previous_Status__c = oldMap.get(ld.Id).Status;
            }
            else if(ld.Status == 'Converted' && ld.Status != oldMap.get(ld.Id).Status){
                ld.Converted_Date__c = System.today();
                ld.Previous_Status__c = oldMap.get(ld.Id).Status;
            }
            
            
        }
       
    }
    
    public override void afterInsert() {
        DRL_LeadTriggerHelper.processAfterInsert(this.newList);
    }

    public override void afterUpdate() {
        checkIfLeadQualifiedFor24HrsLoop();
        checkForMailerConfigsAfterLeadConversion(); 
        try {
            DRL_LeadTriggerHelper.processAfterUpdate(this.newMap, this.oldMap); 
        } catch(Exception objException) {
            DRLUtil.logException(
                'DRL_LeadTriggerHelper',
                'afterUpdate',
                objException,
                true
            );
        }
        List<Lead> leadList = new List<Lead>();
        for(Lead ld : newList){
            if(ld.Status != oldMap.get(ld.Id).Status && ld.CPR__c != null){
                leadList.add(ld);
            }
        }
        if(leadList.size()>0){
            LeadTriggerHandler.sendLeadToPanorama(leadList);
        }
    }
        
    

    public void checkIfLeadQualifiedFor24HrsLoop(){
        set<Id> leadIds = new Set<Id>();
        for (Lead ld : newList){
            if (ld.Status == 'Qualified' && !ld.X24Hrs_Loop_Reminder__c){
                leadIds.add(ld.Id);
            }
        }
        if (!leadIds.isEmpty()){
            set24hrLoopToTrue(leadIds);
        }
    }

    @future
    public static void set24hrLoopToTrue(set<Id> leadIds){
        List<Lead> leads = new List<Lead>();
        for (Id leadId : leadIds){
            leads.add(new Lead(Id = leadId, X24Hrs_Loop_Reminder__c = true));
        }
        update leads;
    }

    public void checkForMailerConfigsAfterLeadConversion(){
        try{
            set<String> emails = new set<String>();
            for (Lead ld : newList){
                if (ld.Run_Automation__c == 'Yes' && 
                    ld.Status == 'Converted' && 
                    ld.Status != oldMap.get(ld.Id).Status && String.isNotBlank(ld.Current_Mailer_Sent__c)){
                    emails.add(ld.email);
                }
            }

            if (!emails.isEmpty()){
                Map<String, Lead> emailIdToLead = new Map<String, Lead>();
                for (Lead ld : [SELECT Id, Email, Current_Mailer_Sent__c, Prospect_Customer__c, CreatedDate
                                FROM Lead
                                WHERE Email IN:emails AND Status = 'Contacted' AND Run_automation__c = 'Yes']){
                    if (!emailIdToLead.containsKey(ld.Email.toLowerCase()) || ld.CreatedDate < emailIdToLead.get(ld.Email.toLowerCase()).CreatedDate){
                        emailIdToLead.put(ld.Email.toLowerCase(), ld);
                    }
                }

                if (!emailIdToLead.isEmpty()){
                    for (Lead ld : newList){
                        if (emailIdToLead.containsKey(ld.Email.toLowerCase())){
                            emailIdToLead.get(ld.Email.toLowerCase()).Current_Mailer_Sent__c = ld.Current_Mailer_Sent__c;
                            if (ld.Current_Mailer_Sent__c == finalMailer){
                                emailIdToLead.get(ld.Email.toLowerCase()).Trigger_Mailer__c = 'STOP';
                            }
                        }
                    }
                    Database.update (emailIdToLead.values(), true);
                }
            }
        } catch (Exception ex){
            System.debug('ERROR MSG::: ' + ex.getMessage());
            System.debug('ERROR STACKTRACE::: ' + ex.getStackTraceString());
        }
    }
    public static void sendLeadToPanorama(List<Lead> leadList){
        system.debug('Lead----->'+LeadList);
        // getting lead related Opportunities
        Map<Id,Opportunity> optyMap=new Map<Id,Opportunity>();
        Set<Id> leadIds = (new Map<Id,Lead>(LeadList)).keySet();
        system.debug('Lead Id List size---->'+leadIds.size());
        list<Opportunity> optyList=[select Id,Name,StageName,Lead_Converted_From__c,Lead_Converted_to_Opp__c from Opportunity where Lead_Converted_From__c in:leadIds];
        system.debug('Opportunity list size--->'+optyList.size());
        if(optyList.size()>0)
        {
            for(Opportunity op:optyList)
            {
                optyMap.put(op.Lead_Converted_From__c,op);
            }
        }
        // getting lead related Opportunities
        List<row> rows = new List<row>();
        Row row = new Row();
        
        for(Lead ld : leadList){
            jsonWrapper json = new jsonWrapper();
            json.Lead_Id = ld.Id;
            //if(ld.Company != null){
                json.Company = ld.Company; 
           // }
           // else{
                //json.Company = ld.Account_Name__c;
            //}
            //updating current timestamp and previous timestamp
            json.Reason_For_Decline = ld.Reason_for_Decline__c;
            if(ld.Status == 'Open'){
                json.Current_Status_TimeStamp = String.valueOf(ld.Open_Date__c);
                
            }
            else if(ld.Status == 'Unqualified'){
                json.Current_Status_TimeStamp = String.valueOf(ld.Unqualified_Date__c);
            }
            else if(ld.Status == 'Qualified'){
                json.Current_Status_TimeStamp = String.valueOf(ld.Qualified_Date__c);
            }
            else if(ld.Status == 'Contacted'){
                json.Current_Status_TimeStamp = String.valueOf(ld.Contacted_Date__c);
            }
            else if(ld.Status == 'On Hold/Postponed'){
                json.Current_Status_TimeStamp = String.valueOf(ld.On_Hold_Postponed_Date__c);
            }
            
            else if(ld.Status == 'Declined'){
                json.Current_Status_TimeStamp = String.valueOf(ld.Declined_Date__c);
                
            }
            else if(ld.Status == 'Converted'){
                json.Current_Status_TimeStamp = String.valueOf(ld.Converted_Date__c);
            }
            
            if(ld.Previous_Status__c == 'Open'){
                json.Previous_Status_TimeStamp = String.valueOf(ld.Open_Date__c);
                
            }
            else if(ld.Previous_Status__c == 'Unqualified'){
                json.Previous_Status_TimeStamp = String.valueOf(ld.Unqualified_Date__c);
            }
            else if(ld.Previous_Status__c == 'Qualified'){
                json.Previous_Status_TimeStamp = String.valueOf(ld.Qualified_Date__c);
            }
            else if(ld.Previous_Status__c == 'Contacted'){
                json.Previous_Status_TimeStamp = String.valueOf(ld.Contacted_Date__c);
            }
            else if(ld.Previous_Status__c == 'On Hold/Postponed'){
                json.Previous_Status_TimeStamp = String.valueOf(ld.On_Hold_Postponed_Date__c);
            }
            
            else if(ld.Previous_Status__c == 'Declined'){
                json.Previous_Status_TimeStamp = String.valueOf(ld.Declined_Date__c);
            }
            else if(ld.Previous_Status__c == 'Converted'){
                json.Previous_Status_TimeStamp = String.valueOf(ld.Converted_Date__c);
            }
            json.Reason = '';
            json.Reason_For_Loss = '';
            json.Product = ld.Product__c;
            json.Target_Region = ld.Target_Region__c;
            //json.CPR = opp.CPR__c;
            
            json.Reporting_Region = ld.Reporting_Region__c;
            json.New_Lead = false;
            
            json.Event_Timestamp=string.valueof(system.now());
            json.Comment='';
            json.Lead_stage = ld.Status;
            if(ld.Status == 'Converted')
            {
                json.Opportunity_Id = optyMap.containsKey(ld.Id)?optyMap.get(ld.Id).Id:null;
                json.Stage_Name = optyMap.containsKey(ld.Id)?optyMap.get(ld.Id).StageName:null;
                json.Lead_Converted_to_Opp = optyMap.containsKey(ld.Id)?optyMap.get(ld.Id).Lead_Converted_to_Opp__c:null;
                json.Existing_Opportunity = true;
            }
            else
            {
                json.Opportunity_Id = '';
                json.Stage_Name = '';
                json.Lead_Converted_to_Opp = '';
                json.Existing_Opportunity = false;
            }
            row.json = json;
            rows.add(row);
            system.debug('json response---->'+rows);
        }
        Map<String,Object> requestMap = new Map<String,Object>{'rows' => rows };
            futurePost(System.json.serialize(requestMap));
    }
     @future (callout=true)
    public static void futurePost(String requestBody){ 
        system.debug('request body----->'+requestBody);
        String accessToken=Panorama_update_from_Salesforce_to_GCP.getAccessTokenJWT('GCP_Access_token');
        //String accessToken='';
        system.debug('Access Token--->'+accessToken);
        if(accessToken == '' || accessToken == null){
            LeadTriggerhandler.sendEmailalert(requestBody);
        }
        else{
            HTTPRequest req = Panorama_update_from_Salesforce_to_GCP.getHttpRequest('Send_to_GCP', '', requestBody);
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            Http http = new Http();
            HTTPResponse res = HTTP.send(req);
            System.debug('response body---->'+res.getBody());
        }
        
        
    }
    public static void sendEmailAlert(String requestBody){
        List<String> emails = System.Label.Panorama_Lead_Status_Failure_Alert.split(',');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emails;
        message.subject = 'Lead not synced to Salesforce due to Access token is null';
        String htmlBody = 'Hi Team,<br/><br/>';
        htmlBody = htmlBody + 'The following CPR details not synced to GCP due to access token is null.<br/>';
        htmlBody = htmlBody + 'CPR Details: '+requestBody;
        message.setHtmlBody(htmlBody);
        Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: '
                         + results[0].errors[0].message);
        }
        
    }
    public class jsonWrapper{
        
        public String Lead_Id{ get; set; }
        public String Opportunity_Id{ get; set; }
        
        public String Stage_Name{ get; set; }
        
        public String Company{ get; set; }
        
        public String Product{ get; set; }
        
        public String Target_Region{ get; set; }
        
        //public String CPR{ get; set; }
        
        public Boolean Existing_Opportunity{ get; set; }
        
        public String Reporting_Region{ get; set; }
        public Boolean New_Lead{ get; set; }
        public String Lead_Converted_to_Opp{ get; set; }
        public String Event_Timestamp{ get; set; }
        public String Reason_For_Decline{ get; set; }
        public String Current_Status_TimeStamp{ get; set; }
        public String Previous_Status_TimeStamp{ get; set; }
        public String Reason{ get; set; }
        public String Reason_For_Loss{ get; set; }
        public String Comment{ get; set; }
        public String Lead_stage { get; set; }
        
        
    }
    
    public class row{
        
        public jsonWrapper json{ get; set; }
    }
}