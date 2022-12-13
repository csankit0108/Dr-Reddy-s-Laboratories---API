/* Author: Dinesh
Company: Bodhtree Consulting Ltd  */

@isTest
Public class opportunityAPITest{
    public static testmethod void APItest(){
        Account a = new Account();
        a.name = 'testaccount';
        a.Geography__c = 'Europe';
        insert a;
        
        product2 p = new product2();
        p.name = 'test';
        insert p;
        ID optyRecordTypeID= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API').getRecordTypeId();
        Opportunity o = new Opportunity();
        o.name = 'test';
        o.AccountId = a.id;
        o.StageName = 'Discussion';
        o.CloseDate = system.today()+1;
        o.RecordTypeId=optyRecordTypeID;
        o.Planned_Price_at_Launch__c=22;
        o.Source_type__c='Primary Source';
        o.Planned_Qty_at_launch__c=40;
		o.Planned_Year__c='2000';        
        insert o;
        Opportunity opt=new Opportunity();
        opt.Id=o.Id;
        opt.StageName='Development';
        opt.Planned_Price_at_Launch__c=32;
        opt.Source_type__c='Secondary Source';
        opt.Planned_Qty_at_launch__c=45;
        opt.Planned_Year__c='2006';
        update opt;
        
        ApexPages.StandardController controller;
        opportunityAPI op = new opportunityAPI(controller);
        op.Cancel();
        op.save1();
        op.save2();
        
    
    }
    public static testmethod void NewControllerTest1(){
        Account a = new Account();
        a.name = 'testaccount';
        a.Geography__c = 'Europe';
        insert a;
        product2 p = new product2();
        p.name = 'test';
        insert p;
        ID optyRecordTypeID= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API +').getRecordTypeId();
        Opportunity o = new Opportunity();
        o.name = 'test';
        o.AccountId = a.id;
        o.StageName = 'Discussion';
        o.CloseDate = system.today()+1;
        o.RecordTypeId=optyRecordTypeID;
        o.Planned_Price_at_Launch__c=22;
        o.Source_type__c='Primary Source';
		o.Planned_Qty_at_launch__c=40;
		o.Planned_Year__c='2000'; 
        insert o;
        Opportunity opt=new Opportunity();
        opt.Id=o.Id;
        opt.StageName='Dossier Filed';
        update opt;
        
        ApexPages.currentPage().getParameters().put('RecordType',o.RecordTypeId);
            OpportunityNewController indentRT = new OpportunityNewController(new ApexPages.StandardController(o));
            indentRT.producttype = 'APIPlus';
           
            indentRT.RedirectPages();
       
        }
    
    public static testmethod void NewControllerTest2(){
        Account a = new Account();
        a.name = 'testaccount';
        a.Geography__c = 'Europe';
        insert a;
        product2 p = new product2();
        p.name = 'test';
        insert p;
        ID optyRecordTypeID= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API').getRecordTypeId();
        
        
        Test.startTest();
        Opportunity o = new Opportunity();
        o.name = 'test';
        o.AccountId = a.id;
        o.StageName = 'Discussion';
        o.CloseDate = system.today()+1;
        o.RecordTypeId=optyRecordTypeID;
        o.Planned_Price_at_Launch__c=22;
        o.Source_type__c='Primary Source';
		o.Planned_Qty_at_launch__c=40;
		o.Planned_Year__c='2000'; 
        insert o;
        
        Opportunity opt=new Opportunity();
        opt.Id=o.Id;
        opt.StageName='ANDA Filed';
        update opt;
        Opportunity opt1=new Opportunity();
        opt1.Id=o.Id;
        opt1.StageName='DCP/MRP';
        update opt1;
        Opportunity opt2=new Opportunity();
        opt2.Id=o.Id;
        opt2.StageName='Marketing License';
        update opt2;
        Opportunity opt3=new Opportunity();
        opt3.Id=o.Id;
        opt3.StageName='ANDA Approved';
        update opt3;
        
        ApexPages.currentPage().getParameters().put('RecordType',o.RecordTypeId);
            OpportunityNewController indentRT = new OpportunityNewController(new ApexPages.StandardController(o));
            indentRT.producttype = 'API';
            //indentRT.MapRecordTypes = MapRecordTypestest;
            indentRT.RedirectPages();
       Test.stopTest();
        
      
    
    }
    
        public static testmethod void NewControllerTest3(){
        Account a = new Account();
        a.name = 'testaccount';
        a.Geography__c = 'Europe';
        insert a;
        
        product2 p = new product2();
        p.name = 'test';
        insert p;
        ID optyRecordTypeID= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API').getRecordTypeId();
            
        Test.startTest();   
        Opportunity o = new Opportunity();
        o.name = 'test';
        o.AccountId = a.id;
        o.StageName = 'Discussion';
        o.CloseDate = system.today()+1;
        o.RecordTypeId=optyRecordTypeID;
        o.Planned_Price_at_Launch__c=22;
        o.Source_type__c='Primary Source';
		o.Planned_Qty_at_launch__c=40;
		o.Planned_Year__c='2000'; 
        insert o;

        Opportunity opt3=new Opportunity();
        opt3.Id=o.Id;
        opt3.StageName='ANDA Approved';
        update opt3;
        Opportunity opt4=new Opportunity();
        opt4.Id=o.Id;
        opt4.StageName='MA (Marketing Authorization)';
        opt4.Planned_Price_at_Launch__c=32;
        opt4.Source_type__c='Primary Source';
        opt4.Planned_Qty_at_launch__c=45;
        opt4.Planned_Year__c='2006';
        opt4.Price__c=43;
        opt4.TotalOpportunityQuantity=12;
        update opt4;
        Opportunity opt5=new Opportunity();
        opt5.Id=o.Id;
        opt5.StageName='Commercial';
        update opt5;
        Opportunity opt6=new Opportunity();
        opt6.Id=o.Id;
        opt6.StageName='Dropped';
        opt6.Reason_for_Loss__c = 'Customer Related';
        opt6.Reason__c='test';
        update opt6;
        
        ApexPages.currentPage().getParameters().put('RecordType',o.RecordTypeId);
            OpportunityNewController indentRT = new OpportunityNewController(new ApexPages.StandardController(o));
            indentRT.producttype = 'API';
            //indentRT.MapRecordTypes = MapRecordTypestest;
            indentRT.RedirectPages();
       Test.stopTest();
        
      
    
    }
        public static testmethod void NewControllerTest4(){
        Account a = new Account();
        a.name = 'testaccount';
        a.Geography__c = 'Europe';
        insert a;
        product2 p = new product2();
        p.name = 'test';
        insert p;
        ID optyRecordTypeID= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API').getRecordTypeId();
        
        
        Test.startTest();
        Opportunity o = new Opportunity();
        o.name = 'test';
        o.AccountId = a.id;
        o.StageName = 'Discussion';
        o.CloseDate = system.today()+1;
        o.RecordTypeId=optyRecordTypeID;
        o.Planned_Price_at_Launch__c=22;
        o.Source_type__c='Primary Source';
		o.Planned_Qty_at_launch__c=40;
		o.Planned_Year__c='2000'; 
        insert o;
        
            
        Opportunity opt6=new Opportunity();
        opt6.Id=o.Id;
        opt6.StageName='Dropped';
        opt6.Reason_for_Loss__c = 'Customer Related';
        opt6.Reason__c='test';
        update opt6;
        Opportunity opt7=new Opportunity();
        opt7.Id=o.Id;
        opt7.StageName='Bio Batches';
        update opt7;
        Opportunity opt8=new Opportunity();
        opt8.Id=o.Id;
        opt8.StageName='Exhibit Batches';
        update opt8;
        Opportunity opt9=new Opportunity();
        opt9.Id=o.Id;
        opt9.StageName='LOA / LOE';
        opt9.Planned_Price_at_Launch__c=33;
        opt9.Source_type__c='Primary Source';
		opt9.Planned_Qty_at_launch__c=40;
		opt9.Planned_Year__c='2000';
        opt9.Price__c=20;
        opt9.TotalOpportunityQuantity=4;
        update opt9;
        Opportunity opt10=new Opportunity();
        opt10.Id=o.Id;
        opt10.StageName='Postponed / Hold';
        update opt10;
        
        ApexPages.currentPage().getParameters().put('RecordType',o.RecordTypeId);
            OpportunityNewController indentRT = new OpportunityNewController(new ApexPages.StandardController(o));
            indentRT.producttype = 'API';
            //indentRT.MapRecordTypes = MapRecordTypestest;
            indentRT.RedirectPages();
       Test.stopTest();
    }


}