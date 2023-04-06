/* Author: Dinesh
Company: Bodhtree Consulting Ltd  */

@isTest
Public class opportunityAPITest {
    public static testmethod void APItest() {
        Account a = new Account();
        a.name = 'testaccount';
        a.Geography__c = 'Europe';
        a.Is_Parent__c = true;
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

    public static testmethod void NewControllerTest1() {
        Account a = new Account();
        a.name = 'testaccount';
        a.Geography__c = 'Europe';
        a.Is_Parent__c = true;
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
    
    public static testmethod void NewControllerTest2() {
        Account a = new Account();
        a.name = 'testaccount';
        a.Geography__c = 'Europe';
        a.Is_Parent__c = true;
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
        indentRT.RedirectPages();
        Test.stopTest();
    }
    
	/**
    * @ author       :  Deeksha Suvarna
    * @ description  :  Test method for updating Stages in Opportunity
    **/  
    public static testmethod void NewControllerTest3() {
        Account objaccount = new Account();
        objaccount.name = 'testaccount';
        objaccount.Geography__c = 'Europe';
        objAccount.Is_Parent__c = true;
        insert objaccount;
        
        product2 objproduct2 = new product2();
        objproduct2.name = 'test';
        insert objproduct2;
        ID optyRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API').getRecordTypeId();
            
        Test.startTest();   
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.name = 'test';
        objOpportunity.AccountId = objaccount.id;
        objOpportunity.StageName = 'Discussion';
        objOpportunity.CloseDate = system.today()+1;
        objOpportunity.RecordTypeId = optyRecordTypeID;
        objOpportunity.Planned_Price_at_Launch__c = 22;
        objOpportunity.Source_type__c = 'Primary Source';
        objOpportunity.Planned_Qty_at_launch__c = 40;
        objOpportunity.Planned_Year__c = '2000'; 
        insert objOpportunity;

        Opportunity objOpportunity3 = new Opportunity();
        objOpportunity3.Id = objOpportunity.Id;
        objOpportunity3.StageName = 'ANDA Approved';
        update objOpportunity3;
        
        Opportunity objOpportunity4 = new Opportunity();
        objOpportunity4.Id = objOpportunity.Id;
        objOpportunity4.StageName = 'MA (Marketing Authorization)';
        objOpportunity4.Planned_Price_at_Launch__c = 32;
        objOpportunity4.Source_type__c = 'Primary Source';
        objOpportunity4.Planned_Qty_at_launch__c = 45;
        objOpportunity4.Planned_Year__c = '2006';
        objOpportunity4.Price__c = 43;
        objOpportunity4.TotalOpportunityQuantity = 12;
        update objOpportunity4;
        
        Opportunity objOpportunity5 = new Opportunity();
        objOpportunity5.Id = objOpportunity.Id;
        objOpportunity5.StageName = 'Commercial';
        update objOpportunity5;
        
        Opportunity objOpportunity6 = new Opportunity();
        objOpportunity6.Id = objOpportunity.Id;
        objOpportunity6.StageName = 'Dropped';
        objOpportunity6.Reason_for_Loss__c = 'Customer Related';
        objOpportunity6.Reason__c = 'test';
        update objOpportunity6;
        
        ApexPages.currentPage().getParameters().put('RecordType',objOpportunity.RecordTypeId);
        OpportunityNewController indentRT = new OpportunityNewController(new ApexPages.StandardController(objOpportunity));
        indentRT.producttype = 'API';
        indentRT.RedirectPages();
        Test.stopTest();
    }
    
	/**
    * @ author       :  Deeksha Suvarna
    * @ description  :  Test method for updating Stages in Opportunity
    **/
    public static testmethod void NewControllerTest4() {
        Account objaccount = new Account();
        objaccount.name = 'testaccount';
        objaccount.Geography__c = 'Europe';
        objAccount.Is_Parent__c = true;
        insert objaccount;
        product2 objproduct2 = new product2();
        objproduct2.name = 'test';
        insert objproduct2;
        ID optyRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API').getRecordTypeId();
        
        Test.startTest();
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.name = 'test';
        objOpportunity.AccountId = objaccount.id;
        objOpportunity.StageName = 'Discussion';
        objOpportunity.CloseDate = system.today()+1;
        objOpportunity.RecordTypeId = optyRecordTypeID;
        objOpportunity.Planned_Price_at_Launch__c = 22;
        objOpportunity.Source_type__c = 'Primary Source';
        objOpportunity.Planned_Qty_at_launch__c = 40;
        objOpportunity.Planned_Year__c = '2000'; 
        insert objOpportunity;
        
        Opportunity objOpportunity6 = new Opportunity();
        objOpportunity6.Id = objOpportunity.Id;
        objOpportunity6.StageName = 'Dropped';
        objOpportunity6.Reason_for_Loss__c = 'Customer Related';
        objOpportunity6.Reason__c = 'test';
        update objOpportunity6;
        
        Opportunity objOpportunity7 = new Opportunity();
        objOpportunity7.Id = objOpportunity.Id;
        objOpportunity7.StageName = 'Bio Batches';
        update objOpportunity7;
        
        Opportunity objOpportunity8 = new Opportunity();
        objOpportunity8.Id = objOpportunity.Id;
        objOpportunity8.StageName = 'Exhibit Batches';
        update objOpportunity8;
        
        Opportunity objOpportunity9 = new Opportunity();
        objOpportunity9.Id = objOpportunity.Id;
        objOpportunity9.StageName = 'LOA / LOE';
        objOpportunity9.Planned_Price_at_Launch__c = 33;
        objOpportunity9.Source_type__c = 'Primary Source';
        objOpportunity9.Planned_Qty_at_launch__c = 40;
        objOpportunity9.Planned_Year__c = '2000';
        objOpportunity9.Price__c = 20;
        objOpportunity9.TotalOpportunityQuantity = 4;
        update objOpportunity9;
        
        Opportunity objOpportunity10 = new Opportunity();
        objOpportunity10.Id = objOpportunity.Id;
        objOpportunity10.StageName = 'Postponed / Hold';
        update objOpportunity10;
        
        ApexPages.currentPage().getParameters().put('RecordType',objOpportunity.RecordTypeId);
        OpportunityNewController indentRT = new OpportunityNewController(new ApexPages.StandardController(objOpportunity));
        indentRT.producttype = 'API';
        indentRT.RedirectPages();
        Test.stopTest();
    }
}