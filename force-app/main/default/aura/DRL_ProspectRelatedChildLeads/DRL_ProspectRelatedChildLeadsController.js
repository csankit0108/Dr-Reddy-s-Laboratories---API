({
    doInit : function(component, event, helper) {
        if (component.get("v.blnIsChildRecordsFound")) {
            helper.setRunAutomationData(component);
        }
    },
    convertSelectedLead:function(component, event, helper){
        let list_SelectedLeads = event.getParam("selectedRows");
        let list_FilteredSelectedLeads = [];
        let blnIsSelectedLeadsValid = true;
        let list_SelectLeadIds = [];
        list_SelectedLeads.forEach(function(objLead){
            if (
                objLead.Product_Lookup__c == null||
                objLead.Product_Lookup__c == undefined||
                objLead.Product_Lookup__c == ""
                ) {
                if (blnIsSelectedLeadsValid) {
                    helper.showMessage("Error!", $A.get("$Label.c.CLDRL00013"), "error", "dismissable");
                    blnIsSelectedLeadsValid = false;
                }                                
            }else{
                list_SelectLeadIds.push(objLead.Id);
                list_FilteredSelectedLeads.push(objLead);
            }
        });
        if (!blnIsSelectedLeadsValid) {
            component.set("v.list_SelectedRows", list_SelectLeadIds);
        }
        if (list_SelectedLeads.length>0) {
            helper.generateOpportunities(component, list_FilteredSelectedLeads);
        }else{
            component.set("v.list_Opportunities", []);
        }    
        component.set("v.list_SelectedLeads", list_FilteredSelectedLeads);   
    }
})