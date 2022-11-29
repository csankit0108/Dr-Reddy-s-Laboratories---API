({
    
    generateContact:function(component, event, helper){
        let objLead = component.get("v.objLead");
        let objContact = {};
        if (!helper.isNullCheck(objLead.LastName)) {
            objContact.LastName = objLead.LastName;
        }
        if (!helper.isNullCheck(objLead.FirstName)) {
            objContact.FirstName = objLead.FirstName;
        }
        if (!helper.isNullCheck(objLead.MobilePhone)) {
            objContact.MobilePhone = objLead.MobilePhone;
        }
        if (!helper.isNullCheck(objLead.Email)) {
            objContact.Email = objLead.Email;
        }
        component.set("v.objContact", objContact);
    },
    
    isNullCheck:function(variable){
        if (variable==""||variable==null||variable==undefined) {
            return true;
        }else{
            return false;
        }
    },
    
    getContactFields : function(component,event,helper){
        let list_ContactFieldsToRender=[];
        let objContact = component.get("v.objContact");
        let list_ContactFieldSet = component.get("v.list_ContactFieldSet");
        list_ContactFieldSet.forEach(function(field_contact){
            let objectContactRecord = {};
            objectContactRecord.name = field_contact.name;//gets the api name of the field
            objectContactRecord.required = field_contact.required;
            if(!helper.isNullCheck(objContact[objectContactRecord.name])){
                objectContactRecord.value = objContact[objectContactRecord.name];
            }
            else{
                objectContactRecord.value = "";
                objContact[objectContactRecord.name] = "";
            }
            list_ContactFieldsToRender.push(objectContactRecord);
        })
        component.set("v.objContact", objContact);
        component.set("v.list_ContactFieldsToRender", list_ContactFieldsToRender);
        
    },
    existingContactHelper : function (component, event, helper) {
        let strContactId = component.get("v.strContactId");
        var action = component.get("c.getContact");
        action.setParams({"strcontactId":strContactId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.objContact", result);
            }
        })
         $A.enqueueAction(action);        
    },
     configureIfParentAlreadyConverted: function (component, event, helper){
        if (component.get("v.blnIsParentProspectConverted")) {
            component.set("v.blnAllowContactSelection",false);
            component.set("v.blnAllowContactCreation",false);
            component.set("v.blnIsContactSelectionAvailable",false);
            component.set("v.blnIsContactCreationAvailable",false);
            component.set("v.blnIsContactCreationSelected",false);
            component.set("v.blnIsContactSelectionSelected",true);
        }else{
            helper.generateContact(component, event, helper);
        }
     }
    
})