global class momedit{
        public Minutes_Of_Meeting__c exmm{get;set;}
        public MOM_Product__c NewmomProduct;
        public List<MOM_Product__c> momp{get;set;}
        public List<wrappermomproduct> updatemomp{get;set;}
        public List<MOM_Product__c> Deletemomp{get;set;}
        public List<MOM_Product__c> momp1;
        public MOM_Product__c MP{get;set;}
        public List<MOM_Product__c> momps;
        public list<MOM_Product__c> mompnotify;
        public list<MOM_Price_Discussions__c> MPDList{get;set;}
        public list<wrapperprice> MPDListwrapper{get;set;}
        public list<contact> tempconlist;
        public   map<string,contact> tempconmap;
        public list<opportunity> optycontainer{get;set;}
        public map<id,list<opportunity>> mapopp{get;set;}
        public List<MOM_Product__c> ProductlisttoRemove{get;set;}
        public list<MOM_Price_Discussions__c> PricelisttoRemove{get;set;}
        public Boolean Flag{get;set;}
        public ID id;
        
        public list<Contact> tempconlistforpricing;   // This list is used to fetch the FYI persons List
      

        //public id mid{get;set}

        //Added by sravan for attachment
        public attachment attobj{get;set;}
        public wrappermomproduct wrapobj{get;set;} 
        public list<wrappermomproduct> wraplistobj{get;set;}
        public wrappermomproduct Newwrappermomproduct;


        //Enhancements for attachment ends here--------->

        public momedit(ApexPages.StandardController controller)
        {
                try{
                    
                        
                        ProductlisttoRemove = new list<mom_product__c>();  //  List to remove product discussions
                        PricelisttoRemove = new list<MOM_Price_Discussions__c>();  //  List to remove price discussions
                        mapopp = new map<id,list<opportunity>>();
                        optycontainer= new list<opportunity>(); 

                        optycontainer = [select id,name,MOM_Product__c,StageName,Product__c,Start_Date__c,End_Date__c,New_Notes__c,CloseDate,Accountid,createddate  from Opportunity  where MOM_Product__c !=null order by createddate  desc limit 48000  ];

                        if(!optycontainer.isempty())
                        {
                                for(opportunity optemp :optycontainer)
                                {
                                        if(mapopp.containsKey(optemp.MOM_Product__c))
                                        {
                                                mapopp.get(optemp.MOM_Product__c).add(optemp);
                                        } 
                                        else
                                        {
                                                mapopp.put(optemp.MOM_Product__c,new list<opportunity>());
                                                mapopp.get(optemp.MOM_Product__c).add(optemp);
                                        } 
                                }
                        }


                        //Added by sboor for attachment option
                        attobj = new attachment(); 
                        wraplistobj = new list<wrappermomproduct>();
                        MPDList = new list<MOM_Price_Discussions__c>();
                        MPDListwrapper = new list<wrapperprice>();
                        //End of functionality for attachment option   

                        momp=new List<MOM_Product__c>();
                        momps=new List<MOM_Product__c>();
                        mompnotify = new list<MOM_Product__c>();
                        updatemomp=new List<wrappermomproduct>();
                        Deletemomp=new List<MOM_Product__c>();
                        MP=new MOM_Product__c();
                        exmm=new Minutes_Of_Meeting__c();
                        momp1=new List<MOM_Product__c>();
                        Id i=ApexPages.currentPage().getParameters().get('Id');
                        system.debug('____URL__ID____'+i);
                        exmm=[select Name,id,Account__c,MOM_Date__c,EventId__c,Persons__c,Description__c,Mode_of_Interaction__c,Save_As_Draft__c,Notify_L_1__c,L_1_Person_Email__c from Minutes_Of_Meeting__c where id=:i ];
                        exmm.Notify_L_1__c = false;           

                        momp=[select id,Minutes_Of_Meeting__c,Additional_Email_Ids__c,Action_Required__c,Create_Opportunity_V2__c,Action_Email_Sent_on__c,Discussion_Stage__c,status__c,feed_back__c,Product__c,Notes__c,Mail_Sent_on__c,Notify__c,Create_Opportunity__c,Delete__c,Email_Alert_to_Department__c,Email_alert_to_Department_person__c,FYI__c,Due_Date__c,Offered_Price__c,Actual_Price__c,Address_book__c,Department_Persons__c,fyi_selected__c,Fetch_FYI__c,update_opportunity__c,record_type__c from MOM_Product__c where Minutes_Of_Meeting__c=:exmm.id /*and product__C!=null*/];
                        MPDList =[select id,name,Account_Name__c,Closed_Date__c,Current_Price__c,Customer_Requested_Price__c,Feedback__c,FYI_Selected__c,Minutes_Of_Meeting__c,Notify__c,Offered_Price__c,Pricing_Discussion__c,Product__c,Product_name__c,Status__c,due_date__c from MOM_Price_Discussions__c where Minutes_Of_Meeting__c =:exmm.id  ];

                        System.debug('MOM Price discussion Size Check__'+MPDList.size());
                        System.debug('MOM Price discussion Records__'+MPDList);
                        

                        //Added by sboor for attachment functionality

                        if(momp.size()!= 0)
                        {

                                tempconlist = new list<contact>();


                                tempconlist = [select Id, Name,department__c,L_1Person__r.name,DRL_Employee__c,FYI__c,IS_Active__c,L_1Person__c from contact where DRL_Employee__c = true and IS_Active__c = true];


                                tempconmap = new map<string,contact>();

                                if(!tempconlist.isempty())
                                {
                                        for(contact c:tempconlist)
                                        {
                                                tempconmap.put(c.name,c);
                                        }
                                }

                                for(mom_product__c m:momp)
                                {

                                        set<contact> tempconsetdepartment = new set<contact>();
                                        set<contact> tempconsetfyi = new set<contact>();
                                        set<id> l1idset = new set<id>();
                                        tempconsetdepartment.addall(tempconlist );
                                        tempconsetfyi.addall(tempconlist);

                                        wrapobj = new wrappermomproduct();
                                        list<string> depselectlist = new list<string>();
                                        list<string> fyiselectlist = new list<string>(); 

                                        if(m.Department_Persons__c !=null)
                                        {
                                                depselectlist = m.Department_Persons__c.split(',');
                                        }

                                        if(!depselectlist.isempty())
                                        {
                                                for(string str:depselectlist)
                                                {
                                                        wrapobj.rightvalues.add(new selectoption(tempconmap.get(str).id ,str));
                                                        tempconsetdepartment.remove(tempconmap.get(str));
                                                        // tempconsetdepartment.remove(tempconmap.get(tempconmap.get(str).L_1Person__r.name));

                                                }
                                        }
                                        if(m.FYI_Selected__c!=null)
                                        {
                                                fyiselectlist = m.FYI_Selected__c.split(','); 
                                        }
                                        if(!fyiselectlist.isempty())
                                        {
                                                for(string fyistr:fyiselectlist )
                                                {
                                                        wrapobj.rightvaluesfyi.add(new selectoption(tempconmap.get(fyistr).id,fyistr));
                                                        tempconsetfyi.remove(tempconmap.get(fyistr));
                                                        tempconsetdepartment.remove(tempconmap.get(fyistr));
                                                }
                                        }

                                        for(contact l1 :tempconsetdepartment)
                                        {
                                                l1idset.add(l1.L_1person__c); 
                                        }  

                                        if(!tempconsetdepartment.isempty())
                                        {

                                                for(contact h:tempconsetdepartment)
                                                {
                                                        if(h.department__c ==m.Email_Alert_to_Department__c &&h.drl_employee__c==true && h.is_active__c==true &&m.Email_Alert_to_Department__c !=null && !l1idset.contains(h.id))
                                                        {
                                                                wrapobj.leftvalues.add(new selectoption(h.id,h.name));
                                                        }
                                                }
                                        } 


                                        if(!tempconsetfyi.isempty())
                                        {
                                                for(contact ifyi:tempconsetfyi)
                                                {
                                                        if(ifyi.fyi__c==true && ifyi.drl_employee__c==true && ifyi.is_active__c==true && m.Email_Alert_to_Department__c !=null)
                                                        {
                                                                wrapobj.leftvaluesfyi.add(new selectoption(ifyi.id,ifyi.name));
                                                        }

                                                }
                                        }  

                                        wrapobj.wrapmomp  = m;





                                        wrapobj.wrapmomp.create_opportunity__c = false; 
                                        wrapobj.wrapmomp.update_opportunity__c = false;  
                                        wrapobj.wrapmomp.notify__c = false;
                                        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+m.id);
                                        wraplistobj.add(wrapobj); 
                                        system.debug('>>> Wraplist'+wraplistobj.size());
                                }
                        }

                        system.debug('list size MPD'+MPDList.size());
                        
                        tempconlistforpricing = new list<contact>();
                        tempconlistforpricing = [select Id, Name,department__c,L_1Person__r.name,DRL_Employee__c,FYI__c,IS_Active__c,L_1Person__c from contact where DRL_Employee__c = true and IS_Active__c = true and FYI__c = true];
                        if(!MPDList.isempty() && !momp.isempty())
                        {
                             
                           
                                for(MOM_Price_Discussions__c wpdvar:MPDList)
                                {
                                
                                    set<contact> tempconset = new set<contact>();
                                    tempconset.addall(tempconlistforpricing);    
                                    
                                        wrapperprice mpdobj = new wrapperprice();
                                        list<string> selectedfyi = new list<string>();
                                        mpdobj.wrapmpd.id = wpdvar.id;
                                        mpdobj.wrapmpd.Closed_Date__c = wpdvar.Closed_Date__c;
                                        mpdobj.wrapmpd.Current_Price__c= wpdvar.Current_Price__c;
                                        mpdobj.wrapmpd.Customer_Requested_Price__c= wpdvar.Customer_Requested_Price__c;
                                        mpdobj.wrapmpd.Feedback__c= wpdvar.Feedback__c;
                                        mpdobj.wrapmpd.FYI_Selected__c= wpdvar.FYI_Selected__c;
                                        mpdobj.wrapmpd.Minutes_Of_Meeting__c= wpdvar.Minutes_Of_Meeting__c;
                                       // mpdobj.wrapmpd.Notify__c= wpdvar.Notify__c;
                                        mpdobj.wrapmpd.Notify__c= false;
                                        mpdobj.wrapmpd.Offered_Price__c= wpdvar.Offered_Price__c;
                                        mpdobj.wrapmpd.Pricing_Discussion__c= wpdvar.Pricing_Discussion__c;
                                        mpdobj.wrapmpd.Product__c= wpdvar.Product__c;
                                        mpdobj.wrapmpd.due_date__c =  wpdvar.due_date__c;
                                        mpdobj.wrapmpd.Status__c= wpdvar.status__c;
                                        if(wpdvar.FYI_Selected__c !=null)
                                        {
                                                selectedfyi=  wpdvar.FYI_Selected__c.split(',');
                                        }
                                        if(!selectedfyi.isempty())
                                        {
                                                for(string sovar:selectedfyi)
                                                {
                                                        mpdobj.rightvaluespricingfyi.add(new selectoption(tempconmap.get(sovar).id,sovar));
                                                        mpdobj.conListselectedpricing.add(tempconmap.get(sovar).id);
                                                        
                                                        tempconset.remove(tempconmap.get(sovar));
                                                        system.debug('S_SS'+tempconmap.get(sovar));
                                                        system.debug('S___S'+tempconset);
                                                        
                                                }
                                                
                                                
                                                
                                        }
                                        for(contact cfyi: tempconset)
                                        {
                                             mpdobj.leftvaluespricingfyi.add(new selectoption(cfyi.id,cfyi.name));
                                        }

                                        mpdlistwrapper.add(mpdobj);
                                        system.debug('Check of MOM wrapper Check s1--'+mpdlistwrapper);  
                                        

                                }
                        } 



                        momps=momp;
                        for(MOM_Product__c smm1:momp){
                                system.debug('___oop1__'+smm1.Create_Opportunity__c);
                                if(smm1.Create_Opportunity__c != true){

                                        momp1.add(smm1);
                                }              
                        }
                        for(MOM_Product__c s:momps){                     
                                if(s.Create_Opportunity__c!=True){
                                        IdSet.add(s.id);
                                }
                        }
                        system.debug('....................................'+IdSet.size());
                        System.debug('++++++++++momp1 constructor level++++++++'+momp1);
                }
                catch(Exception e){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,e.getmessage()));

                }    
        }
        Set<id> IDSet=new Set<id>();
        List<MOM_Product__c> smm= new List<MOM_Product__c>();

        /*-------------------------------------AddRows Method invoking while clicing "Add More Products"-----------------------------------------------*/

        public void AddRows(){
                //------------------------------------------------------------old functionality for add rows commented by sboor------------------------------------------  
                NewmomProduct= new MOM_Product__c();
                try{
                        if(momp.size()<=0){ 

                                NewmomProduct.Minutes_Of_Meeting__c=exmm.ID;
                                NewmomProduct.Discussion_Stage__c='Discussion';
                                NewmomProduct.Status__c='Pending';
                                NewmomProduct.product__c=null;
                                NewmomProduct.Delete__c=null;

                                momp.add(NewmomProduct);
                        }
                        else{
                                NewmomProduct.Minutes_Of_Meeting__c=momp[0].Minutes_Of_Meeting__c;
                                NewmomProduct.Discussion_Stage__c='Discussion';
                                NewmomProduct.Status__c='Pending';
                                NewmomProduct.product__c=null;
                                momp.add(NewmomProduct);}
                        System.debug('_______size__________'+momp.size());

                }catch(exception e)
                {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                }
        }

        /*-----------------------------------Add Rows End----------------------------------------------------------------*/


        //----------------------------------------Add rows functionality with the browse attachment option ------------------------------------------
        public void Addwrapperrows()
        {
                try{
                        wrappermomproduct  Newwrappermomproduct = new wrappermomproduct();
                        Newwrappermomproduct.wrapmomp.Minutes_Of_Meeting__c=exmm.ID;
                        Newwrappermomproduct.wrapmomp.Discussion_Stage__c='Discussion';
                        Newwrappermomproduct.wrapmomp.Status__c='Pending';
                        Newwrappermomproduct.wrapmomp.product__c=null;
                        Newwrappermomproduct.optyidentifier = false;
                        Newwrappermomproduct.optyidentifierout = true;
                        if(wraplistobj == null)
                                wraplistobj = new list<wrappermomproduct>();
                                wraplistobj.add(Newwrappermomproduct);
                                system.debug('--- wraplistobj ---'+wraplistobj);
                }
                catch(exception e){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                }
        }


        //------------------------------------- Add Pricing Rows -------------------------------------------------------------*/

        public void addpricedicussion()
        {
                try{
                        
                       
                        wrapperprice wrpaddrow = new wrapperprice();
                        wrpaddrow.wrapmpd.Status__c='Pending';
                        
                        
                        
                         if(!tempconlistforpricing.isempty())
                         {
                             for(contact cfyi: tempconlistforpricing)
                            {
                               wrpaddrow.leftvaluespricingfyi.add(new selectoption(cfyi.id,cfyi.name));
                            }
                              
                         }

                        mpdlistwrapper.add(wrpaddrow) ;
                }catch(exception e){ }
        } 


        //---------------------------------------- End of addrows functionality ---------------------------------------------------------------------


        /*--------------------------------DeleteRows Method invoking for "Delete Products" and Delete Price Discussions-------------------------------------------------*/

        public void DeleteRows(){
        }

        public void deleteProductRow(){
                String rownum = apexPages.Currentpage().getParameters().get('rownumberProduct');
                system.debug('Row number check**'+rownum);
                system.debug('List Size**'+wraplistobj.size());

                try{ 
                        if(rownum!=null && rownum!='')
                        {
                                system.debug('Record Id Check**'+wraplistobj.get(integer.valueof(rownum)).wrapmomp.id);
                                if(wraplistobj.get(integer.valueof(rownum)).wrapmomp.id!=null)
                                        ProductlisttoRemove.add(wraplistobj.get(integer.valueof(rownum)).wrapmomp);
                                System.debug('*****PRODUCT LIST TO REMOVE********'+ProductlisttoRemove);
                                wraplistobj.remove(integer.valueof(rownum));
                        }
                }
                catch(Exception e){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                }
        }

        public void deletePriceRow(){
                String rownum1 = apexPages.Currentpage().getParameters().get('rownumberPrice');
                system.debug('Row number check**'+rownum1);
                system.debug('List Size**'+mpdlistwrapper.size());

                try{ 
                        if(rownum1!=null && rownum1!='')
                        {
                                system.debug('Record Id Check**'+mpdlistwrapper.get(integer.valueof(rownum1)).wrapmpd.id);
                                if(mpdlistwrapper.get(integer.valueof(rownum1)).wrapmpd.id!=null)
                                        PricelisttoRemove.add(mpdlistwrapper.get(integer.valueof(rownum1)).wrapmpd);
                                System.debug('*****PRICE LIST TO REMOVE********'+PricelisttoRemove);
                                mpdlistwrapper.remove(integer.valueof(rownum1));
                        }
                }
                catch(Exception e){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                }
        }
        /*-------------------------------------Functionality for saving the Page--------------------------------------------------*/



        public Pagereference Csave()
        {   


                // Adder for showing error 

                for(wrappermomproduct setids:wraplistobj)
                {
                        if((setids.wrapmomp.Create_Opportunity__c==true) && (setids.wrapmomp.Product__c==null || setids.wrapmomp.Notes__c==null))
                        {

                                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Selected create opportunity without details of product and Notes .Please fill all the necessary fields'));      
                                return null;

                        }
                        if((setids.wrapmomp.Product__c==null && setids.wrapmomp.Notes__c!=null)||(setids.wrapmomp.Product__c!=null && setids.wrapmomp.Notes__c==null))
                        {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Notes should not be blank.'));      
                                return null;

                        }  
                }


                try
                {

                        if(exmm.Account__c!=null)     
                        {
                                system.debug('____________________');
                            	List<EventFinalList__c> efl=EventFinalList__c.getAll().values();
                            efl.sort();
                            	if(efl.size()>0)
                                {
                                    if(efl[0].Name!='null'){
                                        exmm.EventId__c=efl[0].Name;
                                        exmm.MOM_Date__c=efl[0].EventDate__c;
                                        exmm.EventSubject__c=efl[0].EventSubject__c;
                                    }
                                    
                                    else
                                    {
                                    exmm.EventId__c='';
                                    if(exmm.MOM_Date__c==null)
                                    exmm.MOM_Date__c=system.today();
                                    
                                    
                                    }
                                    system.debug('=========#########'+exmm.EventId__c);
                                    
                                    
                                    
                                }
                            	
                            	delete efl;
                            
                            
                                
                            
                                system.debug('==============************==========='+exmm.EventId__c);
                                update exmm;
                            	system.debug('=============********************'+exmm.EventId__c);

                        } 
                } 
                catch(Exception e)     
                {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                }
                Pagereference p=new PageReference('/apex/momview?id='+exmm.id);
                p.setRedirect(true);    



                System.debug('++++++++++momp++++++++++'+momp);

                List<MOM_Product__c> listToBeUpdated = new List<MOM_Product__c>();


                List<Opportunity> oppList=new List<Opportunity>();

                Map<Id,MOM_Product__c> mompMap = new Map<Id,MOM_Product__c>();
                system.debug('______new MOMP_________');
                for(wrappermomproduct smm1:wraplistobj){

                        Opportunity o=new Opportunity();
                        o.Product__c = smm1.wrapmomp.Product__c;
                        o.AccountId= exmm.Account__c;
                        o.CloseDate=System.Today()+365;
                        o.Description=smm1.wrapmomp.Notes__c;
                        o.MOM_Product__c=smm1.wrapmomp.Id;
                        //o.sss__c='www';
                        o.StageName='Discussion';
                        //o.Name= smm1.Minutes_Of_Meeting__r.Account__r.Name+'-'+smm1.Product__r.Name+'-'+;
                        if((smm1.wrapmomp.Create_Opportunity__c==True)&&(IdSet.contains(smm1.wrapmomp.id))){
                                system.debug('....................................');
                                //smm1.Opportunity__c=
                                //mompMap.put(smm1.Id,smm1);
                                oppList.add(o);
                        }
                }

                //system.debug('___r_'+momp.size());
                if(wraplistobj.size()>0){
                        for(wrappermomproduct MP:wraplistobj){
                                system.debug('________MP@124___'+MP);
                                if(MP.wrapmomp.Product__c!=null ){
                                        system.debug('_____1234_____');
                                        updatemomp.add(MP);

                                }

                        }
                        system.debug('_____chek@136___'+updatemomp);

                        //Removing Dup's

                        Set<MOM_Product__c> setupdatemomp= new Set<MOM_Product__c>();
                        list<MOM_Product__c> tempupdatemomp= new list<MOM_Product__c>();

                        if(updatemomp.size()>0){

                                for(wrappermomproduct u:updatemomp)
                                {
                                        string selectedfyiupdate='';
                                        string selecteddepupdate='';

                                        boolean first = true;
                                        boolean tempfirst = true;
                                        if(u.rightvaluesfyi !=null)
                                        {
                                                for ( selectoption sop: u.rightvaluesfyi) 
                                                {
                                                        if (!first) 
                                                        {
                                                                selectedfyiupdate+=',';
                                                        }
                                                        selectedfyiupdate+= sop.getLabel();
                                                        first = false;
                                                }
                                        }


                                        if(u.rightvalues !=null)
                                        {
                                                for ( selectoption soprightvar: u.rightvalues) 
                                                {
                                                        if (!tempfirst ) 
                                                        {
                                                                selecteddepupdate+=',';
                                                        }
                                                        selecteddepupdate+= soprightvar.getLabel();
                                                        tempfirst = false;
                                                }
                                        }



                                        mom_product__c mompobj = new mom_product__c();
                                        mompobj = u.wrapmomp;
                                        mompobj.FYI_Selected__c = selectedfyiupdate;
                                        mompobj.Department_Persons__c = selecteddepupdate;

                                        setupdatemomp.add(mompobj);
                                }

                                tempupdatemomp.addall(setupdatemomp);

                                /******/

                                Upsert tempupdatemomp;  
                        }
                }

                if(!mpdlistwrapper.isempty())
                {
                        list<MOM_Price_Discussions__c> mpdlistupdate = new list<MOM_Price_Discussions__c>();
                        for(wrapperprice mpdw:mpdlistwrapper)
                        { 

                                string updatepricingfyi='';
                                if(mpdw.rightvaluespricingfyi!=null)

                                {
                                        boolean firstflag=true;

                                        for ( selectoption sopflag: mpdw.rightvaluespricingfyi) 
                                        {
                                                if (!firstflag) 
                                                {
                                                        updatepricingfyi+=',';
                                                }
                                                updatepricingfyi+= sopflag.getLabel();
                                                firstflag= false;
                                        }
                                }



                                MOM_Price_Discussions__c mpdobj = new MOM_Price_Discussions__c();
                                mpdobj.id = mpdw.wrapmpd.id ;
                                mpdobj.Current_Price__c = mpdw.wrapmpd.Current_Price__c ; 
                                mpdobj.Customer_Requested_Price__c = mpdw.wrapmpd.Customer_Requested_Price__c;
                                mpdobj.Feedback__c = mpdw.wrapmpd.Feedback__c;
                                mpdobj.Offered_Price__c = mpdw.wrapmpd.Offered_Price__c;
                                mpdobj.Pricing_Discussion__c = mpdw.wrapmpd.Pricing_Discussion__c;
                                mpdobj.CurrencyIsoCode = mpdw.wrapmpd.CurrencyIsoCode;
                                mpdobj.product__c = mpdw.wrapmpd.product__c;
                                mpdobj.notify__c = mpdw.wrapmpd.notify__c;
                                mpdobj.FYI_Selected__c = updatepricingfyi;
                                mpdobj.Minutes_Of_Meeting__c = exmm.id;
                                mpdobj.Status__c = mpdw.wrapmpd.status__c;
                                mpdobj.Due_Date__c =mpdw.wrapmpd.Due_Date__c;
                                mpdlistupdate.add(mpdobj); 


                        }
                        try{
                                system.debug('Price Discussion Save check":":"'+mpdlistupdate);
                                upsert mpdlistupdate; 
                                system.debug('Product discussion list price before upsert'+mpdlistupdate.size());
                        }catch(exception e){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                        }


                }
                if(!ProductlisttoRemove.isempty() && ProductlisttoRemove!=null)
                {
                        Delete ProductlisttoRemove;
                }
                if(!PricelisttoRemove.isempty() && PricelisttoRemove!=null)
                {
                        Delete PricelisttoRemove;
                } 
                return p;

        }

       

        public class wrapperprice
        {
                public MOM_Price_Discussions__c wrapmpd{get;set;}
                public list<selectoption> leftvaluespricingfyi{get;set;}
                public list<selectoption> rightvaluespricingfyi{get;set;}
                public list<contact> conlistpricefyi = new list<contact>();
                public boolean notifyfyi{get;set;}
                public list<id> conListselectedpricing{get;set;} 

                public wrapperprice()
                {
                        wrapmpd = new MOM_Price_Discussions__c();
                        leftvaluespricingfyi = new  list<selectoption>();
                        rightvaluespricingfyi = new  list<selectoption>();
                        conListselectedpricing = new list<id>();
                        
                                  

                }
        }

        //-------------------------------------------------End of wrapper for existing opportunity-------------------------------------------------            
        //Added by sboor for Attchment functionality            
        public class wrappermomproduct
        {
                public MOM_product__c wrapmomp{get;set;}
                public boolean updateopportunity{get;set;}
                public attachment wrapatt{get;set;}
                public boolean optyidentifier{get;set;}
                public boolean optyidentifierout{get;set;}

                public list<selectoption> leftvalues{get;set;}
                public list<selectoption> rightvalues{get;set;}
                public list<string> leftselected{get;set;}
                public list<string> rightselected{get;set;} 



                public list<selectoption> leftvaluesfyi{get;set;}
                public list<selectoption> rightvaluesfyi{get;set;}
                public list<string> leftselectedfyi{get;set;}
                public list<string> rightselectedfyi{get;set;} 



                public wrappermomproduct()
                {
                        optyidentifier = true;
                        optyidentifierout = true;
                        leftvalues = new list<selectoption>();
                        rightvalues = new list<selectoption>();
                        leftselected = new list<string>();
                        rightselected = new list<string>();

                        leftvaluesfyi = new list<selectoption>();
                        rightvaluesfyi = new list<selectoption>();
                        leftselectedfyi = new list<string>();
                        rightselectedfyi = new list<string>();

                        wrapmomp = new MOM_product__c();
                        wrapatt = new attachment(); 
                }


                public void fetchValuesBasedOnDepartment()
                {
                        wrapmomp.fetch_fyi__c = false;
                        leftvalues.clear();
                        rightvalues.clear();
                        rightvaluesfyi.clear();
                        leftvaluesfyi.clear();
                        
                        
                        

                        leftvalues = new list<selectoption>();
                        rightvalues = new list<selectoption>();
                        if(wrapmomp.Email_Alert_to_Department__c != null){
                                List<Contact> contactlist = [select Id, Name,department__c,DRL_Employee__c,FYI__c,IS_Active__c,L_1Person__c from contact where Department__c=:wrapmomp.Email_Alert_to_Department__c and IS_Active__c = true];
                                list<id> l1list = new list<id>();
                                set<id> l1set = new set<id>();


                                for(Contact c:contactlist)
                                {
                                        if(c.L_1Person__c !=null)
                                        {
                                                l1list.add(c.L_1Person__c);
                                        }
                                }
                                if(!l1list.isempty())
                                {
                                        l1set.addall(l1list);
                                }        

                                if(contactlist != null && !contactlist.isEmpty()){
                                        contactlist.sort(); 
                                        for(contact con : contactlist){
                                                if(con.FYI__c == false && !l1set.contains(con.id))
                                                {
                                                        this.leftvalues.add(new SelectOption(con.id,con.name));
                                                }


                                        }
                                }





                        }
                        system.debug('---'+this.leftvalues);
                } 

                public void fetchfyipersons()
                {
                        if(wrapmomp.fetch_fyi__c==true )
                        {
                                leftvaluesfyi.clear();
                                list<id> selectedconids = new list<id>();
                                list<id> selectedpersonsl1 = new list<id>();
                                set<id> selectedFyiset = new set<id>();  // This list is created to collect  the existing FYI persons or Selected FYI persons
                        
                                for(selectoption temp:this.rightvaluesfyi)
                                {
                                    selectedFyiset.add(temp.getValue());
                                   
                                }
                                for(selectoption temp:this.leftvaluesfyi)
                                {
                                    selectedFyiset.add(temp.getValue());
                                }

                                if(rightvalues.size() !=0 && rightvalues !=null)
                                {
                                        for(selectoption so:rightvalues)
                                        {
                                                selectedconids.add(so.getvalue()) ;


                                        }
                                        if(selectedconids.size() !=0 && selectedconids !=null)
                                        {
                                                for(contact lid:[select id,name,L_1Person__c from contact where id in:selectedconids])
                                                {
                                                        selectedpersonsl1.add(lid.L_1Person__c) ;
                                                } 
                                        } 

                                }
                                
                                
                                
                                List<Contact> contactlistfyi = [select Id, Name,department__c,DRL_Employee__c,FYI__c,IS_Active__c,L_1Person__c from contact where (( IS_Active__c = true and id in :selectedpersonsl1) or (FYI__c =true))];

                                
                                
                                system.debug('FYI SIZE---------------------------------------------->'+contactlistfyi.size());


                                if(contactlistfyi.size() !=0 && contactlistfyi != null )
                                {
                                        for(contact cfyi: contactlistfyi)
                                        {
                                            if(!selectedFyiset.contains(cfyi.id))
                                                this.leftvaluesfyi.add(new selectoption(cfyi.id,cfyi.name)); 
                                        }
                                        
                                            
                                }
                        } 
                        else{ leftvaluesfyi.clear(); rightvaluesfyi.clear();}
                        
                }




        }
    
    public pagereference getres()
        { 
            try{
                List<EventFinalList__c> efl=EventFinalList__c.getAll().values();
                            	if(efl.size()>0)
                                {
                                    delete efl;
                                }
                return null;
            }   
            catch(Exception e){
                return null;
            }
        }
public Pagereference cancel(){
        Pagereference p=new PageReference('/apex/momview?id='+exmm.id);
		p.setRedirect(true); 
        return p;
    }

}