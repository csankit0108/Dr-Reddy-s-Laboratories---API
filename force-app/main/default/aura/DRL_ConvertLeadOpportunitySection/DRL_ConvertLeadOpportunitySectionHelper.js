({
    generateFieldsToRender : function(component,event,helper) {    
        let objopportunity=component.get('v.objopportunity');
        if(helper.isNullCheck(objopportunity.StageName)){
            this.setFieldsToRenderOnStageChange(component,'',helper);
        }
        else{
            this.setFieldsToRenderOnStageChange(component,objopportunity.StageName,helper); 
        }
    },
    isNullCheck:function(variable){
        if(variable==''||variable==null||variable==undefined){
            return true;
        }
        else{
            return false;
        }
    },
    setFieldsToRenderOnStageChange:function(component,strstageName,helper){
        let list_fieldsToRender=[];
        let listMasterFieldset=component.get('v.list_opportunityFormFieldsToRender');
        let map_fieldSetTofieldsMap=component.get('v.map_fieldSetTofieldsMap');
        let map_stageToFieldSetMap=component.get('v.map_stageToFieldSetMap');
        let objopportunity=component.get('v.objopportunity');
        if(this.isNullCheck(strstageName)){
            strstageName='--None--';
        }
        let list_fieldsToDisable=helper.isNullCheck(map_stageToFieldSetMap[strstageName])
                                ?[]
                                :helper.isNullCheck(map_fieldSetTofieldsMap[map_stageToFieldSetMap[strstageName]])
                                ?[]
                                :map_fieldSetTofieldsMap[map_stageToFieldSetMap[strstageName]];


        listMasterFieldset.forEach(function(objField){
            let objFieldToRender={};
            objFieldToRender.name=objField.name;
            let blnisDisabled=list_fieldsToDisable.some(function(objdisabledfield){
                return objField.name==objdisabledfield.name;
            })
            objFieldToRender.required=blnisDisabled?false:objField.required;
            objFieldToRender.disabled=blnisDisabled;
            if(!helper.isNullCheck(objopportunity[objFieldToRender.name]) && !blnisDisabled){
                objFieldToRender.value=objopportunity[objFieldToRender.name];
            }
            else{
                objFieldToRender.value='';
                objopportunity[objFieldToRender.name]='';
            }

            list_fieldsToRender.push(objFieldToRender);            
        })
        component.set('v.objopportunity',objopportunity);
        component.set('v.list_fieldsToRender',list_fieldsToRender);

    }
})