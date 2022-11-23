({
    doInit:function(component,event,helper){
        if(component.get('v.blnIsProspect')){
            helper.setRunautomationData(component,event,helper);
        }
    },
    populateContent: function (component, event, helper) {
        var content = event.getParam("content");
        var map_contentTotal = component.get("v.map_contentTotal");
        var map_contentTotalreset = JSON.parse(JSON.stringify(map_contentTotal));
        var list_finalSelectedContentCatalogs = component.get("v.list_finalSelectedContentCatalogs");

        if (list_finalSelectedContentCatalogs != undefined && list_finalSelectedContentCatalogs != null && list_finalSelectedContentCatalogs != '' && list_finalSelectedContentCatalogs.length > 0) {
            for (var i = 0; i < list_finalSelectedContentCatalogs.length; i++) {
                for (var j = 0; j < map_contentTotal[list_finalSelectedContentCatalogs[i].categoryCount].length; j++) {
                    var itemId = map_contentTotal[list_finalSelectedContentCatalogs[i].categoryCount][j].catalogId;
                    if (list_finalSelectedContentCatalogs[i].catalogId == itemId)
                        map_contentTotal[list_finalSelectedContentCatalogs[i].categoryCount].splice(j, 1);
                }
            }
        }
        component.set("v.list_documentsAvailable", map_contentTotal[content]);
        component.set("v.map_contentTotal", map_contentTotalreset);
    },
    loadItemsApp: function (component, event, helper) {
        component.set("v.list_finalSelectedContentCatalogs", event.getParam("data"));
        if(component.get('v.blnIsProspect')){
            let map_listfinalSelectedContentCatalogs=JSON.parse(JSON.stringify(component.get('v.map_listfinalSelectedContentCatalogs')));
            var list_contentCatalogs=JSON.parse(JSON.stringify(event.getParam("data")));
            map_listfinalSelectedContentCatalogs[component.get('v.strLeadId')]=list_contentCatalogs;
            component.set('v.map_listfinalSelectedContentCatalogs',map_listfinalSelectedContentCatalogs);
        }
    },
    handleChangeDays:function(component,event,helper){
        if(component.get('v.blnIsProspect')){
            let map_strrunAfter=component.get('v.map_strrunAfter');
            map_strrunAfter[component.get('v.strLeadId')]=event.getParam("value");
            component.set('v.map_strrunAfter',map_strrunAfter);
        }
    }
})