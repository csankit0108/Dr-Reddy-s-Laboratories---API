({
    setRunautomationData : function(component, event, helper) {
        let strLeadId = component.get('v.strLeadId');
        let blnContentAvailable = false;
        let map_BlnContentAvailable = component.get('v.map_BlnContentAvailable');
        let map_MapContentTotal = component.get('v.map_MapContentTotal');
        let map_ListDocumentCategoriesAvailable = component.get('v.map_ListDocumentCategoriesAvailable');
        let map_StrRunAfter = component.get('v.map_StrRunAfter');
        let map_ListFinalSelectedContentCatalogs = component.get('v.map_ListFinalSelectedContentCatalogs');
        
        if (!helper.isNullCheck(map_BlnContentAvailable) && !helper.isNullCheck(map_BlnContentAvailable[strLeadId])) {
            blnContentAvailable = map_BlnContentAvailable[strLeadId];
            component.set('v.blnContentAvailable', blnContentAvailable);
            if (blnContentAvailable) {
                component.set('v.map_ContentTotal', map_MapContentTotal[strLeadId]);
                component.set('v.list_DocumentCategoriesAvailable', map_ListDocumentCategoriesAvailable[strLeadId]);
                component.set('v.strRunAfter', map_StrRunAfter[strLeadId]);
                component.set('v.list_FinalSelectedContentCatalogs', map_ListFinalSelectedContentCatalogs[strLeadId]);
            }
        }else{
            component.set('v.blnContentAvailable', blnContentAvailable);
        }
        

    },
    isNullCheck:function(variable){
        if (variable==null || variable==undefined || variable==''){
            return true;
        }else{
            return false;
        }
    }
})