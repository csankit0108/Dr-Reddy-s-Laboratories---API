({
   
    isNullCheck:function(variable){
        if(variable==''||variable==null||variable==undefined){
            return true;
        }
        else{
            return false;
        }
    },
    generateAccount:function(component, event, helper){
        let objlead=component.get('v.objlead');
        let objaccount ={}
        objaccount.Name=objlead.Company;
        component.set('v.obj_Account',objaccount);
    },
    getAccountFields : function(component,event,helper){
        let list_accFieldsToRender=[];
        let obj_Account = component.get('v.obj_Account');
        let list_AccountFields = component.get('v.list_AccountFields');
        list_AccountFields.forEach(function(field_account){
            let objAccountRec = {};
            objAccountRec.name= field_account.name;//gets the api name of the field
             if(!helper.isNullCheck(obj_Account[objAccountRec.name])){
                objAccountRec.value=obj_Account[objAccountRec.name];
            }
             else{
                objAccountRec.value='';
                obj_Account[objAccountRec.name]='';
            }
            list_accFieldsToRender.push(objAccountRec);
        })
        component.set('v.obj_Account',obj_Account);
        component.set('v.list_accFieldsToRender',list_accFieldsToRender);
        
    },
    existingAccountHelper: function (component, event, helper) {
        let str_accountId = component.get('v.str_accountId');
        var action = component.get('c.getAccount');

        action.setParams({'straccountId':str_accountId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                
                var result = response.getReturnValue();
                component.set('v.obj_Account',result);
            }
            
        })
         $A.enqueueAction(action);
     },
     configureIfParentAlreadyConverted: function (component, event, helper){
        if(component.get('v.blnisParentProspectConverted')){
            component.set('v.bln_allowInput2',false);
            component.set('v.bln_allowInput1',false);
            component.set('v.blnRadio2Available',false);
            component.set('v.blnRadio1Available',false);
            component.set('v.isRadio1Checked',false);
            component.set('v.isRadio2Checked',false);
        }
        else{
            helper.generateAccount(component, event, helper);
        }
     }

})