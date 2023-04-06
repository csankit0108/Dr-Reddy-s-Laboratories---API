@isTest
public class LeadReminderEmailSchedulerTest{
    @isTest
    static void testScheduler(){
        
        Product2 objProduct = new Product2();
        objProduct.Name = 'APREPITANT';
        objProduct.ProductCode = '00001';
        objProduct.PQT_Product_Cluster__c = 'APREPITANT';
        insert objProduct;       
        
        Lead objLead = new Lead( LastName = 'Test Lead', 
                            Company = 'Test company', 
                            Email = 'test@test.com', 
                            Status_Change_Date__c = Date.today().addDays(-7), 
                            Status = 'Contacted', 
                            Select_Country__c = 'United_States__c',
                            OwnerId = UserInfo.getUserId(),
                            Product_Lookup__c = objProduct.Id );
        insert objLead;

        Test.startTest();
        LeadReminderEmailScheduler sch = new LeadReminderEmailScheduler();
        sch.execute(null);
        Test.stopTest();
    }

}