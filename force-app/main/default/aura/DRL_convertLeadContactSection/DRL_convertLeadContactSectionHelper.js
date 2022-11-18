({
    renderFields: function(component,event,helper){
        this.getContactFields(component,event,helper);
    },
    
    isNullCheck:function(variable){
        if(variable==''||variable==null||variable==undefined){
            return true;
        }
        else{
            return false;
        }
    },
    
    getContactFields : function(component,event,helper){
        let list_conFieldsToRender=[];
        let obj_contact = component.get('v.obj_contact');
        let list_contactFieldSet = component.get('v.list_contactFieldSet');
        list_contactFieldSet.forEach(function(field_contact){
            let objectContactRecord = {};
            objectContactRecord.name= field_contact.name;//gets the api name of the field
            if(!helper.isNullCheck(obj_contact[objectContactRecord.name])){
                objectContactRecord.value=obj_contact[objectContactRecord.name];
            }
            else{
                objectContactRecord.value='';
                obj_contact[objectContactRecord.name]='';
            }
            list_conFieldsToRender.push(objectContactRecord);
        })
        component.set('v.obj_contact',obj_contact);
        component.set('v.list_conFieldsToRender',list_conFieldsToRender);
        
    },
    existingContactHelper : function (component, event, helper) {
        let str_contactId = component.get("v.str_contactId");
        var action = component.get('c.getContact');
        action.setParams({conId:str_contactId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.obj_contact',result);
            }
            if (state === 'ERROR'){
                console.log('@@@error '+ JSON.stringify(response.getError()));
            }
        })
         $A.enqueueAction(action);        
    },
     configureIfParentAlreadyConverted: function (component, event, helper){
        if(component.get('v.blnisParentProspectConverted')){
            component.set('v.allowInput2',false);
            component.set('v.allowInput1',false);
            component.set('v.blnRadio2Available',false);
            component.set('v.blnRadio1Available',false);
            component.set('v.isRadio1Checked',false);
            component.set('v.isRadio2Checked',false);
        }
     }
    
    
    
})