/*******************************************************************************************************
* 
* @ Name            :   DRL_OfflineOpportunityTest
* @ Purpose         :   Test Class for trigger OfflineOpportunity
* @ Author          :   Kishore Pedireddy
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*    12-12-2022     |  Kishore Pedireddy            |   1.0         |  Initial Version
*******************************************************************************************************/
@isTest
public class DRL_OfflineOpportunityTest {
    @TestSetup
    static void makeData(){

        Account objAccount = new Account();
        objAccount.Name='Raghu Enterprises';
        objAccount.Copy_Address__c=true;
        objAccount.Geography__c='Other';
        objAccount.Other_Country__c='India';
        objAccount.Billing_Street__c='Prakash Nagar';
        objAccount.Billing_State1__c='Hyderabad';
        objAccount.Billing_City__c='A.p';
        objAccount.Billing_Country__c='India';
        objAccount.Postal_Code__c='500016';       
        insert objAccount;

        Contact objContact = new Contact();
        objContact.AccountID=objAccount.Id;
        objContact.LastName='raghu';
        objContact.Email='raghu@testmail.com';
        insert objContact;

        Profile objProfile = [SELECT Id FROM profile WHERE name='Marketing User'];

        User objUser = new User(
                        alias = 'raghu',
                        email = 'raghu@testmail.com',
                        emailencodingkey = 'UTF-8',
                        lastname = 'raghu',
                        languagelocalekey = 'en_US',
                        localesidkey = 'en_US',
                        profileid = objProfile.Id,
                        timezonesidkey = 'America/Los_Angeles', 
                        username = 'usersar@domain.com' );        
        insert objUser; 

        Product2 objProduct = new Product2();
        objProduct.Name = 'Abacavir';
        objProduct.Description = 'Abacavir';
        objProduct.ProductCode = '00000001';
        insert objProduct;

        MOM__c objMom = new MOM__c();
        objMom.Account__c = objAccount.Id;
        objMom.Mode_Of_Communication__c='Call';
        objMom.CurrencyIsoCode='USD';
        objMom.MOM_Date__c=System.Today();
        insert objMom;

        
        
    }
    @isTest
    public static void testCreateOfflineOpportunity() {

        User objUser=[select Id from User where Email='raghu@testmail.com' limit 1];

        Account objAccount = [select Id from Account where Name='Raghu Enterprises' limit 1];

        MOM__c objMom=[select Id from MOM__c where Account__c=:objAccount.Id limit 1];

        Product2 objProduct = [select Id from Product2 where ProductCode='00000001' limit 1];

        Contact objContact = [select Id from Contact where AccountId=:objAccount.Id limit 1];           

        Create_Opportunity__c objOfflineOpportunity = new Create_Opportunity__c();
        objOfflineOpportunity.MOM__c = objMom.Id;
        objOfflineOpportunity.Product__c = objProduct.Id;
        objOfflineOpportunity.Product_Discussion1__c = 'discussion';
        objOfflineOpportunity.IsScheduled__c = true;
        objOfflineOpportunity.Sample_Request__c = true;
        objOfflineOpportunity.Sample_Assigned_To__c = objUser.Id;
        objOfflineOpportunity.Send_Email_Notification1__c = true;        
        objOfflineOpportunity.Send_Email_Notification2__c = true;
        objOfflineOpportunity.Send_Email_Notification3__c = true;
        objOfflineOpportunity.Send_Email_Notification4__c = true;
        objOfflineOpportunity.Task_Assigned_To1__c = objContact.ID;
        objOfflineOpportunity.Task_Assigned_To2__c = objContact.ID;
        objOfflineOpportunity.Task_Assigned_To3__c = objContact.ID;
        objOfflineOpportunity.Task_Assigned_To4__c = objContact.ID;
        objOfflineOpportunity.Opportunity_Created__c='Yes';
        insert objOfflineOpportunity; 
               
    }    
}