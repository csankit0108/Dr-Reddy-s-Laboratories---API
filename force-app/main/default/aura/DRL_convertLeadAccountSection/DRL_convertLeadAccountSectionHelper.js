({
   
    isNullCheck:function(variable){
        if (variable == '' || variable == null || variable == undefined) {
            return true;
        }else{
            return false;
        }
    },
    generateAccount:function(component, event, helper){
        let objLead = component.get('v.objLead');
        let objAccount = {};
        objAccount.Name = objLead.Company;
        component.set('v.objAccount',objAccount);
    },
    getAccountFields : function(component, event, helper){
        let list_AccountFieldsToRender = [];
        let objAccount = component.get('v.objAccount');
        let list_AccountFields = component.get('v.list_AccountFields');
        let map_FieldTypes = {};
        list_AccountFields.forEach(function(objAccountField){
            let objAccountFieldWithValue = {};
            objAccountFieldWithValue.name = objAccountField.name;//gets the api name of the field
            objAccountFieldWithValue.required = objAccountField.required;
            map_FieldTypes[objAccountField.name] = objAccountField.type;
             if (!helper.isNullCheck(objAccount[objAccountFieldWithValue.name])) {
                objAccountFieldWithValue.value = objAccount[objAccountFieldWithValue.name];
            } else {
                if (objAccountField.type == 'BOOLEAN') {
                    objAccountFieldWithValue.value = false;
                    objAccount[objAccountFieldWithValue.name] = false;                    
                } else {
                    objAccountFieldWithValue.value = "";
                    objAccount[objAccountFieldWithValue.name] = "";                    
                }  
            }
            list_AccountFieldsToRender.push(objAccountFieldWithValue);
        })
        component.set('v.objAccount', objAccount);
        component.set('v.list_AccountFieldsToRender', list_AccountFieldsToRender);
        
    },
    existingAccountHelper: function (component, event, helper) {
        let strAccountId = component.get('v.strAccountId');
        var action = component.get('c.getAccount');
        action.setParams({'straccountId':strAccountId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){                
                var result = response.getReturnValue();
                component.set('v.objAccount', result);
            }            
        })
         $A.enqueueAction(action);
     },
     configureIfParentAlreadyConverted: function (component, event, helper){
        if (component.get('v.blnIsParentProspectConverted')) {
            component.set('v.blnAllowAccountSelection', false);
            component.set('v.blnAllowAccountCreation', false);
            component.set('v.blnIsAccountSelectionAvailable', false);
            component.set('v.blnIsAccountCreationAvailable', false);
            component.set('v.blnIsAccountCreationSelected', false);
            component.set('v.blnIsAccountSelectionSelected', true);
        }else{
            helper.generateAccount(component, event, helper);
        }
     }

})