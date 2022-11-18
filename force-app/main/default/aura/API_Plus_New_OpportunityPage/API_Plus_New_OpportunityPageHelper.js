({
    
    validateTriggerSheetList: function(component,event)
    {
        // validate all trigger sheet records
        var isValid=true;
        var message;
        var triggerSheetList=component.get("v.tSheetDetails");
        console.log('t sheet details from comp---->'+triggerSheetList)
        // checking API Plus Opportunity Mandatory fields
        var opty=component.get("v.apiPlusOpty");
        console.log('API Plus Opportunity-------->'+opty);
        if(opty.AccountId=='')
        {
            isValid=false;                
            //alert('Account Name can not be blank');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            	"title":"Error!",
                "message":'Account Name can not be blank',
                "type":"error"
            });
            toastEvent.fire();
        }
        if(opty.Customer_Type__c=='')
        {
            isValid=false;                
            //alert('Customer Type can not be blank');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            	"title":"Error!",
                "message":'Customer Type can not be blank',
                "type":"error"
            });
            toastEvent.fire();
        }
        if(opty.Contact__c=='')
        {
            isValid=false;                
            //alert('Contact can not be blank');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            	"title":"Error!",
                "message":'Contact can not be blank',
                "type":"error"
            });
            toastEvent.fire();
        }
        if(opty.API_Plus_Territory__c=='')
        {
            isValid=false;                
            //alert('Territory can not be blank');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            	"title":"Error!",
                "message":'Territory can not be blank',
                "type":"error"
            });
            toastEvent.fire();
        }
        if(opty.Remarks__c=='')
        {
            isValid=false;                
            //alert('Remarks can not be blank');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            	"title":"Error!",
                "message":'Remarks can not be blank',
                "type":"error"
            });
            toastEvent.fire();
        }
        if(opty.Name=='')
        {
            isValid=false;                
            //alert('Opportunity Name can not be blank');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            	"title":"Error!",
                "message":'Opportunity Name can not be blank',
                "type":"error"
            });
            toastEvent.fire();
        }
        if(opty.CloseDate=='')
        {
            isValid=false;                
            //alert('Close Date can not be blank');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            	"title":"Error!",
                "message":'Close Date can not be blank',
                "type":"error"
            });
            toastEvent.fire();
        }
        if(opty.CurrencyIsoCode=='')
        {
            isValid=false;                
            //alert('Opportunity Currency can not be blank');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            	"title":"Error!",
                "message":'Opportunity Currency can not be blank',
                "type":"error"
            });
            toastEvent.fire();
        }
        // checking API plus Opportunity Mandatory fields
        
        for(var i=0;i<triggerSheetList.length;i++)
        {
            console.log('Product Details--->'+triggerSheetList[i].tSheet.API_Plus_Product__c);
            if(triggerSheetList[i].tSheet.API_Plus_Product__c == '' || triggerSheetList[i].tSheet.API_Plus_Product__c==undefined)
            {                        
                isValid=false;
                
                //alert('Product Name can not be blank on row number'+(i+1));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Error!",
                    "message":'Product Name can not be blank on row number - '+(i+1),
                    "type":"error"
                });
                toastEvent.fire();
            }
            if(triggerSheetList[i].tSheet.API_Plus_Dosage_Form__c == '')
            {                        
                isValid=false;
                
                // alert('Dosage Form can not be blank on row number'+(i+1));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Error!",
                    "message":'Dosage Form can not be blank on row number - '+(i+1),
                    "type":"error"
                });
                toastEvent.fire();
            }
            if(triggerSheetList[i].tSheet.API_Plus_Strengths__c == '')
            {                        
                isValid=false;
                //alert('Strength can not be blank on row number'+(i+1));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Error!",
                    "message":'Strength can not be blank on row number - '+(i+1),
                    "type":"error"
                });
                toastEvent.fire();
            }
            if(triggerSheetList[i].tSheet.API_Plus_Deal_Model__c == '')
            {                        
                isValid=false;
                //alert('Type of Deal can not be blank on row number'+(i+1));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Error!",
                    "message":'Type of Deal can not be blank on row number - '+(i+1),
                    "type":"error"
                });
                toastEvent.fire();
            }
            if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast1__c == '')
            {                        
                isValid=false;
                //alert('Type of Deal can not be blank on row number'+(i+1));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Error!",
                    "message":'Volume Forecast cannot be blank on row - '+(i+1),
                    "type":"error"
                });
                toastEvent.fire();
            }
             if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast1__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast1__c == 0)
                {      
                    isValid=false;
                    //alert('Volume forecast 1');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title":"Error!",
                        "message":'Enter value greater than 0 in volume forecast - 1',
                        "type":"error"
                    });
                    toastEvent.fire();
                }
                if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast2__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast2__c == 0)
                {                        
                    isValid=false;
                    //alert('This is volume forecast2');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title":"Error!",
                        "message":'Enter value greater than 0 in volume forecast - 2',
                        "type":"error"
                    });
                    toastEvent.fire();
                }
                if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast3__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast3__c == 0)
                {                        
                    isValid=false;
                    //alert('Type of Deal can not be blank on row number'+(i+1));
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title":"Error!",
                        "message":'Enter value greater than 0 in volume forecast - 3',
                        "type":"error"
                    });
                    toastEvent.fire();
                } 
                if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast4__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast4__c == 0)
                {                        
                    isValid=false;
                    //alert('Type of Deal can not be blank on row number'+(i+1));
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title":"Error!",
                        "message":'Enter value greater than 0 in volume forecast - 4',
                        "type":"error"
                    });
                    toastEvent.fire();
                } 
                if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast5__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast5__c == 0)
                {                        
                    isValid=false;
                    //alert('Type of Deal can not be blank on row number'+(i+1));
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title":"Error!",
                        "message":'Enter value greater than 0 in volume forecast - 5',
                        "type":"error"
                    });
                    toastEvent.fire();
                } 
                if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast6__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast6__c == 0)
                {                        
                    isValid=false;
                    //alert('Type of Deal can not be blank on row number'+(i+1));
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title":"Error!",
                        "message":'Enter value greater than 0 in volume forecast - 6',
                        "type":"error"
                    });
                    toastEvent.fire();
                }
                if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast7__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast7__c == 0)
                {                        
                    isValid=false;
                    //alert('Type of Deal can not be blank on row number'+(i+1));
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title":"Error!",
                        "message":'Enter value greater than 0 in volume forecast - 7',
                        "type":"error"
                    });
                    toastEvent.fire();
                } 
                if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast8__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast8__c == 0)
                {                        
                    isValid=false;
                    //alert('Type of Deal can not be blank on row number'+(i+1));
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title":"Error!",
                        "message":'Enter value greater than 0 in volume forecast - 8',
                        "type":"error"
                    });
                    toastEvent.fire();
                } 
                if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast9__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast9__c == 0)
                {                        
                    isValid=false;
                    //alert('Type of Deal can not be blank on row number'+(i+1));
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title":"Error!",
                        "message":'Enter value greater than 0 in volume forecast - 9',
                        "type":"error"
                    });
                    toastEvent.fire();
                }
                if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast10__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast10__c == 0)
                {                        
                    isValid=false;
                    //alert('Type of Deal can not be blank on row number'+(i+1));
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title":"Error!",
                        "message":'Enter value greater than 0 in volume forecast - 10',
                        "type":"error"
                    });
                    toastEvent.fire();
                } 
            // Negative values checking
            if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast1__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast1__c < 0)
            {           
                isValid=false;
                console.log('Do not enter negative value in Year 1');                        
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Error!",
                    "message":'Do not enter negative value in Year - 1',
                    "type":"error"
                });
                toastEvent.fire();
            }
            if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast2__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast2__c < 0)
            {           
                isValid=false;
                console.log('Do not enter negative value in Year 2');                        
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Error!",
                    "message":'Do not enter negative value in Year - 2',
                    "type":"error"
                });
                toastEvent.fire();
            }
            if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast3__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast3__c < 0)
            {           
                isValid=false;
                console.log('Do not enter negative value in Year 3');                        
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Error!",
                    "message":'Do not enter negative value in Year - 3',
                    "type":"error"
                });
                toastEvent.fire();
            }
            if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast4__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast4__c < 0)
            {           
                isValid=false;
                console.log('Do not enter negative value in Year 4');                        
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Error!",
                    "message":'Do not enter negative value in Year - 4',
                    "type":"error"
                });
                toastEvent.fire();
            }
            if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast5__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast5__c < 0)
            {           
                isValid=false;
                console.log('Do not enter negative value in Year 5');                        
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Error!",
                    "message":'Do not enter negative value in Year - 5',
                    "type":"error"
                });
                toastEvent.fire();
            }
            if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast6__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast6__c < 0)
            {           
                isValid=false;
                console.log('Do not enter negative value in Year 6');                        
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Error!",
                    "message":'Do not enter negative value in Year - 6',
                    "type":"error"
                });
                toastEvent.fire();
            }
            if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast7__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast7__c < 0)
            {           
                isValid=false;
                console.log('Do not enter negative value in Year 7');                        
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Error!",
                    "message":'Do not enter negative value in Year - 7',
                    "type":"error"
                });
                toastEvent.fire();
            }
            if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast8__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast8__c < 0)
            {           
                isValid=false;
                console.log('Do not enter negative value in Year 8');                        
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Error!",
                    "message":'Do not enter negative value in Year - 8',
                    "type":"error"
                });
                toastEvent.fire();
            }
            if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast9__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast9__c < 0)
            {           
                isValid=false;
                console.log('Do not enter negative value in Year 9');                        
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Error!",
                    "message":'Do not enter negative value in Year - 9',
                    "type":"error"
                });
                toastEvent.fire();
            }
            if(triggerSheetList[i].commercial.API_Plus_Volume_Forecast10__c != '' && triggerSheetList[i].commercial.API_Plus_Volume_Forecast10__c < 0)
            {           
                isValid=false;
                console.log('Do not enter negative value in Year 10');                        
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Error!",
                    "message":'Do not enter negative value in Year - 10',
                    "type":"error"
                });
                toastEvent.fire();
            }
            // Negative values checking
        }
        //}
        
        return isValid;
    },
    saveTriggerSheetList:function(component,event,isSave,isrRemoveYear)
    {
        // Call Apex class and pass trigger sheet list parameters
        console.log('tSheetDetails------->'+component.get("v.tSheetDetails"));
        console.log('Opty ID------->'+component.get("v.optyId"));
        console.log('Tsheet Details------>'+JSON.stringify(component.get("v.tSheetDetails")));
        //console.log('Tsheet-1 Details----->'+component.get("v.tSheetDetails1"));
        console.log('T Sheet Account Id--->'+component.get("v.Account").Id);
        
        var getYearList=component.get("v.yearList");
        var tsheetDetails=component.get("v.tSheetDetails");
        
        if(tsheetDetails!=undefined&&tsheetDetails!=null&&tsheetDetails!='')
        {
            for(var i=0;i<tsheetDetails.length;i++)
            {
                if(getYearList!=undefined&&getYearList!=null&&getYearList!='')
                {
                    
                    if(getYearList.length<9) tsheetDetails[i].commercial.API_Plus_Volume_Forecast10__c=null;
                    if(getYearList.length<8) tsheetDetails[i].commercial.API_Plus_Volume_Forecast9__c=null;
                    if(getYearList.length<7) tsheetDetails[i].commercial.API_Plus_Volume_Forecast8__c=null;
                    if(getYearList.length<6) tsheetDetails[i].commercial.API_Plus_Volume_Forecast7__c=null;
                    if(getYearList.length<5) tsheetDetails[i].commercial.API_Plus_Volume_Forecast6__c=null;
                    if(getYearList.length<4) tsheetDetails[i].commercial.API_Plus_Volume_Forecast5__c=null;
                    if(getYearList.length<3) tsheetDetails[i].commercial.API_Plus_Volume_Forecast4__c=null;
                    if(getYearList.length<2) tsheetDetails[i].commercial.API_Plus_Volume_Forecast3__c=null;
                    if(getYearList.length<1) tsheetDetails[i].commercial.API_Plus_Volume_Forecast2__c=null;
                }
                else
                {
                    tsheetDetails[i].commercial.API_Plus_Volume_Forecast2__c=null;
                    tsheetDetails[i].commercial.API_Plus_Volume_Forecast3__c=null;
                    tsheetDetails[i].commercial.API_Plus_Volume_Forecast4__c=null;
                    tsheetDetails[i].commercial.API_Plus_Volume_Forecast5__c=null;
                    tsheetDetails[i].commercial.API_Plus_Volume_Forecast6__c=null;
                    tsheetDetails[i].commercial.API_Plus_Volume_Forecast7__c=null;
                    tsheetDetails[i].commercial.API_Plus_Volume_Forecast8__c=null;
                    tsheetDetails[i].commercial.API_Plus_Volume_Forecast9__c=null;
                    tsheetDetails[i].commercial.API_Plus_Volume_Forecast10__c=null;
                }
            }
        }
        
        
        var action=component.get("c.insertTSheetCommercial");
        action.setParams({
            "tSheetComm": component.get("v.tSheetDetails"),
            "optyId": component.get("v.recordId"),
            "accId":component.get("v.Account").Id
            
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            console.log('response---->'+response);
            if(state==='SUCCESS')
            {
                //component.set("v.triggerSheetList",[]);
                //alert('Trigger Sheet Records inserted successfully----->');
                //window.location.href = 'https://drreddys--apidigital.lightning.force.com/'+v.recordId;
                if(isrRemoveYear)
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title":"Success!",
                        "message":'Removed year successfully',
                        "type":"success"
                    });
                    toastEvent.fire();
                }
                if(isSave)
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title":"Success!",
                        "message":'Inserted records successfully',
                        "type":"success"
                    });
                    toastEvent.fire();
                }
                
                
                // Do Init logic adding
                var action=component.get("c.optyData");
                action.setParams({"optyId":component.get("v.recordId")});
                action.setCallback(this,function(response){
                    var state=response.getState();
                    console.log(state);
                    if(state==='SUCCESS')
                    {
                        var tSCommDetails=response.getReturnValue();
                        console.log('Existing Trigger Sheet and Commercial details---->'+JSON.stringify(tSCommDetails));
                        console.log('Account ID---->'+tSCommDetails.op.acc);
                        console.log('Opportunity Name---->'+tSCommDetails.op.optyName);
                        console.log('Trigger Sheet and Commercial details--->'+tSCommDetails.tSheetComm);
                        component.set("v.Account",tSCommDetails.op.acc);
                        component.set("v.optyName",tSCommDetails.op.optyName);
                        
                        component.set("v.dilgStarted",tSCommDetails.op.dilgStarted); 
                        
                        if(tSCommDetails.tSheetComm!=undefined&&tSCommDetails.tSheetComm!=null&&tSCommDetails.tSheetComm!='')
                        {
                            console.log('have trigger sheet and commercial details--->');
                            component.set("v.tSheetDetails",tSCommDetails.tSheetComm);  
                            //component.set("v.exiTSheetReadOnly",1);
                            console.log("Commercial details--->"+tSCommDetails.tSheetComm);
                            var disYearList=[]
                            for(var i=0;i<tSCommDetails.tSheetComm.length;i++)
                            {
                                var record=tSCommDetails.tSheetComm[i].commercial;
                                if(record.API_Plus_Volume_Forecast10__c!=undefined&&record.API_Plus_Volume_Forecast10__c!=null&&record.API_Plus_Volume_Forecast10__c!=''){disYearList.push(10);}
                                if(record.API_Plus_Volume_Forecast9__c!=undefined&&record.API_Plus_Volume_Forecast9__c!=null&&record.API_Plus_Volume_Forecast9__c!=''){disYearList.push(9);}
                                if(record.API_Plus_Volume_Forecast8__c!=undefined&&record.API_Plus_Volume_Forecast8__c!=null&&record.API_Plus_Volume_Forecast8__c!=''){disYearList.push(8);}
                                if(record.API_Plus_Volume_Forecast7__c!=undefined&&record.API_Plus_Volume_Forecast7__c!=null&&record.API_Plus_Volume_Forecast7__c!=''){disYearList.push(7);}
                                if(record.API_Plus_Volume_Forecast6__c!=undefined&&record.API_Plus_Volume_Forecast6__c!=null&&record.API_Plus_Volume_Forecast6__c!=''){disYearList.push(6);}
                                if(record.API_Plus_Volume_Forecast5__c!=undefined&&record.API_Plus_Volume_Forecast5__c!=null&&record.API_Plus_Volume_Forecast5__c!=''){disYearList.push(5);}
                                if(record.API_Plus_Volume_Forecast4__c!=undefined&&record.API_Plus_Volume_Forecast4__c!=null&&record.API_Plus_Volume_Forecast4__c!=''){disYearList.push(4);}
                                if(record.API_Plus_Volume_Forecast3__c!=undefined&&record.API_Plus_Volume_Forecast3__c!=null&&record.API_Plus_Volume_Forecast3__c!=''){disYearList.push(3);}
                                if(record.API_Plus_Volume_Forecast2__c!=undefined&&record.API_Plus_Volume_Forecast2__c!=null&&record.API_Plus_Volume_Forecast2__c!=''){disYearList.push(2);}
                            }
                            disYearList.sort(function(a, b) {
                                return a - b;
                            });
                            
                            
                            var disYearListLength=disYearList!=undefined?disYearList[disYearList.length-1]-3:0
                            console.log('Dis Year list---->'+disYearList);
                            console.log('dis Year List Length---->'+disYearListLength);
                            var getList=[]
                            for(var i=0;i<disYearListLength;i++)
                            {
                                getList.push(i);
                            }
                            console.log('get list value in do int--->'+getList);
                            component.set("v.yearList",getList);
                        }   
                        else
                        {
                            console.log('Do not have trigger sheet details--->');
                            var wrapList=[];
                            var newTSheet={"tSheet":{"API_Plus_Product_Name__c":"","API_Plus_Dosage_Form__c":"","API_Plus_Strengths__c":"","API_Plus_Deal_Model__c":""},"commercial":{"API_Plus_Volume_Forecast1__c":"","API_Plus_Volume_Forecast2__c":"","API_Plus_Volume_Forecast3__c":"","API_Plus_Volume_Forecast4__c":"","API_Plus_Volume_Forecast5__c":"","API_Plus_Volume_Forecast6__c":"","API_Plus_Volume_Forecast7__c":"","API_Plus_Volume_Forecast8__c":"","API_Plus_Volume_Forecast9__c":"","API_Plus_Volume_Forecast10__c":""},"index":0};       
                            console.log('new TSheet Details----->'+newTSheet);
                            wrapList.push(newTSheet);
                            component.set("v.tSheetDetails",wrapList);
                        }
                    }
                    else{
                        console.log('Error Details--->'+response.getState());
                    }
                });
                
                $A.enqueueAction(action);
                // Do Init logic adding
            }
        });
        $A.enqueueAction(action);
    },
    contactValidation: function(component,event)
    {
        var contactId = component.get("v.contactId");
        if (contactId === '' || contactId === undefined )
        	{            
                var toastEvent = $A.get("e.force:showToast");
                var message = $A.get("$Label.c.CLDRL00002");
                toastEvent.setParams({
                    "title":"Error!",
                    "message":message,
                    "type":"error"
            });
            toastEvent.fire();  
        }
        else {
            event.preventDefault(); //Prevent default submit
            var response = component.find("APIOptyCreateForm").submit();
        } 
    }
})