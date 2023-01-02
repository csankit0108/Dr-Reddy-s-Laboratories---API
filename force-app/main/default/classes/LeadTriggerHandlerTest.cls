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
    static void testLeadTrigger(){
        Product2 pr = new Product2();
        pr.Name = 'Test Product';
        pr.ProductCode = '123445';
        insert pr;

        List<Lead> list_LeadsToInsert = new List<Lead> () ;
        List<Lead> list_LeadsToUpdate = new List<Lead> () ;
        Lead ld = new Lead(
            LastName = 'Test Lead', 
            Company = 'Test company', 
            Email = 'test@test.com', 
            Status_Change_Date__c = Date.today().addDays(-7), 
            Status='Open', 
            Select_Country__c='United_States__c',
            OwnerId =UserInfo.getUserId());        
        list_LeadsToInsert.add(ld);

        Lead ld1 = new Lead(
            LastName = 'Test Lead1', 
            Company = 'Test company1', 
            Email = 'test1@test.com', 
            Status_Change_Date__c = Date.today().addDays(-7), 
            Status='Unqualified',
            Select_Country__c='United_States__c',
            OwnerId =UserInfo.getUserId());
        list_LeadsToInsert.add(ld1);
        
        Lead ld2 = new Lead(
            LastName = 'Test Lead2', 
            Company = 'Test company2', 
            Email = 'test2@test.com', 
            Status_Change_Date__c = Date.today().addDays(-7), 
            Status='Qualified', 
            Run_Automation__c ='Yes',
            Prospect_Customer__c='Prospect',
            Select_Country__c='United_States__c',
            OwnerId =UserInfo.getUserId());
        list_LeadsToInsert.add(ld2);
        
        Lead ld3 = new Lead(
            LastName = 'Test Lead3', 
            Company = 'Test company3', 
            Email = 'test3@test.com', 
            Status_Change_Date__c = Date.today().addDays(-7),
            Product_Lookup__c=pr.Id, 
            Status='Contacted', 
            Select_Country__c='United_States__c',
            OwnerId =UserInfo.getUserId());
        list_LeadsToInsert.add(ld3);
        
        Lead ld4 = new Lead(
            LastName = 'Test Lead4', 
            Company = 'Test company4', 
            Email = 'test4@test.com', 
            Status_Change_Date__c = Date.today().addDays(-7), 
            Status='On Hold/Postponed', 
            Select_Country__c='United_States__c',
            OwnerId =UserInfo.getUserId());
        list_LeadsToInsert.add(ld4);
        
        Lead ld5 = new Lead(
            LastName = 'Test Lead5', 
            Company = 'Test company5', 
            Email = 'test5@test.com', 
            Status_Change_Date__c = Date.today().addDays(-7), 
            Status='Declined',	
            Reason_for_Decline__c='IP Risk', 
            Select_Country__c='United_States__c',
            OwnerId =UserInfo.getUserId());
        list_LeadsToInsert.add(ld5);

        Lead ld6 = new Lead(
            LastName = 'Test Lead6', 
            Company = 'Test company6', 
            Email = 'test6@test.com', 
            Status_Change_Date__c = Date.today().addDays(-7), 
            Status='Converted',
            Select_Country__c='United_States__c',
            OwnerId =UserInfo.getUserId());
        list_LeadsToInsert.add(ld6);

        Test.startTest();
        insert list_LeadsToInsert;  

        ld.Status = 'Unqualified';
        list_LeadsToUpdate.add(ld);

        ld1.Run_Automation__c = 'Yes';
        ld1.Prospect_customer__c = 'Prospect';
        ld1.Status = 'Qualified';
        ld1.Product_Lookup__c = pr.Id;        
        list_LeadsToUpdate.add(ld1);

        ld2.Product_Lookup__c = pr.Id; 
        ld2.Status = 'Contacted';
        list_LeadsToUpdate.add(ld2);

        ld3.Status = 'On Hold/Postponed';
        list_LeadsToUpdate.add(ld3);

        ld4.Status = 'Declined';
        ld4.Reason_for_Decline__c='IP Risk';
        list_LeadsToUpdate.add(ld4);

        ld5.Status = 'Converted';
        list_LeadsToUpdate.add(ld5);
        update list_LeadsToUpdate;

        List<Lead> leadList = new List<Lead>{ld5};
        //Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SendOpportunityMock());  
        LeadTriggerHandler.sendLeadToPanorama(leadList);
        Test.stopTest();
        
    }

    @isTest
    static void testCheckForMailerConfigsAfterLeadConversion(){
       Product2 pr = new Product2();
        pr.Name = 'Test Product';
        pr.ProductCode = '123445';
        insert pr;
        Lead ld1 = new Lead(LastName = 'Test Lead', Company = 'Test company', 
        Email = 'test@test.com', Status_Change_Date__c = Date.today().addDays(-7), Status='Open', Select_Country__c='United States',
        OwnerId =UserInfo.getUserId(), Current_Mailer_Sent__c = 'Mailer 1');
        insert ld1;
        Lead ld2 = new Lead(LastName = 'Test Lead', Company = 'Test company', 
        Email = 'test@test.com', Status_Change_Date__c = Date.today().addDays(-7), Status='Open', Select_Country__c='United States',
        OwnerId =UserInfo.getUserId());
        insert ld2;
        Test.startTest();
        ld2.Run_Automation__c = 'Yes';
        ld2.Prospect_customer__c = 'Prospect';
        ld2.Status = 'Contacted';
        ld2.Product_Lookup__c = pr.Id;
        update ld2;
        ld1.Run_Automation__c = 'Yes';
        ld1.Status = 'Converted';

        update ld1;
        Test.stopTest();
    }
}