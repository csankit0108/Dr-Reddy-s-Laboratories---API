@isTest
public class OpportunityTriggerHandlerTest {

    @TestSetup
    static void makeData(){

        Account objAccount = new Account(Name='Raghu Ram Enterprises');
        objAccount.Is_Parent__c = true;
        insert objAccount;

        Contact objContact = new Contact(
                                        LastName = 'Raghu Ram',
                                        Email = 'raghuram@testemail.com'
                                        );
        insert objContact ;
        
    }

    @isTest
    public static void testMethod1(){

        Test.setMock(HttpCalloutMock.class, new SendOpportunityMock());  

        ID APIoptyRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('API').getRecordTypeId();

        Account objAccount = [select Id from Account where Name = 'Raghu Ram Enterprises' limit 1];

        Contact objContact = [select id from Contact where Email = 'raghuram@testemail.com'  limit 1];

        List<Opportunity> list_Opportunities= new List<Opportunity>();
        
        Opportunity objOpportunity = new Opportunity(
                                                    RecordTypeId = APIoptyRecordTypeID,
                                                    Name = 'Test Opportunity 1',
                                                    AccountId = objAccount.Id,
                                                    Contact__c = objContact.Id,
                                                    CloseDate = system.today(),
                                                    StageName = 'Discussion',
                                                    Source_type__c = 'Primary Source',
                                                    Launch_Date__c = system.today(),
                                                    TotalOpportunityQuantity = 10,
                                                    Price__c = 10,
                                                    Bypass_Validation__c=true,
                                                    Planned_Price_at_Launch__c=10,
                                                    Planned_Qty_at_launch__c=10,
                                                    Planned_Year__c = '2001'                                                    
                                                    );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId = APIoptyRecordTypeID,
                                        Name = 'Test Opportunity 2',
                                        AccountId = objAccount.Id,
                                        Contact__c = objContact.Id,
                                        CloseDate = system.today(),
                                        StageName = 'Sample',
                                        Source_type__c = 'Primary Source',
                                        Launch_Date__c = system.today(),
                                        TotalOpportunityQuantity = 10,
                                        Price__c = 10,
                                        Bypass_Validation__c=true,
                                        Planned_Price_at_Launch__c=10,
                                        Planned_Qty_at_launch__c=10,
                                        Planned_Year__c = '2001'                                        
                                        );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId = APIoptyRecordTypeID,
                                        Name = 'Test Opportunity 3',
                                        AccountId = objAccount.Id,
                                        Contact__c = objContact.Id,
                                        CloseDate = system.today(),
                                        StageName = 'Development',
                                        Source_type__c = 'Primary Source',
                                        Launch_Date__c = system.today(),
                                        TotalOpportunityQuantity = 10,
                                        Price__c = 10,
                                        Bypass_Validation__c=true,
                                        Planned_Price_at_Launch__c=10,
                                        Planned_Qty_at_launch__c=10,
                                        Planned_Year__c = '2001'                                        
                                        );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId = APIoptyRecordTypeID,
                                        Name = 'Test Opportunity 4',
                                        AccountId = objAccount.Id,
                                        Contact__c = objContact.Id,
                                        CloseDate = system.today(),
                                        StageName = 'Bio Batches',
                                        Source_type__c = 'Primary Source',
                                        Launch_Date__c = system.today(),
                                        TotalOpportunityQuantity = 10,
                                        Price__c = 10,
                                        Bypass_Validation__c=true,
                                        Planned_Price_at_Launch__c=10,
                                        Planned_Qty_at_launch__c=10,
                                        Planned_Year__c = '2001'                                        
                                        );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId = APIoptyRecordTypeID,
                                        Name = 'Test Opportunity 5',
                                        AccountId = objAccount.Id,
                                        Contact__c = objContact.Id,
                                        CloseDate = system.today(),
                                        StageName = 'Exhibit Batches',
                                        Source_type__c = 'Primary Source',
                                        Launch_Date__c = system.today(),
                                        TotalOpportunityQuantity = 10,
                                        Price__c = 10,
                                        Bypass_Validation__c=true,
                                        Planned_Price_at_Launch__c=10,
                                        Planned_Qty_at_launch__c=10,
                                        Planned_Year__c = '2001'                                        
                                        );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId = APIoptyRecordTypeID,
                                        Name = 'Test Opportunity 6',
                                        AccountId = objAccount.Id,
                                        Contact__c = objContact.Id,
                                        CloseDate = system.today(),
                                        StageName = 'LOA / LOE',
                                        Source_type__c = 'Primary Source',
                                        Launch_Date__c = system.today(),
                                        TotalOpportunityQuantity = 10,
                                        Price__c = 10,
                                        Bypass_Validation__c=true,
                                        Planned_Price_at_Launch__c=10,
                                        Planned_Qty_at_launch__c=10,
                                        Planned_Year__c = '2001'                                        
                                        );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId = APIoptyRecordTypeID,
                                        Name = 'Test Opportunity 7',
                                        AccountId = objAccount.Id,
                                        Contact__c = objContact.Id,
                                        CloseDate = system.today(),
                                        StageName = 'ANDA Filed',
                                        Source_type__c = 'Primary Source',
                                        Launch_Date__c = system.today(),
                                        TotalOpportunityQuantity = 10,
                                        Price__c = 10,
                                        Bypass_Validation__c = true,
                                        Planned_Price_at_Launch__c = 10,
                                        Planned_Qty_at_launch__c = 10,
                                        Planned_Year__c = '2001'                                        
                                        );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId = APIoptyRecordTypeID,
                                        Name = 'Test Opportunity 8',
                                        AccountId = objAccount.Id,
                                        Contact__c = objContact.Id,
                                        CloseDate = system.today(),
                                        StageName = 'DCP/MRP',
                                        Source_type__c = 'Primary Source',
                                        Launch_Date__c = system.today(),
                                        TotalOpportunityQuantity = 10,
                                        Price__c = 10,
                                        Bypass_Validation__c = true,
                                        Planned_Price_at_Launch__c = 10,
                                        Planned_Qty_at_launch__c = 10,
                                        Planned_Year__c = '2001'                                        
                                        );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId = APIoptyRecordTypeID,
                                        Name = 'Test Opportunity 9',
                                        AccountId = objAccount.Id,
                                        Contact__c = objContact.Id,
                                        CloseDate = system.today(),
                                        StageName = 'Dossier Filed',
                                        Source_type__c = 'Primary Source',
                                        Launch_Date__c = system.today(),
                                        TotalOpportunityQuantity = 10,
                                        Price__c = 10,
                                        Bypass_Validation__c = true,
                                        Planned_Price_at_Launch__c = 10,
                                        Planned_Qty_at_launch__c = 10,
                                        Planned_Year__c = '2001'                                        
                                        );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId = APIoptyRecordTypeID,
                                        Name = 'Test Opportunity 10',
                                        AccountId = objAccount.Id,
                                        Contact__c = objContact.Id,
                                        CloseDate = system.today(),
                                        StageName = 'Marketing License',
                                        Source_type__c = 'Primary Source',
                                        Launch_Date__c = system.today(),
                                        TotalOpportunityQuantity = 10,
                                        Price__c = 10,
                                        Bypass_Validation__c = true,
                                        Planned_Price_at_Launch__c = 10,
                                        Planned_Qty_at_launch__c = 10,
                                        Planned_Year__c = '2001'                                        
                                        );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId = APIoptyRecordTypeID,
                                        Name = 'Test Opportunity 11',
                                        AccountId = objAccount.Id,
                                        Contact__c = objContact.Id,
                                        CloseDate = system.today(),
                                        StageName = 'ANDA Approved',
                                        Source_type__c = 'Primary Source',
                                        Launch_Date__c = system.today(),
                                        TotalOpportunityQuantity = 10,
                                        Price__c = 10,
                                        Bypass_Validation__c = true,
                                        Planned_Price_at_Launch__c = 10,
                                        Planned_Qty_at_launch__c = 10,
                                        Planned_Year__c = '2001'                                        
                                        );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId = APIoptyRecordTypeID,
                                        Name = 'Test Opportunity 12',
                                        AccountId = objAccount.Id,
                                        Contact__c = objContact.Id,
                                        CloseDate = system.today(),
                                        StageName = 'MA (Marketing Authorization)',
                                        Source_type__c = 'Primary Source',
                                        Launch_Date__c = system.today(),
                                        TotalOpportunityQuantity = 10,
                                        Price__c = 10,
                                        Bypass_Validation__c = true,
                                        Planned_Price_at_Launch__c = 10,
                                        Planned_Qty_at_launch__c = 10,
                                        Planned_Year__c = '2001'                                        
                                        );
        list_Opportunities.add(objOpportunity);
        
        objOpportunity = new Opportunity(
                                        RecordTypeId=APIoptyRecordTypeID,
                                        Name='Test Opportunity 13',
                                        AccountId=objAccount.Id,
                                        Contact__c=objContact.Id,
                                        CloseDate=system.today(),
                                        StageName='Commercial',
                                        Source_type__c ='Primary Source',
                                        Launch_Date__c=system.today(),
                                        TotalOpportunityQuantity=10,
                                        Price__c=10,
                                        Bypass_Validation__c = true,
                                        Planned_Price_at_Launch__c = 10,
                                        Planned_Qty_at_launch__c = 10,
                                        Planned_Year__c = '2001'
                                        );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId=APIoptyRecordTypeID,
                                        Name='Test Opportunity 14',
                                        AccountId=objAccount.Id,
                                        Contact__c=objContact.Id,
                                        CloseDate=system.today(),
                                        StageName='Dropped',
                                        Reason__c = 'Due to Delay',
                                        Source_type__c ='Primary Source',
                                        Launch_Date__c=system.today(),
                                        TotalOpportunityQuantity=10,
                                        Price__c=10,
                                        Bypass_Validation__c=true,
                                        Planned_Price_at_Launch__c=10,
                                        Planned_Qty_at_launch__c=10,
                                        Planned_Year__c = '2001',
                                        Reason_for_Loss__c='Customer Related'
                                        );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId=APIoptyRecordTypeID,
                                        Name='Test Opportunity 15',
                                        AccountId=objAccount.Id,
                                        Contact__c=objContact.Id,
                                        CloseDate=system.today(),
                                        StageName='Postponed / Hold',
                                        Reason__c = 'Due to Delay',
                                        Source_type__c ='Primary Source',
                                        Launch_Date__c=system.today(),
                                        TotalOpportunityQuantity=10,
                                        Price__c=10,
                                        Bypass_Validation__c=true,
                                        Planned_Price_at_Launch__c=10,
                                        Planned_Qty_at_launch__c=10,
                                        Planned_Year__c = '2001',
                                        Reason_for_Loss__c='Customer Related'
                                        );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId=APIoptyRecordTypeID,
                                        Name='Test Opportunity 16',
                                        AccountId=objAccount.Id,
                                        Contact__c=objContact.Id,
                                        CloseDate=system.today(),
                                        StageName='Lead Generation',
                                        Source_type__c ='Primary Source',
                                        Launch_Date__c=system.today(),
                                        TotalOpportunityQuantity=10,
                                        Price__c=10,
                                        Bypass_Validation__c = true,
                                        Planned_Price_at_Launch__c = 10,
                                        Planned_Qty_at_launch__c = 10,
                                        Planned_Year__c = '2001'
                                        );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId=APIoptyRecordTypeID,
                                        Name='Test Opportunity 17',
                                        AccountId=objAccount.Id,
                                        Contact__c=objContact.Id,
                                        CloseDate=system.today(),
                                        StageName='Bio batch ordered',
                                        Source_type__c ='Primary Source',
                                        Launch_Date__c=system.today(),
                                        TotalOpportunityQuantity=10,
                                        Price__c=10,
                                        Bypass_Validation__c = true,
                                        Planned_Price_at_Launch__c = 10,
                                        Planned_Qty_at_launch__c = 10,
                                        Planned_Year__c = '2001'
                                        );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId=APIoptyRecordTypeID,
                                        Name='Test Opportunity 18',
                                        AccountId=objAccount.Id,
                                        Contact__c=objContact.Id,
                                        CloseDate=system.today(),
                                        StageName='Bio batch delivered',
                                        Source_type__c ='Primary Source',
                                        Launch_Date__c=system.today(),
                                        TotalOpportunityQuantity=10,
                                        Price__c=10,
                                        Bypass_Validation__c = true,
                                        Planned_Price_at_Launch__c = 10,
                                        Planned_Qty_at_launch__c = 10,
                                        Planned_Year__c = '2001'
                                        );
        list_Opportunities.add(objOpportunity);

        objOpportunity = new Opportunity(
                                        RecordTypeId=APIoptyRecordTypeID,
                                        Name='Test Opportunity 19',
                                        AccountId=objAccount.Id,
                                        Contact__c=objContact.Id,
                                        CloseDate=system.today(),
                                        StageName='Postponed / Hold',
                                        Reason__c = 'Due to Delay',
                                        Source_type__c ='Primary Source',
                                        Launch_Date__c=system.today(),
                                        TotalOpportunityQuantity=10,
                                        Price__c=10,
                                        Bypass_Validation__c=true,
                                        Planned_Price_at_Launch__c=10,
                                        Planned_Qty_at_launch__c=10,
                                        Planned_Year__c = '2001',
                                        Reason_for_Loss__c='Customer Related',
                                        CPR__c='Customer Related'
                                        );
        list_Opportunities.add(objOpportunity);

        insert list_Opportunities;

        OpportunityTriggerHandler.status = true;
        objOpportunity.StageName='Discussion';
        update objOpportunity;
        
    }
}