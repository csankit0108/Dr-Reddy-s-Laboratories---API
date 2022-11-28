({
    doInit : function(component, event, helper) {
        helper.generateFieldsToRender(component, event, helper);
    },
    handleValueChange : function(component, event, helper) {
        let value = event.getParam("value");
        let strField = event.getSource().get("v.fieldName");
        let objOpportunity = component.get("v.objOpportunity");
        objOpportunity[strField] = value;
        if(strField == "StageName"){
            helper.setFieldsToRenderOnStageChange(component, value, helper);
        }
    }
})