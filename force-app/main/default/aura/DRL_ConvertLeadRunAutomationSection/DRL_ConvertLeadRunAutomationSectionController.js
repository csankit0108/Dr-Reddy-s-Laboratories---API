({
    doInit:function(component, event, helper){
        if (component.get('v.blnIsProspect')) {
            helper.setRunautomationData(component,event,helper);
        }
    },
    populateContent: function (component, event, helper) {
        var content = event.getParam("content");
        var map_ContentTotal = component.get("v.map_ContentTotal");
        var map_contentTotalreset = JSON.parse(JSON.stringify(map_ContentTotal));
        var list_FinalSelectedContentCatalogs = component.get("v.list_FinalSelectedContentCatalogs");

        if ( 
            list_FinalSelectedContentCatalogs != undefined && 
            list_FinalSelectedContentCatalogs != null && 
            list_FinalSelectedContentCatalogs != '' && 
            list_FinalSelectedContentCatalogs.length > 0
            ) {
            for (var i = 0; i < list_FinalSelectedContentCatalogs.length; i++) {
                for (var j = 0; j < map_ContentTotal[list_FinalSelectedContentCatalogs[i].categoryCount].length; j++) {
                    var itemId = map_ContentTotal[list_FinalSelectedContentCatalogs[i].categoryCount][j].catalogId;
                    if (list_FinalSelectedContentCatalogs[i].catalogId == itemId)
                        map_ContentTotal[list_FinalSelectedContentCatalogs[i].categoryCount].splice(j, 1);
                }
            }
        }
        component.set("v.list_DocumentsAvailable", map_ContentTotal[content]);
        component.set("v.map_ContentTotal", map_contentTotalreset);
    },
    loadItemsApp: function (component, event, helper) {
        component.set("v.list_FinalSelectedContentCatalogs", event.getParam("data"));
        if (component.get('v.blnIsProspect')) {
            let map_ListFinalSelectedContentCatalogs = JSON.parse(JSON.stringify(component.get('v.map_ListFinalSelectedContentCatalogs')));
            var list_contentCatalogs = JSON.parse(JSON.stringify(event.getParam("data")));
            map_ListFinalSelectedContentCatalogs[component.get('v.strLeadId')] = list_contentCatalogs;
            component.set('v.map_ListFinalSelectedContentCatalogs', map_ListFinalSelectedContentCatalogs);
        }
    },
    handleChangeDays:function(component, event, helper){
        if (component.get('v.blnIsProspect')) {
            let map_StrRunAfter = component.get('v.map_StrRunAfter');
            map_StrRunAfter[component.get('v.strLeadId')] = event.getParam("value");
            component.set('v.map_StrRunAfter', map_StrRunAfter);
        }
    }
})