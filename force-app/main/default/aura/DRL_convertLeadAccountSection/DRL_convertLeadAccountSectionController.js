({
    doInit: function (component, event, helper) {
        component.set('v.strRadioButtonSelected', '1');
        helper.configureIfParentAlreadyConverted(component, event, helper);
        helper.getAccountFields(component, event, helper);        
    },
    
    
    handleValueChange: function (component, event, helper) {
        let value = event.getParam('value');
        let field = event.getSource().get("v.fieldName");
        let objAccount = component.get('v.objAccount');
        objAccount[field] = value;
    },
    
    handleLookup: function(component, event, helper){
        var strAccountId = event.getParam('value')[0];
        component.set('v.strAccountId',strAccountId);
        helper.existingAccountHelper(component, event, helper);
        
    },
    
    handleRadioChange:function(component, event, helper){
    
        var radioBtn = event.getSource().get("v.value");
        component.set('v.strRadioButtonSelected',radioBtn);
            if(radioBtn === '1'){
                helper.generateAccount(component, event, helper);
                helper.getAccountFields(component, event, helper);
                component.set('v.strExistingAccount','');
                component.set('v.blnAllowAccountCreation',true);
                component.set('v.blnAllowAccountSelection',false);
            }
            if(radioBtn === '2'){
                component.set('v.objAccount',{ 'sobjectType': 'Account'});
                helper.getAccountFields(component, event, helper);
                component.set('v.blnAllowAccountCreation',false);
                component.set('v.blnAllowAccountSelection',true);                
            }
        },
        
    })