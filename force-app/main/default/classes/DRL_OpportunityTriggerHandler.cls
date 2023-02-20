public with sharing class DRL_OpportunityTriggerHandler extends TriggerHandler {
    List<Opportunity> list_NewList = new List<Opportunity>();
	Map<Id, Opportunity> map_NewMap = new Map<Id, Opportunity>();
	List<Opportunity> list_OldList = new List<Opportunity>();
	Map<Id, Opportunity> map_OldMap = new Map<Id, Opportunity>();

    public DRL_OpportunityTriggerHandler() {
        this.list_NewList = (List<Opportunity>) trigger.new;
		this.map_NewMap = (Map<Id, Opportunity>) trigger.newMap;
		this.list_OldList = (List<Opportunity>) trigger.old;
		this.map_OldMap = (Map<Id, Opportunity>) trigger.oldMap;
    }

    public override void afterUpdate() {
		try {
			DRL_OpportunityTriggerHelper.onAfterUpdate(list_NewList,map_OldMap);
		} catch (Exception objException) {
			DRLUtil.logException('DRL_OpportunityTriggerHandler', 'onAfterUpdate', objException, true);
		}
	}    
}