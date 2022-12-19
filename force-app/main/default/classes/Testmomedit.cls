@IsTest

private class Testmomedit{

    Static testmethod void MYMOMEdit(){
        
        ApexPages.StandardController controller;
        
        Account acc= new Account();
        acc.Name='My account';
        insert acc;
        
        
        String lstArea ='';
        
        contact con = new contact();
        con.Lastname = 'Sample name';
        con.is_active__c = true;
        con.email = 'sbooragadda@bodhtree.com';
        con.DRL_employee__c=true;
        con.department__c = 'ipdo';
        insert con;
        lstArea = con.Lastname+',';
        
        contact con1 = new contact();
        con1.Lastname = 'Sample name2';
        con1.is_active__c = true;
        con1.email = 'sbooragadd@bodhtree.com';
        con1.DRL_employee__c=true;
        con1.fyi__c = true;
        con1.AccountId = acc.id;
        con1.Department = 'Quality';
        con1.L_1Person__c = con.Id;
        insert con1; 
        lstArea += con1.Lastname+',';
        
        contact con2 = new contact();
        con2.Lastname = 'Sample name3';
        con2.is_active__c = true;
        con2.email = 'sbooragadd1@bodhtree.com';
        con2.DRL_employee__c=true;
        con2.fyi__c = true;
        con2.L_1Person__c =con1.id;
        con2.AccountId = acc.id;
        insert con2; 
        lstArea += con2.Lastname;
        
        Minutes_Of_Meeting__c mom= new  Minutes_Of_Meeting__c();
        mom.Account__c=acc.id;
        mom.MOM_Date__c=system.today();
        mom.Persons__c='InPerson';
        insert mom;
        
        Product2 prod= new Product2();
        prod.Name='new product123';
        insert prod;
   
        MOM_Product__c momp= new MOM_Product__c();
        momp.product__c=prod.id;
        momp.Minutes_Of_Meeting__c=mom.id;
        momp.Email_Alert_to_Department__c = 'ipdo';
        momp.Discussion_Stage__c='Discussion';
        momp.Fetch_FYI__c = true;
        momp.notes__c = 'Dumay';
        momp.notify__c = true; 
        momp.Address_book__c = 'test@test.com';
		momp.FYI_Selected__c = lstArea; 
        momp.Department_Persons__c = lstArea;
        //momp.Create_Opportunity__c=null;
        insert momp;
                
        /*MOM_Product__c momp1= new MOM_Product__c();
        momp1.product__c=prod.id;
        momp1.Minutes_Of_Meeting__c=mom.id;
        momp1.Discussion_Stage__c='Discussion';
        momp1.Create_Opportunity__c=true;
        momp1.notes__c = 'Dumay';
        momp1.Delete__c=true;
        insert momp1;*/
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.CloseDate = Date.today().addYears(1);
        objOpportunity.Planned_Price_at_Launch__c = 250;
        objOpportunity.Planned_Qty_at_launch__c = 25;
        objOpportunity.Planned_Year__c = '2025';
        objOpportunity.Source_type__c = 'Primary Source';
        objOpportunity.StageName = 'Development';
        objOpportunity.AccountId = acc.Id;
        objOpportunity.Contact__c = con1.Id;
        objOpportunity.Product__c = prod.Id;
        objOpportunity.MOM_Product__c = momp.Id;
        objOpportunity.Start_Date__c = Date.today();
        objOpportunity.End_Date__c = Date.today().addYears(1);
        objOpportunity.MOM1__c='MOM Object';
        insert objOpportunity;
        
        Opportunity_Stage_Tracker__c newRec = new Opportunity_Stage_Tracker__c();
        newRec.Name = objOpportunity.StageName;
        newRec.Actual_End_Date__c=objOpportunity.Actual_End_Date__c;
        newRec.MOM1__c=objOpportunity.MOM1__c;
        newRec.MOM__c=objOpportunity.MOM1__c;
        newRec.Opportunity__c = objOpportunity.Id;
        newRec.Start_Date__c = objOpportunity.Start_Date__c;
        newRec.End_Date__c = objOpportunity.End_Date__c;
        insert newRec;
        System.debug('objOpportunity @'+objOpportunity.Id);
        
            MOM_Price_Discussions__c mpd = new  MOM_Price_Discussions__c();
            mpd.FYI_Selected__c = 'sample name2';
            mpd.product__c =prod.id;
          //  mpd.notify__c = true;
            mpd.Minutes_Of_Meeting__c = mom.id;
            insert mpd;
        
        
        ApexPages.currentPage().getParameters().put('Id',mom.ID);

        momedit m= new momedit(controller);
        momedit m1= new momedit(controller);
      //  m.wrappermomproduct wrappod = new m.wrappermomproduct(); 
      
      
      
       m.exmm = new Minutes_Of_Meeting__c();
       m.NewmomProduct = new MOM_Product__c();
      m.MPDList = new list<MOM_Price_Discussions__c> ();
      
   /*   //m.updatemomp = new List<wrappermomproduct>();
      m.Deletemomp = new  List<MOM_Product__c>();
      m.momp1 = new List<MOM_Product__c>();
       m.MP = new  MOM_Product__c();
     //m.momps = new    List<MOM_Product__c>();
     m.mompnotify = new list<MOM_Product__c>();
     m.MPDList = new list<MOM_Price_Discussions__c>();
     //m.MPDListwrapper = new list<wrapperprice>();
     m.tempconlist = new list<contact>();
     m.tempconmap = new  map<string,contact>();
     m.optycontainer = new list<opportunity>();
     m.mapopp = new map<id,list<opportunity>>(); */
      
        m.DeleteRows();
        m.AddwrapperRows();
        //m.addrows();
        m.addpricedicussion();
        m.deleteProductRow();
        m.deletePriceRow();
        
      
    //  m.wrapobj.fetchvaluesbasedondepartment();
    // m.wrapobj.fetchfyipersons();
        m1.AddRows();
        m1.Csave();
        try{
        //m.Csave();
        m.Addwrapperrows();
        system.debug('--- m.wraplistobj ---'+m.wraplistobj);
        m.wraplistobj.get(0).wrapmomp.Product__c = prod.id;
        m.wraplistobj.get(0).wrapmomp.Notes__c = 'Test Notes';
        m.wraplistobj.get(0).wrapmomp.Email_Alert_to_Department__c = 'ipdo';
        m.wraplistobj.get(0).fetchvaluesbasedondepartment();
        List<SelectOption> rightValues = new List<SelectOption>();
        rightValues.add(m.wraplistobj.get(0).leftvalues.get(0));
        m.wraplistobj.get(0).rightvalues.addAll(rightValues);
        m.wraplistobj.get(0).wrapmomp.fetch_fyi__c = true;
        m.wraplistobj.get(0).fetchfyipersons();
        m.addpricedicussion();
        m.Csave();
        m.addRows();
        
        }catch(Exception e){system.debug('__exception__'+e);}
    
    }  
         

}