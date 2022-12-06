({
    getLeadStatus:function(component,event,helper){
        component.set('v.blnIsComponentRendered',false);
        var action = component.get("c.getStatus");
        action.setParams({recordId : component.get("v.recordId"),objectType:component.get("v.objectType"),selectedField:component.get("v.selectedField")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set("v.picklistValues", response.getReturnValue().statusList);
                component.set("v.initialStep",response.getReturnValue().ld.Status);
                component.set("v.currentStep",response.getReturnValue().ld.Status);
                component.set("v.getStep",response.getReturnValue().ld.Status);
                component.set("v.product",response.getReturnValue().ld.Product_Lookup__c );
                component.set('v.objLead',response.getReturnValue().ld);                
                component.set("v.openPopup","Close");
                if(response.getReturnValue().ld.IsConverted==true){
                    component.set("v.disableMark",true);
                }                    
                console.log(response.getReturnValue().ld.IsConverted);
                console.log(response.getReturnValue());
                component.set("v.spin",false);
            }
            component.set('v.blnIsComponentRendered',true);
        });
        $A.enqueueAction(action);
    },
    getPathStatus:function(component,event,helper){
        let objLead=component.get("v.objLead");
        if(objLead.IsConverted){
            return;
        }
        var getStatus= event.getParam("detail").value;
        var initialStatus=component.get("v.initialStep");
        component.set("v.getStep",getStatus);        
        var statusList=[];
        statusList=component.get("v.picklistValues");
        
        if(component.get("v.disableMark")==true && (component.get("v.getStep")==statusList[statusList.length-1]&&component.get("v.currentStep")==statusList[statusList.length-1]))
        {
            component.set("v.disableMark",true);
        }
        else if(component.get("v.getStep")!=statusList[statusList.length-1]&&component.get("v.currentStep")==statusList[statusList.length-1])
        {
            component.set("v.disableMark",false);
            if(getStatus==initialStatus)
                component.set("v.markStatus","Mark Status as Complete");
            else
                component.set("v.markStatus","Mark as Current Status");
        }
            else if(component.get("v.getStep")!=statusList[statusList.length-1]&&component.get("v.currentStep")==statusList[statusList.length-1])
            {
                component.set("v.disableMark",false);
                if(getStatus==initialStatus)
                    component.set("v.markStatus","Mark Status as Complete");
                else
                    component.set("v.markStatus","Mark as Current Status");
            }
                else
                {
                    component.set("v.disableMark",false);
                    if(getStatus==initialStatus)
                        component.set("v.markStatus","Mark Status as Complete");
                    else
                        component.set("v.markStatus","Mark as Current Status");
                }
        
    },
    updatePathStatus:function(component,event,helper){
        
        var stopLoop=false;
        
        var statusList=[];
        statusList=component.get("v.picklistValues");
        var action = component.get("c.getStatus");
        action.setParams({recordId : component.get("v.recordId"),objectType:component.get("v.objectType"),selectedField:component.get("v.selectedField")});
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status=='SUCCESS')
            {
                var product=response.getReturnValue().ld.Product_Lookup__c;
                component.set("v.product",response.getReturnValue().ld.Product_Lookup__c );
                var run=response.getReturnValue().ld.Run_Automation__c;
                var prospect=response.getReturnValue().ld.Prospect_Customer__c;
                var reasonForOnhold = response.getReturnValue().ld.Reason_for_On_Hold_Postponed__c;
                var declinedReason = response.getReturnValue().ld.Reason_for_Decline__c;
                var convertReason = response.getReturnValue().ld.Reason_for_Convert__c;
                //alert(product);
                console.log('===c1a===');
                
                if(component.get("v.getStep")=='Converted')
                {
                   
                    // if((product!=undefined&&product!=null&&product!='') )
                    // {
                       /* if((convertReason==null || convertReason==undefined || convertReason=='')){
                            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "title": "Error !",
                            "message": "Please update Reason for Convert"
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                        } */
                        //else{
                            var openwindow=component.get("v.openPopup");
                        	component.set("v.openPopup","Open");
                       // }  
                    
                    
                    var loop=false;
                    
                    if(openwindow=='false')
                    {
                        component.set("v.openPopup","Open");
                        loop=true;
                    }
                    if(loop==false&&openwindow=='Close')
                        component.set("v.openPopup","Open");
                    if(loop==false&&openwindow=='Open')
                        component.set("v.openPopup","Close");    
                    // } 
                    // else
                    // {
                    //     var toastEvent = $A.get("e.force:showToast");
                    //     toastEvent.setParams({
                    //         "type": "error",
                    //         "title": "Error !",
                    //         "message": "Please update the Product field and update the Status"
                    //     });
                    //     toastEvent.fire();
                    //     $A.get('e.force:refreshView').fire();
                    // }
                }
                else
                {
                    console.log('===c2a===');
                    var leadStatus=component.get("v.getStep");
                    //alert(leadStatus);
                    component.set("v.openConvertLeadWindow",false);
                     if((leadStatus=='On Hold/Postponed') &&(reasonForOnhold==null || reasonForOnhold=='' || reasonForOnhold==undefined) ){
                           //alert('Hi');
                            
                            var toastEvent = $A.get("e.force:showToast");
                            
                            toastEvent.setParams({
                                "type": "error",
                                "title": "Error !",
                                "message": "Please update the reaon for On Hold/Postponed"
                            });
                            toastEvent.fire();
                           //window.location.reload();
                           $A.get('e.force:refreshView').fire();
                        }
                    else if((leadStatus=='Declined') &&(declinedReason==null || declinedReason=='' || declinedReason==undefined) ){
                           //alert('Hi');
                            
                            var toastEvent = $A.get("e.force:showToast");
                            
                            toastEvent.setParams({
                                "type": "error",
                                "title": "Error !",
                                "message": "Please update the Reason for Decline"
                            });
                            toastEvent.fire();
                            //$A.get('e.force:refreshView').fire();
                           // window.location.reload();
                           $A.get('e.force:refreshView').fire();
                        }
                    else if(((leadStatus=='Contacted'||leadStatus=='Converted')&&product!=undefined&&product!=null&&product!='')||((leadStatus=='Qualified')&&run!=undefined&&run!=null&&run!=''&&prospect!=undefined&&prospect!=null&&prospect!='')||(leadStatus!='Contacted'&&leadStatus!='Converted'&&leadStatus!='Qualified'))
                    {
                        //alert('Hi');
                        
                        
                            if(component.get("v.markStatus")=='Mark as Current Status')
                        {
                            component.set("v.currentStep",component.get("v.getStep"));
                            component.set("v.initialStep",component.get("v.currentStep"));
                            component.set("v.markStatus","Mark Status as Complete");
                            
                            helper.updateLeadStatus(component,event,component.get("v.currentStep"));
                            
                            if(component.get("v.currentStep")==statusList[statusList.length-1] || component.get("v.initialStep")==statusList[statusList.length-1])
                            {
                                component.set("v.disableMark",true);
                            }
                            else
                            {
                                component.set("v.disableMark",false);
                            }
                            
                            stopLoop=true;
                        }
                        if(component.get("v.markStatus")=='Mark Status as Complete' && stopLoop==false)
                        {
                            //alert(1);
                            
                            var next_status=0;
                            for(var i=0;i<statusList.length;i++)
                            {
                                if(statusList[i]==component.get("v.getStep") || statusList[i]==component.get("v.initialStep"))
                                {
                                    if(i!=(statusList.length-1))
                                    {
                                        next_status=i+1;
                                        break;
                                    }
                                    if(statusList[statusList.length-1]==component.get("v.getStep") || statusList[statusList.length-1]==component.get("v.initialStep"))
                                    {
                                        next_status=statusList.length-1;
                                    }    
                                }
                            }
                            
                            
                            //alert(next_status);
                            
                            component.set("v.currentStep",statusList[next_status]);
                            component.set("v.initialStep",component.get("v.currentStep"));
                            
                            
                            helper.updateLeadStatus(component,event,component.get("v.currentStep"));
                            
                            if(component.get("v.currentStep")==statusList[statusList.length-1])
                            {
                                component.set("v.disableMark",true);
                                //component.set("v.finalStep",true);
                            }
                            else
                            {
                                component.set("v.disableMark",false);
                                //component.set("v.finalStep",false);
                            }
                            //alert(statusList[next_status]);   
                        }
                        
                        
                    }
                    else if(((leadStatus=='Contacted'||leadStatus=='Qualified')&&(run==undefined||run==null||run==''||prospect==undefined||prospect==null||prospect=='')))
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        
                        toastEvent.setParams({
                            "type": "error",
                            "title": "Error !",
                            "message": 'Please fill "Run Automation" and "Prospect/Customer" fields and save.'
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                        
                    }
                    else if(((leadStatus=='Contacted'||leadStatus=='Converted')&&(product==undefined||product==null||product=='')))
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        
                        toastEvent.setParams({
                            "type": "error",
                            "title": "Error !",
                            "message": "Please update the Product field and update the Status"
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                    }
                           
                }
                
            }
        })
        $A.enqueueAction(action);
        
    },
    handleSelect : function (component, event, helper) {
        var stepName = event.getParam("detail").value;
        var product=component.get("v.product");
        console.log(stepName);
        console.log(component.get("v.recordId"));
        if(((stepName=='Contacted'||stepName=='Converted')&&product!=undefined&&product!=null&&product!='')||(stepName!='Contacted'&&stepName!='Converted'))
        {
            
            
            var action = component.get("c.updateStatus");
            action.setParams({status:stepName , recordId : component.get("v.recordId")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    if (state === 'SUCCESS'){
                        toastEvent.setParams({
                            "type": "success",
                            "title": "Success!",
                            "message": " Status is Update Succesfully !."
                        });
                    }
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    
                }
            });
            $A.enqueueAction(action);
        }
        else
        {
            var toastEvent = $A.get("e.force:showToast");
            
            toastEvent.setParams({
                "type": "error",
                "title": "Error !",
                "message": "Please update the Product field and update the Status"
            });
            toastEvent.fire();
            $A.get('e.force:refreshView').fire();
        }
    },
    
    handleSelect1 : function (component, event, helper) {
        //get selected Status value
        var selectStatus = event.getParam("detail").value;
        //set selected Status value
        component.set("v.picklistField.Status", selectStatus);
        
        component.find("record").saveRecord($A.getCallback(function(response) {
            if (response.state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                component.find('notifLib').showToast({
                    "variant": "success",
                    "message": "Record was updated sucessfully",
                    "mode" : "sticky"
                });
            } else {
                component.find('notifLib').showToast({
                    "variant": "error",
                    "message": "There was a problem updating the record.",
                    "mode" : "sticky"
                });
            }
        }));
    }
})