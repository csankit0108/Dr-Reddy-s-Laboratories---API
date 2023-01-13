public class OppClassTrigger {



    public static testMethod void  populateValuesInsertTrigger01(){
        Account acct = new Account();
        acct.Name='Test Account';
        acct.Is_Parent__c = true;
        insert acct;

        Account acct1 = new Account();
        acct1.Name='Test Account1';
        acct1.Is_Parent__c = true;
        insert acct1;
        
        Account acct2 = new Account();
        acct2.Name='Test Account2';
        acct2.Is_Parent__c = true;
        insert acct2;        

        Account acct3 = new Account();
        acct3.Name='Test Account3';
        acct3.Is_Parent__c = true;
        insert acct3;

        Account acct4 = new Account();
        acct4.Name='Test Account4';
        acct4.Is_Parent__c = true;
        insert acct4;
        
/*        Account acct5 = new Account();
        acct5.Name='Test Account5';
        insert acct5; 
        */
                        
        Product2 prod = new Product2();
        prod.Name='Test Product';
        insert prod;     
        
        List<Opportunity> list_Opportunities = new List<Opportunity>();
           
        Opportunity opt = new Opportunity();
        opt.AccountId=acct.ID;
        opt.Product__c=prod.ID;
        opt.Name=acct.Name+prod.Name;
        opt.StageName ='Discussion';
        opt.Start_Date__c = System.Today();
        opt.End_Date__c = opt.Start_Date__c + 1;   
        opt.CloseDate = System.Today()+2; 
        opt.Planned_Price_at_Launch__c = 100.00;
        opt.Planned_Qty_at_launch__c = 8.0;
        opt.Planned_Year__c = '2002';
        opt.Source_type__c = 'Primary Source';
        list_Opportunities.add(opt);   
            
        Opportunity opt1 = new Opportunity();
        opt1.AccountId=acct1.ID;
        opt1.Product__c=prod.ID;
        opt1.Name=acct1.Name+prod.Name;
        opt1.Start_Date__c = System.Today();
        opt1.End_Date__c = opt1.Start_Date__c + 1; 
        opt1.CloseDate = System.Today()+2;        
        opt1.StageName ='Postponed / Hold';
        list_Opportunities.add(opt1); 
        
        Opportunity opt2 = new Opportunity();
        opt2.AccountId=acct2.ID;
        opt2.Product__c=prod.ID;
        opt2.Name=acct2.Name+prod.Name;
        opt2.Start_Date__c = System.Today();
        opt2.End_Date__c = opt.Start_Date__c + 1; 
        opt2.CloseDate = System.Today()+2;        
        opt2.StageName ='ANDA Approved';  
        list_Opportunities.add(opt2);      

        Opportunity opt3 = new Opportunity();
        opt3.AccountId=acct3.ID;
        opt3.Product__c=prod.ID;
        opt3.Name=acct3.Name+prod.Name;
        opt3.StageName ='Development';
        opt3.Start_Date__c = System.Today();
        opt3.End_Date__c = opt.Start_Date__c + 1;   
        opt3.CloseDate = System.Today()+2;
        opt3.Planned_Price_at_Launch__c = 100.00;
        opt3.Planned_Qty_at_launch__c = 8.0;
        opt3.Planned_Year__c = '2002';
        opt3.Source_type__c = 'Primary Source';      
        list_Opportunities.add(opt3);    
            
        Opportunity opt4 = new Opportunity();
        opt4.AccountId=acct4.ID;
        opt4.Product__c=prod.ID;
        opt4.Name=acct4.Name+prod.Name;
        opt4.Start_Date__c = System.Today();
        opt4.End_Date__c = opt1.Start_Date__c + 1; 
        opt4.CloseDate = System.Today()+2;        
        opt4.StageName ='Dossier Filed';
        opt4.Planned_Price_at_Launch__c = 100.00;
        opt4.Planned_Qty_at_launch__c = 8.0;
        opt4.Planned_Year__c = '2002';
        opt4.Source_type__c = 'Primary Source';
        list_Opportunities.add(opt4); 
        Test.startTest();
        insert list_Opportunities;
        
        opt4.StageName='Development';
        update opt4;     
        Test.stopTest();            
    }
   
	public static testMethod void optyCoverage()
    {
        // added on 6th May 2021
        Account acc=new Account(Name='Y Ramanji');
        insert acc;
        Contact conTest=new Contact(FirstName='Y',LastName='Ram',Email='ramanji123@dhruvsoft.com');
        insert conTest;
        Id optyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API Plus').getRecordTypeId();
        Opportunity opty = new Opportunity(
            Name='Testing in TST Class_V',
            AccountId=acc.Id,
            Contact__c=conTest.Id,
            Customer_Type__c='Final Seller',
            API_Plus_Territory__c='Test Territory',
            Remarks__c='Testing Remarks',
            CloseDate=system.today(),
            StageName='New Opportunity',
            RecordTypeId=optyRecTypeId
        );
        Test.startTest();
        insert opty;
        opty.Customer_Type__c='Agent';
        update opty; 
        Test.stopTest();
        // added on 6th Mat 2021
    }
    public static testMethod void  populateValuesInsertTrigger02(){
        
        Account acct = new Account();
        acct.Name='Test Account';
        insert acct;
        Product2 prod = new Product2();
        prod.Name='Test Product';
        insert prod;        
           
        Opportunity opt = new Opportunity();
        opt.AccountId=acct.ID;
        opt.Product__c=prod.ID;
        opt.Name=acct.Name+prod.Name;
        opt.StageName = 'Development';
        opt.Start_Date__c = System.Today();
        opt.End_Date__c = opt.Start_Date__c + 1; 
        opt.CloseDate = System.Today()+2;opt.Planned_Price_at_Launch__c = 100.00;
        opt.Planned_Qty_at_launch__c = 8.0;
        opt.Planned_Year__c = '2002';
        opt.Source_type__c = 'Primary Source';
        Test.startTest();
        insert opt;
        Test.stopTest();
    }

    public static testMethod void populateValuesInsertTrigger03(){
        Account acct = new Account();
        acct.Name='Test Account';
        insert acct;
        Product2 prod = new Product2();
        prod.Name='Test Product';
        insert prod;        
           
        Opportunity opt = new Opportunity();
        opt.AccountId=acct.ID;
        opt.Product__c=prod.ID;
        opt.Name=acct.Name+prod.Name;
        opt.StageName ='Bio Batches';
        opt.Start_Date__c = System.Today();
        opt.End_Date__c = opt.Start_Date__c + 1;   
        opt.CloseDate = System.Today()+2;    
        Test.startTest();  
        insert opt;
        Test.stopTest();
    }



    public static testMethod void  populateValuesInsertTrigger04(){
        Account acct = new Account();
        acct.Name='Test Account';
        insert acct;
        Product2 prod = new Product2();
        prod.Name='Test Product';
        insert prod;        
           
        Opportunity opt = new Opportunity();
        opt.AccountId=acct.ID;
        opt.Product__c=prod.ID;
        opt.Name=acct.Name+prod.Name;
        opt.StageName ='Exhibit Batches';
        opt.Start_Date__c = System.Today();
        opt.End_Date__c = opt.Start_Date__c + 1;   
        opt.CloseDate = System.Today() + 2; 
        Test.startTest();     
        insert opt;
        Test.stopTest();
    }

    public static testMethod void  populateValuesInsertTrigger05(){
        Account acct = new Account();
        acct.Name='Test Account';
        insert acct;
        Product2 prod = new Product2();
        prod.Name='Test Product';
        insert prod;        
           
        Opportunity opt = new Opportunity();
        opt.AccountId=acct.ID;
        opt.Product__c=prod.ID;
        opt.Name=acct.Name+prod.Name;
        opt.StageName = 'LOA / LOE';
        opt.Start_Date__c = System.Today();
        opt.End_Date__c = opt.Start_Date__c + 1; 
        opt.CloseDate = System.Today()+2;
		opt.Planned_Price_at_Launch__c = 100.00;
        opt.Planned_Qty_at_launch__c = 8.0;
        opt.Planned_Year__c = '2002';
        opt.Source_type__c = 'Primary Source'; 
        opt.TotalOpportunityQuantity = 10;
        opt.Price__c = 100.00;     
        Test.startTest();  
        insert opt;
        Test.stopTest();
    }

    public static testMethod void populateValuesInsertTrigger06(){
        Account acct = new Account();
        acct.Name='Test Account';
        insert acct;
        Product2 prod = new Product2();
        prod.Name='Test Product';
        insert prod;        
           
        Opportunity opt = new Opportunity();
        opt.AccountId=acct.ID;
        opt.Product__c=prod.ID;
        opt.Name=acct.Name+prod.Name;
        opt.StageName ='ANDA Filed';
        opt.Start_Date__c = System.Today();
        opt.End_Date__c = opt.Start_Date__c + 1;   
        opt.CloseDate = System.Today() + 2;  
        Test.startTest();    
        insert opt;
        Test.stopTest();
    }

    public static testMethod void  populateValuesInsertTrigger07(){
        Account acct = new Account();
        acct.Name='Test Account';
        insert acct;
        Product2 prod = new Product2();
        prod.Name='Test Product';
        insert prod;        
           
        Opportunity opt = new Opportunity();
        opt.AccountId=acct.ID;
        opt.Product__c=prod.ID;
        opt.Name=acct.Name+prod.Name;
        opt.StageName = 'DCP/MRP';
        opt.Start_Date__c = System.Today();
        opt.End_Date__c = opt.Start_Date__c + 1; 
        opt.CloseDate = System.Today() + 2; 
        Test.startTest();       
        insert opt;
        Test.stopTest();
    }    
}