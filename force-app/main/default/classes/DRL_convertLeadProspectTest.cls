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
    public static void createData() {
        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
        Map<String, Id> map_OppRecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Opportunity');
        //create Account
        Account objExistingAccount = new Account();
        objExistingAccount.Name = 'Test Existing Account';
        objExistingAccount.Industry__c = 'Generics';
        objExistingAccount.Is_Parent__c = true;
        insert objExistingAccount;
        
        //Create Contact
        Contact objExistingContact = new Contact();
        objExistingContact.LastName = 'testExistingContact';
        objExistingContact.Email = 'testExistingContact@email.com';
        objExistingContact.Job_Level__c = 'Manager';
        objExistingContact.Department__c = 'Quality';
        insert objExistingContact;
        
        Product2 objProduct = new Product2();
        objProduct.Name = 'Abacavir';
        objProduct.ProductCode = '12345';
        objProduct.PQT_Product_Cluster__c = 'Abacavir Base';
        insert objProduct;
        
        Content_Catalog__c objContentCatalog = new Content_Catalog__c();
        objContentCatalog.name= 'contenCatalog';
        objContentCatalog.product__c = objProduct.Id;
        objContentCatalog.product_cluster__c = 'Abacavir Base';
        objContentCatalog.Document_URL__c = 'abacavir.test.com11';
        objContentCatalog.Document_Category__c = 'IP advantage';
        objContentCatalog.Active_Document__c = true;
        insert objContentCatalog;
        
        //child lead of prospect record
        Lead objChildLead = new Lead();
        objChildLead.FirstName = '';
        objChildLead.LastName = 'testChildLead';
        objChildLead.Company = 'Absyz'; 
        objChildLead.Select_Country__c = 'India';
        objChildLead.IsConverted = false;
        objChildLead.Status = 'Open';
        objChildLead.Email = 'testProspect@drl.com';
        objChildLead.recordTypeId =map_RecordTypeIdByDeveloperName.get('DRL_Lead');
        insert objChildLead;

        //update name on prospect record 
        objChildLead = [SELECT DRL_Prospect__c FROM Lead WHERE Id =: objChildLead.Id];
        Lead objProspect = [SELECT Id FROM Lead WHERE Id =: objChildLead.DRL_Prospect__c ];
        objProspect.LastName = 'testProspectLead';
        update objProspect;
        
        //lead record
        Lead objLead = new Lead();
        objLead.FirstName = '';
        objLead.LastName = 'testLead3';
        objLead.Company = 'Absyz'; 
        objLead.Select_Country__c = 'India';
        objLead.IsConverted = false;
        objLead.Status = 'Open';
        objLead.product_lookup__c = objProduct.Id;
        objLead.DRL_Prospect__c = objProspect.Id;
        objLead.recordTypeId =map_RecordTypeIdByDeveloperName.get('DRL_Lead');
        insert objLead;

        List<Opportunity> list_Opportunities = new List<Opportunity>();
        
        Opportunity objChildOpportunity = new Opportunity();
        objChildOpportunity.Name = 'testChildOpportunity';
        objChildOpportunity.recordTypeId = map_OppRecordTypeIdByDeveloperName.get('API');
        objChildOpportunity.Target_Markets__c = 'North America';
        objChildOpportunity.CloseDate = System.today() + 5;
        objChildOpportunity.StageName = 'Lead Generation';
        objChildOpportunity.Lead_Converted_From__c = objChildLead.Id;
        list_Opportunities.add(objChildOpportunity);
     
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'testProspectLead';
        objOpportunity.recordTypeId = map_OppRecordTypeIdByDeveloperName.get('API');
        objOpportunity.Target_Markets__c = 'North America';
        objOpportunity.CloseDate = System.today() + 5;
        objOpportunity.StageName = 'Lead Generation';
        list_Opportunities.add(objOpportunity);
        insert list_Opportunities;
    }
    
    /**
    * @ author       :  Subhodeep Sarkar
    * @ description  :  This method is used to test the static methods.  
    **/
    @isTest
    public static void testStaticMethods(){
        Test.startTest();
        
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'Test Existing Account' LIMIT 1];
        Contact objContact = [SELECT Id, Email FROM Contact WHERE LastName = 'testExistingContact' LIMIT 1];
        
        DRL_ConvertLeadProspectController.getAccount(objAccount.Id);
        DRL_ConvertLeadProspectController.getContact(objContact.Id);
        DRL_ConvertLeadProspectController.getQueryFields('Account', 'LeadConvertFields');
        DRL_ConvertLeadProspectController.getDataTableColumns('Account', 'LeadConvertFields');
        DRL_ConvertLeadProspectController.getDataTableColumns('Opportunity', 'convertLeadSuccessScreenList');
        DRL_ConvertLeadProspectController.checkEmail(objContact.Email);
        Test.stopTest();
    }
    
    /**
    * @ author       :  Subhodeep Sarkar
    * @ description  :  This method is used to test the condition - Open Prospect with Open child lead is converted,.  
    **/    
    @isTest
    public static void testProspectwithChild() {
        Map<String, Id> map_OppRecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Opportunity');
        
        Lead objLeadProspect = [SELECT Id FROM Lead WHERE LastName = 'testProspectLead' and RecordType.DeveloperName='DRL_Prospect' LIMIT 1 ];
        List<Lead> list_Leads = new List<Lead>{[SELECT Id FROM Lead WHERE LastName = 'testChildLead' and RecordType.DeveloperName='DRL_Lead' LIMIT 1 ]};
        Test.startTest();

        Account objExistingAccount = new Account();
        objExistingAccount.Name = 'Test Existing Account';
        objExistingAccount.Industry__c = 'Generics';
        
        Contact objExistingContact = new Contact();
        objExistingContact.LastName = 'testExistingContact';
        objExistingContact.Email = 'testExistingContact@email.com';
        objExistingContact.Job_Level__c = 'Manager';
        objExistingContact.Department__c = 'Quality';
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'testProspectLead';
        objOpportunity.recordTypeId = map_OppRecordTypeIdByDeveloperName.get('API');
        objOpportunity.Target_Markets__c = 'North America';
        objOpportunity.CloseDate = System.today() + 5;
        objOpportunity.StageName = 'Lead Generation';
        List<Opportunity> list_Opportunities = new List<Opportunity>{ objOpportunity };
   
        Opportunity objOpportunity2 = [SELECT Id FROM Opportunity WHERE Name = 'testProspectLead' LIMIT 1] ;
        List<DRL_ConvertLeadProspectController.contentCatalog> list_ParentContentCatalogs = 
            new List<DRL_ConvertLeadProspectController.contentCatalog>();
        List<Content_Catalog__c> list_ChildcontentCatalogs = new List<Content_Catalog__c>([
            SELECT Id 
            FROM Content_Catalog__c 
            WHERE Name = 'contenCatalog' 
            LIMIT 1
        ]);
        
        Map<String, String> map_strrunAfter = new Map<String, String>{ String.valueOf(list_Leads[0].Id) => 'Immediately' };
        String strLeadId = objLeadProspect.Id;
        System.AssertEquals([SELECT RecordType.DeveloperName FROM Lead WHERE Id = :strLeadId].RecordType.DeveloperName, 'DRL_Prospect');
        List<DRL_ConvertLeadProspectController.contentCatalog> list_ContentCatalogs = 
            new List<DRL_ConvertLeadProspectController.contentCatalog>();
        
        DRL_ConvertLeadProspectController.getLeadDetails(strLeadId);
        DRL_ConvertLeadProspectController.contentCatalog objCustomContentCatalog = 
            new DRL_ConvertLeadProspectController.contentCatalog();
        objCustomContentCatalog.label = 'test Catalog';
        objCustomContentCatalog.value = 'test Catalog';
        objCustomContentCatalog.catalogId = list_ChildcontentCatalogs[0].Id;
        objCustomContentCatalog.categoryValue = 'IP advantage - test Catalog';
        objCustomContentCatalog.categoryCount = 'IP advantage(1)';
        list_ContentCatalogs.add(objCustomContentCatalog);
        
        Map<String, List<DRL_ConvertLeadProspectController.ContentCatalog>> map_ListContentCatalogsByLeadId = 
            new Map<String, List<DRL_ConvertLeadProspectController.ContentCatalog>>();
        map_ListContentCatalogsByLeadId.put(String.valueOf(list_Leads[0].Id), list_ContentCatalogs);
        DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(objLeadProspect.Id));
        DRL_ConvertLeadProspectController.getChildLeads(String.valueOf(list_Leads[0].Id));
        DRL_ConvertLeadProspectController.ConvertLeadDataWrapper objResponse = 
            new DRL_ConvertLeadProspectController.ConvertLeadDataWrapper();
        objResponse.strstatus = 'Open';
        objResponse.objLead = objLeadProspect;
        objResponse.listProspectChildLeads = list_Leads;
        
        DRL_ConvertLeadProspectController.convertLead(
            strLeadId,
            objExistingAccount,
            objExistingContact,
            objOpportunity2,
            list_Opportunities,
            list_Leads, 
            list_ParentContentCatalogs,
            'Immediately',
            map_ListContentCatalogsByLeadId,
            map_strrunAfter
        );

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
        Account objExistingAccount1 = new Account();
        objExistingAccount1.Name = 'Test Account';
        objExistingAccount1.Industry__c = 'Generics';
        
        Contact objExistingContact1 = new Contact();
        objExistingContact1.LastName = 'test Contact';
        objExistingContact1.Email = 'testExistingContact123@email.com';
        objExistingContact1.Job_Level__c = 'Manager';
        objExistingContact1.Department__c = 'Quality';
        
        Account objExistingAccount2 = new Account();
        objExistingAccount2.Name = 'Test Account';
        objExistingAccount2.Industry__c = 'Generics';
        
        Contact objExistingContact2 = new Contact();
        objExistingContact2.LastName = 'test Contact';
        objExistingContact2.Email = 'testExistingContact23@email.com';
        objExistingContact2.Job_Level__c = 'Manager';
        objExistingContact2.Department__c = 'Quality';
        
        Lead objLeadProspect = [SELECT 
                                Id 
                                FROM Lead 
                                WHERE LastName = 'testProspectLead' 
                                AND RecordType.DeveloperName = 'DRL_Prospect' 
                                LIMIT 1];
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'testProspectLead';
        objOpportunity.recordTypeId = map_OppRecordTypeIdByDeveloperName.get('API');
        objOpportunity.Target_Markets__c = 'North America';
        objOpportunity.CloseDate = System.today() + 5;
        objOpportunity.StageName = 'Lead Generation';
        
        Opportunity objOpportunity2 = new Opportunity();
        objOpportunity2.Name = 'testProspectLead';
        objOpportunity2.recordTypeId = map_OppRecordTypeIdByDeveloperName.get('API');
        objOpportunity2.Target_Markets__c = 'North America';
        objOpportunity2.CloseDate = System.today() + 5;
        objOpportunity2.StageName = 'Lead Generation';
        Lead objLead = [SELECT Id FROM Lead WHERE LastName = 'testLead3' AND RecordType.DeveloperName = 'DRL_Lead' LIMIT 1];
        
        List<DRL_ConvertLeadProspectController.contentCatalog> list_ParentContentCatalogs = 
            new List<DRL_ConvertLeadProspectController.contentCatalog>();
        Map<String, String> map_strrunAfter = new Map<String, String>();
        Map<String, List<DRL_ConvertLeadProspectController.ContentCatalog>> map_ListContentCatalogs = 
            new Map<String, List<DRL_ConvertLeadProspectController.ContentCatalog>>();
        List<Opportunity> list_Opportunities = new List<Opportunity>{objOpportunity2};
        List<Lead> list_Leads = new List<Lead>{ objLead };
                
        DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(objLeadProspect.Id));
        DRL_ConvertLeadProspectController.convertLead(
            String.valueOf(objLeadProspect.Id),
            objExistingAccount1,
            objExistingContact1,
            objOpportunity,
            list_Opportunities,
            list_Leads, 
            list_ParentContentCatalogs,
            'Immediately',
            map_ListContentCatalogs,
            map_strrunAfter
        );
        DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(objLead.Id));
        DRL_ConvertLeadProspectController.convertLead(
            String.valueOf(objLead.Id),
            objExistingAccount2,
            objExistingContact2,
            objOpportunity2,
            list_Opportunities,
            list_Leads, 
            list_ParentContentCatalogs,
            'Immediately',
            map_ListContentCatalogs,
            map_strrunAfter
        );
        Test.stopTest();   
    }

    /**
    * @ author       : Kishore Pedireddy
    * @ description  : This method is used to test the method getErroMessage -
    **/
    @isTest
    public static void testGetErroMessage() {
        Database.SaveResult objSaveResult = Database.insert(new Account(), false);
        if (!objSaveResult.getErrors().isEmpty()) {
            DRL_ConvertLeadProspectController.getErroMessage(objSaveResult.getErrors()[0], 'Account', 'Insertion');
        }

        objSaveResult = Database.insert(
            new Lead(
                Company='Test Enterrises',
                LastName='testLead',
                Status='Contacted'
            )
            ,
            false
        );
        if (!objSaveResult.getErrors().isEmpty()) {
            DRL_ConvertLeadProspectController.getErroMessage(objSaveResult.getErrors()[0], 'Lead', 'Insertion');
        }

        objSaveResult = Database.insert(new Account(Name = 'Test Error Account'), false);
        if (!objSaveResult.getErrors().isEmpty()) {
            DRL_ConvertLeadProspectController.getErroMessage(objSaveResult.getErrors()[0], 'Account', 'Insertion');
        }

        objSaveResult = Database.insert(new Account(Name = 'Test Error Account'), false);
        if (!objSaveResult.getErrors().isEmpty()) {
            DRL_ConvertLeadProspectController.getErroMessage(objSaveResult.getErrors()[0], 'Account', 'Insertion');
        }        
    }

    /**
    * @ author       : Kishore Pedireddy
    * @ description  : This method is used to test the convert functionality if Lead related parent prospect is not converted
    **/
    @isTest
    public static void testConvertLeadIfProspectNotConverted() {
        Product2 objProduct = new Product2();
        objProduct.Name = 'APREPITANT';
        objProduct.ProductCode = '00001';
        objProduct.PQT_Product_Cluster__c = 'APREPITANT';
        insert objProduct;

        Content_Catalog__c objContentCatalog = new Content_Catalog__c();
        objContentCatalog.Name = 'APREPITANT';
        objContentCatalog.product__c = objProduct.Id;
        objContentCatalog.product_cluster__c = 'APREPITANT';
        objContentCatalog.Document_URL__c = 'antoxidptablet.test.com';
        objContentCatalog.Document_Category__c = 'IP advantage';
        objContentCatalog.Active_Document__c = true;
        insert objContentCatalog;        

        User objUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Id idAPIRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('API').getRecordTypeId();

        System.runAs(objUser) {   
            Test.startTest();
            Lead objLead = new Lead();
            objLead.Company = 'Raghu Ram Enterprises';
            objLead.Select_Country__c = 'India';
            objLead.LastName = 'Raghu Ram';
            objLead.email = 'raghuram@email.test.com';
            objLead.Status = 'Open';
            objLead.Product_Lookup__c = objProduct.Id;
            insert objLead;    
            
            DRL_ConvertLeadProspectController.ConvertLeadDataWrapper objResponse = 
                DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(objLead.Id));

            Account objAccount = new Account();
            objAccount.Name = objLead.Company;
            objAccount.Industry__c = 'Generics';

            Contact objContact = new Contact();
            objContact.LastName = objLead.LastName;
            objContact.email = objLead.email;
            objContact.Job_Level__c = 'CXO/Head';
            objContact.Department__c = 'Regulatory';

            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Name = objLead.Company + ' ' + objProduct.Name;
            objOpportunity.RecordTypeId = idAPIRecordTypeId;
            objOpportunity.CurrencyIsoCode = 'EUR';
            objOpportunity.Target_Markets__c = 'North Asia';
            objOpportunity.CloseDate = System.today().addDays(2);
            objOpportunity.StageName = 'Lead Generation';

            objResponse = DRL_ConvertLeadProspectController.convertLead(
                String.valueOf(objLead.Id),
                objAccount,
                objContact,
                objOpportunity,
                null,
                null,
                objResponse.catList, 
                'Immediately',
                null,
                null
            );
            Test.stopTest();
        }        
    }    
    
    /**
    * @ author       : Kishore Pedireddy
    * @ description  : This method is used to test the convert functionality if Lead related parent prospect is converted
    **/
    @isTest
    public static void testConvertLeadIfProspectConverted() {
        Product2 objProduct = [SELECT Id, Name FROM Product2 WHERE ProductCode = '12345' LIMIT 1];

        User objUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Id idAPIRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('API').getRecordTypeId();

        System.runAs(objUser){   
            Lead objLead = new Lead();
            objLead.Company = 'Raghu Ram Enterprises';
            objLead.Select_Country__c = 'India';
            objLead.LastName = 'Raghu Ram';
            objLead.email = 'raghuram@email.test.com';
            objLead.Status = 'Open';
            objLead.Product_Lookup__c = objProduct.Id;
            insert objLead;    

            Lead objProspect = [SELECT 
                                Id 
                                FROM Lead 
                                WHERE Email = 'raghuram@email.test.com' 
                                AND RecordType.DeveloperName = 'DRL_Prospect' LIMIT 1];          

            Account objAccount = new Account();
            objAccount.Name = objLead.Company;
            objAccount.Industry__c = 'Generics';

            Contact objContact = new Contact();
            objContact.LastName = objLead.LastName;
            objContact.email = objLead.email;
            objContact.Job_Level__c = 'CXO/Head';
            objContact.Department__c = 'Regulatory'; 
            
            Test.startTest();
            //Convert Prospect
            DRL_ConvertLeadProspectController.convertLead(
                String.valueOf(objProspect.Id),
                objAccount,
                objContact,
                null,
                null,
                null,
                null, 
                null,
                null,
                null
            );

            DRL_ConvertLeadProspectController.ConvertLeadDataWrapper objResponse = 
                DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(objProspect.Id));
            
            objResponse = DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(objLead.Id));

            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Name = objLead.Company+' '+ objProduct.Name;
            objOpportunity.RecordTypeId = idAPIRecordTypeId;
            objOpportunity.CurrencyIsoCode = 'EUR';
            objOpportunity.Target_Markets__c = 'North Asia';
            objOpportunity.CloseDate = System.today().addDays(2);
            objOpportunity.StageName = 'Lead Generation';

            //Convert Lead
            objResponse = DRL_ConvertLeadProspectController.convertLead(
                String.valueOf(objLead.Id),
                objResponse.objparentProspectAccount,
                objResponse.objparentProspectContact,
                objOpportunity,
                null,
                null,
                objResponse.catList, 
                'Immediately',
                null,
                null
            );
            Test.stopTest();
        }        
    }    

    /**
    * @ author       : Kishore Pedireddy
    * @ description  : This method is used to test the convert functionality to convert prospect and child lead together
    **/
    @isTest
    public static void testConvertLeadIfProspectAlreadyConverted() {
        Product2 objProduct = new Product2();
        objProduct.Name = 'APREPITANT';
        objProduct.ProductCode = '00001';
        objProduct.PQT_Product_Cluster__c = 'APREPITANT';
        insert objProduct;

        Content_Catalog__c objContentCatalog = new Content_Catalog__c();
        objContentCatalog.Name= 'APREPITANT';
        objContentCatalog.product__c = objProduct.Id;
        objContentCatalog.product_cluster__c = 'APREPITANT';
        objContentCatalog.Document_URL__c = 'antoxidptablet.test.com';
        objContentCatalog.Document_Category__c = 'IP advantage';
        objContentCatalog.Active_Document__c = true;
        insert objContentCatalog;       

        User objUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Id idAPIRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('API').getRecordTypeId();

        System.runAs(objUser){   
            Test.startTest();
            Lead objLead = new Lead();
            objLead.Company = 'Raghu Ram Enterprises';
            objLead.Select_Country__c = 'India';
            objLead.LastName = 'Raghu Ram';
            objLead.Email = 'raghuram@email.test.com';
            objLead.Status = 'Open';
            objLead.Product_Lookup__c = objProduct.Id;
            insert objLead;    

            Lead objProspect = [SELECT 
                                Id 
                                FROM Lead 
                                WHERE Email = 'raghuram@email.test.com' 
                                AND RecordType.DeveloperName = 'DRL_Prospect' 
                                LIMIT 1];          

            DRL_ConvertLeadProspectController.ConvertLeadDataWrapper objResponse = 
                DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(objProspect.Id));            

            Account objAccount = new Account();
            objAccount.Name = objLead.Company;
            objAccount.Industry__c = 'Generics';

            Contact objContact = new Contact();
            objContact.LastName = objLead.LastName;
            objContact.Email = objLead.email;
            objContact.Job_Level__c = 'CXO/Head';
            objContact.Department__c = 'Regulatory';   

            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Name = objLead.Company + ' ' + objProduct.Name;
            objOpportunity.RecordTypeId = idAPIRecordTypeId;
            objOpportunity.CurrencyIsoCode = 'EUR';
            objOpportunity.Target_Markets__c = 'North Asia';
            objOpportunity.CloseDate = System.today().addDays(2);
            objOpportunity.StageName = 'Lead Generation';
            objOpportunity.Lead_Converted_From__c = objLead.Id;

            Map<String, String> map_strrunAfter = new Map<String, String>();
            map_strrunAfter.put(String.valueOf(objLead.Id), 'Immediately');

            objResponse=DRL_ConvertLeadProspectController.convertLead(  
                String.valueOf(objProspect.Id),
                objAccount,
                objContact,
                null,
                new List<Opportunity>{ objOpportunity },
                objResponse.listProspectChildLeads,
                null, 
                null,
                objResponse.map_catList,
                 map_strrunAfter
            );
            Test.stopTest();
        } 
    }

    /**
    * @ author       : Kishore Pedireddy
    * @ description  : This method is used to test the contact role creation functionality
    **/
    @isTest
    public static void testContactRoleCreation(){
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'Test Existing Account' LIMIT 1];
        Contact objContact2 = [SELECT Id, Email,AccountId FROM Contact WHERE LastName = 'testExistingContact' LIMIT 1];
        Contact objContact1 = new Contact();
        objContact1.LastName = 'testContact1';
        objContact1.Email = 'testContact1@email.com';
        objContact1.Job_Level__c = 'Manager';
        objContact1.Department__c = 'Quality';
        insert objContact1;
        Opportunity objOpportunity = [SELECT Id FROM Opportunity WHERE Name = 'testProspectLead' LIMIT 1] ;               
        Test.startTest();
        objOpportunity.Contact__c = objContact1.Id;
        update objOpportunity; 
        objOpportunity = DRL_ConvertLeadProspectController.getOpportunity(objOpportunity.Id);
        Lead objLead = [SELECT Id FROM Lead WHERE LastName = 'testChildLead' and RecordType.DeveloperName='DRL_Lead' LIMIT 1 ];
        DRL_ConvertLeadProspectController.convertLead(
            objLead.Id,
            objAccount,
            objContact2,
            objOpportunity,
            null,
            null, 
            null,
            null,
            null,
            null
        );
        Test.stopTest();
        List<OpportunityContactRole> list_OpportunityContactRoles = [ SELECT Id 
                                                                      FROM OpportunityContactRole 
                                                                      WHERE ContactId =:objContact2.Id 
                                                                      AND OpportunityId =:objOpportunity.Id ];
        System.assert(!list_OpportunityContactRoles.isEmpty(),'Opportunity Contact Role Creation Failed');
    }
}