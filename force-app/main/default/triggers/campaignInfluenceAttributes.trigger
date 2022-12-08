trigger campaignInfluenceAttributes on CampaignInfluence (after insert,after update) {
    if (caseStaticVars.allowInfluenceInTrigger) {
        List<CampaignInfluence> camplist = new List<CampaignInfluence>();
        List<CampaignInfluence> camplist2 = new List<CampaignInfluence>();
        try
        {
            Map<Id,Id> campOptyMap = new Map<Id,Id>();
            Map<Id,Id> optyStageTrackerMap = new Map<Id,Id>();
            Map<Id,Opportunity_Stage_Tracker__c> optyStageTrackerMap2 = new Map<Id,Opportunity_Stage_Tracker__c>();
            Map<Id,Id> optyStageTrackerMapFinal = new Map<Id,Id>();
            for(CampaignInfluence cf:[Select Id, CreatedDate,Pardot_Campaign_Status__c, CreatedById, LastModifiedDate,Opportunity.Product__r.Name, LastModifiedById, SystemModstamp, ContactId, CampaignId,Campaign.Product__c,Campaign.Product__r.Name,Opportunity.Product__c, Influence, OpportunityId from CampaignInfluence where Id IN: Trigger.newMap.keySet()])
            {
                campOptyMap.put(cf.Id,cf.OpportunityId);
                if(cf.OpportunityId!=null&&cf.Opportunity.Product__c!=null&&cf.Campaign.Product__c!=null)
                {
                    
                    String prodName=cf.Campaign.Product__r.Name;
                    system.debug('==CampaignProd=='+prodName);
                    system.debug('==OpportunityProd=='+cf.Opportunity.Product__r.Name);
                    String product=cf.Opportunity.Product__c!=null?cf.Opportunity.Product__r.Name:'';
                    if(product!='')
                    {
                        Boolean foundProd1=product.contains(prodName);
                        Boolean foundProd2=prodName.contains(product);
                        if((foundProd1||foundProd2)&&cf.Pardot_Campaign_Status__c=='Opened')
                        {
                            system.debug('===Matched==100');
                            cf.Influence=100;
                            camplist.add(cf);
                        }
                        else if((foundProd1||foundProd2)&&cf.Pardot_Campaign_Status__c!='Opened'&&cf.Influence!=100)
                        {
                            system.debug('===Matched==50');
                            cf.Influence=0;
                            camplist.add(cf);
                        }
                        else
                        {
                            if(cf.Influence!=100)
                            {
                                system.debug('===Matched==0');
                                cf.Influence=0;
                                camplist.add(cf);
                            }
                        }
                    }
                }
                else
                {
                    if( cf.Influence!=100)
                    {
                        system.debug('===Matched==ELSE');
                        cf.Influence=10;
                        camplist.add(cf);
                    }
                }
            }
            
            if(campOptyMap.size()>0)
            {
                system.debug('==='+campOptyMap.size());
                List<Opportunity_Stage_Tracker__c> stageTrackerList=[SELECT Id, Name, CreatedDate, LastModifiedDate, Actual_End_Date__c, End_Date__c, MOM__c, Opportunity__c, Start_Date__c, MOM1__c, MOM_Lastmodified_Date__c, MOM_Created_Date__c, Stage_Duration__c FROM Opportunity_Stage_Tracker__c where Opportunity__c IN: campOptyMap.values() ORDER BY CreatedDate DESC];
                if(stageTrackerList.size()>0)
                {
                    system.debug('==2=='+campOptyMap.size());
                    for(Opportunity_Stage_Tracker__c opt:stageTrackerList)
                    {
                        if(!optyStageTrackerMap.containsKey(opt.Opportunity__c))
                        {
                            optyStageTrackerMap.put(opt.Opportunity__c,opt.Id);
                            optyStageTrackerMap2.put(opt.Opportunity__c,opt);
                        }
                    }
                    
                    system.debug('==3=='+optyStageTrackerMap.size());
                    
                    for(Id campId:campOptyMap.keySet())
                    {
                        system.debug('==4=='+optyStageTrackerMap.size());
                        Id optyId=campOptyMap.get(campId);
                        if(optyStageTrackerMap.containsKey(optyId))
                        {
                            system.debug('==5=='+optyStageTrackerMap.size()); 
                            optyStageTrackerMapFinal.put(optyId,campId);
                            system.debug('==6=='+optyStageTrackerMap.get(optyId));
                            CampaignInfluence cm=new CampaignInfluence(Id=campId,Opportunity_Stage_Tracker_Id__c=optyStageTrackerMap.get(optyId),Stage_Name__c=optyStageTrackerMap2.get(optyId).Name,Stage_Updated_On__c=optyStageTrackerMap2.get(optyId).CreatedDate);
                            camplist2.add(cm);
                        }
                    }
                }
            }
            
            if(camplist.size()>0)
            {
                caseStaticVars.allowInfluenceInTrigger=false;
                update camplist;
            }
            if(camplist2.size()>0&&Trigger.isInsert)
            {
                caseStaticVars.allowInfluenceInTrigger=false;
                update camplist2;
            }
        }
        Catch(Exception e)
        {            
        }
        
    }

    if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
        DRL_CampaignInfluenceTriggerHelper.calculateValueOfBioBatch(trigger.new);
    }
}