/*******************************************************************************************************
* 
* @ Name            :   DRL_LeadCleanupBatchTest
* @ Purpose         :   Test class for DRL_LeadCleanupBatch
* @ Author          :   Kishore Pedireddy
*
*   Date            |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   29-12-2022      |  kishore.pedieddy@absyz.com           |  1.0          |  Initial Version
*******************************************************************************************************/
@isTest
public class DRL_LeadCleanupBatchTest {
    public static Boolean blnThrowException = false;
    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to setup data for testing batch class 'DRL_LeadCleanupBatch'
    **/
    @TestSetup
    static void createData() {
        Account objAccount = new DRL_TestUtility.AccountBuilder()
            .setName('Test Account')
            .createAccount();
        insert objAccount;

        Contact objContact = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test')
            .setLastName('Contact')
            .setAccountId(objAccount.Id)
            .createContact();
        insert objContact;
        
        Product2 objProduct = new DRL_TestUtility.ProductBuilder()
            .setName('Test Product')
            .createProduct();
        objProduct.ProductCode='PROD0001';
        insert objProduct;

        Profile objProfile = [SELECT Id FROM Profile where Name = 'Copy System Admin'];

        User objUser = new DRL_TestUtility.UserBuilder()
            .setFirstName('Test')
            .setLastName('User')
            .setEmail('testuser@email.com')
            .setProfileId(objProfile.Id)
            .setUsername('testuser@drl.absyz.email.com')
            .setAlias('testUser')
            .setTimeZoneSidKey('America/Los_Angeles')
            .setLocaleSidKey('en_US')
            .setEmailEncodingKey('ISO-8859-1')
            .setLanguageLocaleKey('en_US')
            .createUser();
        insert objUser;
    }

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  test method to test the Updation of recordtypes
    **/
    @isTest
    private static void testLeadRecordTypeUpdate() {
        User objUser = [SELECT Id FROM User WHERE Email = 'testuser@email.com' LIMIT 1];
        System.runAs(objuser) {
            Product2 objProduct = [SELECT Id FROM Product2 LIMIT 1];
            DRL_LeadTriggerHelper.blnSkipTrigger = true;
            List<Lead> list_Leads = new List<Lead>();
            Lead objLead = new Lead();
            objLead.FirstName = 'Test';
            objLead.LastName = 'Lead1';
            objLead.Email = 'testlead1@yopmail.com';
            objLead.Company = 'Test Lead 1';
            objLead.Product_Lookup__c = objProduct.Id;
            objLead.Select_Country__c = 'India';
            objLead.DRL_IsProspect__c = true;
            list_Leads.add(objLead);
            objLead = new Lead();
            objLead.FirstName = 'Test';
            objLead.LastName = 'Lead2';
            objLead.Email = 'testlead1@yopmail.com';
            objLead.Company = 'Test Lead 1';
            objLead.Status = 'Unqualified';
            objLead.Product_Lookup__c = objProduct.Id;
            list_Leads.add(objLead);
            objLead = new Lead();
            objLead.FirstName = 'Test';
            objLead.LastName = 'Lead4';
            objLead.Email = 'testlead1@yopmail.com';
            objLead.Company = 'Test Lead 1';
            objLead.Status = 'Qualified';
            objLead.Run_Automation__c='Yes';
            objLead.Prospect_Customer__c='Prospect';
            objLead.Product_Lookup__c = objProduct.Id;
            list_Leads.add(objLead);
            objLead = new Lead();
            objLead.FirstName = 'Test';
            objLead.LastName = 'Lead3';
            objLead.Company = 'Absyz';                      
            list_Leads.add(objLead);
    
            Test.startTest();
            insert list_Leads;
            list_Leads = [SELECT Id FROM Lead WHERE RecordTypeId = null];
            System.assert(list_Leads.size() == 4, 'Master Lead record Creation Failed!');

            DRL_LeadTriggerHelper.blnSkipTrigger = false;
            Database.executeBatch(new DRL_LeadCleanupBatch());
            Test.stopTest();
            List<Lead> list_Prospects = [SELECT Id FROM Lead WHERE Recordtype.Developername = 'DRL_Prospect' ];
            System.assert(list_Prospects.size() == 1, 'Prospect Creation for Leads with Email Failed!');
            list_Leads = [SELECT Id FROM Lead WHERE Recordtype.Developername = 'DRL_Lead' ];
            System.assert(list_Leads.size() == 4, 'Lead Update Successful');
        }
    }

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  Test method to cover catch block
    **/
    @isTest
    private static void testExceptions() {
        User objUser = [SELECT Id FROM User WHERE Email='testuser@email.com' LIMIT 1];
        System.runAs(objuser) {
            DRL_LeadTriggerHelper.blnSkipTrigger = true;
            Lead objLead = new Lead();
            objLead.FirstName = 'Test';
            objLead.LastName = 'Lead1';
            objLead.Email = 'testlead1@yopmail.com';
            objLead.Company = 'Test Lead 1';
            insert objLead;
            DRL_LeadTriggerHelper.blnSkipTrigger = false;

            Test.startTest();
            blnThrowException = true;
            DRL_LeadCleanupBatch objLeadBatchUpdate = new DRL_LeadCleanupBatch();
            Database.executeBatch(new DRL_LeadCleanupBatch());
            Test.stopTest();
            blnThrowException = false;
        }
    }    
}