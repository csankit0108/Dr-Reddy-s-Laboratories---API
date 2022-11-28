({
    getDetailsOnLoad : function(component,event,helper) {
        var strLeadRecordId = component.get("v.recordId");
        var action = component.get("c.getLeadDetails");
        action.setParams({ "strrecordId": strLeadRecordId });
        action.setCallback(this, function (response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var objLeadRecord = result.objLead;
                component.set("v.objLead", objLeadRecord);
                if (
                        (   objLeadRecord.RecordTypeId && 
                            objLeadRecord.RecordType.DeveloperName === "DRL_Lead" && 
                            result.blnisParentProspectConverted == true)||
                        (   objLeadRecord.IsConverted == true && 
                            objLeadRecord.RecordType.DeveloperName == "DRL_Prospect" &&
                            result.listProspectChildLeads.length > 0)
                    ) {
                        component.set("v.objAccount", result.objparentProspectAccount);
                        component.set("v.strAccountId", result.objparentProspectAccount.Id);
                        let objContact = result.objparentProspectContact;
                        objContact.Name = helper.isNullCheck(objContact.FirstName)
                                        ?objContact.LastName
                                        :objContact.FirstName+" "+objContact.LastName;
                        component.set("v.objContact", objContact);
                        component.set("v.strContactId", result.objparentProspectContact.Id);
                        component.set("v.blnIsParentProspectConverted", true);
                    }
                component.set("v.list_AccountFieldSet", JSON.parse(result.strAccountMasterFieldSet));
                component.set("v.list_ContactFieldSet", JSON.parse(result.strContactMasterFieldSet));
                helper.setOpportunityDetailsOnLoad(component, helper, result)
                if (
                    (   objLeadRecord.Product_Lookup__c == undefined || 
                        objLeadRecord.Product_Lookup__c == null || 
                        objLeadRecord.Product_Lookup__c == "" ) && 
                        objLeadRecord.RecordType.DeveloperName != "DRL_Prospect" 
                    ) {                    
                        var toastEvent = $A.get("e.force:showToast");                    
                        toastEvent.setParams({
                            "type": "error",
                            "title": "Error !",
                            "message": $A.get("$Label.c.CLDRL00013")
                        });
                        toastEvent.fire();
                        $A.get("e.force:refreshView").fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }else{                    
                        if (
                            (objLeadRecord.IsConverted == true && 
                             objLeadRecord.RecordType.DeveloperName == "DRL_Lead")||
                            (objLeadRecord.IsConverted == true && 
                             objLeadRecord.RecordType.DeveloperName == "DRL_Prospect" &&
                             result.listProspectChildLeads.length == 0)
                            ){                        
                            helper.openAlert("error",
                                                $A.get("$Label.c.CLDRL00011"),
                                                $A.get("$Label.c.CLDRL00010"),
                                                function(){}
                                            );
                            helper.closeQuickAction(component);
                            return;
                        }             
                        if (objLeadRecord.IsConverted == false)
                            component.set("v.convertedStatus", false);
                    }
                //set Automation data
                if((objLeadRecord.RecordTypeId && objLeadRecord.RecordType.DeveloperName==="DRL_Lead")){
                    component.set("v.map_ContentTotal", result.mapContentList);
                    component.set("v.blnContentAvailable", result.contentAvailable);
                    if (result.contentAvailable){
                        component.set("v.list_DocumentCategoriesAvailable", result.catList);
                    }                        
                }
                else if((objLeadRecord.RecordTypeId && objLeadRecord.RecordType.DeveloperName==="DRL_Prospect")){
                    component.set("v.map_MapContentTotal", result.map_mapContentList);
                    component.set("v.map_BlnContentAvailable", result.map_contentAvailable);
                    component.set("v.map_ListDocumentCategoriesAvailable",result.map_catList);
                }
                
                component.set("v.blnIsFormDataLoaded",true);  
            }
            else{
                helper.showMessage("Error!",$A.get("$Label.c.CLDRL00003"),"error","dismissible");
            }
            component.set("v.blnIsLoading",false);
        });        
        $A.enqueueAction(action);
    },
    setOpportunityDetailsOnLoad:function(component,helper,result){
        let objLeadrecord=result.objLead;
        component.set("v.list_OpportunityFormFieldsToRender",JSON.parse(result.stropportunityMasterFieldSet));
        let map_opportunityDisableFieldSets=result.map_opportunityDisableFieldSets;
        let map_FieldSetToFieldsMap={}
        for (let strFieldSetName in map_opportunityDisableFieldSets) {
            map_FieldSetToFieldsMap[strFieldSetName.toLowerCase()]=JSON.parse(map_opportunityDisableFieldSets[strFieldSetName]);
        }
        component.set("v.map_FieldSetToFieldsMap",map_FieldSetToFieldsMap);
        
        let map_StageToFieldSetMap={};
        let list_LeadConvertOpportunityFormControllers=result.list_LeadConvertOpportunityFormControllers;
        list_LeadConvertOpportunityFormControllers.forEach(function(objformController){
            map_StageToFieldSetMap[objformController["Label"]]=objformController["FieldSetAPIName__c"].toLowerCase();
        });
        component.set("v.map_StageToFieldSetMap",map_StageToFieldSetMap);
        
        let list_OpportunityRecordTypes=[];
        let objOpportunityRecordTypes=result.map_opportunityRecordTypes;
        for (let strRecordTypeId in objOpportunityRecordTypes) {
            list_OpportunityRecordTypes.push({
                "key":strRecordTypeId,
                "value":objOpportunityRecordTypes[strRecordTypeId]
            });                    
        }
        component.set("v.list_OpportunityRecordTypes",list_OpportunityRecordTypes);
        component.set("v.strDefaultRecordTypeId",list_OpportunityRecordTypes[0].key);                
        if( objLeadrecord.RecordTypeId && objLeadrecord.RecordType.DeveloperName==="DRL_Prospect"){
            component.set("v.blnIsProspect",true);
            let list_ProspectChildLeads=result.listProspectChildLeads;
            if(list_ProspectChildLeads.length>0){
                component.set("v.blnIsChildRecordsFound",true);
                component.set("v.list_ProspectChildLeads",helper.setChildLeads(component,list_ProspectChildLeads,result.strchildLeadTableColumns));
            }
        }
        else{
            component.set("v.blnIsProspect",false);
            let objOpportunity={};
            objOpportunity.Name=objLeadrecord.Name;
            objOpportunity.Lead_Converted_From__c=objLeadrecord.Id;
            objOpportunity.RecordTypeId=component.get("v.strDefaultRecordTypeId");
            component.set("v.objOpportunity",objOpportunity);
        }
        
    },
    closeQuickAction:function(component){
        $A.get("e.force:refreshView").fire();
        $A.get("e.force:closeQuickAction").fire();
        if(component.get("v.blnrenderfrompath")){
            var modal = component.find("modal");
            $A.util.addClass(modal, "hideContent");
            var modalbackdrop = component.find("modalbackdrop");
            $A.util.addClass(modalbackdrop, "hideContent"); 
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
        if(variable==""||variable==null||variable==undefined){
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
        var objAccount = component.get("v.objAccount")       
        let list_fieldArray = component.get("v.list_AccountFieldSet");
        list_fieldArray.forEach(function(objaccountField){
            if(objaccountField.required== true && helper.isNullCheck(objAccount[objaccountField.name])){
                component.set("v.strErrorMessage",$A.get("$Label.c.CLDRL00008"));
                component.set("v.blnShowErrorMessage",true);
                return false;
            }
        });
        return true;        
    },
    
    isValidContact : function(component, event, helper){
        var objContact = component.get("v.objContact")    
        let list_fieldArray = component.get("v.list_ContactFieldSet");
        list_fieldArray.forEach(function(objcontactField){
            if(objcontactField.required== true && helper.isNullCheck(objContact[objcontactField.name])){
                component.set("v.strErrorMessage",$A.get("$Label.c.CLDRL00008"));
                component.set("v.blnShowErrorMessage",true);
                component.set("v.blnIsLoading",false);
                return false;
            }
        });
        //radio button check for new contact
        var strContactRadioButtonSelected = component.get("v.strContactRadioButtonSelected");
        if(strContactRadioButtonSelected==="3" && !component.get("v.blnIsParentProspectConverted")){
            var action = component.get("c.checkEmail");
            action.setParams({"strmail":objContact.email});
            action.setCallback(this,function(response){
                let state=response.getState();
                if(state==="SUCCESS"){
                    let result=response.getReturnValue();
                    if (result == true){     //email already exists
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": $A.get("$Label.c.CLDRL00018"),
                            "type":"error",
                            "mode":"dismissible"
                        });
                        toastEvent.fire();
                        component.set("v.strErrorMessage",$A.get("$Label.c.CLDRL00018"));
                        component.set("v.blnShowErrorMessage",true);                        
                        component.set("v.blnIsLoading",false);
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
        var objContact = component.get("v.objContact");
        var strAccountId = component.get("v.strAccountId");
        var strContactId = component.get("v.strContactId")
        
        if ((!helper.isNullCheck(strAccountId) && !helper.isNullCheck(strContactId)) && (objContact.AccountId != strAccountId || helper.isNullCheck(objContact.AccountId))){
            component.set("v.strErrorMessage",$A.get("$Label.c.CLDRL00017"));
            component.set("v.blnShowErrorMessage",true);
            return false;
        }
        else{             
            return true;
        }
    },    
    
    isValidOpportunities:function(component,event,helper){
        let blnIsProspect=component.get("v.blnIsProspect");
        if(blnIsProspect){
            let list_Opportunities=component.get("v.list_Opportunities");
            for (const objOpportunity of list_Opportunities) {
                let list_mandatoryFields=helper.getMandatoryFields(component,objOpportunity.StageName,helper);
                for (const strfield of list_mandatoryFields) {
                    if(helper.isNullCheck(objOpportunity[strfield])){
                        component.set("v.strErrorMessage",$A.get("$Label.c.CLDRL00008"));
                        component.set("v.blnShowErrorMessage",true);
                        return false;
                    }                
                }
            }
            return true;
        }
        else{
            let objOpportunity=component.get("v.objOpportunity");
            let list_mandatoryFields=helper.getMandatoryFields(component,objOpportunity.StageName,helper);
            for (const strfield of list_mandatoryFields) {
                if(helper.isNullCheck(objOpportunity[strfield])){
                    component.set("v.strErrorMessage",$A.get("$Label.c.CLDRL00008"));
                    component.set("v.blnShowErrorMessage",true);
                    return false;
                }                
            }
            return true;
        }
    },
    getMandatoryFields:function(component,stageName,helper){
        let list_mandatoryFields=[];
        let listMasterFieldset=component.get("v.list_OpportunityFormFieldsToRender");
        let map_FieldSetToFieldsMap=component.get("v.map_FieldSetToFieldsMap");
        let map_StageToFieldSetMap=component.get("v.map_StageToFieldSetMap");
        if(this.isNullCheck(stageName)){
            stageName="--None--";
        }
        let list_fieldsToDisable=helper.isNullCheck(map_StageToFieldSetMap[stageName])
        ?[]
        :helper.isNullCheck(map_FieldSetToFieldsMap[map_StageToFieldSetMap[stageName]])
        ?[]
        :map_FieldSetToFieldsMap[map_StageToFieldSetMap[stageName]];
        
        
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
            if(objColumn.type=="url"){
                if(objColumn.typeAttributes.label.fieldName=="Name"){
                    list_ProspectChildLeads.forEach(objLead=>{
                        objLead.LeadUrl="/"+objLead.Id;                               
                    });
                }
                else{
                    let strfieldName=objColumn.fieldName.substring(0, objColumn.fieldName.length-3);
                    let strObjectName="";                    
                    if(strfieldName.match("Id$")){
                        strObjectName=strfieldName.substring(0,strfieldName.length-2);
                    }
                    else{
                        strObjectName=strfieldName.substring(0,strfieldName.length-1)+"r";
                    }
                    
                    list_ProspectChildLeads.forEach(objLead=>{
                        objLead[objColumn.fieldName]="/"+objLead[strfieldName];                               
                        objLead[strfieldName+"Name"]=objLead[strObjectName]["Name"];
                    });
                }
            }                    
        });
        component.set("v.list_ChildLeadTableColumns",list_ChildLeadTableColumns);        
        return list_ProspectChildLeads;
    },
    isValidRunAutomationData:function(component,event,helper){
        let objLead=component.get("v.objLead");
        if(objLead.RecordTypeId && objLead.RecordType.DeveloperName==="DRL_Lead"){
            let blnContentAvailable=component.get("v.blnContentAvailable");
            if(blnContentAvailable){
                let strRunAfter=component.get("v.strRunAfter");
                if(helper.isNullCheck(strRunAfter)){
                    helper.showMessage("Error!",$A.get("$Label.c.CLDRL00015"),"error","dismissible");
                    return false;
                }
                let list_FinalSelectedContentCatalogs=component.get("v.list_FinalSelectedContentCatalogs");
                if(helper.isNullCheck(list_FinalSelectedContentCatalogs)||list_FinalSelectedContentCatalogs.length==0){
                    helper.showMessage("Error!",$A.get("$Label.c.CLDRL00016"),"error","dismissible");
                    return false;
                }
            }
        }
        else if(objLead.RecordTypeId && objLead.RecordType.DeveloperName==="DRL_Prospect" && component.get("v.blnisChildRecordsFound")){
            let list_Opportunities=component.get("v.list_Opportunities");
            if(!helper.isNullCheck(list_Opportunities)&&list_Opportunities.length>0){
                let map_BlnContentAvailable=component.get("v.map_BlnContentAvailable");
                let map_StrRunAfter=component.get("v.map_StrRunAfter");
                let map_ListFinalSelectedContentCatalogs=component.get("v.map_ListFinalSelectedContentCatalogs");      
                for (var i = 0; i < list_Opportunities.length; i++) {
                    let objOpportunity=list_Opportunities[i];
                    if(map_BlnContentAvailable[objOpportunity.Lead_Converted_From__c]){
                        let strRunAfter=map_StrRunAfter[objOpportunity.Lead_Converted_From__c];
                        if(helper.isNullCheck(strRunAfter)){
                            helper.showMessage("Error!",$A.get("$Label.c.CLDRL00015"),"error","dismissible");
                            return false;
                        }
                        let list_FinalSelectedContentCatalogs=map_ListFinalSelectedContentCatalogs[objOpportunity.Lead_Converted_From__c];
                        if(helper.isNullCheck(list_FinalSelectedContentCatalogs)||list_FinalSelectedContentCatalogs.length==0){
                            helper.showMessage("Error!",$A.get("$Label.c.CLDRL00016"),"error","dismissible");
                            return false;
                        }
                    }
                }              
            }
        }
        return true;
    },
    convertLeadHelper:function(component,event,helper){
        var action=component.get("c.convertLead");
        action.setParams({
            "strleadRecordId":component.get("v.recordId"),
            "objaccount":component.get("v.objAccount"),
            "objcontact":component.get("v.objContact"),
            "objopportunity":component.get("v.objOpportunity"),
            "list_leadOpportunities":component.get("v.list_Opportunities"),
            "list_leads":component.get("v.list_SelectedLeads"),
            "list_contentCatalogs":component.get("v.list_FinalSelectedContentCatalogs"),
            "strrunAfter":component.get("v.strRunAfter"),
            "map_listContentCatalogs":component.get("v.map_ListFinalSelectedContentCatalogs"),
            "map_strrunAfter":component.get("v.map_StrRunAfter")
        });
        action.setCallback(this,function(response){
            let state=response.getState();
            if(state==="SUCCESS"){
                let result=response.getReturnValue();
                if(result.strstatus=="Success"){
                    helper.showMessage("Success!",$A.get("$Label.c.CLDRL00012"),"success","dismissible");
                    component.set("v.objAccount",result.objaccount);
                    component.set("v.objContact",result.objcontact);
                    if(!helper.isNullCheck(result.objopportunity)){
                        component.set("v.objOpportunity",result.objopportunity);
                    }
                    if(!helper.isNullCheck(result.list_opportunities)){
                        component.set("v.list_Opportunities",result.list_opportunities);
                    }
                    component.set("v.map_SuccessFieldsToShow",result.map_successFieldsToShow);
                    component.set("v.strErrorMessage","");
                    component.set("v.blnShowErrorMessage",false);                  
                    component.set("v.blnIsConvertedSuccess",true);
                }
                else if(result.strstatus=="Duplicate Account"){
                    helper.showMessage("Error!",$A.get("$Label.c.CLDRL00004"),"error","dismissible");
                }
                else if(result.strstatus=="Duplicate"){
                    helper.showMessage("Error!",$A.get("$Label.c.CLDRL00005"),"error","dismissible");
                }
                else{                    
                    helper.showMessage("Error!",$A.get("$Label.c.CLDRL00006") ,"error","dismissible");
                }
            }
            else{
                helper.showMessage("Error!",$A.get("$Label.c.CLDRL00006"),"error","dismissible");
            }
            component.set("v.blnIsLoading",false);
        });
        $A.enqueueAction(action);
    }
})