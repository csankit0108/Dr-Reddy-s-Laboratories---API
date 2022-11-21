({
    getDetailsOnLoad : function(component,event,helper) {
        var strleadRecordId = component.get('v.recordId');
        var action = component.get('c.getLeadDetails');
        action.setParams({ "strrecordId": strleadRecordId });
        action.setCallback(this, function (response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result=response.getReturnValue();
                var objleadRecord = result.objLead;
                component.set('v.objlead',objleadRecord);
                if((objleadRecord.RecordTypeId && objleadRecord.RecordType.DeveloperName==='DRL_Lead' && result.blnisParentProspectConverted==true)||
                    (objleadRecord.IsConverted == true && objleadRecord.RecordType.DeveloperName=='DRL_Prospect' &&result.listProspectChildLeads.length>0)
                ){
                    component.set('v.objaccountRecord',result.objparentProspectAccount);
                    component.set('v.straccountId',result.objparentProspectAccount.Id);
                    let objContact=result.objparentProspectContact;
                    objContact.Name=helper.isNullCheck(objContact.FirstName)?objContact.LastName:objContact.FirstName+' '+objContact.LastName;
                    component.set('v.objcontactRecord',objContact);
                    component.set('v.strcontactId',result.objparentProspectContact.Id);
                    component.set('v.blnisParentProspectConverted',true);
                }
                component.set('v.list_accountFieldSet',JSON.parse(result.strAccountMasterFieldSet));
                component.set('v.list_contactFieldSet', JSON.parse(result.strContactMasterFieldSet));
                helper.setOpportunityDetailsOnLoad(component,helper,result)
                if ((objleadRecord.Product_Lookup__c == undefined || objleadRecord.Product_Lookup__c == null || objleadRecord.Product_Lookup__c == '' ) && objleadRecord.RecordType.DeveloperName!='DRL_Prospect') {
                    
                    var toastEvent = $A.get("e.force:showToast");                    
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error !",
                        "message": $A.get("$Label.c.DRL_productField_errorMsg")
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
                else {                    
                    if (
                        (objleadRecord.IsConverted == true && objleadRecord.RecordType.DeveloperName=='DRL_Lead')||
                        (objleadRecord.IsConverted == true && objleadRecord.RecordType.DeveloperName=='DRL_Prospect' &&result.listProspectChildLeads.length==0)
                        ){                        
                        helper.openAlert('error',
                                         $A.get("$Label.c.DRL_LeadAlreadyConvertedMessageHeader"),
                                         $A.get("$Label.c.DRL_LeadAlreadyConverted"),
                                         function(){}
                                        );
                        helper.closeQuickAction(component);
                        return;
                    }             
                    if (objleadRecord.IsConverted == false)
                        component.set("v.convertedStatus", false);
                }
                
                component.set('v.blnisFormDataLoaded',true);  
            }
            else{
                helper.showMessage('Error!',$A.get("$Label.c.DRL_ConvertLeadDataLoadError"),'error','dismissible');
            }
            component.set('v.blnisLoading',false);
        });        
        $A.enqueueAction(action);
    },
    setOpportunityDetailsOnLoad:function(component,helper,result){
        let objleadrecord=result.objLead;
        component.set('v.list_opportunityFormFieldsToRender',JSON.parse(result.stropportunityMasterFieldSet));
        let map_opportunityDisableFieldSets=result.map_opportunityDisableFieldSets;
        let map_fieldSetTofieldsMap={}
        for (let strFieldSetName in map_opportunityDisableFieldSets) {
            map_fieldSetTofieldsMap[strFieldSetName.toLowerCase()]=JSON.parse(map_opportunityDisableFieldSets[strFieldSetName]);
        }
        component.set('v.map_fieldSetTofieldsMap',map_fieldSetTofieldsMap);
        
        let map_stageToFieldSetMap={};
        let list_LeadConvertOpportunityFormControllers=result.list_LeadConvertOpportunityFormControllers;
        list_LeadConvertOpportunityFormControllers.forEach(function(objformController){
            map_stageToFieldSetMap[objformController['Label']]=objformController['Field_Set_Api_Name__c'].toLowerCase();
        });
        component.set('v.map_stageToFieldSetMap',map_stageToFieldSetMap);
        
        let list_opportunityRecordTypes=[];
        let objOpportunityRecordTypes=result.map_opportunityRecordTypes;
        for (let strRecordTypeId in objOpportunityRecordTypes) {
            list_opportunityRecordTypes.push({
                'key':strRecordTypeId,
                'value':objOpportunityRecordTypes[strRecordTypeId]
            });                    
        }
        component.set('v.list_opportunityRecordTypes',list_opportunityRecordTypes);
        component.set('v.strdefaultRecordTypeId',list_opportunityRecordTypes[0].key);                
        if( objleadrecord.RecordTypeId && objleadrecord.RecordType.DeveloperName==='DRL_Prospect'){
            component.set('v.blnisProspect',true);
            let list_ProspectChildLeads=result.listProspectChildLeads;
            if(list_ProspectChildLeads.length>0){
                component.set('v.blnisChildRecordsFound',true);
                component.set('v.list_ProspectChildLeads',helper.setChildLeads(component,list_ProspectChildLeads,result.strchildLeadTableColumns));
            }
        }
        else{
            component.set('v.blnisProspect',false);
            let objopportunity={};
            objopportunity.Name=objleadrecord.Name;
            objopportunity.Lead_Converted_From__c=objleadrecord.Id;
            objopportunity.RecordTypeId=component.get('v.strdefaultRecordTypeId');
            component.set('v.objopportunity',objopportunity);
        }
        
    },
    closeQuickAction:function(component){
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
        if(component.get('v.blnrenderfrompath')){
            var modal = component.find("modal");
            $A.util.addClass(modal, "hideContent");
        }
    },
    openAlert : function(strtheme,strlabel,strmessage,action){
        this.LightningAlert.open({
            theme: strtheme,
            label: strlabel,
            message: strmessage
        }).then(action);
    },
    isNullCheck:function(variable){
        if(variable==''||variable==null||variable==undefined){
            return true;
        }else{
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
    },
    
    isValidAccount : function(component, event, helper){
        var objaccountRecord = component.get('v.objaccountRecord')       
        let list_fieldArray = component.get('v.list_accountFieldSet');
        list_fieldArray.forEach(function(objaccountField){
            if(objaccountRecord[objaccountField.required]== true && helper.isNullCheck(objaccountRecord[objaccountField.name])){
                component.set('v.strerrorMsg',$A.get('$Label.c.DRL_convertLeadRequiredFieldsError'));
                component.set('v.blnerrorMsg',true);
                return false;
            }
        });
        return true;        
    },
    
    isValidContact : function(component, event, helper){
        var objcontactRecord = component.get('v.objcontactRecord')    
        let list_fieldArray = component.get('v.list_contactFieldSet');
        list_fieldArray.forEach(function(objcontactField){
            if(objcontactRecord[objcontactField.required]== true && helper.isNullCheck(objcontactRecord[objcontactField.name])){
                component.set('v.strerrorMsg',$A.get('$Label.c.DRL_convertLeadRequiredFieldsError'));
                component.set('v.blnerrorMsg',true);
                component.set('v.blnisLoading',false);
                return false;
            }
        });
        //radio button check for new contact
        var strcontactRadioButton = component.get('v.strcontactRadioButton');
        if(strcontactRadioButton==='3' && !component.get('v.blnisParentProspectConverted')){
            var action = component.get('c.checkEmail');
            action.setParams({'strmail':objcontactRecord.email});
            action.setCallback(this,function(response){
                let state=response.getState();
                if(state==='SUCCESS'){
                    let result=response.getReturnValue();
                    if (result == true){     //email already exists
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": 'Error!',
                            "message": $A.get('$Label.c.DRL_contactWithEmailExistError'),
                            "type":'error',
                            "mode":'dismissible'
                        });
                        toastEvent.fire();
                        component.set('v.strerrorMsg',$A.get('$Label.c.DRL_contactWithEmailExistError'));
                        component.set('v.blnerrorMsg',true);                        
                        component.set('v.blnisLoading',false);
                    }
                    else{
                        helper.convertLeadHelper(component,event,helper);                        
                    }
                }
                
                
            });
            $A.enqueueAction(action);
        }
        else{
            helper.convertLeadHelper(component,event,helper);            
        }
    },
    
    isAccountRelatedContact : function(component, event, helper){        
        var objcontactRecord = component.get('v.objcontactRecord');
        var straccountId = component.get('v.straccountId');
        var strcontactId = component.get('v.strcontactId')
        
        if ((!helper.isNullCheck(straccountId) && !helper.isNullCheck(strcontactId)) && (objcontactRecord.AccountId != straccountId || helper.isNullCheck(objcontactRecord.AccountId))){
            component.set('v.strerrorMsg',$A.get('$Label.c.DRL_accountNotRelatedToContactError'));
            component.set('v.blnerrorMsg',true);
            return false;
        }
        else{             
            return true;
        }
    },    
    
    isValidOpportunities:function(component,event,helper){
        let blnisProspect=component.get('v.blnisProspect');
        if(blnisProspect){
            let list_Opportunities=component.get('v.list_Opportunities');
            for (const objopportunity of list_Opportunities) {
                let list_mandatoryFields=helper.getMandatoryFields(component,objopportunity.StageName,helper);
                for (const strfield of list_mandatoryFields) {
                    if(helper.isNullCheck(objopportunity[strfield])){
                        component.set('v.strerrorMsg',$A.get('$Label.c.DRL_convertLeadRequiredFieldsError'));
                        component.set('v.blnerrorMsg',true);
                        return false;
                    }                
                }
            }
            return true;
        }
        else{
            let objopportunity=component.get('v.objopportunity');
            let list_mandatoryFields=helper.getMandatoryFields(component,objopportunity.StageName,helper);
            for (const strfield of list_mandatoryFields) {
                if(helper.isNullCheck(objopportunity[strfield])){
                    component.set('v.strerrorMsg',$A.get('$Label.c.DRL_convertLeadRequiredFieldsError'));
                    component.set('v.blnerrorMsg',true);
                    return false;
                }                
            }
            return true;
        }
    },
    getMandatoryFields:function(component,stageName,helper){
        let list_mandatoryFields=[];
        let listMasterFieldset=component.get('v.list_opportunityFormFieldsToRender');
        let map_fieldSetTofieldsMap=component.get('v.map_fieldSetTofieldsMap');
        let map_stageToFieldSetMap=component.get('v.map_stageToFieldSetMap');
        if(this.isNullCheck(stageName)){
            stageName='--None--';
        }
        let list_fieldsToDisable=helper.isNullCheck(map_stageToFieldSetMap[stageName])
        ?[]
        :helper.isNullCheck(map_fieldSetTofieldsMap[map_stageToFieldSetMap[stageName]])
        ?[]
        :map_fieldSetTofieldsMap[map_stageToFieldSetMap[stageName]];
        
        
        listMasterFieldset.forEach(function(objField){
            let isDisabled=list_fieldsToDisable.some(function(objdisableField){
                return objField.name==objdisableField.name;
            })
            if(!isDisabled&&objField.required){
                list_mandatoryFields.push(objField.name);   
            }                     
        })
        return list_mandatoryFields;
    },
    setChildLeads:function(component,list_ProspectChildLeads,strchildLeadTableColumns){
        let list_ChildLeadTableColumns=JSON.parse(strchildLeadTableColumns);
        list_ChildLeadTableColumns.forEach(objColumn=>{
            if(objColumn.type=='url'){
                if(objColumn.typeAttributes.label.fieldName=='Name'){
                    list_ProspectChildLeads.forEach(objlead=>{
                        objlead.LeadUrl='/'+objlead.Id;                               
                    });
                }
                else{
                    let strfieldName=objColumn.fieldName.substring(0, objColumn.fieldName.length-3);
                    let strObjectName='';                    
                    if(strfieldName.match("Id$")){
                        strObjectName=strfieldName.substring(0,strfieldName.length-2);
                    }
                    else{
                        strObjectName=strfieldName.substring(0,strfieldName.length-1)+'r';
                    }
                    
                    list_ProspectChildLeads.forEach(objlead=>{
                        objlead[objColumn.fieldName]='/'+objlead[strfieldName];                               
                        objlead[strfieldName+'Name']=objlead[strObjectName]['Name'];
                    });
                }
            }                    
        });
        component.set('v.list_ChildLeadTableColumns',list_ChildLeadTableColumns);        
        return list_ProspectChildLeads;
    },
    convertLeadHelper:function(component,event,helper){
        var action=component.get('c.convertLead');
        action.setParams({
            'strleadRecordId':component.get('v.recordId'),
            'objaccount':component.get('v.objaccountRecord'),
            'objcontact':component.get('v.objcontactRecord'),
            'objopportunity':component.get('v.objopportunity'),
            'list_leadOpportunities':component.get('v.list_Opportunities'),
            'list_leads':component.get('v.list_selectedLeads')
        });
        action.setCallback(this,function(response){
            let state=response.getState();
            if(state==='SUCCESS'){
                let result=response.getReturnValue();
                if(result.strstatus=='Success'){
                    helper.showMessage('Success!',$A.get('$Label.c.DRL_leadConvertSuccessMessage'),'success','dismissible');
                    component.set('v.objaccountRecord',result.objaccount);
                    component.set('v.objcontactRecord',result.objcontact);
                    if(!helper.isNullCheck(result.objopportunity)){
                        component.set('v.objopportunity',result.objopportunity);
                    }
                    if(!helper.isNullCheck(result.list_opportunities)){
                        component.set('v.list_Opportunities',result.list_opportunities);
                    }
                    component.set('v.strerrorMsg','');
                    component.set('v.blnerrorMsg',false);
                    component.set('v.blnisConvertedSuccess',true);
                }
                else if(result.strstatus=='Duplicate Account'){
                    helper.showMessage('Error!',$A.get('$Label.c.DRL_convertLeadDuplicateAccountError'),'error','dismissible');
                }
                else if(result.strstatus=='Duplicate'){
                    helper.showMessage('Error!',$A.get('$Label.c.DRL_convertLeadDuplicateContactError'),'error','dismissible');
                }
                else{                    
                    helper.showMessage('Error!',$A.get('$Label.c.DRL_ConvertLeadError') ,'error','dismissible');
                }
            }
            else{
                helper.showMessage('Error!',$A.get('$Label.c.DRL_ConvertLeadError'),'error','dismissible');
            }
            component.set('v.blnisLoading',false);
        });
        $A.enqueueAction(action);
    }
})