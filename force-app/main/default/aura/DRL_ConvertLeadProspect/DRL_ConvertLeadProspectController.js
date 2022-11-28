({	
    doInit: function(component, event, helper){
        component.set('v.blnIsLoading', true);
        if (component.get('v.blnrenderfrompath')) {
            var modalContainer = component.find("modalContainer");
            $A.util.removeClass(modalContainer, "Container");            
        }else{
            var modalbackdrop = component.find("modalbackdrop");
            $A.util.addClass(modalbackdrop, "hideContent");             
        }
        helper.getDetailsOnLoad(component,event,helper);       
    },
    
    cancelAction:function(component,event,helper){
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
        if (component.get('v.blnrenderfrompath')) {
            var modal = component.find("modal");
            $A.util.addClass(modal, "hideContent");
            var modalbackdrop = component.find("modalbackdrop");
            $A.util.addClass(modalbackdrop, "hideContent"); 
        }
    },
    handleConvert:function(component,event,helper){   
        component.set('v.blnIsLoading', true);
        if (!component.get('v.blnIsParentProspectConverted')) {
            if(!helper.isValidAccount(component, event, helper)) {
                component.set('v.blnIsLoading', false);
                return false;
            }
            var strAccountRadioButtonSelected = component.get('v.strAccountRadioButtonSelected');
            var strContactRadioButtonSelected = component.get('v.strContactRadioButtonSelected');
            if (strAccountRadioButtonSelected === '2' && strContactRadioButtonSelected === '4') {
             if (!helper.isAccountRelatedContact(component,event,helper)) {
                component.set('v.blnIsLoading', false);
                return false;
            }
            }
        }        
         if (!helper.isValidOpportunities(component, event, helper)) {
            component.set('v.blnIsLoading', false);
            return false;
        }   
        if (!helper.isValidRunAutomationData(component, event, helper)) {
            component.set('v.blnIsLoading', false);
            return false;
        }
        helper.isValidContact(component, event, helper);
    } 
    
})