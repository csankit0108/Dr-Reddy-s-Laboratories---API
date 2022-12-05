({
    doInit : function(component, event, helper) {
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
        
    }
})