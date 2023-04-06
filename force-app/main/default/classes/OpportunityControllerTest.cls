@isTest
private class OpportunityControllerTest {
public static testMethod void testOppty() {
    
    Test.startTest();
    
    	Account acc=new Account(Name='Test ACC', Is_Parent__c = true);
    	insert acc;
    
    	Contact c=new Contact(Lastname='Test Contact',Email='test@test.com',AccountId=acc.Id);
        insert c;
    
    	Contact c1=new Contact(Lastname='Test Contact1',Email='tes1t@test.com',AccountId=acc.Id);
        insert c1;
        String Con=String.valueOf(c1.Id);
    
    	Event ev=new Event(Subject='Test Agenda Event',StartDateTime=system.today(),EndDateTime=system.today()+5,WhoId=c.Id,WhatId=acc.Id);
        ev.EventRelationIds__c=Con+';';
		insert ev;
    
    	Product2 p = new Product2();
        p.Name = 'Sample Product';
     	insert p;
    
    	Opportunity opp=new Opportunity(Name='Test OPTY',AccountId=acc.Id,Product__c=p.Id,StageName='Lead Generation',CloseDate=system.today()+3);
    	insert opp;
    
    	Minutes_of_Meeting__c mom=new Minutes_of_Meeting__c(Account__c=acc.Id,MOM_Date__c=system.today(),EventId__c=string.valueOf(ev.Id));
    	insert mom;
    
    	MOM_Product__c momp=new MOM_Product__c(Minutes_of_Meeting__c=mom.Id,Product__c=p.Id);
    	insert momp;
    	
    	OpportunityController.getMOMProducts(opp.Id);
    	update ev;
    Test.stopTest();
}
    
}