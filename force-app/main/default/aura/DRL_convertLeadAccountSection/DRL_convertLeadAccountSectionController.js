({
    doInit: function (component, event, helper) {
        component.set('v.strRadioButtonSelected', '1');
        helper.configureIfParentAlreadyConverted(component, event, helper);
        helper.getAccountFields(component, event, helper);        
    },
    
    
    handleValueChange: function (component, event, helper) {
        let objAccount = component.get('v.objAccount');
        let field = event.getSource().get("v.fieldName");
        let map_FieldTypes = component.get('v.map_FieldTypes');
        if (map_FieldTypes[field] == 'BOOLEAN') {
            objAccount[field] = !objAccount[field];
        } else{
            let value = event.getSource().get('v.value');
            objAccount[field] = value;
        }
        component.set('v.objAccount', objAccount);
    },
    
    handleLookup: function(component, event, helper){
        var strAccountId = event.getParam('value')[0];
        if(helper.isNullCheck(strAccountId)){
            component.set('v.objAccount',{ 'sobjectType': 'Account'});
        }
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
                component.set('v.objAccount',{ 'sobjectType': 'Account'});
                component.set('v.blnAllowAccountCreation',false);
                component.set('v.blnAllowAccountSelection',true);                
            }
        },
        
    })