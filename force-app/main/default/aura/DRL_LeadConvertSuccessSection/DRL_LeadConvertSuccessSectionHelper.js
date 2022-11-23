({
    getColumns : function(component) {
        var action=component.get('c.getDataTableColumns');
        action.setParams({
            'strSObjectName':'Opportunity',
            'strFieldSetName':'DRL_convertLeadSuccessScreenList'
        });
        action.setCallback(this,function(response){
            let strState=response.getState();
            if(strState==='SUCCESS'){
                let list_Opportunities=component.get('v.list_Opportunities');
                let list_Columns=JSON.parse(response.getReturnValue());
                list_Columns.forEach(objColumn=>{
                    if(objColumn.type=='url'){
                        if(objColumn.typeAttributes.label.fieldName=='Name'){
                            list_Opportunities.forEach(objopportunity=>{
                                objopportunity.OpportunityUrl='/'+objopportunity.Id;                               
                            });
                        }
                        else{
                            let strfieldName=objColumn.fieldName.substring(0, objColumn.fieldName.length-3);
                            if(strfieldName.match("Id$")){
                                strObjectName=strfieldName.substring(0,strfieldName.length-2);
                            }
                            else{
                                strObjectName=strfieldName.substring(0,strfieldName.length-1)+'r';
                            }
                            list_Opportunities.forEach(objopportunity=>{
                                objopportunity[objColumn.fieldName]='/'+objopportunity[strfieldName];                               
                                objopportunity[strfieldName+'Name']=objopportunity[strObjectName]['Name'];
                            });
                        }
                    }                    
                });
                component.set('v.list_Opportunities',list_Opportunities);
                component.set('v.list_opportunityColumns',list_Columns);
            }
            else{
                helper.showMessage('Error!',$A.get('$Label.c.CLDRL00009'),'error','dismissable');
            }
        });
        $A.enqueueAction(action);
    },
    setFieldsToRender:function(component,helper){
        let map_successFieldsToShow=component.get('v.map_successFieldsToShow');
        for (const strobjectName in map_successFieldsToShow) {
                const map_fieldApiNametoLabel = map_successFieldsToShow[strobjectName];
                let objRecord={};
                if(strobjectName=='Account'){
                    objRecord=component.get('v.objaccount');
                }
                else if(strobjectName=='Contact'){
                    objRecord=component.get('v.objcontact');
                }
                else if(strobjectName=='Opportunity'){
                    objRecord=component.get('v.objopportunity');
                    if(helper.isNullCheck(objRecord)){
                        continue;
                    }
                }
                let list_fieldsTorender=[];
                
                for (const strfieldApiName in map_fieldApiNametoLabel) {
                    let objfieldLabelandValue={};
                    if(!helper.isNullCheck(objRecord[strfieldApiName])){
                        objfieldLabelandValue.label=map_fieldApiNametoLabel[strfieldApiName];
                        objfieldLabelandValue.value=objRecord[strfieldApiName];
                        list_fieldsTorender.push(objfieldLabelandValue);   
                    }                                        
                }
                if(strobjectName=='Account'){
                    component.set('v.list_AccountFieldsToRender',list_fieldsTorender);
                }
                else if(strobjectName=='Contact'){
                    component.set('v.list_ContactFieldsToRender',list_fieldsTorender);
                }
                else if(strobjectName=='Opportunity'){
                    component.set('v.list_OpportunityFieldsToRender',list_fieldsTorender);
                }
                
        }

    },
    isNullCheck :function(variable){
        if(variable==''||variable==null||variable==undefined){
            return true;
        }
        else{
            return false;
        }
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
    }
})