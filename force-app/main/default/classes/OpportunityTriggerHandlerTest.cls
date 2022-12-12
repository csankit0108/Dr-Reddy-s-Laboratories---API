@isTest
public class OpportunityTriggerHandlerTest {

    @TestSetup
    static void makeData(){

        Account objAccount = new Account(Name='Raghu Ram Enterprises');
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

        // Opportunity opp = new Opportunity();
        // opp.Name = 'Test';
        // opp.StageName='test';
        // opp.CloseDate = System.today();
        // insert opp;
        // Opportunity opp1 = new Opportunity(Name = 'Test Lead', StageName = 'Discussion',Planned_Price_at_Launch__c=120,Planned_Qty_at_launch__c=4,Planned_Year__c='3456',Source_type__c='Primary Source',CloseDate= System.today());
        // insert opp1;
        // Opportunity opp2 = new Opportunity(Name = 'Test opp1', StageName = 'Sample',Planned_Price_at_Launch__c=120,Planned_Qty_at_launch__c=4,Planned_Year__c='3456',Source_type__c='Primary Source',CloseDate= System.today());
        // insert opp2;
        // Opportunity opp3 = new Opportunity(Name = 'Test opp2', StageName = 'Development',Planned_Price_at_Launch__c=120,Planned_Qty_at_launch__c=4,Planned_Year__c='3456',Source_type__c='Primary Source',CloseDate= System.today());
        // insert opp3;
        // Opportunity opp4 = new Opportunity(Name = 'Test opp3', StageName = 'Bio batch ordered',Price__c=78,TotalOpportunityQuantity=90,Planned_Price_at_Launch__c=120,Planned_Qty_at_launch__c=4,Planned_Year__c='3456',Source_type__c='Primary Source',CloseDate= System.today());
        // insert opp4;
        // Opportunity opp5 = new Opportunity(Name = 'Test opp4', StageName = 'Bio batch delivered',Price__c=78,TotalOpportunityQuantity=90,Planned_Price_at_Launch__c=120,Planned_Qty_at_launch__c=4,Planned_Year__c='3456',Source_type__c='Primary Source',CloseDate= System.today());
        // insert opp5;
      /*  Opportunity opp6 = new Opportunity(Name = 'Test opp5', StageName = 'LOA / LOE',Price__c=78,TotalOpportunityQuantity=90,Planned_Price_at_Launch__c=120,Planned_Qty_at_launch__c=4,Planned_Year__c='3456',Source_type__c='Primary Source',CloseDate= System.today());
        insert opp6;
        Opportunity opp7 = new Opportunity(Name = 'Test opp6', StageName = 'Under Registration',Price__c=78,TotalOpportunityQuantity=90,Planned_Price_at_Launch__c=120,Planned_Qty_at_launch__c=4,Planned_Year__c='3456',Source_type__c='Primary Source',CloseDate= System.today());
        insert opp7;
       Opportunity opp8 = new Opportunity(Name = 'Test opp7', StageName = 'ANDA/Dossier Approval',Price__c=78,TotalOpportunityQuantity=90,Planned_Price_at_Launch__c=120,Planned_Qty_at_launch__c=4,Planned_Year__c='3456',Source_type__c='Primary Source',CloseDate= System.today());
        insert opp8;
        Opportunity opp9 = new Opportunity(Name = 'Test opp8', StageName = 'Commercial',Price__c=78,TotalOpportunityQuantity=90,Planned_Price_at_Launch__c=120,Planned_Qty_at_launch__c=4,Planned_Year__c='3456',Source_type__c='Primary Source',CloseDate= System.today());
        insert opp9;
        Opportunity opp10 = new Opportunity(Name = 'Test opp9', StageName = 'Postponed / Hold',Price__c=78,TotalOpportunityQuantity=90,Planned_Price_at_Launch__c=120,Planned_Qty_at_launch__c=4,Planned_Year__c='3456',Source_type__c='Primary Source',CloseDate= System.today());
        insert opp10;
        Opportunity opp11 = new Opportunity(Name = 'Test opp10', StageName = 'Lost',Price__c=78,TotalOpportunityQuantity=90,Planned_Price_at_Launch__c=120,Planned_Qty_at_launch__c=4,Planned_Year__c='3456',Source_type__c='Primary Source',CloseDate= System.today());
        insert opp11;
        Opportunity opp12 = new Opportunity(Name = 'Test opp11', Reason_for_Loss__c='IP Risk',StageName = 'Dropped',Price__c=78,TotalOpportunityQuantity=90,Planned_Price_at_Launch__c=120,Planned_Qty_at_launch__c=4,Planned_Year__c='3456',Source_type__c='Primary Source',CloseDate= System.today());
        insert opp12;  */
        // opp.StageName = 'Discussion';
        // opp.Planned_Price_at_Launch__c = 100;
        // opp.Planned_Qty_at_launch__c = 2;
        // opp.Planned_Year__c = '2015';
        // opp.Source_type__c = 'Primary Source';
        // update opp;
      /*  opp.StageName = 'Sample';
        update opp;
        
        opp.StageName = 'Development';
        opp.CPR__c = 'Discussion';
        opp.Planned_Price_at_Launch__c = 100;
        opp.Planned_Qty_at_launch__c = 2;
        opp.Planned_Year__c = '2015';
        opp.Source_type__c = 'Primary Source';
        update opp;
        opp.StageName = 'Bio batch ordered';
        opp.Planned_Price_at_Launch__c = 100;
        opp.Planned_Qty_at_launch__c = 2;
        opp.Planned_Year__c = '2015';
        
        opp.Price__c=45;
        opp.TotalOpportunityQuantity=8;
        update opp;
        opp.StageName = 'Bio batch delivered';
        update opp;
        opp.StageName = 'LOA / LOE';
        update opp; 
        
        
        opp.StageName = 'Under Registration';
        update opp;
        opp.StageName = 'ANDA/Dossier Approval';
        update opp;
        opp.StageName = 'Commercial';
        update opp; 
        opp.StageName = 'Postponed / Hold';
        update opp; 
        opp.StageName = 'Lost';
        opp.Reason_for_Loss__c=	'IP Risk';
        update opp;
        opp.StageName = 'Dropped';
        opp.Reason_for_Loss__c=	'IP Risk';
        update opp;  */
        /*
        List<Opportunity> oppList = new List<Opportunity>{opp};
            Test.setMock(HttpCalloutMock.class, new SendOpportunityMock());  
        OpportunityTriggerHandler.sendOppToPanorama(oppList);
        */
        
    }
}