({
    setRunautomationData : function(component,event,helper) {
        let strLeadId=component.get('v.strLeadId');
        let blncontentAvailable=false;
        let map_blncontentAvailable=component.get('v.map_blncontentAvailable');
        let map_mapcontentTotal=component.get('v.map_mapcontentTotal');
        let map_listdocumentCategoriesAvailable=component.get('v.map_listdocumentCategoriesAvailable');
        let map_strrunAfter=component.get('v.map_strrunAfter');
        let map_listfinalSelectedContentCatalogs=component.get('v.map_listfinalSelectedContentCatalogs');
        
        if(!helper.isNullCheck(map_blncontentAvailable)&&!helper.isNullCheck(map_blncontentAvailable[strLeadId])){
            blncontentAvailable=map_blncontentAvailable[strLeadId];
            component.set('v.blncontentAvailable',blncontentAvailable);
            if(blncontentAvailable){
                component.set('v.map_contentTotal',map_mapcontentTotal[strLeadId]);
                component.set('v.list_documentCategoriesAvailable',map_listdocumentCategoriesAvailable[strLeadId]);
                component.set('v.strrunAfter',map_strrunAfter[strLeadId]);
                component.set('v.list_finalSelectedContentCatalogs',map_listfinalSelectedContentCatalogs[strLeadId]);
            }
        }
        else{
            component.set('v.blncontentAvailable',blncontentAvailable);
        }
        

    },
    isNullCheck:function(variable){
        if(variable==null||variable==undefined||variable==''){
            return true;
        }
        else{
            return false;
        }
    }
})