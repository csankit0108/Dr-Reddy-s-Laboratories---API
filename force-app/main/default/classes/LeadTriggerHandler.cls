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
    }

    public override void beforeUpdate(){
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
    
    public override void afterInsert() {
        DRL_LeadTriggerHelper.processAfterInsert(this.newList);
    }

    public override void afterUpdate(){
        checkIfLeadQualifiedFor24HrsLoop();
        checkForMailerConfigsAfterLeadConversion(); 
        Set<String> set_oldProspectStatus = new Set<String>();
        Set<String> set_newLeadStatus = new Set<String>();
        Set<Id>set_prospectId = new Set<Id>();
        for(Lead objLead : newList)
        {
            if(oldMap.get(objLead.Id).status != objLead.Status){
                set_oldProspectStatus.add(oldMap.get(objLead.Id).status);
                set_newLeadStatus.add(objLead.Status);
                set_prospectId.add(objLead.DRL_Prospect__c);
            }
        }
         DRL_LeadTriggerHelper.processAfterUpdate(set_oldProspectStatus,set_newLeadStatus,set_prospectId);  
      


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
            
            json.Company = ld.Account_Name__c;
            json.Product = ld.Product_Name__c;
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
        system.debug('Access Token--->'+accessToken);
        HTTPRequest req = Panorama_update_from_Salesforce_to_GCP.getHttpRequest('Send_to_GCP', '', requestBody);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        Http http = new Http();
        HTTPResponse res = HTTP.send(req);
        
        System.debug('response body---->'+res.getBody());
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
        public String Comment{ get; set; }
        public String Lead_stage { get; set; }
     
        
    }
    
    public class row{
        
        public jsonWrapper json{ get; set; }
    }
}