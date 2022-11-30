/*******************************************************************************************************
* 
* @ Name            :   DRL_convertLeadProspectTest
* @ Purpose         :   Test class for DRL_ConvertLeadProspectController
* @ Author          :   Subhodeep Sarkar
*
*   Date            |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   20-11-2022      |  subhodeep.sarkar@absyz.com            |  1.0          |  Initial Version
*******************************************************************************************************/
@isTest
public class DRL_convertLeadProspectTest {
    
    
    /**
* @ author       :  Subhodeep Sarkar
* @ description  :  This method is used to setup data for testing apex class 'DRL_ConvertLeadProspectController'
**/
    
    @TestSetup
    public static void createData(){
        
        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
        Map<String, Id> map_OppRecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Opportunity');
        
        
        
        //create Account
        Account testExistingAccount = new Account();
        testExistingAccount.Name = 'Test Existing Account';
        testExistingAccount.Industry__c = 'Generics';
        insert testExistingAccount;
        
        //Create Contact
        Contact testExistingContact = new Contact();
        testExistingContact.LastName = 'testExistingContact';
        testExistingContact.Email = 'testExistingContact@email.com';
        testExistingContact.Job_Level__c = 'Manager';
        testExistingContact.Department__c = 'Quality';
        insert testExistingContact;
        
        Product2 obj_product = new Product2();
        obj_product.name = 'Abacavir';
        obj_product.ProductCode = '12345';
        obj_product.PQT_Product_Cluster__c = 'Abacavir Base';
        insert obj_product;
        
        Content_Catalog__c obj_contentCatalog = new Content_Catalog__c();
        obj_contentCatalog.name= 'contenCatalog';
        obj_contentCatalog.product__c = obj_product.Id;
        obj_contentCatalog.product_cluster__c = 'Abacavir Base';
        obj_contentCatalog.Document_URL__c	 = 'abacavir.test.com11';
        obj_contentCatalog.Document_Category__c = 'IP advantage';
        obj_contentCatalog.Active_Document__c = true;
        insert obj_contentCatalog;
        
        //create prospect
        Lead ldProspect = new Lead();
        ldProspect.FirstName = '';
        ldProspect.LastName = 'testProspectLead';
        ldProspect.Company = 'Absyz'; 
        ldProspect.Select_Country__c = 'India';
        ldProspect.IsConverted = false;
        ldProspect.product_lookup__c = obj_product.Id;
        ldProspect.Status = 'Open';
        ldProspect.recordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Prospect');
        insert ldProspect;
        
        //child lead of prospect record
        Lead ldChild = new Lead();
        ldChild.FirstName = '';
        ldChild.LastName = 'testChildLead';
        ldChild.Company = 'Absyz'; 
        ldChild.Select_Country__c = 'India';
        ldChild.IsConverted = false;
        ldChild.Status = 'Open';
        ldChild.DRL_Prospect__c = ldProspect.Id;
        ldChild.recordTypeId =map_RecordTypeIdByDeveloperName.get('DRL_Lead');
        insert ldChild;
        
        //lead record
        Lead lead_Record = new Lead();
        lead_Record.FirstName = '';
        lead_Record.LastName = 'testLead3';
        lead_Record.Company = 'Absyz'; 
        lead_Record.Select_Country__c = 'India';
        lead_Record.IsConverted = false;
        lead_Record.Status = 'Open';
        lead_Record.product_lookup__c = obj_product.Id;
        lead_Record.DRL_Prospect__c = ldProspect.Id;
        lead_Record.recordTypeId =map_RecordTypeIdByDeveloperName.get('DRL_Lead');
        insert lead_Record;
        
        Opportunity testChildOpportunity = new Opportunity();
        testChildOpportunity.Name = 'testChildOpportunity';
        testChildOpportunity.recordTypeId = map_OppRecordTypeIdByDeveloperName.get('API');
        testChildOpportunity.Target_Markets__c = 'North America';
        testChildOpportunity.CloseDate = System.today() + 5;
        testChildOpportunity.StageName = 'Lead Generation';
        testChildOpportunity.Lead_Converted_From__c = ldChild.Id;
        List<Opportunity> list_opportunity = new List<Opportunity>();
        list_opportunity.add(testChildOpportunity);
     
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'testProspectLead';
        testOpportunity.recordTypeId = map_OppRecordTypeIdByDeveloperName.get('API');
        testOpportunity.Target_Markets__c = 'North America';
        testOpportunity.CloseDate = System.today() + 5;
        testOpportunity.StageName = 'Lead Generation';
        list_opportunity.add(testOpportunity);
        insert list_opportunity;
    }
     /**
* @ author       :  Subhodeep Sarkar
* @ description  :  This method is used to test the static methods.  
**/
    @isTest
    public static void testStaticMethods(){
        
        Test.startTest();
        
        Account obj_Account = [Select Id from Account where Name = 'Test Existing Account' LIMIT 1 ] ;
        Contact obj_Contact = [Select Id, Email from Contact where LastName = 'testExistingContact' LIMIT 1 ] ;
        
        DRL_ConvertLeadProspectController.getAccount(obj_Account.Id);
        DRL_ConvertLeadProspectController.getContact(obj_Contact.Id);
        DRL_ConvertLeadProspectController.getQueryFields('Account', 'LeadConvertFields');
        DRL_ConvertLeadProspectController.getDataTableColumns('Account', 'LeadConvertFields');
        DRL_ConvertLeadProspectController.getDataTableColumns('Opportunity', 'convertLeadSuccessScreenList');
        DRL_ConvertLeadProspectController.checkEmail(obj_Contact.Email);
        Test.stopTest();
    }
    
/**
* @ author       :  Subhodeep Sarkar
* @ description  :  This method is used to test the condition - Open Prospect with Open child lead is converted,.  
**/
    
    @isTest
    public static void testProspectwithChild(){
        
        
        Map<String, Id> map_OppRecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Opportunity');
        
        Lead obj_leadProspect = [Select Id from Lead where LastName = 'testProspectLead' and RecordType.DeveloperName='DRL_Prospect' LIMIT 1 ];
        List<Lead> list_Lead =  new List<Lead>{[Select Id from Lead where LastName = 'testChildLead' and RecordType.DeveloperName='DRL_Prospect' LIMIT 1 ]};
        Test.startTest();

        Account testExistingAccount = new Account();
        testExistingAccount.Name = 'Test Existing Account';
        testExistingAccount.Industry__c = 'Generics';
        
        Contact testExistingContact = new Contact();
        testExistingContact.LastName = 'testExistingContact';
        testExistingContact.Email = 'testExistingContact@email.com';
        testExistingContact.Job_Level__c = 'Manager';
        testExistingContact.Department__c = 'Quality';
        
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'testProspectLead';
        testOpportunity.recordTypeId = map_OppRecordTypeIdByDeveloperName.get('API');
        testOpportunity.Target_Markets__c = 'North America';
        testOpportunity.CloseDate = System.today() + 5;
        testOpportunity.StageName = 'Lead Generation';
        List<Opportunity> list_opportunities = new List<Opportunity>{testOpportunity};
   
        Opportunity obj_Opportunity =  [Select Id from Opportunity where Name = 'testProspectLead' LIMIT 1 ] ;
        List<DRL_ConvertLeadProspectController.contentCatalog> list_parentContentCatalog = new List<DRL_ConvertLeadProspectController.contentCatalog>();
        List<Content_Catalog__c> list_ChildcontentCatalog = new List<Content_Catalog__c>([Select Id from Content_Catalog__c where name = 'contenCatalog' LIMIT 1]);
        
        Map<String, String> map_strrunAfter = new Map<String, String>{String.valueOf(list_Lead[0].Id) => 'Immediately'};
        String str_leadId = obj_leadProspect.Id;
        System.AssertEquals([select RecordType.DeveloperName from Lead where Id=:str_leadId].RecordType.DeveloperName,'DRL_Prospect');
        List<DRL_ConvertLeadProspectController.contentCatalog> list_ContentCatalog = new List<DRL_ConvertLeadProspectController.contentCatalog>();
        
        DRL_ConvertLeadProspectController.getLeadDetails(str_leadId);
        DRL_ConvertLeadProspectController.contentCatalog objCustomContentCatalog = new DRL_ConvertLeadProspectController.contentCatalog();
        objCustomContentCatalog.label = 'test Catalog';
        objCustomContentCatalog.value = 'test Catalog';
        objCustomContentCatalog.catalogId = list_ChildcontentCatalog[0].Id;
        objCustomContentCatalog.categoryValue = 'IP advantage - test Catalog';
        objCustomContentCatalog.categoryCount = 'IP advantage(1)';
        list_ContentCatalog.add(objCustomContentCatalog);
        
        Map< String,List<DRL_ConvertLeadProspectController.ContentCatalog> > map_listContentCatalogs = new  Map< String,List<DRL_ConvertLeadProspectController.ContentCatalog> >();
        map_listContentCatalogs.put(String.valueOf(list_Lead[0].Id),list_ContentCatalog);
        DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(obj_leadProspect.Id));
        DRL_ConvertLeadProspectController.getChildLeads(String.valueOf(list_Lead[0].Id));
        DRL_ConvertLeadProspectController.ConvertLeadDataWrapper objResponse = new DRL_ConvertLeadProspectController.ConvertLeadDataWrapper();
        objResponse.strstatus = 'Open';
        objResponse.objLead = obj_leadProspect;
        objResponse.listProspectChildLeads = list_Lead;
        
        DRL_ConvertLeadProspectController.convertLead(str_leadId,testExistingAccount,testExistingContact,obj_Opportunity,list_opportunities,list_Lead, list_parentContentCatalog,'Immediately',map_listContentCatalogs,map_strrunAfter);

        Test.stopTest();
    }
/**
* @ author       :  Subhodeep Sarkar
* @ description  :  This method is used to test the condition - Converted Prospect with Open child lead is converted.  
**/
    @isTest
    public static void testConvertedProspect(){
        Map<String, Id> map_OppRecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Opportunity');
        
        Test.startTest();
        Account testExistingAccount1 = new Account();
        testExistingAccount1.Name = 'Test Account';
        testExistingAccount1.Industry__c = 'Generics';
        
        Contact testExistingContact1 = new Contact();
        testExistingContact1.LastName = 'test Contact';
        testExistingContact1.Email = 'testExistingContact123@email.com';
        testExistingContact1.Job_Level__c = 'Manager';
        testExistingContact1.Department__c = 'Quality';
        
        Account testExistingAccount2 = new Account();
        testExistingAccount2.Name = 'Test Account';
        testExistingAccount2.Industry__c = 'Generics';
        
        Contact testExistingContact2 = new Contact();
        testExistingContact2.LastName = 'test Contact';
        testExistingContact2.Email = 'testExistingContact23@email.com';
        testExistingContact2.Job_Level__c = 'Manager';
        testExistingContact2.Department__c = 'Quality';
        
        Lead obj_leadProspect = [Select Id from Lead where LastName = 'testProspectLead' and RecordType.DeveloperName='DRL_Prospect' LIMIT 1 ];
        
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'testProspectLead';
        testOpportunity.recordTypeId = map_OppRecordTypeIdByDeveloperName.get('API');
        testOpportunity.Target_Markets__c = 'North America';
        testOpportunity.CloseDate = System.today() + 5;
        testOpportunity.StageName = 'Lead Generation';
        
        Opportunity testOpportunity2 = new Opportunity();
        testOpportunity2.Name = 'testProspectLead';
        testOpportunity2.recordTypeId = map_OppRecordTypeIdByDeveloperName.get('API');
        testOpportunity2.Target_Markets__c = 'North America';
        testOpportunity2.CloseDate = System.today() + 5;
        testOpportunity2.StageName = 'Lead Generation';
        Lead test_Lead =  [Select Id from Lead where LastName = 'testLead3' and RecordType.DeveloperName='DRL_Lead' LIMIT 1 ];
        
        
        List<DRL_ConvertLeadProspectController.contentCatalog> list_parentContentCatalog = new List<DRL_ConvertLeadProspectController.contentCatalog>();
        Map<String, String> map_strrunAfter = new Map<String, String>();
        Map< String,List<DRL_ConvertLeadProspectController.ContentCatalog> > map_listContentCatalogs = new  Map< String,List<DRL_ConvertLeadProspectController.ContentCatalog> >();
        List<Opportunity> list_opportunities = new List<Opportunity>{testOpportunity2};
        List<Lead> list_Lead = new List<Lead>{test_Lead};
                
        DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(obj_leadProspect.Id));
        DRL_ConvertLeadProspectController.convertLead(String.valueOf(obj_leadProspect.Id),testExistingAccount1,testExistingContact1,testOpportunity,list_opportunities,list_Lead, list_parentContentCatalog,'Immediately',map_listContentCatalogs,map_strrunAfter);
        DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(test_Lead.Id));
        DRL_ConvertLeadProspectController.convertLead(String.valueOf(test_Lead.Id),testExistingAccount2,testExistingContact2,testOpportunity2,list_opportunities,list_Lead, list_parentContentCatalog,'Immediately',map_listContentCatalogs,map_strrunAfter);
        Test.stopTest();
        
        
    }
    /**
    * @ author       : Kishore Pedireddy
    * @ description  : This method is used to test the method getErroMessage -
    **/
    @isTest
    public static void testGetErroMessage(){
        Database.SaveResult objSaveResult=Database.insert(new Account(),false);
        if(objSaveResult.getErrors().size()>0){
            DRL_ConvertLeadProspectController.getErroMessage(objSaveResult.getErrors()[0],'Account','Insertion');
        }
        objSaveResult=Database.insert(new Lead(
                                                Company='Test Enterrises',
                                                LastName='testLead',
                                                Status='Qualified',
                                                RecordTypeId=Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('DRL_Prospect').getRecordTypeId())
                                                ,false);
        if(objSaveResult.getErrors().size()>0){
            DRL_ConvertLeadProspectController.getErroMessage(objSaveResult.getErrors()[0],'Lead','Insertion');
        }
       objSaveResult=Database.insert(new Account(Name='Test Error Account'),false);
        if(objSaveResult.getErrors().size()>0){
            DRL_ConvertLeadProspectController.getErroMessage(objSaveResult.getErrors()[0],'Account','Insertion');
        }
       objSaveResult=Database.insert(new Account(Name='Test Error Account'),false);
        if(objSaveResult.getErrors().size()>0){
            DRL_ConvertLeadProspectController.getErroMessage(objSaveResult.getErrors()[0],'Account','Insertion');
        }        
    }
    
    
}