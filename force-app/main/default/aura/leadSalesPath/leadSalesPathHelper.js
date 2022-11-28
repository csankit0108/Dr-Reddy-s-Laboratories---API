({
    
    
    updateLeadStatus : function(component,event,leadStatus) {
        component.set("v.spin",true);
        var product=component.get("v.product");
        
        console.log('====1a====');
        
        if(((leadStatus=='Contacted'||leadStatus=='Converted')&&product!=undefined&&product!=null&&product!='')||(leadStatus!='Contacted'&&leadStatus!='Converted'))
        {
            
            console.log('====2a====');
            var action = component.get("c.updateLead");
            action.setParams({
                status: leadStatus,
                recordId:component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var status = response.getState();
                if(status=='SUCCESS')
                {
                    console.log('====3a====');
                    component.set("v.spin",false);
                    $A.get('e.force:refreshView').fire();
                    
                }
                else
                {
                    component.set("v.spin",false);
                    var toastEvent = $A.get("e.force:showToast");
                    
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error !",
                        "message": "Status is not updated. Error Occurred"
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
                
            })
            $A.enqueueAction(action);
        }
        else
        {
            component.set("v.spin",false);
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
})