({	
    doInit: function(component, event, helper){
        component.set('v.blnisLoading',true);
        if(component.get('v.blnrenderfrompath')){
            var modalContainer = component.find("modalContainer");
            $A.util.removeClass(modalContainer, "Container");            
        }
        else{
            var modalbackdrop = component.find("modalbackdrop");
            $A.util.addClass(modalbackdrop, "hideContent");             
        }
        helper.getDetailsOnLoad(component,event,helper);       
    },
    
    cancelAction:function(component,event,helper){
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
        if(component.get('v.blnrenderfrompath')){
            var modal = component.find("modal");
            $A.util.addClass(modal, "hideContent");
            var modalbackdrop = component.find("modalbackdrop");
            $A.util.addClass(modalbackdrop, "hideContent"); 
        }
    },
    handleConvert:function(component,event,helper){   
        component.set('v.blnisLoading',true);
        if(!component.get('v.blnisParentProspectConverted')){
            if(!helper.isValidAccount(component,event,helper)) {
                component.set('v.blnisLoading',false);
                return false;
            }
            var straccountRadioButton = component.get('v.straccountRadioButton');
            var strcontactRadioButton = component.get('v.strcontactRadioButton');
            if(straccountRadioButton === '2' && strcontactRadioButton === '4'){
             if(!helper.isAccountRelatedContact(component,event,helper)) {
                component.set('v.blnisLoading',false);
                return false;
            }
            }
        }        
         if(!helper.isValidOpportunities(component,event,helper)) {
            component.set('v.blnisLoading',false);
            return false;
        }   
        if(!helper.isValidRunAutomationData(component,event,helper)){
            component.set('v.blnisLoading',false);
            return false;
        }
        helper.isValidContact(component,event,helper)

    } 
    
})