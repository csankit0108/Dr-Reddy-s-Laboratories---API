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
            let blnisDisabled = list_fieldsToDisable.some(function(objdisabledfield){
                return objField.name == objdisabledfield.name;
            })
            objFieldToRender.required = blnisDisabled
                                        ? false 
                                        : objField.required;
            objFieldToRender.disabled = blnisDisabled;
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

    }
})