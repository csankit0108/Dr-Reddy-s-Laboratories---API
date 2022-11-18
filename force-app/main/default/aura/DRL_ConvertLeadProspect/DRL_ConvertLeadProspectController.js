({	
    doInit: function(component, event, helper){
        helper.getDetailsOnLoad(component,event,helper);       
    },
    
    cancelAction:function(component,event,helper){
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    handleConvert:function(component,event,helper){   
        component.set('v.blnisFormDataLoaded',false);
        if(!component.get('v.blnisParentProspectConverted')){
            if(!helper.isValidAccount(component,event,helper)) {
                component.set('v.blnisFormDataLoaded',true);
                return false;
            }
            var straccountRadioButton = component.get('v.straccountRadioButton');
            var strcontactRadioButton = component.get('v.strcontactRadioButton');
            if(straccountRadioButton === '2' && strcontactRadioButton === '4'){
             if(!helper.isAccountRelatedContact(component,event,helper)) {
                component.set('v.blnisFormDataLoaded',true);
                return false;
            }
            }
        }        
         if(!helper.isValidOpportunities(component,event,helper)) {
            component.set('v.blnisFormDataLoaded',true);
            return false;
        }   
        helper.isValidContact(component,event,helper)

    } 
    
})