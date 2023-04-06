({
    doInit : function(component, event, helper) {
        if(!component.get('v.blnIsProspect')){
            component.set('v.blnIsOpportunityCreationSelected',true);
            component.set('v.blnIsOpportunityCreationDisabled',false);
            component.set('v.blnIsOpportunitySelectionSelected',false); 
            component.set('v.strOpportunityOptionSelected','CREATE');
            if(!helper.isNullCheck(component.get('v.strSelectedAccountId'))){
                component.set('v.blnIsOpportunitySelectionDisabled',false);
            } else{
                component.set('v.blnIsOpportunitySelectionDisabled',true);                
            }
        }
        helper.generateFieldsToRender(component, event, helper);
    },
    handleValueChange : function(component, event, helper) {        
        let objOpportunity = component.get('v.objOpportunity');
        let strField = event.getSource().get("v.fieldName");
        let map_FieldTypes = component.get('v.map_FieldTypes');
        if (map_FieldTypes[strField] == 'BOOLEAN'){
            objOpportunity[strField] = !objOpportunity[strField];
            component.set('v.objOpportunity', objOpportunity);
        } else{
            let value = event.getSource().get('v.value');
            objOpportunity[strField] = value;
            if (strField == "StageName") {
                helper.setFieldsToRenderOnStageChange(component, value, helper);
            } else {
                component.set('v.objOpportunity', objOpportunity);
            }
        }        
    },
    handleLookup : function(component, event, helper) {
        var strSelectedOpportunityId = event.getParam('value')[0];
        if(helper.isNullCheck(strSelectedOpportunityId)){
            component.set('v.objOpportunity',{ 'sobjectType': 'Opportunity'});  
            component.set('v.strSelectedOpportunityId','');
        } else{
            component.set('v.strSelectedOpportunityId',strSelectedOpportunityId);
            helper.existingOpportunityHelper(component, event, helper);
        }
    },
    handleRadioChange : function(component, event, helper) {
        var radioBtn = event.getSource().get("v.value");
        component.set('v.strOpportunityOptionSelected',radioBtn);
        if(radioBtn === 'CREATE'){
            component.set('v.strSelectedopportunity','');
            component.set('v.blnIsOpportunityCreationSelected',true);
            component.set('v.blnIsOpportunitySelectionSelected',false);
            helper.generateOpportunity(component, event, helper);
            helper.generateFieldsToRender(component, event, helper);            
        }
        if(radioBtn === 'SELECT'){
            component.set('v.strSelectedopportunity','');
            component.set('v.strSelectedOpportunityId','');
            component.set('v.objOpportunity',{ 'sobjectType': 'Opportunity'});            
            component.set('v.blnIsOpportunityCreationSelected',false);
            component.set('v.blnIsOpportunitySelectionSelected',true); 
            helper.generateFieldsToRender(component, event, helper);
            component.set('v.objOpportunity',{ 'sobjectType': 'Opportunity'});  
        }        

    },
    handleSelectedAccountEvent : function(component, event, helper) {
        if(!component.get('v.blnIsProspect')){
            let strAccountId = event.getParam("strId");
            let blnIsExistingAccountOptionSelected = event.getParam("blnIsExistingAccountSelected");
            component.set('v.strSelectedAccountId',strAccountId);
            if(blnIsExistingAccountOptionSelected){
                component.set("v.blnIsOpportunitySelectionDisabled",false);
                component.set('v.blnIsOpportunityCreationDisabled',false);
                helper.validateIsAccountRelatedtoOpportunity(component,event,helper);
            } else if (component.get('v.blnIsOpportunitySelectionSelected') && !blnIsExistingAccountOptionSelected){
                component.set('v.strSelectedopportunity','');
                component.set('v.strSelectedOpportunityId','');
                component.set('v.objOpportunity',{ 'sobjectType': 'Opportunity'});   
                component.set('v.strOpportunityOptionSelected','CREATE');
                component.set('v.blnIsOpportunityCreationSelected',true);
                component.set('v.blnIsOpportunityCreationDisabled',true);
                component.set('v.blnIsOpportunitySelectionSelected',false);
                component.set("v.blnIsOpportunitySelectionDisabled",true);
                helper.generateFieldsToRender(component, event, helper);
            } else {
                component.set('v.strSelectedopportunity','');
                component.set('v.strSelectedOpportunityId','');
                component.set("v.blnIsOpportunitySelectionDisabled",true);
            }
        }        
    }
})