({
    doInit : function(component, event, helper) {
        if(component.get('v.list_Opportunities')!=null&&component.get('v.list_Opportunities')!=undefined&&component.get('v.list_Opportunities').length>0){
            helper.getColumns(component);
        }
    }
})