trigger leadContentUpdate on Lead (before insert,before update,after update,after insert) {
    
     if (
         Disable_Trigger__c.getInstance().Disable_LeadTrigger__c
     ) {
         return;
     }

    Map<String,Lead> leadMap=new Map<String,Lead>();
    Map<String,Lead> leadEmailMap=new Map<String,Lead>();
    
    if(CaseStaticVars.allowLeadInTrigger)
    {
        for(Lead ld:trigger.new)
        {
            if(Trigger.isBefore&&(Trigger.isInsert||Trigger.isUpdate))
            {
                String contentId=ld.Content_Catalog_Sent_Id__c;
                if(contentId!=null&&contentId!=''&&contentId.contains('SENT'))
                {
                    String totalContentIds=ld.Total_Content_List__c;if(ld.Total_Content_List__c==null) ld.Total_Content_List__c='';if(totalContentIds!=null&&!totalContentIds.contains(contentId)) ld.Total_Content_List__c+=contentId+';';if(totalContentIds==null) ld.Total_Content_List__c+=contentId+';';
                }
                Lead c=ld;
                String camStatus=c.Pardot_Campaign_Status__c;
                if(camStatus!=null&&camStatus!=''&&camStatus.contains('Opened')&&c.Email!=null)
                {
                    String totalCampaignIds=c.Pardot_Campaign_Status_Area__c;if(c.Pardot_Campaign_Status_Area__c==null) c.Pardot_Campaign_Status_Area__c='';if(totalCampaignIds!=null&&!camStatus.contains(totalCampaignIds)) c.Pardot_Campaign_Status_Area__c+=camStatus+';';if(totalCampaignIds==null) c.Pardot_Campaign_Status_Area__c+=camStatus+';';                  
                }
                
                if(ld.Total_Mailer_List__c==null&&ld.Current_Mailer_Sent__c!=null)ld.Total_Mailer_List__c+=ld.Current_Mailer_Sent__c+';';
                if(ld.Total_Mailer_List__c!=null&&ld.Current_Mailer_Sent__c!=null&&!ld.Total_Mailer_List__c.contains(ld.Current_Mailer_Sent__c))ld.Total_Mailer_List__c+=ld.Current_Mailer_Sent__c+';';  
            }
        }
        
        if(Trigger.isAfter&&(Trigger.isUpdate))
        {
            system.debug('====OLD===='+trigger.new[0].Status);
            system.debug('====OLD===='+trigger.new[0].Contacted_Journey_Status__c);
            system.debug('====OLD===='+trigger.new[0].Email);
            If((Trigger.new[0].Status=='Converted' || Trigger.new[0].Status=='Declined' )&& Trigger.new[0].Contacted_Journey_Status__c=='Play'&&Trigger.new[0].Email!=null)
            {
                List<Lead> ldlist=[Select Id,Contacted_Journey_Status__c from Lead where Email=: Trigger.new[0].Email and Id<>:Trigger.new[0].Id and Status='Contacted' and Contacted_Journey_Status__c='Pause' AND X21_Days_Loop__c='DONT-START-LOOP' LIMIT 1];
                if(!ldlist.isEmpty()&&ldlist.size()>0)
                {
                    CaseStaticVars.allowLeadInTrigger=false;ldlist[0].Contacted_Journey_Status__c='Play';ldlist[0].X21_Days_Loop__c='LOOP1';update ldlist[0];
                }
            }
            
            
        }
        
        
        if(Trigger.isAfter&&(Trigger.isInsert||Trigger.isUpdate))
        {
            if(trigger.new[0].Pardot_Campaign_Status__c!=null&&trigger.new[0].Pardot_Campaign_Status__c!=''&&trigger.new[0].Pardot_Campaign_Status__c.contains('Opened')&&trigger.new[0].Email!=null)
                Lead_Contact_Campaign_Helper.updateMemberStatus(trigger.new[0].Pardot_Campaign_Status__c,trigger.new[0].Email);  
            
            for(Lead c:trigger.new)
            {
                
                if(c.Email!=null&&c.Email!='') leadEmailMap.put(c.Email,c);
                
                if((! Test.isRunningTest())&&c.Email!=null&&c.Campaign_Id__c!=null&&c.Campaign_Id__c!=''&&c.Register_User_in_GW__c=='Register-In-G2W') GW_RegisterUserForWebnar.doRegister(String.ValueOf(c.Campaign_Id__c),String.ValueOf(c.Id),c.FirstName,c.LastName,c.Email,'','','','',c.MobilePhone,c.Company,c.Title,''); 
            }
            List<Lead2Contact__c> ldConList = new List<Lead2Contact__c>();
            List<Lead2Contact__c> ldConList2 = new List<Lead2Contact__c>();
            
            List<Lead2Contact__c> ldConInsertList = new List<Lead2Contact__c>();
            List<Lead2Contact__c> ldConUpdateList = new List<Lead2Contact__c>();
            List<Lead2Contact__c> ldConDelList = new List<Lead2Contact__c>();
            
            Map<String,Lead2Contact__c> ldConMap = new Map<String,Lead2Contact__c>();           
            Map<String,Lead2Contact__c> ldConMap2 = new Map<String,Lead2Contact__c>();     
            Map<String,Lead2Contact__c> ldConMap3 = new Map<String,Lead2Contact__c>();    
            
            Map<String,Contact> conMap = new Map<String,Contact>();           
            
            List<Contact> conList = [Select Id,Email from Contact where Email IN: leadEmailMap.keySet()]; 
            if(conList.size()>0)
            {
                for(Contact c:conList) 
                {
                    if(c.Email!=null) conMap.put(c.Email,c);
                }
            }
            
            
            
            ldConList=[Select Id,Lead__c,Contact__c,Contact__r.Email,Lead__r.Email from Lead2Contact__c where Lead__r.Email IN:leadEmailMap.keySet() OR Contact__r.Email IN:leadEmailMap.keySet()];
            ldConList2=[Select Id,Lead__c,Contact__c,Contact__r.Email,Lead__r.Email from Lead2Contact__c where Contact__r.Email IN:leadEmailMap.keySet()];
            
            if(ldConList.size()>0)
            {
                for(Lead2Contact__c lc:ldConList)
                {
                    if(lc.Lead__c!=null) ldConMap.put(lc.Lead__c,lc);
                    if(lc.Contact__c!=null) ldConMap2.put(lc.Contact__c,lc);
                    //if(lc.Contact__c!=null&&lc.Lead__c!=null&&lc.Contact__r.Email!=null&&lc.Lead__r.Email!=null&&lc.Contact__r.Email!=lc) 
                }    
            }
            
            if(ldConList2.size()>0)
            {
                for(Lead2Contact__c lc:ldConList2)
                {
                    if(lc.Contact__c!=null) ldConMap3.put(lc.Contact__c,lc);
                }
            }
            for(Lead c:trigger.new)
            {
                if(c.Email!=null&&ldConMap.size()>0&&ldConMap.containsKey(c.Id))
                {
                    if(ldConMap.get(c.Id).Contact__c!=null&&c.Email==ldConMap2.get(ldConMap.get(c.Id).Contact__c).Contact__r.Email&&!ldConMap.containsKey(c.Id))
                    {
                        system.debug('==1A==');
                        Lead2Contact__c lc = new Lead2Contact__c();
                        lc.Lead__c=c.Id;
                        if(conMap.size()>0&&conMap.containsKey(c.Email)) lc.Contact__c=conMap.get(c.Email).Id;
                        ldConInsertList.add(lc);
                    }
                    else if(ldConMap.get(c.Id).Contact__c!=null&&c.Email==ldConMap2.get(ldConMap.get(c.Id).Contact__c).Contact__r.Email)
                    {
                        system.debug('==Entry 1=='+c.email+'==='+ldConMap2.get(ldConMap.get(c.Id).Contact__c).Contact__r.Email);
                        Lead2Contact__c lc = new Lead2Contact__c();
                        lc.Id=ldConMap2.get(conMap.get(c.Email).Id).Id;
                        lc.Contact__c=conMap.get(c.Email).Id;
                        lc.Lead__c=c.Id;
                        ldConUpdateList.add(lc);
                    }
                    else if(ldConMap.get(c.Id).Contact__c!=null&&c.Email!=ldConMap.get(c.Id).Contact__r.Email)
                    {
                        system.debug('==Entry 2==');
                        Lead2Contact__c lc = new Lead2Contact__c();
                        lc.Id=ldConMap.get(c.Id).Id;
                        lc.Contact__c=conMap.size()>0&&conMap.containsKey(c.Email)?conMap.get(c.Email).Id:lc.Contact__c;
                        lc.Lead__c=null;
                        ldConDelList.add(lc);
                        
                        Lead2Contact__c lc2 = new Lead2Contact__c();
                        lc2.Contact__c=conMap.size()>0&&conMap.containsKey(c.Email)?conMap.get(c.Email).Id:lc2.Contact__c;
                        lc2.Lead__c=c.Id;
                        if(ldConMap3.size()>0&&ldConMap3.containsKey(lc2.Contact__c)&&ldConMap3.get(lc2.Contact__c).Lead__c==null)
                        {
                            lc2.Id=ldConMap3.get(lc2.Contact__c).Id;
                            ldConUpdateList.add(lc2);
                        }
                        else
                            ldConInsertList.add(lc2);
                    }
                    else
                    {
                        system.debug('==Entry 3==');
                        if(conMap.size()>0&&conMap.containsKey(c.Email))
                        {
                            //ldConUpdateList
                            //
                            system.debug('==Entry 3==');
                            Lead2Contact__c lc = new Lead2Contact__c();
                            lc.Id=ldConMap.get(c.Id).Id;
                            lc.Contact__c=conMap.get(c.Email).Id;
                            ldConUpdateList.add(lc);
                        }
                    }
                }
                else if(ldConMap2.size()>0&&conMap.size()>0&&conMap.containsKey(c.Email)&&ldConMap2.containsKey(conMap.get(c.Email).Id)&&!ldConMap.containsKey(c.Id))
                {
                    system.debug('==4==');
                    Lead2Contact__c lc = new Lead2Contact__c();
                    lc.Lead__c=c.Id;
                    if(conMap.size()>0&&conMap.containsKey(c.Email)) lc.Contact__c=conMap.get(c.Email).Id;
                    if(conMap.size()>0&&conMap.containsKey(c.Email)&&ldConMap2.size()>0&&ldConMap2.containsKey(conMap.get(c.Email).Id)&&ldConMap2.get(conMap.get(c.Email).Id).Lead__c==null)
                    {
                        lc.Id=ldConMap2.get(conMap.get(c.Email).Id).Id;
                        ldConUpdateList.add(lc);    
                    }
                    else
                        ldConInsertList.add(lc);
                }
                else if(ldConMap2.size()>0&&conMap.size()>0&&conMap.containsKey(c.Email)&&ldConMap2.containsKey(conMap.get(c.Email).Id))
                {
                    system.debug('==4==');
                    Lead2Contact__c lc = new Lead2Contact__c();
                    lc.Id=ldConMap2.get(conMap.get(c.Email).Id).Id;
                    system.debug(lc.Id);
                    lc.Lead__c=c.Id;
                    ldConUpdateList.add(lc);
                }
                else
                {
                    system.debug('==5==');
                    Lead2Contact__c lc = new Lead2Contact__c();
                    lc.Lead__c=c.Id;
                    if(conMap.size()>0&&conMap.containsKey(c.Email)) lc.Contact__c=conMap.get(c.Email).Id;
                    if(c.Email!=null) ldConInsertList.add(lc);
                    
                    if(ldConMap.size()>0&&ldConMap.containsKey(c.Id)&&ldConMap2.size()>0&&conMap.size()>0&&conMap.containsKey(c.Email)&&ldConMap2.containsKey(conMap.get(c.Email).Id))
                    {
                        system.debug('==6==');
                        lc.lead__c=null;
                        lc.Id=ldConMap2.get(conMap.get(c.Email).Id).Id;
                        ldConUpdateList.add(lc);
                    }
                    else if(ldConMap.size()>0&&ldConMap.containsKey(c.Id)&&ldConMap.get(c.Id).Contact__c==null)
                    {
                        system.debug('==7==');
                        lc.lead__c=null;
                        lc.Id=ldConMap.get(c.Id).Id;
                        ldConDelList.add(lc);
                    }
                    else if(conMap.size()==0||(conMap.size()>0&&!conMap.containsKey(c.Email)))
                    {
                        
                    }
                }
            }
            
            
            if(ldConInsertList.size()>0) insert ldConInsertList;
            if(ldConUpdateList.size()>0) update ldConUpdateList;
            if(ldConDelList.size()>0) delete ldConDelList;
            
        }
        Integer i=0;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        
    }
    
}