/*******************************************************************************************************
* 
* @ Name            :   LeadTriggerHandlerTest
* @ Purpose         :   Test class for LeadTriggerHandler
* @ Author          :   
*
*   Date            |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   08-12-2022      |  subhodeep.sarkar@absyz.com            |  1.0          |  Updated Version
*******************************************************************************************************/
@isTest
public class LeadTriggerHandlerTest {
    @isTest
    static void testLeadTrigger() {
        Product2 objProduct = new Product2();
        objProduct.Name = 'Test Product';
        objProduct.ProductCode = '123445';
        insert objProduct;

        List<Lead> list_LeadsToInsert = new List<Lead>();
        List<Lead> list_LeadsToUpdate = new List<Lead>();
        Lead objLead = new Lead(
            LastName = 'Test Lead', 
            Company = 'Test company', 
            Email = 'test@test.com', 
            Status_Change_Date__c = Date.today().addDays(-7), 
            Status = 'Open', 
            Select_Country__c = 'United_States__c',
            OwnerId = UserInfo.getUserId()
        );        
        list_LeadsToInsert.add(objLead);

        Lead objLead1 = new Lead(
            LastName = 'Test Lead1', 
            Company = 'Test company1', 
            Email = 'test1@test.com', 
            Status_Change_Date__c = Date.today().addDays(-7), 
            Status = 'Unqualified',
            Select_Country__c = 'United_States__c',
            OwnerId = UserInfo.getUserId()
        );
        list_LeadsToInsert.add(objLead1);
        
        Lead objLead2 = new Lead(
            LastName = 'Test Lead2', 
            Company = 'Test company2', 
            Email = 'test2@test.com', 
            Status_Change_Date__c = Date.today().addDays(-7), 
            Status='Qualified', 
            Run_Automation__c ='Yes',
            Prospect_Customer__c='Prospect',
            Select_Country__c='United_States__c',
            OwnerId =UserInfo.getUserId()
        );
        list_LeadsToInsert.add(objLead2);
        
        Lead objLead3 = new Lead(
            LastName = 'Test Lead3', 
            Company = 'Test company3', 
            Email = 'test3@test.com', 
            Status_Change_Date__c = Date.today().addDays(-7),
            Product_Lookup__c = objProduct.Id, 
            Status = 'Contacted', 
            Select_Country__c = 'United_States__c',
            OwnerId = UserInfo.getUserId()
        );
        list_LeadsToInsert.add(objLead3);
        
        Lead objLead4 = new Lead(
            LastName = 'Test Lead4', 
            Company = 'Test company4', 
            Email = 'test4@test.com', 
            Status_Change_Date__c = Date.today().addDays(-7), 
            Status='On Hold/Postponed', 
            Select_Country__c='United_States__c',
            OwnerId =UserInfo.getUserId());
        list_LeadsToInsert.add(objLead4);
        
        Lead objLead5 = new Lead(
            LastName = 'Test Lead5', 
            Company = 'Test company5', 
            Email = 'test5@test.com', 
            Status_Change_Date__c = Date.today().addDays(-7), 
            Status = 'Declined',	
            Reason_for_Decline__c ='IP Risk', 
            Select_Country__c ='United_States__c',
            OwnerId = UserInfo.getUserId()
        );
        list_LeadsToInsert.add(objLead5);

        Lead objLead6 = new Lead(
            LastName = 'Test Lead6', 
            Company = 'Test company6', 
            Email = 'test6@test.com', 
            Status_Change_Date__c = Date.today().addDays(-7), 
            Status = 'Converted',
            Select_Country__c = 'United_States__c',
            OwnerId = UserInfo.getUserId()
        );
        list_LeadsToInsert.add(objLead6);

        Test.startTest();
        insert list_LeadsToInsert;  

        objLead.Status = 'Unqualified';
        list_LeadsToUpdate.add(objLead);

        objLead1.Run_Automation__c = 'Yes';
        objLead1.Prospect_customer__c = 'Prospect';
        objLead1.Status = 'Qualified';
        objLead1.Product_Lookup__c = objProduct.Id;        
        list_LeadsToUpdate.add(objLead1);

        objLead2.Product_Lookup__c = objProduct.Id; 
        objLead2.Status = 'Contacted';
        list_LeadsToUpdate.add(objLead2);

        objLead3.Status = 'On Hold/Postponed';
        list_LeadsToUpdate.add(objLead3);

        objLead4.Status = 'Declined';
        objLead4.Reason_for_Decline__c = 'IP Risk';
        list_LeadsToUpdate.add(objLead4);

        objLead5.Status = 'Converted';
        list_LeadsToUpdate.add(objLead5);
        update list_LeadsToUpdate;

        List<Lead> list_Leads = new List<Lead>{ objLead5 };
        Test.setMock(HttpCalloutMock.class, new SendOpportunityMock());  
        LeadTriggerHandler.sendLeadToPanorama(list_Leads);
        Test.stopTest();
    }

    @isTest
    static void testCheckForMailerConfigsAfterLeadConversion() {
        List<Lead> list_LeadsToInsert = new List<Lead>();
        List<Lead> list_LeadsToUpdate = new List<Lead>();

        Product2 objProduct = new Product2();
        objProduct.Name = 'Test Product';
        objProduct.ProductCode = '123445';
        insert objProduct;

        Lead objLead1 = new Lead(
            LastName = 'Test Lead', 
            Company = 'Test company', 
            Email = 'test@test.com', 
            Status_Change_Date__c = Date.today().addDays(-7), 
            Status = 'Open', 
            Select_Country__c = 'United States',
            OwnerId = UserInfo.getUserId(), 
            Current_Mailer_Sent__c = 'Mailer 1'
        );
        list_LeadsToInsert.add(objLead1);

        Lead objLead2 = new Lead(
            LastName = 'Test Lead', 
            Company = 'Test company', 
            Email = 'test@test.com', 
            Status_Change_Date__c = Date.today().addDays(-7), 
            Status = 'Open', 
            Select_Country__c = 'United States',
            OwnerId = UserInfo.getUserId()
        );
        list_LeadsToInsert.add(objLead2);

        insert list_LeadsToInsert;

        Test.startTest();
        objLead2.Run_Automation__c = 'Yes';
        objLead2.Prospect_customer__c = 'Prospect';
        objLead2.Status = 'Contacted';
        objLead2.Product_Lookup__c = objProduct.Id;
        list_LeadsToUpdate.add(objLead2);

        objLead1.Run_Automation__c = 'Yes';
        objLead1.Status = 'Converted';
        list_LeadsToUpdate.add(objLead1);

        update list_LeadsToUpdate;
        Test.stopTest();
    }
}