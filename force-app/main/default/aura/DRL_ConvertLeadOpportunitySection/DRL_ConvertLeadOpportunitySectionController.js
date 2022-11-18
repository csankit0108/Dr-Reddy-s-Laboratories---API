({
    doInit : function(component, event, helper) {
        helper.generateFieldsToRender(component,event,helper);
    },
    handleValueChange : function(component, event, helper) {
        let value=event.getParam('value');
        let strfield=event.getSource().get("v.fieldName");
        let objopportunity=component.get('v.objopportunity');
        objopportunity[strfield]=value;
        if(strfield=='StageName'){
            helper.setFieldsToRenderOnStageChange(component,value,helper);
        }
    }
})