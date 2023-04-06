({
    generateFieldsToRender : function(component, event, helper) {    
        let objOpportunity = component.get("v.objOpportunity");
        if (helper.isNullCheck(objOpportunity.StageName)) {
            this.setFieldsToRenderOnStageChange(component, "", helper);
        }else{
            this.setFieldsToRenderOnStageChange(component, objOpportunity.StageName, helper); 
        }
    },
    isNullCheck:function(variable) {
        if (variable == "" || variable == null || variable == undefined) {
            return true;
        }else{
            return false;
        }
    },
    setFieldsToRenderOnStageChange:function(component, strstageName, helper){
        let list_FieldsToRender = [];
        let listMasterFieldset = component.get("v.list_OpportunityFormFieldsToRender");
        let map_FieldSetToFieldsMap = component.get("v.map_FieldSetToFieldsMap");
        let map_StageToFieldSetMap = component.get("v.map_StageToFieldSetMap");
        let objOpportunity = component.get("v.objOpportunity");
        let map_FieldTypes={};
        if (this.isNullCheck(strstageName)) {
            strstageName = "--None--";
        }
        let list_fieldsToDisable = helper.isNullCheck(map_StageToFieldSetMap[strstageName])
                                ? []
                                : helper.isNullCheck(map_FieldSetToFieldsMap[map_StageToFieldSetMap[strstageName]])
                                ? []
                                : map_FieldSetToFieldsMap[map_StageToFieldSetMap[strstageName]];


        listMasterFieldset.forEach(function(objField) {
            let objFieldToRender = {};
            objFieldToRender.name = objField.name;
            let blnisDisabled = true;
            if(component.get('v.blnIsOpportunityCreationSelected')){
                blnisDisabled = list_fieldsToDisable.some(function(objdisabledfield){
                    return objField.name == objdisabledfield.name;
                })
                objFieldToRender.required =  blnisDisabled
                                            ? false 
                                            : objField.required;
                objFieldToRender.disabled =  blnisDisabled;
            } else {
                objFieldToRender.required =  false
                objFieldToRender.disabled =  true;
            }
            
            map_FieldTypes[objField.name]=objField.type;
            if (!helper.isNullCheck(objOpportunity[objFieldToRender.name]) && !blnisDisabled) {
                objFieldToRender.value = objOpportunity[objFieldToRender.name];
            }else{
                if (objField.type=='BOOLEAN') {
                    objFieldToRender.value = false;
                    objOpportunity[objFieldToRender.name] = false;                    
                } else {
                    objFieldToRender.value = "";
                    objOpportunity[objFieldToRender.name] = "";                    
                }                  
            }
            list_FieldsToRender.push(objFieldToRender);            
        })
        component.set("v.objOpportunity", objOpportunity);
        component.set("v.list_FieldsToRender", list_FieldsToRender);

    },
    existingOpportunityHelper : function(component, event, helper) {
        var action = component.get('c.getOpportunity');
        console.log(JSON.stringify(component.get('v.strSelectedOpportunityId')));
        action.setParams({'strOpportunityId':component.get('v.strSelectedOpportunityId')});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){                
                let objOpportunity = response.getReturnValue();
                let objLead = component.get('v.objLead');
                console.log(JSON.stringify(objOpportunity));
                objOpportunity.Lead_Converted_From__c = objLead.Id;
                component.set('v.objOpportunity', objOpportunity);
                helper.validateIsAccountRelatedtoOpportunity(component,event,helper);
            } else {
                helper.showMessage("Error!",$A.get("$Label.c.CLDRL00020") ,"error","dismissible");
            }          
        })
         $A.enqueueAction(action);
    },
    showMessage : function(strtitle,strmessage,strtype,strmode){
        var objtoastEvent = $A.get("e.force:showToast");
        objtoastEvent.setParams({
            "title": strtitle,
            "message": strmessage,
            "type":strtype,
            "mode":strmode
        });
        objtoastEvent.fire();
    },
    generateOpportunity : function(component, event, helper){
        let objLead = component.get('v.objLead');
        let objOpportunity={};
        objOpportunity.Name=objLead.Name;
        objOpportunity.Lead_Converted_From__c=objLead.Id;
        objOpportunity.RecordTypeId=component.get("v.strDefaultRecordTypeId");
        component.set("v.objOpportunity",objOpportunity);
    },
    validateIsAccountRelatedtoOpportunity : function (component,event,helper){
        let strSelectedAccountId = component.get('v.strSelectedAccountId');
        let objOpportunity = component.get('v.objOpportunity');        
        if(
            !helper.isNullCheck(strSelectedAccountId) && 
            !helper.isNullCheck(objOpportunity.AccountId) &&
            strSelectedAccountId != objOpportunity.AccountId
            ){
            component.set('v.blnIsInvalidOpportunity',true);
            helper.showMessage("Error!",$A.get("$Label.c.CLDRL00019") ,"error","dismissible");
        } else {
            component.set('v.blnIsInvalidOpportunity',false);
        }
    }
})