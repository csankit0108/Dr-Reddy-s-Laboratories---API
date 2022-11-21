({
    doInit: function (component, event, helper) {
        component.set('v.str_radioButtonValue', '1');
        helper.configureIfParentAlreadyConverted(component, event, helper);
        helper.getAccountFields(component, event, helper);        
    },
    
    
    handleValueChange: function (component, event, helper) {
        let value = event.getParam('value');
        let field = event.getSource().get("v.fieldName");
        let obj_Account = component.get('v.obj_Account');
        obj_Account[field] = value;
    },
    
    handleLookup: function(component, event, helper){
        var strAccountId = event.getParam('value')[0];
        component.set('v.str_accountId',strAccountId);
        helper.existingAccountHelper(component, event, helper);
        
    },
    
    handleRadioChange:function(component, event, helper){
    
        var radioBtn = event.getSource().get("v.value");
        component.set('v.str_radioButtonValue',radioBtn);
            if(radioBtn === '1'){
                helper.generateAccount(component, event, helper);
                helper.getAccountFields(component, event, helper);
                component.set('v.existingAccount','');
                component.set('v.bln_allowInput1',true);
                component.set('v.bln_allowInput2',false);
            }
            if(radioBtn === '2'){
                component.set('v.obj_Account',{ 'sobjectType': 'Account'});
                helper.getAccountFields(component, event, helper);
                component.set('v.bln_allowInput1',false);
                component.set('v.bln_allowInput2',true);                
            }
        },
        
    })