/*******************************************************************************************************
* 
* @ Name            :   DRL_ConvertLeadProspectController
* @ Purpose         :   controller class for component DRL_ConvertLeadProspect
* @ Author          :   Kishore Pedireddy
* @ Usage           :   1) retrieve lead record details on load
                        2) convert lead to account,contact,opportunities
* @ Test Class Name :   DRL_ConvertLeadProspectTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*  10-11-2022       |  Kishore Pedireddy            |     1.0       |  Initial Version
*  12-11-2022       |  Subhodeep Sarkar             |     2.0       |  Email, account and contact section changes

*******************************************************************************************************/
public with sharing class DRL_ConvertLeadProspectController {
    public static System.savepoint save;

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to get the lead and component configuration details in DRL_ConvertLeadProspect component
    * @ params       :  strrecordId - lead recordId 
    * @ return       :  Returns ConvertLeadDataWrapper object 
    **/

    @AuraEnabled
    public static ConvertLeadDataWrapper getLeadDetails(String strrecordId){
        try{
            ConvertLeadDataWrapper objRespone=new ConvertLeadDataWrapper();
            objRespone.objLead=Database.query('SELECT ' + DRLUtil.getsObjectFieds('Lead') + 
                                            ',RecordType.DeveloperName,DRL_Prospect__r.IsConverted'+
                                            ',DRL_Prospect__r.ConvertedAccount.Name,DRL_Prospect__r.ConvertedAccountId'+
                                            ',DRL_Prospect__r.ConvertedContactId,DRL_Prospect__r.ConvertedContact.LastName,DRL_Prospect__r.ConvertedContact.FirstName'+
                                            ',ConvertedAccount.Name'+
                                            ',ConvertedContact.LastName,ConvertedContact.FirstName'+
                                            ' FROM Lead WHERE Id =:strrecordId');
            if(objRespone.objLead.RecordType.DeveloperName == 'DRL_Lead') {
                if (
                (objRespone.objLead.DRL_Prospect__c != null) && 
                (objRespone.objLead.DRL_Prospect__r.IsConverted)
                ){
                    objRespone.blnisParentProspectConverted = true;            
                    objRespone.objparentProspectAccount = new Account(
                        Id=objRespone.objLead.DRL_Prospect__r.ConvertedAccountId,
                        Name=objRespone.objLead.DRL_Prospect__r.ConvertedAccount.Name                   
                    );  
                    objRespone.objparentProspectContact = new Contact(
                        Id=objRespone.objLead.DRL_Prospect__r.ConvertedContactId,
                        FirstName=objRespone.objLead.DRL_Prospect__r.ConvertedContact.FirstName,
                        LastName=objRespone.objLead.DRL_Prospect__r.ConvertedContact.LastName,
                        AccountId= objRespone.objLead.DRL_Prospect__r.ConvertedAccountId
                    );  
                }
                else{
                    objRespone.blnisParentProspectConverted = false;
                }  
                if (objRespone.objLead.Product_Lookup__c != null && objRespone.objLead.Cluster__c != null){
                    objRespone=getContentCatalogDetails(objRespone);
                }
            }        
            else if(objRespone.objLead.RecordType.DeveloperName == 'DRL_Prospect'){
                if(objRespone.objLead.IsConverted == true){
                    objRespone.blnisParentProspectConverted = true;            
                    objRespone.objparentProspectAccount = new Account(
                        Id = objRespone.objLead.ConvertedAccountId,
                        Name = objRespone.objLead.ConvertedAccount.Name                   
                    );  
                    objRespone.objparentProspectContact = new Contact(
                        Id = objRespone.objLead.ConvertedContactId,
                        FirstName = objRespone.objLead.ConvertedContact.FirstName,
                        LastName = objRespone.objLead.ConvertedContact.LastName,
                        AccountId= objRespone.objLead.ConvertedAccountId
                    );                  
                }
                objRespone.listProspectChildLeads=getChildLeads(strrecordId);
                if(objRespone.listProspectChildLeads.size()>0){
                    objRespone = getChildLeadContentCatalogDetails(objRespone);
                }
                objRespone.strchildLeadTableColumns = getDataTableColumns('Lead','DRL_convertLeadProspectChildLeads');
            }
            objRespone.stropportunityMasterFieldSet = DRLUtil.getFieldSet('Opportunity','DRL_ConvertToLeadMaster');
            objRespone.strAccountMasterFieldSet = DRLUtil.getFieldSet('Account','LeadConvertFields');
            objRespone.strContactMasterFieldSet = DRLUtil.getFieldSet('Contact','ConvertLeadContact');
            objRespone.map_opportunityDisableFieldSets = getOpportunityDisableFieldSets();
            objRespone.list_LeadConvertOpportunityFormControllers = getOpportunityStageFieldsetDisableMap();
            objRespone.map_opportunityRecordTypes = DRLUtil.getRecordTypeIdToNameMap('Opportunity');
            for (Id key : objRespone.map_opportunityRecordTypes.keySet()) {
                if(objRespone.map_opportunityRecordTypes.get(key) != 'API' && objRespone.map_opportunityRecordTypes.get(key) != 'API +'){
                    objRespone.map_opportunityRecordTypes.remove(key);
                }
            }                
            return objRespone;
        } catch(Exception objException) {
            DRLUtil.logException(
                'DRL_ConvertLeadProspectController',
                'getLeadDetails',
                objException,
                true
            );
            throw objException;
        }
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
                        list_contentCatalogs    - list of ContentCatalog records
                        strrunAfter             - String value for Run_Automation_After__c field on Opportunity
                        map_listContentCatalogs - map of Lead Id to list of ContentCatalog records
                        map_strrunAfter         - map of Lead Id to String value for Run_Automation_After__c field on Opportunity
    * @ return       :  Returns ConvertLeadDataWrapper object
    **/
    
    @AuraEnabled
    public static ConvertLeadDataWrapper convertLead(String strleadRecordId, 
                                                     Account objaccount, 
                                                     Contact objcontact, 
                                                     Opportunity objopportunity, 
                                                     List<Opportunity> list_leadOpportunities,
                                                     List<Lead> list_leads,
                                                     List<ContentCatalog> list_contentCatalogs, 
                                                     String strrunAfter,
                                                     Map< String,List<ContentCatalog> > map_listContentCatalogs,
                                                     Map<String,String> map_strrunAfter){
        save = database.setSavepoint();
        //List of all the Errors occurred during DML operation
        List<String> list_ConsolidatedDMLErrors = new List<String>();

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
                            RecordType.DeveloperName,
                            DRL_Prospect__r.IsConverted,
                            DRL_Prospect__c
                            FROM Lead
                            WHERE Id = :strleadRecordId];

            //set account information
            if (objaccount.Id == Null){
                objaccount.Lead_Converted_From__c = objlead.Id;
                objaccount.Is_Parent__c = true;
                List<Database.SaveResult> list_Results = new List<Database.SaveResult>();
                list_Results.add(Database.insert(objaccount, false));
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_Results, 'Insert'));
                if (!list_ConsolidatedDMLErrors.isEmpty()) {
                    DRLUtil.logDMLException('DRL_ConvertLeadProspectController', 'convertLead', list_ConsolidatedDMLErrors);
                    database.rollback(save);
                    objresponse.strstatus = 'Fail';
                    objresponse.strmessage = getErroMessage(list_Results[0].getErrors()[0],'Account','Insertion');
                    return objresponse;                                     
                } 
            }

            //set contact information
            if (objcontact.Id == null || objcontact.AccountId == null){
                objcontact.AccountId = objaccount.Id;
                objcontact.Lead_Converted_From__c = objlead.Id;
                Database.UpsertResult objResult= Database.upsert(objcontact, false);
                List<String> list_Errors = new List<String>();
                for (Database.Error objError : objResult.getErrors()) {
                    String strErrorMessage = 'Upsert failed for ' +objResult.getId() + 
                                             '. Error: ' + objError.getMessage() + 
                                             '. Status Code: ' + objError.getStatusCode();
                    list_Errors.add(strErrorMessage);                    
                }
                if (!list_Errors.isEmpty()) {
                    DRLUtil.logDMLException('DRL_ConvertLeadProspectController', 'convertLead', list_Errors);
                    database.rollback(save);
                    objresponse.strstatus = 'Fail';
                    objresponse.strmessage = getErroMessage(objResult.getErrors()[0],'Contact','Upsert');
                    return objresponse;
                } 
            }
            if(objlead.RecordType.DeveloperName == 'DRL_Prospect'){
                LeadStatus convertStatus = [SELECT Id, MasterLabel, IsConverted
                                            FROM LeadStatus
                                            WHERE IsConverted = true
                                            limit 1]; 
                List<Database.LeadConvert> list_leadsToconvert = new List<Database.LeadConvert>();   
                if(!objlead.IsConverted){
                    objlead.Converted_Account__c = objaccount.Id;
                    objlead.Converted_Contact__c = objcontact.Id;
                    objlead.Status = 'Converted';
                    List<Database.SaveResult> list_Results=new List<Database.SaveResult>();
                    list_Results.add(Database.update(objlead, false));
                    list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_Results, 'Update'));
                    if (!list_ConsolidatedDMLErrors.isEmpty()) {
                        DRLUtil.logDMLException('DRL_ConvertLeadProspectController', 'convertLead', list_ConsolidatedDMLErrors);
                        database.rollback(save);
                        throw new CustomDMLException(getErroMessage(list_Results[0].getErrors()[0],'Lead','Updation'));
                    }                                    
                    Database.LeadConvert objLeadConvert =  convertLeadHelper(objlead, objaccount.Id, objcontact.Id, null,convertStatus.MasterLabel);                
                    list_leadsToconvert.add(objLeadConvert);
                }
                if(list_leadOpportunities!=null && list_leadOpportunities.size()>0){
                    list_leadsToconvert.addAll(convertChildLeads(objaccount.Id,
                                                                objcontact.Id,
                                                                list_leadOpportunities,
                                                                list_leads,
                                                                convertStatus.MasterLabel,
                                                                map_listContentCatalogs,
                                                                map_strrunAfter));                   
                }
                List<Database.LeadConvertResult> list_leadConvertResults = Database.convertLead(list_leadsToconvert);
                Set<Id> set_OpportunitiesToUpdate = new Set<Id>();
                for (Opportunity objChildleadOpportunity : list_leadOpportunities) {
                    set_OpportunitiesToUpdate.add(objChildleadOpportunity.Id) ;                                  
                }

                if (!set_OpportunitiesToUpdate.isEmpty()) {
                    updateContactOnOpportunity(JSON.serialize(set_OpportunitiesToUpdate), objcontact.Id, true);
                }

                objresponse.objaccount = objaccount;
                objresponse.objcontact = objcontact;
                if(list_leadOpportunities!=null && list_leadOpportunities.size() > 0){
                    objresponse.list_opportunities = Database.query('select'+getQueryFields('Opportunity','DRL_convertLeadSuccessScreenList') + 'from Opportunity where Id in:list_leadOpportunities');
                }
                
                objresponse.strstatus = 'Success';
            } else {
                String strContentIds = getOrderedContents(list_contentCatalogs);
                Boolean blnIsContactUpdateRequired = (objopportunity.Id == null || objopportunity.Contact__c == null);
                objopportunity = setOpportunityDetails(objopportunity,objaccount.Id,objcontact.Id,objlead,strContentIds,strrunAfter); 
                DRL_OpportunityTriggerHelper.blnSkipOpportunityTrigger = true;               
                List<Database.UpsertResult> list_UpsertResult=new List<Database.UpsertResult >();
                DRL_OpportunityTriggerHelper.blnSkipOpportunityTrigger = false; 
                list_UpsertResult.add(Database.upsert(objopportunity, false));
                List<String> list_Errors = new List<String>();
                for (Database.UpsertResult ObjUpsertResult : list_UpsertResult) {
                    if (!ObjUpsertResult.isSuccess()) {
                        for (Database.Error objError : ObjUpsertResult.getErrors()) {
                            String strErrorMessage = 'Upsert failed for ' + 
                                ObjUpsertResult.getId() + '. Error: ' + objError.getMessage() + 
                                '. Status Code: ' + objError.getStatusCode();
                            list_Errors.add(strErrorMessage);
                        }
                    }                    
                }
                list_ConsolidatedDMLErrors.addAll(list_Errors);
                if (!list_ConsolidatedDMLErrors.isEmpty()) {
                    DRLUtil.logDMLException('DRL_ConvertLeadProspectController', 'convertLead', list_ConsolidatedDMLErrors);
                    database.rollback(save);
                    throw new CustomDMLException(getErroMessage(list_UpsertResult[0].getErrors()[0],'Opportunity','Upsertion'));
                } 
                List<Lead> list_leadsToUpdate = new List<Lead>();
                List<Database.LeadConvert> list_LeadsToConvert = new List<Database.LeadConvert>();
                LeadStatus convertStatus = [SELECT Id, MasterLabel, IsConverted
                                            FROM LeadStatus
                                            WHERE IsConverted = true
                                            limit 1];

                if ( 
                    objlead.RecordType.DeveloperName == 'DRL_Lead' && 
                    objlead.DRL_Prospect__c !=null && 
                    !objlead.DRL_Prospect__r.IsConverted
                    ){
                        Lead objProspect=new Lead(Id=objlead.DRL_Prospect__c);
                        objProspect.Converted_Account__c = objaccount.Id;
                        objProspect.Converted_Contact__c = objcontact.Id;
                        objProspect.Status = 'Converted';
                        list_leadsToUpdate.add(objProspect);
                        list_LeadsToConvert.add(convertLeadHelper(objProspect, objaccount.Id, objcontact.Id, null,convertStatus.MasterLabel));
                    }                     

                objlead.Converted_Account__c = objaccount.Id;
                objlead.Converted_Contact__c = objcontact.Id;
                objlead.Converted_Opportunity__c = objopportunity.Id;
                objlead.Status = 'Converted';
                list_leadsToUpdate.add(objlead);
                List<Database.SaveResult> list_Results=new List<Database.SaveResult>();
                list_Results.addAll(Database.update(list_leadsToUpdate, false));
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_Results, 'Update'));
                if (!list_ConsolidatedDMLErrors.isEmpty()) {
                    DRLUtil.logDMLException('DRL_ConvertLeadProspectController', 'convertLead', list_ConsolidatedDMLErrors);
                    database.rollback(save);
                    for(Database.SaveResult objSaveResult:list_Results){
                        if(objSaveResult.getErrors().size()>0){
                            if(objlead.DRL_Prospect__c != null && objSaveResult.getId() == objlead.DRL_Prospect__c){
                                throw new CustomDMLException(getErroMessage(objSaveResult.getErrors()[0],'Parent Prospect','Updation'));
                            } else{
                                throw new CustomDMLException(getErroMessage(objSaveResult.getErrors()[0],'Lead','Updation'));
                            }                            
                        }
                    } 
                }                
                
                list_LeadsToConvert.add(convertLeadHelper(objlead, objaccount.Id, objcontact.Id, objopportunity.Id,convertStatus.MasterLabel));                
                DRL_OpportunityContactRoleTriggerHelper.blnSkipOpportunityContactRoleTrigger = true;
                List<Database.LeadConvertResult> list_leadConvertResult = Database.convertLead(list_LeadsToConvert);
                DRL_OpportunityContactRoleTriggerHelper.blnSkipOpportunityContactRoleTrigger = false;
                if (blnIsContactUpdateRequired) {
                    updateContactOnOpportunity(objopportunity.Id, objcontact.Id, false);
                } 

                objresponse.objaccount = objaccount;
                objresponse.objcontact = objcontact;
                objresponse.objopportunity = objopportunity;                              
                objresponse.strstatus = 'Success';
            }
            objresponse.map_successFieldsToShow = getResultFieldInformation();  
            objresponse = getResultRecords(objresponse);
        } Catch (CustomDMLException objException){
            database.rollback(save);
            objresponse.strmessage = objException.getMessage();
            objresponse.strstatus = 'Fail';
            DRLUtil.logException(
                'DRL_ConvertLeadProspectController',
                'convertLead',
                objException,
                true
            );
            return objresponse;         
        } Catch (Exception objException){
            database.rollback(save);
            objresponse.strmessage = objException.getMessage();
            objresponse.strstatus = 'Fail';
            DRLUtil.logException(
                'DRL_ConvertLeadProspectController',
                'convertLead',
                objException,
                true
            );
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
                        strmasterLabel - Converted Lead Status(String)
                        map_listContentCatalogs - map of Lead Id to list of ContentCatalog records
                        map_strrunAfter - map of Lead Id to String value for Run_Automation_After__c field on Opportunity
    * @ return       :  returns list of Database.LeadConvert records to convert
    **/
    public static List<Database.LeadConvert> convertChildLeads(String straccountId,
                                                               String strcontactId,
                                                               List<Opportunity> list_leadOpportunities,
                                                               List<Lead> list_leads,
                                                               String strmasterLabel,
                                                               Map< String,List<ContentCatalog> > map_listContentCatalogs,
                                                               Map<String,String> map_strrunAfter) {        
            //List of all the Errors occurred during DML operation
            List<String> list_ConsolidatedDMLErrors = new List<String>();
            Map<Id,Lead> map_leadIdToLeadRecord=new Map<Id,Lead>();
            Map<Id,Opportunity> map_opportunityIdToOpportunityRecord = new Map<Id,Opportunity>();
            List<Database.LeadConvert> list_childLeadConvertRecords = new List<Database.LeadConvert>();
            for(Lead objlead:list_leads){
                map_leadIdToLeadRecord.put(objLead.Id, objLead);
            }
            for(Opportunity objopportunity:list_leadOpportunities){
                objopportunity=setOpportunityDetails(objopportunity,
                                                    straccountId,
                                                    strcontactId,
                                                    map_leadIdToLeadRecord.get(objopportunity.Lead_Converted_From__c),
                                                    getOrderedContents(map_listContentCatalogs.get(objopportunity.Lead_Converted_From__c)),
                                                    map_strrunAfter.get(objopportunity.Lead_Converted_From__c));
                map_opportunityIdToOpportunityRecord.put(objopportunity.Lead_Converted_From__c,objopportunity);
            }
            List<Database.SaveResult> list_Results = Database.insert(list_leadOpportunities, false);
            list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_Results, 'Insert'));
            if (!list_ConsolidatedDMLErrors.isEmpty()) {
                DRLUtil.logDMLException('DRL_ConvertLeadProspectController', 'convertChildLeads', list_ConsolidatedDMLErrors);
                database.rollback(save);
                for(Database.SaveResult objSaveResult:list_Results){
                    if(objSaveResult.getErrors().size()>0){
                        throw new CustomDMLException(getErroMessage(objSaveResult.getErrors()[0],'Opportunity','Insertion'));
                    }
                }                
            } 
            for(Lead objlead:list_leads){
                objlead.Converted_Account__c = straccountId;
                objlead.Converted_Contact__c = strcontactId;
                objlead.Converted_Opportunity__c = map_opportunityIdToOpportunityRecord.get(objLead.Id).Id;
                objlead.Status = 'Converted';
                list_childLeadConvertRecords.add(convertLeadHelper(objlead, straccountId, strcontactId, objlead.Converted_Opportunity__c,strmasterLabel));
            }
            
            list_Results = Database.update(list_leads, false);
            list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_Results, 'Update'));
            if (!list_ConsolidatedDMLErrors.isEmpty()) {
                DRLUtil.logDMLException('DRL_ConvertLeadProspectController', 'convertChildLeads', list_ConsolidatedDMLErrors);
                database.rollback(save);
                for(Database.SaveResult objSaveResult:list_Results){
                    if(objSaveResult.getErrors().size()>0){
                        throw new CustomDMLException(getErroMessage(objSaveResult.getErrors()[0],'Lead','Updation'));
                    }
                }  
            } 
            
            return list_childLeadConvertRecords;
    }
    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to set populate opportunity details before comversion
    * @ params       :  objLead          : Lead Record
                        strAccountId     : Account Id 
                        strContactId     : Contact Id
                        stropportunityId : Opportunity Id
                        strMasterLabel   : Converted Lead Status(String)
    * @ return       :  returns Database.LeadConvert record 
    **/
    public static Database.LeadConvert convertLeadHelper(Lead objLead, String strAccountId, String strContactId, String stropportunityId,String strMasterLabel) {
        Database.LeadConvert objLeadConvert = new Database.LeadConvert();
        objLeadConvert.setLeadId(objLead.Id);
        objLeadConvert.setAccountId(strAccountId);
        objLeadConvert.setContactId(strContactId);
        if(stropportunityId != null){
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
    * @ description  :  This method is used to populate opportunity details before conversion
    * @ params       :  objopportunity : Opportunity 
                        straccountId   : Account Id 
                        strcontactId   : Contact Id
                        objlead        : Lead Record
                        strContentIds  : Content_Catalog__c Id's separated by ;
                        strrunAfter    : String value for Run_Automation_After__c field on Opportunity
    * @ return       :  returns populated opportunity
    **/
    public static Opportunity setOpportunityDetails( Opportunity objopportunity,
                                                     String straccountId,
                                                     String strcontactId,
                                                     Lead objlead,
                                                     String strContentIds,
                                                     String strrunAfter) {
        if(objopportunity.Id == null){
            objopportunity.AccountId = straccountId;
            objopportunity.Contact__c = null;
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
        } else if(
            objopportunity.Id != null && 
            objopportunity.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API').getRecordTypeId() &&
            objopportunity.Contact__c != null && 
            objopportunity.Contact__c != strcontactId){
            List <OpportunityContactRole> list_ExistingContactRoles = [ SELECT Id 
                                                                        FROM OpportunityContactRole 
                                                                        WHERE ContactId=:strcontactId and OpportunityId =:objopportunity.Id ];
            if (list_ExistingContactRoles.isEmpty()) {
                String strDefaultSecondaryContactRole = System.Label.CLDRL00024;
                OpportunityContactRole objOpportunityContactRole = new OpportunityContactRole();
                objOpportunityContactRole.ContactId = strcontactId;
                objOpportunityContactRole.OpportunityId = objopportunity.Id;
                objOpportunityContactRole.Role = strDefaultSecondaryContactRole;
                List<Database.SaveResult> list_Results = new List<Database.SaveResult>();
                List<String> list_ConsolidatedDMLErrors = new List<String>();
                list_Results.add(Database.insert(objOpportunityContactRole, false));
                list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_Results, 'Insert'));
                if (!list_ConsolidatedDMLErrors.isEmpty()) {
                    DRLUtil.logDMLException('DRL_ConvertLeadProspectController', 'setOpportunityDetails', list_ConsolidatedDMLErrors);
                    database.rollback(save);
                    for(Database.SaveResult objSaveResult:list_Results){
                        if(objSaveResult.getErrors().size()>0){
                            throw new CustomDMLException(getErroMessage(objSaveResult.getErrors()[0],'Opportunity','Insertion'));
                        }
                    }                
                }
            }
        }               
        Boolean blnstageBelowDevelopment = (objopportunity.StageName == 'Lead Generation' || 
                                        objopportunity.StageName == 'Sample' || 
                                        objopportunity.StageName == 'Discussion');
        objopportunity.Lead_Converted_From__c = objlead.Id;
        objopportunity.Converted_Contact__c = strcontactId;
        objopportunity.Trigger_Content__c = blnstageBelowDevelopment ? 'Yes' : 'No';
        Date dt = system.today();
        if (strrunAfter == 'Immediately')
            dt = system.today();
        if (strrunAfter == 'After 15 Days')
            dt = system.today().addDays(15);
        if (strrunAfter == 'After 30 Days')
            dt = system.today().addDays(30);
        if (strrunAfter == 'After 60 Days')
            dt = system.today().addDays(60);
        
        objopportunity.Opp_Journey_Content_Ids__c = strContentIds;
        objopportunity.Run_Market_Automation_Journey_Date__c = dt;
        objopportunity.Run_Automation_After__c = strrunAfter;
        if (strrunAfter != null && strrunAfter != ''){
            objopportunity.Journey_Date__c = dt;
        }
        return objopportunity;        
    }


    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to get the fields to disable for the opportunity section of Lead Convert Component
    * @ params       :  None
    * @ return       :  Returns Map<String(FieldSetName),String(JSON fieldSet)> of Opportunity fieldsets with api name starting with 'DRL_FieldsToDisableSet'.
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
                FieldSetAPIName__c 
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
                Owner.Name,
                Cluster__c ,
                CPR__c,
                Target_Region__c,
                Reporting_Region__c
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
        try{
            Account objAccount = new Account();
            objAccount = straccountId != null ? Database.query('SELECT ' + DRLUtil.getsObjectFieds('Account') + 'FROM Account WHERE Id =:straccountId') : null;
            return objAccount;
        } catch(Exception objException) {
            DRLUtil.logException(
                'DRL_ConvertLeadProspectController',
                'getAccount',
                objException,
                true
            );
            throw objException;
        }        
    }

    /**
    * @ author       :  Subhodeep Sarkar
    * @ description  :  This method is used to retrieve selected contact records
    * @ params       :  strcontactId - Contact Id
    * @ return       :  returns Contact
    **/
    
    @AuraEnabled
    public static Contact getContact(String strcontactId){
        try{
            Contact objContact = new Contact();
            objContact = strcontactId != null ? Database.query('SELECT ' + DRLUtil.getsObjectFieds('Contact') + 'FROM Contact WHERE Id =:strcontactId') : null;
            return objContact;
        } catch(Exception objException) {
            DRLUtil.logException(
                'DRL_ConvertLeadProspectController',
                'getContact',
                objException,
                true
            );
            throw objException;
        }  
        
    }

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to retrieve selected Opportunity records
    * @ params       :  strOpportunityId - Opportunity Id
    * @ return       :  returns Opportunity
    **/
    
    @AuraEnabled
    public static Opportunity getOpportunity(String strOpportunityId){
        try{
            Opportunity objOpportunity = new Opportunity();
            objOpportunity = strOpportunityId != null ? Database.query('SELECT ' + DRLUtil.getsObjectFieds('Opportunity') + 'FROM Opportunity WHERE Id =:strOpportunityId') : null;
            return objOpportunity;
        } catch(Exception objException) {
            DRLUtil.logException(
                'DRL_ConvertLeadProspectController',
                'getOpportunity',
                objException,
                true
            );
            throw objException;
        } 
    }

    /**
    * @ author       :  Subhodeep Sarkar
    * @ description  :  This method is used to retrieve all records with same email
    * @ params       :  strmail - email
    * @ return       :  returns List of Contact records with same name
    **/
    
    @AuraEnabled
    public static Boolean checkEmail(String strmail){
        try{
            List<Contact> list_contact = new List<Contact>();
            list_contact = strmail != null ? Database.query('SELECT ' + DRLUtil.getsObjectFieds('Contact') + 'FROM Contact WHERE email =:strmail') : list_contact ;
            if(list_contact.size()>0){
                return true;
                
            } else{
                return false;
            }
        } catch(Exception objException) {
            DRLUtil.logException(
                'DRL_ConvertLeadProspectController',
                'checkEmail',
                objException,
                true
            );
            throw objException;
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
        try{
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
                        if(objField.getLabel()=='Name'){
                            jsonPart='{"label":"'+objDescribe.getLabel()+' Name",';
                        }                        
                        jsonPart += '"fieldName":"'+strSObjectName+'Url",';
                        jsonPart += '"type":"url",';
                        jsonPart += '"typeAttributes":{';
                        jsonPart += '"tooltip":{ "fieldName": "Name" }, ';
                        jsonPart += '"label":{';
                        jsonPart += '"fieldName":"Name"';
                        jsonPart += '}},';
                        jsonPart += '"tagert":"_self"';
                    }
                    else if(String.valueOf(objField.getType())=='PICKLIST'){
                        jsonPart += '"fieldName":"'+objField.getFieldPath()+'",';
                        jsonPart += '"type":"Text"';
                    }
                    else if(String.valueOf(objField.getType())=='CURRENCY'){
                        jsonPart += '"fieldName":"'+objField.getFieldPath()+'",';
                        jsonPart += '"type":"currency",';
                        jsonPart += '"typeAttributes":{"currencyCode":"'+UserInfo.getDefaultCurrency()+'"}';
                    }
                    else if(String.valueOf(objField.getType())=='REFERENCE'){
                        jsonPart += '"fieldName":"'+objField.getFieldPath()+'Url",';
                        jsonPart += '"type":"url",';
                        jsonPart += '"typeAttributes":{';
                        jsonPart += '"tooltip":{ "fieldName": "'+ objField.getFieldPath()+'Name" }, ';
                        jsonPart += '"label":{';
                        jsonPart += '"fieldName":"'+objField.getFieldPath()+'Name"';
                        jsonPart += '}},';
                        jsonPart += '"tagert":"_self"';
                    }
                    else{
                        jsonPart += '"fieldName":"'+objField.getFieldPath()+'",';
                        jsonPart += '"type":"Text"';
                    }
                    jsonPart += '}';
                    strColumns += jsonPart;
                }
            }
            return '['+strColumns+']';   
        } catch(Exception objException) {
            DRLUtil.logException(
                'DRL_ConvertLeadProspectController',
                'getDataTableColumns',
                objException,
                true
            );
            throw objException;
        } 
        
    }
    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to get Query from fieldSet
    * @ params       :  strSObjectName - Object Name
    *                   strFieldSetName - FieldSet Name
    * @ return       :  Returns String of queryfields
    **/
    public static String getQueryFields(String strSObjectName,String strFieldSetName) {
        String strqueryFields = ' ';
        SObjectType objToken = Schema.getGlobalDescribe().get(strSObjectName);
        Schema.DescribeSObjectResult objDescribe = objToken.getDescribe();
        Map<String, Schema.FieldSet> map_fieldSetNameToFieldSet = objDescribe.fieldSets.getMap();
        if(map_fieldSetNameToFieldSet.containsKey(strFieldSetName)){
            for(Schema.FieldSetMember objField : map_fieldSetNameToFieldSet.get(strFieldSetName).getFields()) {
                if(strqueryFields != ' '){
                    strqueryFields += ',';
                }
                if(String.valueOf(objField.getType()) == 'CURRENCY'){
                    strqueryFields += 'convertCurrency('+objField.getFieldPath()+')';
                }
                else if(String.valueOf(objField.getType()) == 'REFERENCE'){
                    if(objField.getFieldPath().endsWith('__c')){
                        strqueryFields += objField.getFieldPath() + ',' + objField.getFieldPath().left(objField.getFieldPath().length()-1) + 'r.Name';
                    }
                    else{
                        strqueryFields += objField.getFieldPath() + ',' + objField.getFieldPath().left(objField.getFieldPath().length()-2) + '.Name';
                    }                    
                }
                else{
                    strqueryFields += objField.getFieldPath();
                }
            }
        }
        strqueryFields += ' ';
        return strqueryFields;
    }

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to get fields to render in success screen of lead convert component
    * @ params       :  N/A
    * @ return       :  Returns Map<String(ObjectName),Map<String(FieldApiName),String(FieldLabel)>>
    **/
    public static Map<String,Map<String,String>> getResultFieldInformation() {
        Map<String,Map<String,String>> map_successFieldsToShow = new Map<String,Map<String,String>>();
        for(DRL_ConvertLeadSuccessConfiguration__mdt objfieldsToshow : [SELECT Label, FieldAPINames__c FROM DRL_ConvertLeadSuccessConfiguration__mdt]){
            Map<String,String> map_fieldApitoLabel = new Map<String,String>();
            Schema.DescribeSObjectResult objdescribeSobjectsResult = Schema.getGlobalDescribe().get(objfieldsToshow.Label).getDescribe();
            Map<String, Schema.SObjectField> map_allFieldsInformation = objdescribeSobjectsResult.fields.getMap();

            for(String strFieldApiName:objfieldsToshow.FieldAPINames__c.split(',')){
                map_fieldApitoLabel.put(strFieldApiName,map_allFieldsInformation.get(strFieldApiName).getDescribe().getLabel());
            }
            map_successFieldsToShow.put(objfieldsToshow.Label,map_fieldApitoLabel);
        }
        return map_successFieldsToShow;
    }
    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to set result record fields
    * @ params       :  objresponse - ConvertLeadDataWrapper object with
    * @ return       :  Returns ConvertLeadDataWrapper with account,contact and opportunity details 
    **/
    public static ConvertLeadDataWrapper getResultRecords(ConvertLeadDataWrapper objresponse) {
        
        for(DRL_ConvertLeadSuccessConfiguration__mdt objfieldsToshow : [SELECT Label, FieldAPINames__c FROM DRL_ConvertLeadSuccessConfiguration__mdt]){
            String strId = '';
            if(objfieldsToshow.Label == 'Account'){
                strId = objresponse.objaccount.Id;
            }
            else if(objfieldsToshow.Label == 'Contact'){
                strId = objresponse.objcontact.Id;
            }
            else if(objfieldsToshow.Label == 'Opportunity'){
                if(objresponse.objopportunity == null){
                    continue;
                }
                strId = objresponse.objopportunity.Id;
            }
            String strquery = 'select Id,'+ objfieldsToshow.FieldAPINames__c +' from '+ objfieldsToshow.Label + ' where Id=:strId';
            if(objfieldsToshow.Label == 'Account'){
                objresponse.objaccount=Database.query(strquery);
            }
            else if(objfieldsToshow.Label == 'Contact'){
                objresponse.objcontact = Database.query(strquery);
            }
            else if(objfieldsToshow.Label == 'Opportunity'){
                objresponse.objopportunity = Database.query(strquery);
            }

        }
        return objresponse;
    }

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to get Content Cataglog Details
    * @ params       :  objresponse - ConvertLeadDataWrapper object
    * @ return       :  Returns ConvertLeadDataWrapper with Content Cataglog Details
    **/
    public static ConvertLeadDataWrapper getContentCatalogDetails(ConvertLeadDataWrapper objresponse) {
        Lead objLead = objresponse.objLead;
        Map<String, List<contentCatalog>> map_categoryToContentCatalogList = new Map<String, List<contentCatalog>>();              
        List<contentCatalog> list_customContentCatalogs = new List<contentCatalog>();
        List<categoryContentCatalog> list_categoryContentCatalog = new List<categoryContentCatalog>();
        Boolean blncontentAvailable = false;

        if (objLead.Product_Lookup__c != null && objLead.Cluster__c != null){    
            String strcluster=objLead.Cluster__c;        
            List<Content_Catalog__c> list_ContentCatalogs = Database.query('SELECT ' + DRLUtil.getsObjectFieds('Content_Catalog__c') + 'FROM Content_Catalog__c WHERE Product_Cluster__c =:strcluster and Active_Document__c=True');
            if (!list_ContentCatalogs.isEmpty()){
                blncontentAvailable = true;                
                Map<String, List<Content_Catalog__c>> map_categoryWiseContent = new Map<String, List<Content_Catalog__c>>();
                for (Content_Catalog__c objcontentCatalog : list_ContentCatalogs){
                    if (!map_categoryWiseContent.containsKey(objcontentCatalog.Document_category__c)){
                        map_categoryWiseContent.put(objcontentCatalog.Document_category__c, new List<Content_Catalog__c>());
                    }
                    map_categoryWiseContent.get(objcontentCatalog.Document_category__c).add(objcontentCatalog);
                }
                for (String strdocumentCategory : map_categoryWiseContent.keySet()){
                    categoryContentCatalog objcategoryContentCatalog = new categoryContentCatalog();
                    objcategoryContentCatalog.category = strdocumentCategory + '(' + map_categoryWiseContent.get(strdocumentCategory).size() + ')';
                    List<contentCatalog> list_ContentCatalog = new List<contentCatalog>();
                    for (Content_Catalog__c objcontentCatalog : map_categoryWiseContent.get(strdocumentCategory)){
                        contentCatalog objCustomContentCatalog = new contentCatalog();
                        objCustomContentCatalog.label = objcontentCatalog.Name;
                        objCustomContentCatalog.value = objcontentCatalog.Name;
                        objCustomContentCatalog.catalogId = objcontentCatalog.Id;
                        objCustomContentCatalog.categoryValue = strdocumentCategory + ' - ' + objcontentCatalog.Name;
                        objCustomContentCatalog.categoryCount = objcategoryContentCatalog.category;
                        list_ContentCatalog.add(objCustomContentCatalog);
                    }
                    objcategoryContentCatalog.contentList = list_ContentCatalog;
                    contentCatalog objCustomContentCatalog = new contentCatalog();
                    objCustomContentCatalog.label = objcategoryContentCatalog.category;
                    objCustomContentCatalog.value = objcategoryContentCatalog.category;
                    list_customContentCatalogs.add(objCustomContentCatalog);
                    map_categoryToContentCatalogList.put(objcategoryContentCatalog.category, list_ContentCatalog);
                    list_categoryContentCatalog.add(objcategoryContentCatalog);
                }
            }
        }
        objresponse.mapContentList = map_categoryToContentCatalogList;
        objresponse.categoryList = list_categoryContentCatalog;
        objresponse.catList = list_customContentCatalogs;
        objresponse.contentAvailable = blncontentAvailable;
        return objresponse;
    }  

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to get Content Cataglog Details
    * @ params       :  objresponse - ConvertLeadDataWrapper object
    * @ return       :  Returns ConvertLeadDataWrapper object with Content Cataglog Details of prospect child leads
    **/
    public static ConvertLeadDataWrapper getChildLeadContentCatalogDetails(ConvertLeadDataWrapper objresponse) {

        Set<String> set_clusters=new Set<String>();
        for(Lead objlead:objresponse.listProspectChildLeads){
            if(objlead.Product_Lookup__c != null && objlead.Cluster__c != null){
                set_clusters.add(objlead.Cluster__c);
            }
        }

        Map<String,Boolean> map_contentAvailable = new Map<String,Boolean>();
        Map<String,Map<String, List<contentCatalog>>> map_mapContentList = new Map<String,Map<String, List<contentCatalog>>>();
        Map<String,List<categoryContentCatalog>> map_categoryList = new Map<String,List<categoryContentCatalog>>();
        Map<String,List<contentCatalog>> map_catList = new Map<String,List<contentCatalog>>();

        if(set_clusters.size()>0){
            List<Content_Catalog__c> list_fullcatalogList = new List<Content_Catalog__c>();            
            list_fullcatalogList = Database.query('SELECT ' + DRLUtil.getsObjectFieds('Content_Catalog__c') + 'FROM Content_Catalog__c WHERE Product_Cluster__c in:set_clusters and Active_Document__c=True');
            Map<String,List<Content_Catalog__c>> map_clusterToContentCatalogs=new Map<String,List<Content_Catalog__c>>();
            for(Content_Catalog__c objContentCatalog:list_fullcatalogList){
                if (!map_clusterToContentCatalogs.containsKey(objContentCatalog.Product_Cluster__c)){
                    map_clusterToContentCatalogs.put(objContentCatalog.Product_Cluster__c, new List<Content_Catalog__c>());
                }
                map_clusterToContentCatalogs.get(objContentCatalog.Product_Cluster__c).add(objContentCatalog);
            }

            for(Lead objlead:objresponse.listProspectChildLeads){
                
                Map<String, List<contentCatalog>> map_categoryToContentCatalogList = new Map<String, List<contentCatalog>>();  
                List<contentCatalog> list_customContentCatalogs = new List<contentCatalog>(); 
                List<categoryContentCatalog> list_categoryContentCatalog = new List<categoryContentCatalog>();
                Boolean blncontentAvailable = false;
            
                
                if(objlead.Product_Lookup__c != null && objlead.Cluster__c != null){                    
                    if(map_clusterToContentCatalogs.containsKey(objLead.Cluster__c)){
                        List<Content_Catalog__c> list_ContentCatalogs = map_clusterToContentCatalogs.get(objlead.Cluster__c);
                        blncontentAvailable = true;
                        Map<String, List<Content_Catalog__c>> categoryWiseContent = new Map<String, List<Content_Catalog__c>>();
                        for (Content_Catalog__c objcontentCatalog : list_ContentCatalogs){
                            if (!categoryWiseContent.containsKey(objcontentCatalog.Document_category__c)){
                                categoryWiseContent.put(objcontentCatalog.Document_category__c, new List<Content_Catalog__c>());
                            }
                            categoryWiseContent.get(objcontentCatalog.Document_category__c).add(objcontentCatalog);
                        }
                        for (String strdocumentCategory : categoryWiseContent.keySet()){
                            categoryContentCatalog objcategoryContentCatalog = new categoryContentCatalog();
                            objcategoryContentCatalog.category = strdocumentCategory + '(' + categoryWiseContent.get(strdocumentCategory).size() + ')';
                            List<contentCatalog> list_ContentCatalog = new List<contentCatalog>();
                            for (Content_Catalog__c objcontentCatalog : categoryWiseContent.get(strdocumentCategory)){
                                contentCatalog objcustomcontentCatalog = new contentCatalog();
                                objcustomcontentCatalog.label = objcontentCatalog.Name;
                                objcustomcontentCatalog.value = objcontentCatalog.Name;
                                objcustomcontentCatalog.catalogId = objcontentCatalog.Id;
                                objcustomcontentCatalog.categoryValue = strdocumentCategory + ' - ' + objcontentCatalog.Name;
                                objcustomcontentCatalog.categoryCount = objcategoryContentCatalog.category;
                                list_ContentCatalog.add(objcustomcontentCatalog);
                            }
                            objcategoryContentCatalog.contentList = list_ContentCatalog;
                            contentCatalog objcontentCatalog = new contentCatalog();
                            objcontentCatalog.label = objcategoryContentCatalog.category;
                            objcontentCatalog.value = objcategoryContentCatalog.category;
                            list_customContentCatalogs.add(objcontentCatalog);
                            map_categoryToContentCatalogList.put(objcategoryContentCatalog.category, list_ContentCatalog);
                            list_categoryContentCatalog.add(objcategoryContentCatalog);
                        }
                    }
                }
                map_contentAvailable.put(objlead.Id, blncontentAvailable);
                map_mapContentList.put(objlead.Id,map_categoryToContentCatalogList);
                map_categoryList.put(objlead.Id,list_categoryContentCatalog);
                map_catList.put(objlead.Id,list_customContentCatalogs);                
            }
        }
        objresponse.map_contentAvailable = map_contentAvailable;
        objresponse.map_mapContentList = map_mapContentList;
        objresponse.map_categoryList = map_categoryList;
        objresponse.map_catList = map_catList;
        return objresponse;
    }

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to get Content Cataglog Ids separated by ';'
    * @ params       :  list_contentCatalogs - list of contentCatalog
    * @ return       :  Returns String  with Content_Catalog__c Id's separated by ;
    **/
    public static String getOrderedContents(List<contentCatalog> list_contentCatalogs){
        String strcontentIds = '';
        if (list_contentCatalogs != null && list_contentCatalogs.size() > 0){
            for (contentCatalog c : list_contentCatalogs){
                if (String.isNotBlank(strcontentIds)){
                    strcontentIds += ';'+c.catalogId ;
                }else{
                    strcontentIds = c.catalogId;
                }
            }
        }
        return strcontentIds;
    }

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to handle DML errors and set error message to return
    * @ params       :  objError - Error Object
                        strObjectName - object on which DML operation is appied
                        strOpertation - type of operation done on object
    * @ return       :  Returns String  error message 
    **/
    public static String getErroMessage(Database.Error objError, String strObjectName, String strOpertation){
        String strErrorMessage = '';
        if (String.valueOf(objError.getStatusCode()).contains('DUPLICATES_DETECTED')) {            
            strErrorMessage = 'Duplicate '+strObjectName+' Found';
        }
        else if (String.valueOf(objError.getStatusCode()).contains('DUPLICATE_VALUE')) {
            String strDuplicateRecordId = objError.getMessage().split(' ')[objError.getMessage().split(' ').size()-1];  
            SObject objRecord = Database.query('select Name from Opportunity  where Id=:strDuplicateRecordId')[0];      
            strErrorMessage = 'Duplicate '+strObjectName+' Found : '+ objRecord.get('Name');
        }
        else if (String.valueOf(objError.getStatusCode()).contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {            
            strErrorMessage = strObjectName+' :'+objError.getMessage();
        } 
        else if (String.valueOf(objError.getStatusCode()).contains('REQUIRED_FIELD_MISSING')) {            
            strErrorMessage = strObjectName+' :'+objError.getMessage();
        } 
        else{            
            strErrorMessage = 'Error during '+strObjectName+' '+ strOpertation+' :'+objError.getMessage();
        }  
        return strErrorMessage;        
    }

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is update contact on Opportunity after convertion 
    * @ params       :  strOpportunityIds - OpportunityId or JSON.String of Set of Ids
                        strContactId - contact id to update on opportunities
                        blnIsProspect - true if lead is prospect record type
    * @ return       :  Returns String  error message 
    **/
    @future
    public static void updateContactOnOpportunity(String strOpportunityIds, String strContactId, Boolean blnIsProspect) {
        List<Opportunity> list_Opportunitiestoupdate = new List<Opportunity>();
        List<OpportunityContactRole> list_OpportunityContactRole = new List<OpportunityContactRole> ();
        if (blnIsProspect) {
            Set<Id> set_OpportunityIds = (Set<Id>)JSON.deserialize(strOpportunityIds, Set<Id>.class);
            list_OpportunityContactRole = [SELECT 
                                           Id 
                                           FROM OpportunityContactRole 
                                           WHERE OpportunityId IN :set_OpportunityIds 
                                           AND ContactId = :strContactId];
            for (Id OpportunityId : set_OpportunityIds) {
                list_Opportunitiestoupdate.add(new Opportunity(Id=OpportunityId, Contact__c = strContactId));
            }
        } else {
            list_OpportunityContactRole = [SELECT 
                                           Id 
                                           FROM OpportunityContactRole 
                                           WHERE OpportunityId = :strOpportunityIds 
                                           AND ContactId = :strContactId];
            list_Opportunitiestoupdate.add(new Opportunity(Id=strOpportunityIds, Contact__c = strContactId));          
        }

        List<String> list_ConsolidatedDMLErrors = new List<String>();
        if (!list_OpportunityContactRole.isEmpty()) {
            DRL_OpportunityContactRoleTriggerHelper.blnSkipOpportunityContactRoleTrigger = true;
            List<Database.DeleteResult> list_Results = Database.delete(list_OpportunityContactRole, false);
            list_ConsolidatedDMLErrors.addAll(DRLUtil.processDeleteResult(list_Results));            
            DRL_OpportunityContactRoleTriggerHelper.blnSkipOpportunityContactRoleTrigger = false;
        }

        if (!list_Opportunitiestoupdate.isEmpty()) {   
            List<Database.SaveResult> list_Results = Database.update(list_Opportunitiestoupdate, false);
            list_ConsolidatedDMLErrors.addAll(DRLUtil.processDMLErrors(list_Results,'Update'));        
        }

        if (!list_ConsolidatedDMLErrors.isEmpty()) {
            DRLUtil.logDMLException(
                'DRL_ConvertLeadProspectController',
                'updateContactOnOpportunity',
                list_ConsolidatedDMLErrors
            );
        }        
    }

    public class CustomDMLException extends Exception{}

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
        @AuraEnabled
        public Map<String,Map<String,String>> map_successFieldsToShow{get;set;}
        @AuraEnabled
        public Boolean contentAvailable{ get; set; }
        @AuraEnabled
        public Map<String, List<contentCatalog>> mapContentList{ get; set; }
        @AuraEnabled
        public List<categoryContentCatalog> categoryList{ get; set; }        
        @AuraEnabled
        public List<contentCatalog> catList{ get; set; }

        @AuraEnabled
        public Map<String,Boolean> map_contentAvailable{ get; set; }
        @AuraEnabled
        public Map<String,Map<String, List<contentCatalog>>> map_mapContentList{ get; set; }
        @AuraEnabled
        public Map<String,List<categoryContentCatalog>> map_categoryList{ get; set; }        
        @AuraEnabled
        public Map<String,List<contentCatalog>> map_catList{ get; set; }
    } 

    public class contentCatalog{
        @AuraEnabled
        public String label{ get; set; }
        @AuraEnabled
        public String value{ get; set; }
        @AuraEnabled
        public String categoryValue{ get; set; }
        @AuraEnabled
        public String catalogId{ get; set; }
        @AuraEnabled
        public String categoryCount{ get; set; }
        @AuraEnabled
        public Boolean highlight{ get; set; }
    }

    public class categoryContentCatalog{
        @AuraEnabled
        public String category{ get; set; }
        @AuraEnabled
        public List<contentCatalog> contentList{ get; set; }
    }
    
}