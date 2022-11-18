({
    doInit : function(component, event, helper) {
        helper.setTableColumns(component);
    },
    convertSelectedLead:function(component,event,helper){
        let list_selectedLeads = event.getParam('selectedRows');
        let list_filteredSelectedLeads=[];
        let blnisSelectedLeadsValid=true;
        let list_selectLeadIds=[]
        list_selectedLeads.forEach(function(objlead){
            if(objlead.Product_Lookup__c==null||objlead.Product_Lookup__c==undefined||objlead.Product_Lookup__c==''){
                if(blnisSelectedLeadsValid){
                    helper.showMessage('Error!',$A.get("$Label.c.DRL_productField_errorMsg"),'error','dismissable');
                    blnisSelectedLeadsValid=false;
                }                                
            }
            else{
                list_selectLeadIds.push(objlead.Id);
                list_filteredSelectedLeads.push(objlead);
            }
        });
        if(!blnisSelectedLeadsValid){
            component.set('v.list_selectedRows',list_selectLeadIds);
        }
        if(list_selectedLeads.length>0){
            helper.generateOpportunities(component,list_filteredSelectedLeads);
        }
        else{
            component.set('v.list_opportunities',[]);
        }    
        component.set('v.list_selectedLeads',list_filteredSelectedLeads);   
    }
})