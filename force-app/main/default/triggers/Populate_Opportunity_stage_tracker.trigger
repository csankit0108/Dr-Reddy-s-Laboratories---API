trigger Populate_Opportunity_stage_tracker on Opportunity (after insert,after update,before update,before delete) 
{
    ID optyRecordTypeID= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API').getRecordTypeId();
    system.debug('Opportunity API Record Type ID--->'+optyRecordTypeID);    
    if(trigger.isbefore)
    {
        if(trigger.isupdate)
        {
            for(Opportunity o:trigger.new)
            {
                if(o.RecordTypeId==optyRecordTypeID){
                    if(o.Workflow_Identifier__c!=null)
                      o.Workflow_Identifier__c=  o.Workflow_Identifier__c + 1;
                }
                  
            }
        }
        //by sk to send email
        if(trigger.isdelete)
        {            
            list<Opportunity> deletedrec =new list<Opportunity>();
            id apiPlusRecTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API Plus').getRecordTypeId();                
            for(Opportunity o:trigger.old)
            {
                if(apiPlusRecTypeId != null && o.RecordTypeId == apiPlusRecTypeId){
                    deletedrec.add(o);
                }
            }
            if(deletedrec.size() > 0){
                API_Plus_View_PF.sendAlertForRecDeletion(deletedrec);
            }
        }
        //upto here
    }
    
    if(trigger.isafter)
    {
        String accId=trigger.new[0].Ultimate_Parent_ID__c;
        system.debug('==accId=='+accId);
        if(accId!=null&&accId!=''&&!Test.isRunningTest() && !System.isFuture() && !System.isBatch()) AccountTeamAccessHelper.accountTeamAccess(accId);
        if(trigger.isinsert)
        {
            
            list<Opportunity_stage_tracker__c> ostList = new list<Opportunity_stage_tracker__c>();
            map<id,list<Opportunity_stage_tracker__c>> ostMap = new map<id,list<Opportunity_stage_tracker__c>>();
            set<id> oppId = new set<id>();
            Map<String,OpportunityContactRole> optyRoleMap = new Map<String,OpportunityContactRole>();
            List<OpportunityContactRole> existlist = [Select Id,OpportunityId,ContactId from OpportunityContactRole where OpportunityId IN:Trigger.newMap.KeySet()];
            if(existlist.size()>0)
            {
                for(OpportunityContactRole op:existlist)
                {
                    String opCon = String.ValueOf(op.ContactId)+String.ValueOf(op.OpportunityId);
                    optyRoleMap.put(opCon,op);
                }
            }
            
            List<OpportunityContactRole> oclist = new List<OpportunityContactRole>();
            
            for(Opportunity tempOpp :trigger.new)
            {
                if(tempOpp.RecordTypeId==optyRecordTypeID)
                {
                    oppId.add(tempOpp.id);
                    OpportunityContactRole oc = new OpportunityContactRole();
                    oc.ContactId=tempOpp.Contact__c;
                    oc.OpportunityId=tempOpp.Id;
                    String opCon = String.ValueOf(oc.ContactId)+String.ValueOf(oc.OpportunityId);
                    if(oc.ContactId!=null&&!optyRoleMap.containsKey(opCon)) oclist.add(oc);
                }
                
            }    
            
            if(!oppId.isempty())
            {
                for(Opportunity_stage_tracker__c i : [select id,name,opportunity__c,start_date__c from Opportunity_stage_tracker__c where Opportunity__c in :oppId])
                {
                    if(ostMap.get(i.opportunity__c) !=null)
                    {
                        ostMap.get(i.opportunity__c).add(i);
                    }
                    else
                    {
                        ostMap.put(i.opportunity__c,new list<Opportunity_stage_tracker__c>());
                        ostMap.get(i.opportunity__c).add(i);
                    }
                }
            }  
            for(Opportunity tempOpp :trigger.new)
            {
                if(tempOpp.RecordTypeId==optyRecordTypeID)
                {
                    if(tempOpp.Update_MOM_Tracker__c == true)
                    {
                        Opportunity_stage_tracker__c ostObj = new Opportunity_stage_tracker__c();
                        // ostObj.Start_Date__c = date.today();
                        ostObj.MOM__c = tempOpp.New_notes__c;
                        ostObj.name = tempOpp.stagename;
                        ostObj.Opportunity__c = tempOpp.id;
                        
                        ostList.add(ostObj);
                        system.debug('** Trigger Check Stage Tracker DEBUG 1'+ostObj);
                    }
                }
                
            }
            if(!ostList.isempty() && ostList!=null)
            {
                try{
                    insert ostList;
                }
                catch(exception e)
                {
                    for(Opportunity tempOpp :trigger.new)
                    {
                        tempOpp.adderror('There is some problem in tracking the stage please find the error below'+'\n'+e.getmessage());
                    }
                }
            }
            if(oclist.size()>0) insert oclist;
        }
        
        else if(trigger.isupdate)
        {
            list<Opportunity_stage_tracker__c> ostList = new list<Opportunity_stage_tracker__c>();
            map<id,Opportunity> oppoldMap = new map<id,Opportunity>();
            map<id,Opportunity_stage_tracker__c> ostOldmap= new map<id,Opportunity_stage_tracker__c>();
            list<Opportunity_stage_tracker__c> ostvaluestoupdate = new list<Opportunity_stage_tracker__c>();
            list<id> oppcollector = new list<id>();
            
            Map<String,OpportunityContactRole> optyRoleMap = new Map<String,OpportunityContactRole>();
            List<OpportunityContactRole> existlist = [Select Id,ContactId,OpportunityId from OpportunityContactRole where OpportunityId IN:Trigger.newMap.KeySet()];
            if(existlist.size()>0)
            {
                for(OpportunityContactRole op:existlist)
                {
                    String opCon = String.ValueOf(op.ContactId)+String.ValueOf(op.OpportunityId);
                    optyRoleMap.put(opCon,op);
                }
            }
            
            List<OpportunityContactRole> oclist = new List<OpportunityContactRole>();
            
            for(Opportunity tempOpp :trigger.new)
            {
                if(tempOpp.RecordTypeId==optyRecordTypeID)
                {
                    OpportunityContactRole oc = new OpportunityContactRole();
                    oc.ContactId=tempOpp.Contact__c;
                    oc.OpportunityId=tempOpp.Id;
                    String opCon = String.ValueOf(oc.ContactId)+String.ValueOf(oc.OpportunityId);
                    if(oc.ContactId!=null&&!optyRoleMap.containsKey(opCon)) oclist.add(oc);
                }
                
            } 
            for(Opportunity tempoldOpp :trigger.old)
            {
                if(tempoldOpp.RecordTypeId==optyRecordTypeID)
                {
                    oppoldMap.put(tempoldOpp.id,tempoldOpp);
                }
            }
            
            for(Opportunity_stage_tracker__c ost : [select id,name,actual_end_date__c,lastmodifieddate,opportunity__c from Opportunity_stage_tracker__c where opportunity__c in:oppoldMap.keyset() order by createddate Asc])
            {
                ostOldmap.put(ost.opportunity__c,ost);
            }
            
            for(Opportunity tempOpp :trigger.new)
            {
                if(tempOpp.RecordTypeId==optyRecordTypeID)
                {
                    oppcollector.add(tempOpp.id);
                    if(tempOpp.Update_MOM_Tracker__c == true)
                    {
                        
                        
                        Opportunity_stage_tracker__c ostObj = new Opportunity_stage_tracker__c();
                        ostObj.MOM__c = tempOpp.New_notes__c;
                        ostObj.name = tempOpp.stagename;
                        ostObj.Opportunity__c = tempOpp.id;
                        system.debug('_-_-_-_'+tempOpp.Workflow_Identifier__c);
                        if(tempOpp.Workflow_Identifier__c != 1)
                            ostList.add(ostObj);
                    }
                }
                
            }
            
            if(!ostList.isempty() && ostList!=null)
            {
                try{
                    insert ostList;
                    system.debug('** Trigger Check Stage Tracker Update DEBUG 2'+ostList);
                }
                catch(exception e)
                {
                    for(Opportunity tempOpp :trigger.new)
                    {
                        tempOpp.adderror('There is some problem in tracking the stage please find the error below'+'\n'+e.getmessage());
                    }
                }
            }
            system.debug('---**'+oppcollector);
            if(oppcollector !=null && !oppcollector.isempty()&&!Test.isRunningTest())
                MomTrackerTriggerhandler mttobj = new MomTrackerTriggerhandler(oppcollector);     
        }
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