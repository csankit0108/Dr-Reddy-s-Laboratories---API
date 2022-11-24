({	
    doInit: function (component, event, helper) {
        component.set("v.strRadioButtonSelected", "3");
        helper.configureIfParentAlreadyConverted(component, event, helper);
        helper.getContactFields(component, event, helper);      
    },
    
    handleValueChange:function(component, event, helper){        
        let value = event.getParam("value");
        let field = event.getSource().get("v.fieldName");        
        let objContact = component.get("v.objContact");
        objContact[field] = value;
    },
    
    handleLookup: function(component, event, helper){
        var strContactId = event.getParam("value")[0];
        component.set("v.strContactId", strContactId);
        helper.existingContactHelper(component, event, helper);
    },
    
    handleRadioChange: function(component, event, helper){
        var strRadioButton = event.getSource().get("v.value");
        component.set("v.strRadioButtonSelected", strRadioButton);
        if (strRadioButton === "3") {
            helper.generateContact(component, event, helper);
            helper.getContactFields(component, event, helper);
            component.set("v.strExistingContact", "");
            component.set("v.blnAllowContactCreation", true);
            component.set("v.blnAllowContactSelection", false);
            
        }
        if (strRadioButton === "4") {
            component.set("v.objContact",{ "sobjectType": "Contact"});
            helper.getContactFields(component, event, helper);
            component.set("v.blnAllowContactCreation", false);
            component.set("v.blnAllowContactSelection", true);            
        }        
    },
    
    
})