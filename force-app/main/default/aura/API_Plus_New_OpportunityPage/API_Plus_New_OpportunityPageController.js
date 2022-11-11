({//by sk
    doInit:function(component,event,helper)
    {
        component.set("v.isRecdType",1);
    },
    showSelectedproducts: function (component, event, helper) {
        component.set("v.isModalOpen", true);
        
    },    
    closePopup: function (component, event, helper) {
        component.set("v.isModalOpen", false);
        component.set("v.isRecdType", 0);
        component.set("v.isAPI", 0);
        component.set("v.isAPIPLUS", 0);
        component.set("v.recTypeSelected", 0);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/006"
        });
        urlEvent.fire();
        
    },
    SavePopup: function (component, event, helper) {
       component.set("v.isModalOpen", false);
    },
    //upto here
    handleRadioClick : function(cmp, evt, helper){
     cmp.set('v.selectedOption', evt.getSource().get('v.value'));
	},
    handleValidity: function(component,event,helper)
    {        
        var newRecordTypeName;
        //var newRecordTypeName=component.get("v.recordTypeName");
        //console.log('Selected record type Name--->'+newRecordTypeName); 
        var api=component.find("radio1").getElement().checked;
        console.log('API selected through radio buttion--->'+ api)
        var apiPlus=component.find("radio2").getElement().checked;
		console.log('API Plus selected through radio buttion--->'+ apiPlus)  
        //newRecordTypeName!=undefined && newRecordTypeName=="API" ||
        if( api == true)
        {
            newRecordTypeName='API';
            component.set("v.recTypeSelected",1);
            component.set("v.isAPI",1);
            component.set("v.isRecdType",0);
            component.set("v.isAPIPLUS",0);
           
        }
        else if(apiPlus == true)
        {
            //newRecordTypeName!=undefined && newRecordTypeName=="API Plus" || 
            newRecordTypeName='API Plus';
            component.set("v.recTypeSelected",1);
            component.set("v.isAPIPLUS",1);
            component.set("v.isRecdType",0);
            component.set("v.isAPI",0);
            var wrapList=[];
            var newTSheet={"tSheet":{"API_Plus_Product__c":"","API_Plus_Dosage_Form__c":"","API_Plus_Strengths__c":"","API_Plus_Deal_Model__c":""},"commercial":{"API_Plus_Volume_Forecast1__c":"","API_Plus_Volume_Forecast2__c":"","API_Plus_Volume_Forecast3__c":"","API_Plus_Volume_Forecast4__c":"","API_Plus_Volume_Forecast5__c":"","API_Plus_Volume_Forecast6__c":"","API_Plus_Volume_Forecast7__c":"","API_Plus_Volume_Forecast8__c":"","API_Plus_Volume_Forecast9__c":"","API_Plus_Volume_Forecast10__c":""},"index":0};       
            console.log('new TSheet Details----->'+newTSheet);
            wrapList.push(newTSheet);
            component.set("v.tSheetDetails",wrapList);
        }
        else
        {
        	component.set("v.message","Please select at lease one record type");
        	alert('no record type selected');
            //by sk
            
        }
        //newRecordTypeName!=undefined && (newRecordTypeName=="API" || newRecordTypeName=="API Plus" ||
        if( api == true || apiPlus == true )
        {
            console.log('calling RecordTypeID Method--->');
            var action=component.get("c.OptyRecordTypeID");
            action.setParams({"optyRecordTypeName":newRecordTypeName});            
            action.setCallback(this, function(response) {
                var state=response.getState();
                
                console.log('Response State--->'+state);
                var recTypeID=response.getReturnValue();
                console.log('Record Type ID-------->'+recTypeID);
                if(recTypeID!=undefined && recTypeID !=null && recTypeID !='')
                {
                    component.set("v.recTypeID",recTypeID);
                    component.set("v.isRecdType", 0);
                }
                
            });
            $A.enqueueAction(action);
        }
    },
    cancel:function(component,event,helper)
    {
        component.set("v.isRecdType", 0);
        component.set("v.recTypeSelected", 0);
		component.set("v.isAPI", 0);
        component.set("v.isAPIPLUS", 0);        
        console.log('cancel--->');
        $A.get('e.force:refreshView').fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/006"
        });
        urlEvent.fire();
        
    },
    handleCancel : function(component, event, helper) {
        
        $A.get('e.force:refreshView').fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/006"
        });
        urlEvent.fire();
    },
    APIPlusRecordCreation:function(component,event,helper)
    {
        console.log('API Plus Opportunity record creationn process---->');
        console.log('is API Plus Save------>'+component.get("v.isAPIPlusSave"));
        var opty=component.get("v.apiPlusOpty");
        if(helper.validateTriggerSheetList(component,event) && component.get("v.isAPIPlusSave")==false)
        {
            component.set("v.isAPIPlusSave",true);
            console.log('is API Plus Save------>'+component.get("v.isAPIPlusSave"));
            console.log('Validated successfully');
            console.log('API Plus Opportunity-------->'+opty);
            console.log('API Plus Opportunity-------->'+JSON.stringify(opty));
            console.log('Opportunity Record Type ID----->'+component.get("v.recTypeID"));
            console.log('Opportunity Stage----->'+component.get("v.stage"));
            console.log('tSheetDetails------->'+component.get("v.tSheetDetails"));
            console.log('Tsheet Details in JSON Format------>'+JSON.stringify(component.get("v.tSheetDetails")));
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
            var action=component.get("c.optyAndTSheetCommCreation");
            action.setParams({
                'op':opty,
                'optyStage':component.get("v.stage"),
                'optyRecordTypeId':component.get("v.recTypeID"),
                'tSheetComm':tsheetDetails
            });
            action.setCallback(this,function(response){
                console.log('checking call back---->');
            //var State=response.getState();
            //console.log('State-------->'+State);
            	var state=response.getState();
                console.log('Response State--->'+state);
                if(state==='SUCCESS')
                {
                    
                    var optyRes=response.getReturnValue();
                    console.log('API Plus Opty response from Apex class--->'+optyRes);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title":"Success!",
                        "message":optyRes.message,
                        "type":"success"
                    });
                    //$A.get('e.force:refreshView').fire();
                    toastEvent.fire();
                    // navigating to API Plus Opportunity details page
                    var navService = component.find("navServiceAPIOpty");        
                    var pageReference = {
                        "type": 'standard__recordPage',         
                        "attributes": {              
                            "recordId": optyRes.apiOptyId,
                            "actionName": "view",               
                            "objectApiName":"Opportunity"              
                        }        
                    };
                    
                    component.set("v.pageReference", pageReference);            
                    var pageReference = component.get("v.pageReference");
                    console.log('Page Reference--->'+pageReference);
                    navService.navigate(pageReference);
                    console.log('Navigation Service--->'+navService);
                    // navigating to API Plus Opportunity details page
                    $A.get('e.force:refreshView').fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
        			dismissActionPanel.fire(); 
                    component.set("v.isRecdType", 0);
                    component.set("v.recTypeSelected", 1);
                    component.set("v.isAPI", 0);
                    component.set("v.isAPIPLUS", 0);   
                    
                    
                   
                }
                else
                {
                    
                }
            });
            $A.enqueueAction(action);
        }                       
    },
    APIRecordCreation:function(component,event,helper)
    {
        component.set("v.isModalOpen", false);
        component.set("v.isRecdType", 0);
        console.log('API Opportunity record creationn process---->');
        event.preventDefault(); //Prevent default submit
        var response=component.find("APIOptyCreateForm").submit();
        //var param = event.getParams(); //get event params
        //var fields = param.response.fields; //get all field info
        //console.log('All Fields---->'+fields);
        
    },
    handleOnLoad : function(component, event, helper) {
        console.log('handle on Load---->');
        
    },     
    handleOnSubmit : function(component, event, helper) {
        console.log('record type value--->'+component.get("v.isRecdType"))
        event.preventDefault(); //Prevent default submit
        var response=component.find("APIOptyCreateForm").submit();
        console.log('handle on submit---->');
        
    },      
    handleOnSubmitSaveNew:function(component,event,helper)
    {
        console.log('entered into handleOnSubmitSaveNew loop--->');
        event.preventDefault(); //Prevent default submit
        var response=component.find("APIOptyCreateForm").submit();
        console.log('handle on submit from SaveNew method---->');
        component.set("v.SaveNew", 1);
    },
    handleOnSuccess : function(component, event, helper) {  
        console.log('handler on Success--->');
        console.log('Record Type ID---->'+component.get("v.recTypeID"));
        console.log('API Plus Record Type---->'+component.get("v.isAPIPLUS"));
        console.log('Save and New Value---->'+component.get("v.SaveNew"))
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
        	"title":"Success!",
            "message":'Successfully created API Opportunity record',
            "type":"success"
        });        
        toastEvent.fire();
        
        console.log('handle on success---->');
        
        var param = event.getParams(); //get event params
        var fields = param.response.fields; //get all field info
        var childRelationships = param.response.childRelationships; //get child relationship info
        var recordTypeInfo = param.response.recordTypeInfo; //get record type info
        var recordId = param.response.id; //get record id
        console.log('Param--->'+JSON.stringify(param));
        console.log('Fields--->'+JSON.stringify(fields));
        console.log('Child Relationship - ' + JSON.stringify(childRelationships)); 
        console.log('Record Type Info - ' + JSON.stringify(recordTypeInfo)); 
        console.log('Record Id - ' + JSON.stringify(recordId)); 
        //component.set("v.recordId",recordId); 
        if(component.get("v.SaveNew")==1)
        {
            console.log('enter into savenew logic--->');
            component.set("v.isAPI", 1);
            component.set("v.isAPIPLUS", 0);
        	component.set("v.recTypeSelected", 1);
            component.set("v.recTypeID",component.get("v.recTypeID"));
            //$A.get('e.force:refreshView').fire();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
        	dismissActionPanel.fire();
            component.set("v.reloadForm", false);
       		component.set("v.reloadForm", true);
            component.set("v.SaveNew", 0);
        }
        else
        {            
           /* component.set("v.isModalOpen", false);
            component.set("v.isRecdType", 0);
            component.set("v.isAPI", 0);
            component.set("v.isAPIPLUS", 0);
            component.set("v.recTypeSelected", 0);*/
            
            console.log('Entered into only save logic----->');
            var navService = component.find("navService");        
            var pageReference = {
                "type": 'standard__recordPage',         
                "attributes": {              
                    "recordId": param.response.id,
                    "actionName": "view",               
                    "objectApiName":"Opportunity"              
                }        
            };        
            component.set("v.pageReference", pageReference);            
            var pageReference = component.get("v.pageReference");
            console.log('Page Reference--->'+pageReference);
            navService.navigate(pageReference);
            console.log('Navigation Service--->'+navService);
            
            component.set("v.isRecdType", 0);
        	component.set("v.recTypeSelected", 0);
			component.set("v.isAPI", 0);
        	component.set("v.isAPIPLUS", 0);        
        	console.log('cancel--->');
        	$A.get('e.force:refreshView').fire();
        	var dismissActionPanel = $A.get("e.force:closeQuickAction");
        	dismissActionPanel.fire();
            console.log('Record Type selected--->'+component.get("v.recTypeSelected"));
        }
        
         
        
        
    },      
    handleOnError : function(component, event) {
        console.log('handle on error--->');  
        console.log('handleError event-->');                
		var errors = event.getParams();
        //alert('Errors here--->'+errors);
		//console.log('Error Response', JSON.stringify(errors));
        //alert('Errors here--->'+JSON.stringify(errors));
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            	"title":"Error!",
            	"message":'Mandatory Information is missing, Plese review the information',
                "type":"error"
            });
            toastEvent.fire();
        
    },
    addProduct : function(component, event, helper) {
        var wrapList=component.get("v.tSheetDetails");
        var indexLength=wrapList.length;
        var newTSheetDetails={"tSheet":{"API_Plus_Product__c":"","API_Plus_Dosage_Form__c":"","API_Plus_Strengths__c":"","API_Plus_Deal_Model__c":""},"commercial":{"API_Plus_Volume_Forecast1__c":"","API_Plus_Volume_Forecast2__c":"","API_Plus_Volume_Forecast3__c":"","API_Plus_Volume_Forecast4__c":"","API_Plus_Volume_Forecast5__c":"","API_Plus_Volume_Forecast6__c":"","API_Plus_Volume_Forecast7__c":"","API_Plus_Volume_Forecast8__c":"","API_Plus_Volume_Forecast9__c":"","API_Plus_Volume_Forecast10__c":""},"index":indexLength};
        //var newTSheetDetails={"tSheet":{"API_Plus_Product_Name__c":"","API_Plus_Dosage_Form__c":"","API_Plus_Strengths__c":"","API_Plus_Deal_Model__c":""}};
        console.log('new TSheet Details----->'+newTSheetDetails);
        wrapList.push(newTSheetDetails);
        component.set("v.tSheetDetails",wrapList);
        //helper.addTriggerSheetRecord(component,event);
        //console.log('handler call add product--->');
        
    },
    addYear:function(component,event,helper)
    {
        var getList=component.get("v.yearList");
        if(getList!=undefined&&getList!=null&&getList!='')
        {
            if(getList.length<9) getList.push('Year');
        }
        else
        {
            getList.push('Year');
        }
        
        component.set("v.yearList",getList);
    },
    
    removeYear:function(component,event,helper)
    {
        var isrRemoveYear=false;
        var isSave=false;
        var getList=component.get("v.yearList");
        
        if(getList!=undefined&&getList!=null&&getList!=''&&getList.length>0)
        {
            getList.splice(getList.length-1,1);
            component.set("v.yearList",getList);
            console.log('called save method');
            /*if(helper.validateTriggerSheetList(component,event))
            {
                console.log('Validated successfully');
                isrRemoveYear=true;
                //helper.saveTriggerSheetList(component,event,isSave,isrRemoveYear);
            }*/
        }
    },
    removeRow: function(component,event,helper)
    {
        console.log('coming into remove Row logic--->');
        //Get the triggersheet list
        var triggerSheetList=component.get("v.tSheetDetails");
        // Get the Target Object
        var selectedItem=event.currentTarget;
        var index=selectedItem.dataset.record;
        
        console.log('remove the row--->'+index);
        triggerSheetList.splice(index,1);
        component.set("v.tSheetDetails",triggerSheetList);
        
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            	"title":"Success!",
            	"message":'Deleted record successfully',
                "type":"success"
            });
            toastEvent.fire();
    }
})