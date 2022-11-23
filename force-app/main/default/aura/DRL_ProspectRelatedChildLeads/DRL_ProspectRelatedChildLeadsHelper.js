({
    setRunAutomationData : function(component){
        let map_strrunAfter={};
        let map_listfinalSelectedContentCatalogs={};
        let list_ProspectChildLeads=component.get('v.list_ProspectChildLeads');
        list_ProspectChildLeads.forEach(function(objlead){
            map_strrunAfter[objlead.Id]='';
            map_listfinalSelectedContentCatalogs[objlead.Id]=[];
        });
        component.set('v.map_strrunAfter',map_strrunAfter);
        component.set('v.map_listfinalSelectedContentCatalogs',map_listfinalSelectedContentCatalogs);
    },
    generateOpportunities : function(component,list_selectedLeads){
        let map_selectedLeads={};
        let list_opportunities=component.get('v.list_opportunities');
        list_opportunities.forEach(objopportunity => {
            map_selectedLeads[objopportunity.Lead_Converted_From__c]=objopportunity;
        });
        list_opportunities=[];
        for (const objlead of list_selectedLeads) {
            if(!map_selectedLeads[objlead.Id]){
                let objopportunity={};
                objopportunity.Name=objlead.Name;
                objopportunity.Lead_Converted_From__c=objlead.Id;
                objopportunity.RecordTypeId=component.get('v.strdefaultRecordTypeId');
                map_selectedLeads[objlead.Id]=objopportunity;
                list_opportunities.push(objopportunity);
            }
            else{
                list_opportunities.push(map_selectedLeads[objlead.Id]);
            }
        }
        component.set('v.list_opportunities',list_opportunities);       
    },
    showMessage : function(strtitle,strmessage,strtype,strmode){
        var objtoastEvent = $A.get("e.force:showToast");
        objtoastEvent.setParams({
            "title": strtitle,
            "message": strmessage,
            "type":strtype,
            "mode":strmode
        });
        objtoastEvent.fire();
    }
})