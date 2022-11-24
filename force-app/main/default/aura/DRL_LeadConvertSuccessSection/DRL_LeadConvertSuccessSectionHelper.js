({
    getColumns : function(component) {
        var action=component.get("c.getDataTableColumns");
        action.setParams({
            "strSObjectName":"Opportunity",
            "strFieldSetName":"DRL_convertLeadSuccessScreenList"
        });
        action.setCallback(this, function(response){
            let strState = response.getState();
            if (strState === "SUCCESS") {
                let list_Opportunities = component.get("v.list_Opportunities");
                let list_Columns = JSON.parse(response.getReturnValue());
                list_Columns.forEach(objColumn=>{
                    if (objColumn.type == "url") {
                        if (objColumn.typeAttributes.label.fieldName == "Name") { 
                            list_Opportunities.forEach(objOpportunity=>{
                                objOpportunity.OpportunityUrl = "/"+objOpportunity.Id;                               
                            });
                        }else{
                            let strFieldName = objColumn.fieldName.substring(0, objColumn.fieldName.length-3);
                            if (strFieldName.match("Id$")) {
                                strObjectName = strFieldName.substring(0,strFieldName.length-2);
                            } else {
                                strObjectName = strFieldName.substring(0,strFieldName.length-1)+"r";
                            }
                            list_Opportunities.forEach(objOpportunity=>{
                                objOpportunity[objColumn.fieldName] = "/"+objOpportunity[strFieldName];                               
                                objOpportunity[strFieldName+"Name"] = objOpportunity[strObjectName]["Name"];
                            });
                        }
                    }                    
                });
                component.set("v.list_Opportunities", list_Opportunities);
                component.set("v.list_OpportunityColumns", list_Columns);
            }else{
                helper.showMessage("Error!", $A.get("$Label.c.CLDRL00009"), "error", "dismissable");
            }
        });
        $A.enqueueAction(action);
    },
    setFieldsToRender:function(component, helper){
        let map_SuccessFieldsToShow = component.get("v.map_SuccessFieldsToShow");
        for (const strobjectName in map_SuccessFieldsToShow) {
                const map_fieldApiNametoLabel = map_SuccessFieldsToShow[strobjectName];
                let objRecord = {};

                if (strobjectName == "Account") {
                    objRecord = component.get("v.objAccount");
                }else if (strobjectName == "Contact") {
                    objRecord = component.get("v.objContact");
                }else if (strobjectName == "Opportunity") {
                    objRecord = component.get("v.objOpportunity");
                    if (helper.isNullCheck(objRecord)) {
                        continue;
                    }
                }

                let list_FieldsTorender = [];
                
                for (const strfieldApiName in map_fieldApiNametoLabel) {
                    let objFieldLabelAndValue = {};
                    if (!helper.isNullCheck(objRecord[strfieldApiName])) {
                        objFieldLabelAndValue.label = map_fieldApiNametoLabel[strfieldApiName];
                        objFieldLabelAndValue.value = objRecord[strfieldApiName];
                        list_FieldsTorender.push(objFieldLabelAndValue);   
                    }                                        
                }

                if (strobjectName=="Account") {
                    component.set("v.list_AccountFieldsToRender", list_FieldsTorender);
                }else if (strobjectName=="Contact") {
                    component.set("v.list_ContactFieldsToRender", list_FieldsTorender);
                }else if (strobjectName == "Opportunity") {
                    component.set("v.list_OpportunityFieldsToRender",list_FieldsTorender);
                }                
        }
    },
    isNullCheck :function(variable){
        if (variable=="" || variable==null || variable == undefined) {
            return true;
        }else{
            return false;
        }
    },
    showMessage : function(strTitle,strMessage,strType,strMode){
        var objToastEvent = $A.get("e.force:showToast");
        objToastEvent.setParams({
            "title": strTitle,
            "message": strMessage,
            "type":strType,
            "mode":strMode
        });
        objToastEvent.fire();
    }
})