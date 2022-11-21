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
                helper.showMessage('Error!',$A.get('$Label.c.DRL_convertLeadSuccessOpportunityColumnsLoadError'),'error','dismissable');
            }
        });
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
    }
})