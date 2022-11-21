/*******************************************************************************************************
* 
* @ Name            :   DRL_ConvertLeadProspectController
* @ Purpose         :   controller class for component DRL_ConvertLeadProspect
* @ Author          :   Kishore Pedireddy
* @ Usage           :   1) retrieve lead record details on load
                        2)convert lead to account,contact,opportunities
* @ Test Class Name :   
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*  10-11-2022       |  Kishore Pedireddy            |     1.0       |  Initial Version
*******************************************************************************************************/
public with sharing class DRL_ConvertLeadProspectController {

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to get the lead and component configuration details in DRL_ConvertLeadProspect component
    * @ params       :  strrecordId - lead recordId 
    * @ return       :  Returns ConvertLeadDataWrapper object 
    **/

    @AuraEnabled
    public static ConvertLeadDataWrapper getLeadDetails(String strrecordId){

        ConvertLeadDataWrapper objRespone=new ConvertLeadDataWrapper();
        objRespone.objLead=Database.query('SELECT ' + DRLUtil.getsObjectFieds('Lead') + 
                                        ',RecordType.DeveloperName,DRL_Prospect__r.IsConverted'+
                                        ',DRL_Prospect__r.ConvertedAccount.Name,DRL_Prospect__r.ConvertedAccountId'+
                                        ',DRL_Prospect__r.ConvertedContactId,DRL_Prospect__r.ConvertedContact.LastName,DRL_Prospect__r.ConvertedContact.FirstName'+
                                        ',ConvertedAccount.Name'+
                                        ',ConvertedContact.LastName,ConvertedContact.FirstName'+
                                        ' FROM Lead WHERE Id =:strrecordId');
        if(objRespone.objLead.RecordType.DeveloperName=='DRL_Lead') {
            if (
            (objRespone.objLead.DRL_Prospect__c!=null) && 
            (objRespone.objLead.DRL_Prospect__r.IsConverted)
            ){
                objRespone.blnisParentProspectConverted=true;            
                objRespone.objparentProspectAccount=new Account(
                    Id=objRespone.objLead.DRL_Prospect__r.ConvertedAccountId,
                    Name=objRespone.objLead.DRL_Prospect__r.ConvertedAccount.Name                   
                );  
                objRespone.objparentProspectContact=new Contact(
                    Id=objRespone.objLead.DRL_Prospect__r.ConvertedContactId,
                    FirstName=objRespone.objLead.DRL_Prospect__r.ConvertedContact.FirstName,
                    LastName=objRespone.objLead.DRL_Prospect__r.ConvertedContact.LastName
                );  
            }
            else{
                objRespone.blnisParentProspectConverted=false;
            }        
        }        
        else if(objRespone.objLead.RecordType.DeveloperName=='DRL_Prospect'){
            if(objRespone.objLead.IsConverted==true){
                objRespone.blnisParentProspectConverted=true;            
                objRespone.objparentProspectAccount=new Account(
                    Id=objRespone.objLead.ConvertedAccountId,
                    Name=objRespone.objLead.ConvertedAccount.Name                   
                );  
                objRespone.objparentProspectContact=new Contact(
                    Id=objRespone.objLead.ConvertedContactId,
                    FirstName=objRespone.objLead.ConvertedContact.FirstName,
                    LastName=objRespone.objLead.ConvertedContact.LastName
                );                  
            }
            objRespone.listProspectChildLeads=getChildLeads(strrecordId);
            objRespone.strchildLeadTableColumns=getDataTableColumns('Lead','DRL_convertLeadProspectChildLeads');
        }
        objRespone.stropportunityMasterFieldSet=DRLUtil.getFieldSet('Opportunity','DRL_ConvertToLeadMaster');
        objRespone.strAccountMasterFieldSet = DRLUtil.getFieldSet('Account','LeadConvertFields');
        objRespone.strContactMasterFieldSet = DRLUtil.getFieldSet('Contact','ConvertLeadContact');
        objRespone.map_opportunityDisableFieldSets=getOpportunityDisableFieldSets();
        objRespone.list_LeadConvertOpportunityFormControllers=getOpportunityStageFieldsetDisableMap();
        objRespone.map_opportunityRecordTypes=DRLUtil.getRecordTypeIdToNameMap('Opportunity');
        for (Id key : objRespone.map_opportunityRecordTypes.keySet()) {
            if(objRespone.map_opportunityRecordTypes.get(key)!='API'&&objRespone.map_opportunityRecordTypes.get(key)!='API +'){
                objRespone.map_opportunityRecordTypes.remove(key);
            }
        }                
        return objRespone;
    }

     /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used convert lead to account,contact and opportunity
    * @ params       :  strleadRecordId         - Lead recordId 
                        objaccount              - Account record
                        objcontact              - Contact record
                        objopportunity          - Opportunity record
                        list_leadOpportunities  - list of Opportunity records
                        list_leads              - list of Lead records
    * @ return       :  Returns ConvertLeadDataWrapper object
    **/

    @AuraEnabled
    public static ConvertLeadDataWrapper convertLead(String strleadRecordId, Account objaccount, Contact objcontact, Opportunity objopportunity, List<Opportunity> list_leadOpportunities,List<Lead> list_leads){
        System.savepoint save = database.setSavepoint();

        ConvertLeadDataWrapper objresponse = new ConvertLeadDataWrapper();
        try{
            Lead objlead = [SELECT 
                            Id,
                            Status, 
                            IsConverted,
                            Product_Lookup__c, 
                            pi__campaign__c, 
                            Source_Campaign_Id__c,
                            CPR__c,
                            Target_Region__c,
                            Reporting_Region__c,
                            RecordType.DeveloperName
                            FROM Lead
                            WHERE Id = :strleadRecordId];

            //set account information
            if (objaccount.Id == Null){
                objaccount.Lead_Converted_From__c = objlead.Id;
                try{
                    upsert objaccount;
                } catch (Exception ex){
                    database.rollback(save);
                    objresponse.strstatus = 'Duplicate Account';
                    return objresponse;
                }
            }

            //set contact information
            if (objcontact.Id == null){
                objcontact.AccountId = objaccount.Id;
                objcontact.Lead_Converted_From__c = objlead.Id;
                try{
                    upsert objcontact;
                } catch (Exception ex){
                    database.rollback(save);
                    objresponse.strstatus = 'Duplicate';
                    return objresponse;
                }
            }
            if(objlead.RecordType.DeveloperName=='DRL_Prospect'){
                LeadStatus convertStatus = [SELECT Id, MasterLabel, IsConverted
                                            FROM LeadStatus
                                            WHERE IsConverted = true
                                            limit 1]; 
                List<Database.LeadConvert> list_leadsToconvert=new List<Database.LeadConvert>();   
                if(!objlead.IsConverted){
                    objlead.Converted_Account__c = objaccount.Id;
                    objlead.Converted_Contact__c = objcontact.Id;
                    objlead.Status = 'Converted';
                    update objlead;                                     
                    Database.LeadConvert objLeadConvert=convertLeadHelper(objlead, objaccount.Id, objcontact.Id, null,convertStatus.MasterLabel);                
                    list_leadsToconvert.add(objLeadConvert);
                }
                if(list_leadOpportunities.size()>0){
                    list_leadsToconvert.addAll(convertChildLeads(objaccount.Id,objcontact.Id,list_leadOpportunities,list_leads,convertStatus.MasterLabel));                   
                }
                List<Database.LeadConvertResult> list_leadConvertResults = Database.convertLead(list_leadsToconvert);
                objresponse.objaccount= objaccount;
                objresponse.objcontact= objcontact;
                if(list_leadOpportunities.size()>0){
                    objresponse.list_opportunities=Database.query('select'+getQueryFields('Opportunity','DRL_convertLeadSuccessScreenList')+'from Opportunity where Id in:list_leadOpportunities');
                }
                
                objresponse.strstatus = 'Success';
            }
            else{
                objopportunity=setOpportunityDetails(objopportunity,objaccount.Id,objcontact.Id,objlead);
                upsert objopportunity;

                objlead.Converted_Account__c = objaccount.Id;
                objlead.Converted_Contact__c = objcontact.Id;
                objlead.Converted_Opportunity__c = objopportunity.Id;
                objlead.Status = 'Converted';
                update objlead;

                LeadStatus convertStatus = [SELECT Id, MasterLabel, IsConverted
                                            FROM LeadStatus
                                            WHERE IsConverted = true
                                            limit 1];
                
                Database.LeadConvert objLeadConvert=convertLeadHelper(objlead, objaccount.Id, objcontact.Id, objopportunity.Id,convertStatus.MasterLabel);                
                Database.LeadConvertResult list_leadConvertResult = Database.convertLead(objLeadConvert);
                objresponse.objaccount= objaccount;
                objresponse.objcontact= objcontact;
                objresponse.objopportunity= objopportunity;
                objresponse.strstatus = 'Success';
            }
        } Catch (Exception ex){
            database.rollback(save);
            objresponse.strmessage = ex.getMessage();
            objresponse.strstatus = 'Fail';
            return objresponse;         
        }
        return objresponse;
    }
    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to set populate opportunity details before comversion
    * @ params       :  straccountId - AccountId
                        strcontactId - Contact Id
                        list_leadOpportunities - list of opportunities
                        list_leads - list of leads
    * @ return       :  returns list of Database.LeadConvert records to convert
    **/
    public static List<Database.LeadConvert> convertChildLeads(String straccountId,String strcontactId,List<Opportunity> list_leadOpportunities,List<Lead> list_leads,String strmasterLabel) {

        Map<Id,Lead> map_leadIdToLeadRecord=new Map<Id,Lead>();
        Map<Id,Opportunity> map_opportunityIdToOpportunityRecord=new Map<Id,Opportunity>();
        List<Database.LeadConvert> list_childLeadConvertRecords=new List<Database.LeadConvert>();
        for(Lead objlead:list_leads){
            map_leadIdToLeadRecord.put(objLead.Id, objLead);
        }
        for(Opportunity objopportunity:list_leadOpportunities){
            objopportunity=setOpportunityDetails(objopportunity,straccountId,strcontactId,map_leadIdToLeadRecord.get(objopportunity.Lead_Converted_From__c));
            map_opportunityIdToOpportunityRecord.put(objopportunity.Lead_Converted_From__c,objopportunity);
        }
        insert list_leadOpportunities;
        for(Lead objlead:list_leads){
            objlead.Converted_Account__c = straccountId;
            objlead.Converted_Contact__c = strcontactId;
            objlead.Converted_Opportunity__c =map_opportunityIdToOpportunityRecord.get(objLead.Id).Id;
            objlead.Status = 'Converted';
            list_childLeadConvertRecords.add(convertLeadHelper(objlead, straccountId, strcontactId, objlead.Converted_Opportunity__c,strmasterLabel));
        }
        update list_leads;
        
        return list_childLeadConvertRecords;
    }
    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to set populate opportunity details before comversion
    * @ params       :  None
    * @ return       :  returns populated opportunity
    **/
    public static Database.LeadConvert convertLeadHelper(Lead objLead, String strAccountId, String strContactId, String stropportunityId,String strMasterLabel) {
        Database.LeadConvert objLeadConvert = new Database.LeadConvert();
        System.debug('objLead.Id'+objLead.Id);
        System.debug('strAccountId'+strAccountId);
        System.debug('strContactId'+strContactId);
        System.debug('stropportunityId'+stropportunityId);
        objLeadConvert.setLeadId(objLead.Id);
        objLeadConvert.setAccountId(strAccountId);
        objLeadConvert.setContactId(strContactId);
        if(stropportunityId!=null){
            objLeadConvert.setOpportunityId(stropportunityId);        
        } 
        else{
            objLeadConvert.setDoNotCreateOpportunity(true);
        }       
        objLeadConvert.setConvertedStatus(strMasterLabel);
        return objLeadConvert;        
    }
    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to set populate opportunity details before comversion
    * @ params       :  None
    * @ return       :  returns populated opportunity
    **/
    public static Opportunity setOpportunityDetails(Opportunity objopportunity,String straccountId,String strcontactId,Lead objlead) {
        objopportunity.AccountId = straccountId;
        objopportunity.Contact__c = strcontactId;
        objopportunity.Lead_Converted_to_Opp__c = 'Yes';
        if(objlead.CPR__c != null){
            objopportunity.CPR__c = objlead.CPR__c;
        }
        if(objlead.Target_Region__c != null){
            objopportunity.Target_Region__c = objlead.Target_Region__c;
        }
        if(objlead.Reporting_Region__c != null){
            objopportunity.Reporting_Region__c = objlead.Reporting_Region__c;
        }
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API Plus').getRecordTypeId();
        if (objopportunity.RecordTypeId != recordTypeId){
            objopportunity.Product__c = objlead.Product_Lookup__c;
        }        
        Boolean stageBelowDevelopment = objopportunity.StageName == 'Lead Generation' || objopportunity.StageName == 'Sample' || objopportunity.StageName == 'Discussion';
        objopportunity.Lead_Converted_From__c = objlead.Id;
        objopportunity.Converted_Contact__c = strcontactId;
        objopportunity.Trigger_Content__c = stageBelowDevelopment ? 'Yes' : 'No';
        
        return objopportunity;        
    }


    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to get the fields to disable for the opportunity section of Lead Convert Component
    * @ params       :  None
    * @ return       :  Returns JSON string of Opportunity fieldsets with api name starting with 'DRL_FieldsToDisableSet'.
    **/
    public static Map<String,String>  getOpportunityDisableFieldSets() {
        Map<String,String> map_disableFieldSets=new Map<String,String>();
        Map<String, Schema.FieldSet> map_opportunityFieldSets = Schema.SObjectType.opportunity.fieldSets.getMap();
        for (String strFieldSetName : map_opportunityFieldSets.keySet()) {
            if(strFieldSetName.startsWithIgnoreCase('DRL_FieldsToDisableSet')){
                map_disableFieldSets.put(strFieldSetName,DRLUtil.getFieldSet('Opportunity',strFieldSetName));
            }            
        }
        return map_disableFieldSets;
    }

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to get the fields to disable for the opportunity section of Lead Convert Component
    * @ params       :  None
    * @ return       :  Returns List of LeadConvertFormController metadata records.
    **/
    public static List<DRL_LeadConvertFormController__mdt >  getOpportunityStageFieldsetDisableMap() {
        return [select 
                Label,
                Field_Set_Api_Name__c 
                from DRL_LeadConvertFormController__mdt ];
    }
    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to get child Leads of Prospect Record
    * @ params       :  prospectId : Prospect RecordId
    * @ return       :  Returns List of Lead records.
    **/
    public static List<Lead> getChildLeads(String prospectId) {
        return [select 
                Id,
                Name,
                Product_Lookup__c,
                Product_Lookup__r.Name,
                Company,
                Status,
                OwnerId,
                Owner.Name 
                from Lead 
                where DRL_Prospect__c=:prospectId 
                AND IsConverted=false
                AND recordType.Developername='DRL_Lead'];        
    }

     /**
    * @ author       :  Subhodeep Sarkar
    * @ description  :  This method is used to retrieve selected account records
    * @ params       :  straccountId - AccountId
    * @ return       :  returns Account
    **/
    
    @AuraEnabled
    public static Account getAccount(String straccountId){
        Account objAccount = new Account();
        objAccount = straccountId != null ? Database.query('SELECT ' + DRLUtil.getsObjectFieds('Account') + 'FROM Account WHERE Id =:straccountId') : null;
        return objAccount;
    }

    /**
    * @ author       :  Subhodeep Sarkar
    * @ description  :  This method is used to retrieve selected contact records
    * @ params       :  strcontactId - Contact Id
    * @ return       :  returns Contact
    **/
    
    @AuraEnabled
    public static Contact getContact(String strcontactId){
        Contact objContact = new Contact();
        objContact = strcontactId != null ? Database.query('SELECT ' + DRLUtil.getsObjectFieds('Contact') + 'FROM Contact WHERE Id =:strcontactId') : null;
        return objContact;
    }

    /**
    * @ author       :  Subhodeep Sarkar
    * @ description  :  This method is used to retrieve all records with same email
    * @ params       :  strmail - email
    * @ return       :  returns List of Contact records with same name
    **/
    
    @AuraEnabled
    public static Boolean checkEmail(String strmail){
        
        List<Contact> list_contact = new List<Contact>();
        list_contact = strmail != null ? Database.query('SELECT ' + DRLUtil.getsObjectFieds('Contact') + 'FROM Contact WHERE email =:strmail') : list_contact ;
        if(list_contact.size()>0){
            return true;
            
        }
        else{
            return false;
        }
    }
        /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to get Datatable Columns
    * @ params       :  strSObjectName - Object Name
    *                   strFieldSetName - FieldSet Name
    * @ return       :  Returns String of datatable Columns datastructure
    **/
    @AuraEnabled
    public static String getDataTableColumns(String strSObjectName,String strFieldSetName) {
        String strColumns='';
        SObjectType objToken = Schema.getGlobalDescribe().get(strSObjectName);
        Schema.DescribeSObjectResult objDescribe = objToken.getDescribe();
        Map<String, Schema.FieldSet> map_fieldSetNameToFieldSet = objDescribe.fieldSets.getMap();
        if(map_fieldSetNameToFieldSet.containsKey(strFieldSetName)){
            for(Schema.FieldSetMember objField : map_fieldSetNameToFieldSet.get(strFieldSetName).getFields()) {
                    
                if(strColumns != ''){
                    strColumns += ',';
                }
                String jsonPart = '{';
                jsonPart+='"label":"'+objField.getLabel()+'",';

                if(objField.getFieldPath()=='Id'){
                    continue;
                }
                else if(objField.getFieldPath()=='Name'){
                    jsonPart+='"fieldName":"'+strSObjectName+'Url",';
                    jsonPart+='"type":"url",';
                    jsonPart+='"typeAttributes":{';
                    jsonPart+='"label":{';
                    jsonPart+='"fieldName":"Name"';
                    jsonPart+='}},';
                    jsonPart+='"tagert":"_self"';
                }
                else if(String.valueOf(objField.getType())=='PICKLIST'){
                    jsonPart+='"fieldName":"'+objField.getFieldPath()+'",';
                    jsonPart+='"type":"Text"';
                }
                else if(String.valueOf(objField.getType())=='CURRENCY'){
                    jsonPart+='"fieldName":"'+objField.getFieldPath()+'",';
                    jsonPart+='"type":"currency",';
                    jsonPart+='"typeAttributes":{"currencyCode":"'+UserInfo.getDefaultCurrency()+'"}';
                }
                else if(String.valueOf(objField.getType())=='REFERENCE'){
                    jsonPart+='"fieldName":"'+objField.getFieldPath()+'Url",';
                    jsonPart+='"type":"url",';
                    jsonPart+='"typeAttributes":{';
                    jsonPart+='"label":{';
                    jsonPart+='"fieldName":"'+objField.getFieldPath()+'Name"';
                    jsonPart+='}},';
                    jsonPart+='"tagert":"_self"';
                }
                else{
                    jsonPart+='"fieldName":"'+objField.getFieldPath()+'",';
                    jsonPart+='"type":"Text"';
                }
                jsonPart += '}';
                strColumns += jsonPart;
            }

        }
        return '['+strColumns+']';               
    }
    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to get Query from fieldSet
    * @ params       :  strSObjectName - Object Name
    *                   strFieldSetName - FieldSet Name
    * @ return       :  Returns String of queryfields
    **/
    public static String getQueryFields(String strSObjectName,String strFieldSetName) {
        String strqueryFields=' ';
        SObjectType objToken = Schema.getGlobalDescribe().get(strSObjectName);
        Schema.DescribeSObjectResult objDescribe = objToken.getDescribe();
        Map<String, Schema.FieldSet> map_fieldSetNameToFieldSet = objDescribe.fieldSets.getMap();
        if(map_fieldSetNameToFieldSet.containsKey(strFieldSetName)){
            for(Schema.FieldSetMember objField : map_fieldSetNameToFieldSet.get(strFieldSetName).getFields()) {
                if(strqueryFields!=' '){
                    strqueryFields+=',';
                }
                if(String.valueOf(objField.getType())=='CURRENCY'){
                    strqueryFields+='convertCurrency('+objField.getFieldPath()+')';
                }
                else if(String.valueOf(objField.getType())=='REFERENCE'){
                    if(objField.getFieldPath().endsWith('__c')){
                        strqueryFields+=objField.getFieldPath()+','+objField.getFieldPath().left(objField.getFieldPath().length()-1)+'r.Name';
                    }
                    else{
                        strqueryFields+=objField.getFieldPath()+','+objField.getFieldPath().left(objField.getFieldPath().length()-2)+'.Name';
                    }                    
                }
                else{
                    strqueryFields+=objField.getFieldPath();
                }
            }
        }
        strqueryFields+=' ';
        return strqueryFields;
    }

    public class ConvertLeadDataWrapper{
        @AuraEnabled
        public string strstatus{get; set; }
        @AuraEnabled
        public Lead objLead {get;set;}
        @AuraEnabled
        public List<Lead> listProspectChildLeads{ get; set; }
        @AuraEnabled
        public String strAccountMasterFieldSet{ get; set; }
        @AuraEnabled
        public String strContactMasterFieldSet{ get; set; }
        @AuraEnabled
        public String stropportunityMasterFieldSet{ get; set; }
        @AuraEnabled
        public Map<String,String> map_opportunityDisableFieldSets{ get; set; }
        @AuraEnabled
        public List<DRL_LeadConvertFormController__mdt> list_LeadConvertOpportunityFormControllers{ get; set; }
        @AuraEnabled
        public Map<Id,String> map_opportunityRecordTypes{ get; set; }
        @AuraEnabled
        public Boolean blnisParentProspectConverted{get; set; }
        @AuraEnabled
        public Account objparentProspectAccount{get; set; }
        @AuraEnabled
        public Contact objparentProspectContact{get; set; }        
        @AuraEnabled
        public String strmessage{get; set; }
        @AuraEnabled
        public Account objaccount {get;set;}
        @AuraEnabled
        public Contact objcontact {get;set;}
        @AuraEnabled
        public Opportunity objopportunity {get;set;}
        @AuraEnabled
        public List<Opportunity> list_opportunities {get;set;}
        @AuraEnabled
        public String strchildLeadTableColumns{get;set;}
    } 

    
}