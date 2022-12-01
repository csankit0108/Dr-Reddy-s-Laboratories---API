({
    setRunAutomationData : function(component){
        let map_StrRunAfter = {};
        let map_ListFinalSelectedContentCatalogs = {};
        let list_ProspectChildLeads = component.get("v.list_ProspectChildLeads");
        list_ProspectChildLeads.forEach(function(objLead){
            map_StrRunAfter[objLead.Id] = "";
            map_ListFinalSelectedContentCatalogs[objLead.Id] = [];
        });
        component.set("v.map_StrRunAfter", map_StrRunAfter);
        component.set("v.map_ListFinalSelectedContentCatalogs", map_ListFinalSelectedContentCatalogs);
    },
    generateOpportunities : function(component,list_SelectedLeads){
        let map_SelectedLeads = {};
        let list_Opportunities = component.get("v.list_Opportunities");
        list_Opportunities.forEach(objopportunity => {
            map_SelectedLeads[objopportunity.Lead_Converted_From__c] = objopportunity;
        });
        list_Opportunities = [];
        for (const objLead of list_SelectedLeads) {
            if(!map_SelectedLeads[objLead.Id]){
                let objopportunity = {};
                objopportunity.Name = objLead.Name;
                objopportunity.Lead_Converted_From__c = objLead.Id;
                objopportunity.RecordTypeId = component.get("v.strDefaultRecordTypeId");
                objopportunity.productName=objLead.Product_Lookup__r.Name;
                map_SelectedLeads[objLead.Id] = objopportunity;
                list_Opportunities.push(objopportunity);
            }else{
                list_Opportunities.push(map_SelectedLeads[objLead.Id]);
            }
        }
        component.set("v.list_Opportunities", list_Opportunities);       
    },
    showMessage : function(strTitle, strMessage, strType, strMode){
        var objToastEvent = $A.get("e.force:showToast");
        objToastEvent.setParams({
            "title": strTitle,
            "message": strMessage,
            "type":strType,
            "mode":strMode
        });
        objToastEvent.fire();
    }
})