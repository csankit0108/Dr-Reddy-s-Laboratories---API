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
        insert objExistingAccount;
        
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
        
        //child lead of prospect record
        Lead ldChild = new Lead();
        ldChild.FirstName = '';
        ldChild.LastName = 'testChildLead';
        ldChild.Company = 'Absyz'; 
        ldChild.Select_Country__c = 'India';
        ldChild.IsConverted = false;
        ldChild.Status = 'Open';
        ldChild.Email = 'testProspect@drl.com';
        ldChild.recordTypeId =map_RecordTypeIdByDeveloperName.get('DRL_Lead');
        insert ldChild;

        //update name on prospect record 
        ldChild = [SELECT DRL_Prospect__c FROM Lead WHERE Id =: ldChild.Id];
        Lead objProspect = [SELECT Id FROM Lead WHERE Id =: ldChild.DRL_Prospect__c ];
        objProspect.LastName = 'testProspectLead';
        update objProspect;
        
        //lead record
        Lead lead_Record = new Lead();
        lead_Record.FirstName = '';
        lead_Record.LastName = 'testLead3';
        lead_Record.Company = 'Absyz'; 
        lead_Record.Select_Country__c = 'India';
        lead_Record.IsConverted = false;
        lead_Record.Status = 'Open';
        lead_Record.product_lookup__c = obj_product.Id;
        lead_Record.DRL_Prospect__c = objProspect.Id;
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
        
        Account obj_Account = [SELECT Id FROM Account WHERE Name = 'Test Existing Account' LIMIT 1 ] ;
        Contact obj_Contact = [SELECT Id, Email FROM Contact WHERE LastName = 'testExistingContact' LIMIT 1 ] ;
        
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
    public static void testProspectwithChild() {
        Map<String, Id> map_OppRecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Opportunity');
        
        Lead obj_leadProspect = [SELECT Id FROM Lead WHERE LastName = 'testProspectLead' and RecordType.DeveloperName='DRL_Prospect' LIMIT 1 ];
        List<Lead> list_Lead =  new List<Lead>{[SELECT Id FROM Lead WHERE LastName = 'testChildLead' and RecordType.DeveloperName='DRL_Lead' LIMIT 1 ]};
        Test.startTest();

        Account objExistingAccount = new Account();
        objExistingAccount.Name = 'Test Existing Account';
        objExistingAccount.Industry__c = 'Generics';
        
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
   
        Opportunity obj_Opportunity =  [SELECT Id FROM Opportunity WHERE Name = 'testProspectLead' LIMIT 1 ] ;
        List<DRL_ConvertLeadProspectController.contentCatalog> list_parentContentCatalog = new List<DRL_ConvertLeadProspectController.contentCatalog>();
        List<Content_Catalog__c> list_ChildcontentCatalog = new List<Content_Catalog__c>([SELECT Id FROM Content_Catalog__c WHERE name = 'contenCatalog' LIMIT 1]);
        
        Map<String, String> map_strrunAfter = new Map<String, String>{String.valueOf(list_Lead[0].Id) => 'Immediately'};
        String str_leadId = obj_leadProspect.Id;
        System.AssertEquals([SELECT RecordType.DeveloperName FROM Lead WHERE Id=:str_leadId].RecordType.DeveloperName,'DRL_Prospect');
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
        
        DRL_ConvertLeadProspectController.convertLead(str_leadId,objExistingAccount,testExistingContact,obj_Opportunity,list_opportunities,list_Lead, list_parentContentCatalog,'Immediately',map_listContentCatalogs,map_strrunAfter);

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
        
        Contact testExistingContact1 = new Contact();
        testExistingContact1.LastName = 'test Contact';
        testExistingContact1.Email = 'testExistingContact123@email.com';
        testExistingContact1.Job_Level__c = 'Manager';
        testExistingContact1.Department__c = 'Quality';
        
        Account objExistingAccount2 = new Account();
        objExistingAccount2.Name = 'Test Account';
        objExistingAccount2.Industry__c = 'Generics';
        
        Contact testExistingContact2 = new Contact();
        testExistingContact2.LastName = 'test Contact';
        testExistingContact2.Email = 'testExistingContact23@email.com';
        testExistingContact2.Job_Level__c = 'Manager';
        testExistingContact2.Department__c = 'Quality';
        
        Lead obj_leadProspect = [SELECT Id FROM Lead WHERE LastName = 'testProspectLead' and RecordType.DeveloperName='DRL_Prospect' LIMIT 1 ];
        
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
        Lead test_Lead =  [SELECT Id FROM Lead WHERE LastName = 'testLead3' and RecordType.DeveloperName='DRL_Lead' LIMIT 1 ];
        
        List<DRL_ConvertLeadProspectController.contentCatalog> list_parentContentCatalog = new List<DRL_ConvertLeadProspectController.contentCatalog>();
        Map<String, String> map_strrunAfter = new Map<String, String>();
        Map< String,List<DRL_ConvertLeadProspectController.ContentCatalog> > map_listContentCatalogs = new  Map< String,List<DRL_ConvertLeadProspectController.ContentCatalog> >();
        List<Opportunity> list_opportunities = new List<Opportunity>{testOpportunity2};
        List<Lead> list_Lead = new List<Lead>{test_Lead};
                
        DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(obj_leadProspect.Id));
        DRL_ConvertLeadProspectController.convertLead(String.valueOf(obj_leadProspect.Id),objExistingAccount1,testExistingContact1,testOpportunity,list_opportunities,list_Lead, list_parentContentCatalog,'Immediately',map_listContentCatalogs,map_strrunAfter);
        DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(test_Lead.Id));
        DRL_ConvertLeadProspectController.convertLead(String.valueOf(test_Lead.Id),objExistingAccount2,testExistingContact2,testOpportunity2,list_opportunities,list_Lead, list_parentContentCatalog,'Immediately',map_listContentCatalogs,map_strrunAfter);
        Test.stopTest();   
    }

    /**
    * @ author       : Kishore Pedireddy
    * @ description  : This method is used to test the method getErroMessage -
    **/
    @isTest
    public static void testGetErroMessage() {
        Database.SaveResult objSaveResult=Database.insert(new Account(),false);
        if(objSaveResult.getErrors().size()>0) {
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
        objContentCatalog.Name= 'APREPITANT';
        objContentCatalog.product__c = objProduct.Id;
        objContentCatalog.product_cluster__c = 'APREPITANT';
        objContentCatalog.Document_URL__c	 = 'antoxidptablet.test.com';
        objContentCatalog.Document_Category__c = 'IP advantage';
        objContentCatalog.Active_Document__c = true;
        insert objContentCatalog;        

        User objUser=[SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
        Id opportunityRecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('API').getRecordTypeId();

        System.runAs(objUser){   
            test.startTest();
            Lead objLead = new Lead();
            objLead.Company = 'Raghu Ram Enterprises';
            objLead.Select_Country__c = 'India';
            objLead.LastName = 'Raghu Ram';
            objLead.email = 'raghuram@email.test.com';
            objLead.Status = 'Open';
            objLead.Product_Lookup__c = objProduct.Id;
            insert objLead;    
            
            DRL_ConvertLeadProspectController.ConvertLeadDataWrapper objResponse=DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(objLead.Id));

            Account objAccount = new Account();
            objAccount.Name = objLead.Company;
            objAccount.Industry__c = 'Generics';

            Contact objContact = new Contact();
            objContact.LastName = objLead.LastName;
            objContact.email = objLead.email;
            objContact.Job_Level__c = 'CXO/Head';
            objContact.Department__c = 'Regulatory';

            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Name = objLead.Company+' '+ objProduct.Name;
            objOpportunity.RecordTypeId = opportunityRecordTypeId;
            objOpportunity.CurrencyIsoCode = 'EUR';
            objOpportunity.Target_Markets__c = 'North Asia';
            objOpportunity.CloseDate = System.today().addDays(2);
            objOpportunity.StageName = 'Lead Generation';

            
            objResponse=DRL_ConvertLeadProspectController.convertLead(  String.valueOf(objLead.Id),
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
            test.stopTest();
        }        
    }    
    
    /**
    * @ author       : Kishore Pedireddy
    * @ description  : This method is used to test the convert functionality if Lead related parent prospect is converted
    **/
    @isTest
    public static void testConvertLeadIfProspectConverted(){
        Product2 objProduct = new Product2();
        objProduct.Name = 'APREPITANT';
        objProduct.ProductCode = '00001';
        objProduct.PQT_Product_Cluster__c = 'APREPITANT';
        insert objProduct;

        Content_Catalog__c objContentCatalog = new Content_Catalog__c();
        objContentCatalog.Name= 'APREPITANT';
        objContentCatalog.product__c = objProduct.Id;
        objContentCatalog.product_cluster__c = 'APREPITANT';
        objContentCatalog.Document_URL__c	 = 'antoxidptablet.test.com';
        objContentCatalog.Document_Category__c = 'IP advantage';
        objContentCatalog.Active_Document__c = true;
        insert objContentCatalog;

        User objUser=[SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
        Id opportunityRecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('API').getRecordTypeId();

        System.runAs(objUser){   
            test.startTest();
            Lead objLead = new Lead();
            objLead.Company = 'Raghu Ram Enterprises';
            objLead.Select_Country__c = 'India';
            objLead.LastName = 'Raghu Ram';
            objLead.email = 'raghuram@email.test.com';
            objLead.Status = 'Open';
            objLead.Product_Lookup__c = objProduct.Id;
            insert objLead;    

            Lead objProspect=[SELECT Id FROM Lead WHERE email='raghuram@email.test.com' and RecordType.DeveloperName='DRL_Prospect' limit 1];          
            

            Account objAccount = new Account();
            objAccount.Name = objLead.Company;
            objAccount.Industry__c = 'Generics';

            Contact objContact = new Contact();
            objContact.LastName = objLead.LastName;
            objContact.email = objLead.email;
            objContact.Job_Level__c = 'CXO/Head';
            objContact.Department__c = 'Regulatory';          

            //Convert Prospect
            DRL_ConvertLeadProspectController.convertLead(String.valueOf(objProspect.Id),
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

            DRL_ConvertLeadProspectController.ConvertLeadDataWrapper objResponse=DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(objProspect.Id));
            objResponse=DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(objLead.Id));

            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Name = objLead.Company+' '+ objProduct.Name;
            objOpportunity.RecordTypeId = opportunityRecordTypeId;
            objOpportunity.CurrencyIsoCode = 'EUR';
            objOpportunity.Target_Markets__c = 'North Asia';
            objOpportunity.CloseDate = System.today().addDays(2);
            objOpportunity.StageName = 'Lead Generation';

            //Convert Lead
            objResponse=DRL_ConvertLeadProspectController.convertLead(  String.valueOf(objLead.Id),
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
            test.stopTest();
        }        

    }    

    /**
    * @ author       : Kishore Pedireddy
    * @ description  : This method is used to test the convert functionality to convert prospect and child lead together
    **/
    @isTest
    public static void testConvertLeadIfProspectAlreadyConverted(){
        Product2 objProduct = new Product2();
        objProduct.Name = 'APREPITANT';
        objProduct.ProductCode = '00001';
        objProduct.PQT_Product_Cluster__c = 'APREPITANT';
        insert objProduct;

        Content_Catalog__c objContentCatalog = new Content_Catalog__c();
        objContentCatalog.Name= 'APREPITANT';
        objContentCatalog.product__c = objProduct.Id;
        objContentCatalog.product_cluster__c = 'APREPITANT';
        objContentCatalog.Document_URL__c	 = 'antoxidptablet.test.com';
        objContentCatalog.Document_Category__c = 'IP advantage';
        objContentCatalog.Active_Document__c = true;
        insert objContentCatalog;       

        User objUser=[SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
        Id opportunityRecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('API').getRecordTypeId();

        System.runAs(objUser){   
            test.startTest();
            Lead objLead = new Lead();
            objLead.Company = 'Raghu Ram Enterprises';
            objLead.Select_Country__c = 'India';
            objLead.LastName = 'Raghu Ram';
            objLead.email = 'raghuram@email.test.com';
            objLead.Status = 'Open';
            objLead.Product_Lookup__c = objProduct.Id;
            insert objLead;    

            Lead objProspect=[SELECT Id FROM Lead WHERE email='raghuram@email.test.com' and RecordType.DeveloperName='DRL_Prospect' limit 1];          

            DRL_ConvertLeadProspectController.ConvertLeadDataWrapper objResponse=DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(objProspect.Id));            

            Account objAccount = new Account();
            objAccount.Name = objLead.Company;
            objAccount.Industry__c = 'Generics';

            Contact objContact = new Contact();
            objContact.LastName = objLead.LastName;
            objContact.email = objLead.email;
            objContact.Job_Level__c = 'CXO/Head';
            objContact.Department__c = 'Regulatory';   

            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Name = objLead.Company+' '+ objProduct.Name;
            objOpportunity.RecordTypeId = opportunityRecordTypeId;
            objOpportunity.CurrencyIsoCode = 'EUR';
            objOpportunity.Target_Markets__c = 'North Asia';
            objOpportunity.CloseDate = System.today().addDays(2);
            objOpportunity.StageName = 'Lead Generation';
            objOpportunity.Lead_Converted_From__c = objLead.Id;

            Map<String,String> map_strrunAfter=new Map<String,String>();
            map_strrunAfter.put(String.valueOf(objLead.Id),'Immediately');

            objResponse=DRL_ConvertLeadProspectController.convertLead(  String.valueOf(objProspect.Id),
                                                                        objAccount,
                                                                        objContact,
                                                                        null,
                                                                        new List<Opportunity>{objOpportunity},
                                                                        objResponse.listProspectChildLeads,
                                                                        null, 
                                                                        null,
                                                                        objResponse.map_catList,
                                                                        map_strrunAfter
                                                                        );
            test.stopTest();
        } 
    }
}