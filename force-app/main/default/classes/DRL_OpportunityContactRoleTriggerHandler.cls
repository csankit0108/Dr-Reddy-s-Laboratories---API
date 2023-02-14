/*******************************************************************************************************
* @ Name            :   DRL_OpportunityContactRoleTriggerHandler
* @ Purpose         :   Trigger handler class for DRL_OpportunityContactRoleTrigger
* @ Author          :   Ankit C
* @ Test Class Name :   DRL_OpportunityContactRoleTriggerHelperTest
*
*   Date            |  Developer Name                       |  Version      |    Changes    
* ======================================================================================================        
*  10-01-2023       |  Ankit C                              |  1.0          |    Initial Version          
*******************************************************************************************************/
public class DRL_OpportunityContactRoleTriggerHandler extends TriggerHandler {
	List<OpportunityContactRole> list_NewList = new List<OpportunityContactRole>();
	Map<Id, OpportunityContactRole> map_NewMap = new Map<Id, OpportunityContactRole>();
	List<OpportunityContactRole> list_OldList = new List<OpportunityContactRole>();
	Map<Id, OpportunityContactRole> map_OldMap = new Map<Id, OpportunityContactRole>();

	public DRL_OpportunityContactRoleTriggerHandler() {
		this.list_NewList = (List<OpportunityContactRole>) trigger.new;
		this.map_NewMap = (Map<Id, OpportunityContactRole>) trigger.newMap;
		this.list_OldList = (List<OpportunityContactRole>) trigger.old;
		this.map_OldMap = (Map<Id, OpportunityContactRole>) trigger.oldMap;
	}

	public override void beforeInsert() {
		try {
			DRL_OpportunityContactRoleTriggerHelper.onBeforeInsert(list_NewList);
		} catch (Exception objException) {
			DRLUtil.logException(
				'DRL_OpportunityContactRoleTriggerHandler',
				'onBeforeInsert',
				objException,
				true
			);
		}
	}
}