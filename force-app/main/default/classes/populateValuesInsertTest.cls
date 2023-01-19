@isTest
public class populateValuesInsertTest {
    @TestSetup
    static void makeData(){

        Account objAccount = new Account(Name='Raghu Ram Enterprises', Is_Parent__c = true);
        insert objAccount;

        Contact objContact = new Contact(
                                        LastName = 'Raghu Ram',
                                        Email = 'raghuram@testemail.com'
                                        );
        insert objContact ;
        
    }

	@isTest
    public static void optypoulatevaluesInsertTrigger()
    {
        ID optyRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API Plus').getRecordTypeId();
        ID APIoptyRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API').getRecordTypeId();

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
        insert list_Opportunities;

        Opportunity objAPIPlusOpportunity = new Opportunity(
                                                            RecordTypeId = optyRecordTypeID,
                                                            Name = 'Test Opportunity 16',
                                                            AccountId = objAccount.Id,
                                                            Contact__c = objContact.Id,
                                                            Customer_Type__c = 'Final Seller',
                                                            API_Plus_Territory__c = 'Test Territory',
                                                            Remarks__c = 'Testing Remarks',
                                                            CloseDate = system.today(),
                                                            StageName = 'New Opportunity');
        insert objAPIPlusOpportunity;

        Account objAccount2=new Account(Name='Raja Lakshman Corporation', Is_Parent__c = true);
        insert objAccount2;
        
        objAPIPlusOpportunity.AccountId = objAccount2.Id;
        update objAPIPlusOpportunity;
        
    //     API_Plus_Opportunity__c apiplusOpty=new API_Plus_Opportunity__c(Name=objAPIPlusOpportunity.Name,API_Plus_Account_Name__c=objAPIPlusOpportunity.AccountId,API_Plus_Contact__c=objAPIPlusOpportunity.Contact__c,API_Plus_Std_Opportunity__c=objAPIPlusOpportunity.Id,API_Plus_Customer_Type__c=objAPIPlusOpportunity.Customer_Type__c,API_Plus_Territory__c=objAPIPlusOpportunity.API_Plus_Territory__c,API_Plus_Remarks__c=objAPIPlusOpportunity.Remarks__c,API_Plus_Close_Date__c=objAPIPlusOpportunity.CloseDate,API_Plus_Stage__c=objAPIPlusOpportunity.StageName,API_Plus_Proposal_Created__c=false);
    //     insert apiplusOpty;
    //     Account acc1=new Account(Name='Y Ramanji Test');
    //     insert acc1;
    //    objAPIPlusOpportunity.AccountId=acc1.Id;
    //    update objAPIPlusOpportunity;
    }
}