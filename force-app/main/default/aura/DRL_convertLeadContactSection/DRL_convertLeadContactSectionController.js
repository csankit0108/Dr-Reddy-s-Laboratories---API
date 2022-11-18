({	
    doInit: function (component, event, helper) {
        component.set('v.str_radioButtonVal2', '3');
        helper.configureIfParentAlreadyConverted(component, event, helper);
        helper.renderFields(component, event, helper);        
    },
    
    handleValueChange:function(component, event, helper){
        
        let value = event.getParam('value');
        let field = event.getSource().get("v.fieldName");
        
        let obj_Contact = component.get('v.obj_contact');
        obj_Contact[field] = value;
    },

    
    handleLookup: function(component, event, helper){
        var str_contactId = event.getParam('value')[0];
        component.set('v.str_contactId',str_contactId);
        helper.existingContactHelper(component, event, helper);
    },
    
    handleRadioChange: function(component, event, helper){
        var strRadioButton = event.getSource().get("v.value");
        component.set('v.str_radioButtonVal2', strRadioButton);
        if(strRadioButton === '3'){
            component.set('v.blnallowInput1',true);
            component.set('v.blnallowInput2',false);
            
        }
        if(strRadioButton === '4'){
            component.set('v.blnallowInput1',false);
            component.set('v.blnallowInput2',true);
            
        }
        
    },
    
    
})