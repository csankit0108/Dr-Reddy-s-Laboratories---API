/**
* @description       : This class contains all resuable methods.
* @author            : Surender Patel (Dhruvsoft)
* @group             :
* @last modified on  : 10-08-2020
* @last modified by  : Surender Patel (Dhruvsoft)
* Modifications Log
* Ver   Date         Author                       Modification
* 1.0   03-08-2020   Surender Patel (Dhruvsoft)   Initial Version
**/
public class DRLUtil{
    public static Boolean update_new_product = false;
    public static Boolean allowLineItem = true;
    /**
* @description This method gives all fields with comma, to use in query. Don't add fields again. Just add reference fields if needed.
* @author Surender Patel (Dhruvsoft) | 04-08-2020
* @param String obj - Object Name
* @return String - all fields with comma, to use in query.
**/
    public static String getsObjectFieds(String obj){
        String allFieldsStr;
        List<String> allFieldsList = new List<String>();
        
        for (Schema.SObjectField field : ((sObject)Type.forName(obj).newInstance()).getSObjectType().getDescribe().fields.getMap().values()){
            if (field.getDescribe().isAccessible()){
                allFieldsList.add(String.valueOf(field));
            }
            
        }
        
        integer i = 0;
        for (String str : allFieldsList){
            if (i == 0){
                allFieldsStr = ' ' + str + ',';
                i++;
            } else if (i == allFieldsList.size()-1){
                allFieldsStr = allFieldsStr + str + ' ';
                i++;
            } else if (i < allFieldsList.size()-1){
                allFieldsStr = allFieldsStr + str + ',';
                i++;
            }
        }
        
        return allFieldsStr;
    }
    
    /**
* @description This method will search and give appropriate approval matrix for the quotation.
* @author Surender Patel (Dhruvsoft) | 05-08-2020
* @param PQT_Quotation__c quotation
* @return PQT_Master_Data__c
**/
    public static PQT_Master_Data__c getApprovalMatrix(PQT_Quotation__c quotation){
        PQT_Master_Data__c selectedMatrix = new PQT_Master_Data__c();
        Id quoteOwner = quotation.OwnerId;
        
        String query = 'SELECT ' + DRLUtil.getsObjectFieds('PQT_Master_Data__c')+',RecordType.Name,PQT_L1_Approver__r.Name,PQT_L1_B_Approver__r.Name,PQT_L1_B_Approver__r.Email,'+
            +'PQT_L2_Approver__r.Name,PQT_L3_Approver__r.Name,PQT_L4_Approver__r.Name,PQT_L3B_Finance_BU_Head__r.Name,PQT_L1_Approver__r.Email,PQT_L1_Approver__r.Manager.Email,PQT_L1_B_Approver__r.Manager.Email '+
            +''+
            +' FROM PQT_Master_Data__c LIMIT 10000';
        List<PQT_Master_Data__c> masterApprovalMatrix = Database.query(query);
        Map<String, List<PQT_Master_Data__c>> matrixMap = new Map<String, List<PQT_Master_Data__c>>();
        
        for (PQT_Master_Data__c matrix : masterApprovalMatrix){
            
            if (matrixMap.get(matrix.RecordType.Name) != null){
                List<PQT_Master_Data__c> existingRecords = matrixMap.get(matrix.RecordType.Name);
                existingRecords.add(matrix);
                matrixMap.put(matrix.RecordType.Name, existingRecords);
            } else{
                matrixMap.put(matrix.RecordType.Name, new List<PQT_Master_Data__c>{matrix});
            }
        }
        
        
        //check if account is key account.
        /*	if (quotation.PQT_Customer__r.Key_Account__c){
//get Key account region matrix details

for (PQT_Master_Data__c keyMatrix : matrixMap.get('Region Approval Matrix')){
if (keyMatrix.PQT_Region__c == 'Key Accounts'){
System.debug('Key Account selected' + keyMatrix);
selectedMatrix = keyMatrix;
return selectedMatrix;
}
}
} else{ */
        //Perform user based search
        
        for (PQT_Master_Data__c userMatrix : matrixMap.get('User Approval Matrix')){
            
            if (userMatrix.PQT_User_Approval_Matrix_User__c == quoteOwner){
                System.debug('userMatrix selected' + userMatrix);
                selectedMatrix = userMatrix;
                return selectedMatrix;
            }
        }
        
        //Perform region based search
        for (PQT_Master_Data__c regionMatrix : matrixMap.get('Region Approval Matrix')){
            if (regionMatrix.PQT_Region__c == quotation.PQT_Price_Book__c){
                System.debug('regionMatrix selected' + regionMatrix);
                selectedMatrix = regionMatrix;
                return selectedMatrix;
            }
        }
        //}
        
        
        return selectedMatrix;
    }
    
    public static void manualShareEdit(Id recordId, List<Id> userOrGroupIds){
        
        //Remove existing shares
        List<PQT_Quotation__Share> existingQuoteShareList = [SELECT AccessLevel,Id,ParentId,RowCause,UserOrGroupId 
                                                             FROM PQT_Quotation__Share WHERE ParentId=:recordId ];
        
        List<Database.DeleteResult> delResultList = Database.delete(existingQuoteShareList,false);
        
        //Share given records
        List<PQT_Quotation__Share> quoteShareList  = new List<PQT_Quotation__Share>();
        
        for(Id userOrGroupId : userOrGroupIds){
            
            PQT_Quotation__Share quoteShare  = new PQT_Quotation__Share();
            quoteShare.ParentId = recordId;
            quoteShare.UserOrGroupId = userOrGroupId;
            quoteShare.AccessLevel = 'Edit';
            quoteShare.RowCause = Schema.PQT_Quotation__Share.RowCause.Manual;
            
            quoteShareList.add(quoteShare);  
        }
        
        List<Database.SaveResult> resultList = Database.insert(quoteShareList,false);
        
        /*
if(sr.isSuccess()){

//return true;
}
else {

Database.Error err = sr.getErrors()[0];

// Check if the error is related to trival access level.
// Access level must be more permissive than the object's default.
// These sharing records are not required and thus an insert exception is acceptable. 
if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  && err.getMessage().contains('AccessLevel')){
//return true;
}
else{
//return false;
}
}
*/
        
        
    }
    
    public Static String formattedCurrencyString(String format,String value){
        String finalformattedValue='';
        
        String actualValue=value;
        String actualFirstPart=actualValue.subString(0,actualValue.length()-3);
        String actualSecondPart=actualValue.subString(actualValue.length()-2,actualValue.length());
        Boolean containsNegative=false;
        
        if(actualValue.subString(0,1)=='-'&&actualFirstPart.length()>1)
        {
            containsNegative=true;
            actualFirstPart=actualValue.subString(0+1,actualValue.length()-3);
        }

        
        Integer loopcounter=0;
        String formattedValue='';
        for(Integer i=actualFirstPart.length();i>0;i--)
        {
            loopcounter=loopcounter+1;
            formattedValue=actualFirstPart.subString(i-1,i)+formattedValue;
            system.debug(actualFirstPart.subString(i-1,i));
            if(actualFirstPart.length()>3)
            {
                if(loopcounter==3&&(format=='INR - 9,99,999.00'||format=='USD - 999,999.00'))
                {
                    formattedValue=','+formattedValue; 
                }
                else if(loopcounter==3&&format=='EUR - 999.999,00')
                {
                    formattedValue='.'+formattedValue; 
                }
                else if(loopcounter>3&&math.mod(loopcounter,2)==1&&format=='INR - 9,99,999.00')
                {
                    formattedValue=','+formattedValue;  
                }
                else if(loopcounter>3&&math.mod(loopcounter,3)==0&&format=='EUR - 999.999,00')
                {
                    formattedValue='.'+formattedValue; 
                }
                else if(loopcounter>3&&math.mod(loopcounter,3)==0&&format=='USD - 999,999.00')
                {
                    formattedValue=','+formattedValue;  
                }
            }
            else
            {
                formattedValue=actualFirstPart;  
            }
        }
        
        if(formattedValue.subString(0,1)==','||formattedValue.subString(0,1)=='.') formattedValue=formattedValue.subString(1,formattedValue.length());
		
        if(containsNegative) formattedValue='-'+formattedValue;
        
        If(format=='INR - 9,99,999.00' || format=='USD - 999,999.00') finalformattedValue=formattedValue+'.'+actualSecondPart;
        else if(format=='EUR - 999.999,00')  finalformattedValue=formattedValue+','+actualSecondPart;
          
        
        system.debug(formattedValue);
        
        return finalformattedValue;
    }

    /**
    * @ author       :  Ankit C
    * @ description  :  This method is used to get the record type of a object
    * @ params       :  strObjectName - Object Name where the record types exist
    * @ return       :  Returns map of record type Ids by their Names of that particular object.
    **/
    public static Map<String, Id> getRecordTypeDeveloperNameIdMap(String strObjectName) {
        Schema.DescribeSObjectResult objDescribeSObjectResult = Schema.getGlobalDescribe().get(strObjectName).getDescribe();
        Map<String, RecordTypeInfo> map_RecordTypeInfoByName = objDescribeSObjectResult.getRecordTypeInfosByDeveloperName();
        Map<String, Id> map_RecordTypeIdByDeveloperName = new Map<String, Id>();
        for (RecordTypeInfo objRecordTypeInfo : map_RecordTypeInfoByName.values()) {
            map_RecordTypeIdByDeveloperName.put(objRecordTypeInfo.getDeveloperName(), objRecordTypeInfo.getRecordTypeId());
        }
        
        return map_RecordTypeIdByDeveloperName;
    }
     /**
    * @ author       :  Dinesh Chandra
    * @ description  :  This method is used to initialize/insert a DRL_ExceptionLog__c record
    *                   based on the input parameters.
    * @ params       :  strClassName - Class name where exception has occurred
    *                   strMethodName - Method name where exception has occurred
    *                   objException - Exception object
    *                   blnIsInsertMode - if set as true, then the record will be inserted else it won't
    * @ return       :  DRL_ExceptionLog__c - new record which is inserted/initialized.
    **/
    public static DRL_ExceptionLog__c logException(
        String strClassName, 
        String strMethodName, 
        Exception objException, 
        Boolean blnIsInsertMode
    ) {
        DRL_ExceptionLog__c objExceptionLog = new DRL_ExceptionLog__c(
            ClassName__c = strClassName,
            MethodName__c = strMethodName,
            ErrorMessage__c = objException.getMessage(),
            StackTrace__c = objException.getStackTraceString(),
            ExceptionType__c = objException.getTypeName()
        );
        
        if (blnIsInsertMode) {
            Database.insert(objExceptionLog, false);
        }
        
        return objExceptionLog;
    }
    
    /**
    * @ author       :  Dinesh Chandra
    * @ description  :  This method is used to create exception logs from a list of error messages
    *                   from a DML operation.
    * @ params       :  strClassName - Class name where DML exception has occurred
    *                   strMethodName - Method name where DML exception has occurred
    *                   list_ErrorMessages - List of rror message from the DML operation
    **/
    public static void logDMLException(
        String strClassName, 
        String strMethodName, 
        List<String> list_ErrorMessages
    ) {
        List<DRL_ExceptionLog__c> list_ExceptionLogs = new List<DRL_ExceptionLog__c>();
        for (String strErrorMessage : list_ErrorMessages) {
            DRL_ExceptionLog__c objExceptionLog = new DRL_ExceptionLog__c(
                ClassName__c = strClassName,
                MethodName__c = strMethodName,
                ErrorMessage__c = strErrorMessage,
                ExceptionType__c = 'DMLException'
            );
            list_ExceptionLogs.add(objExceptionLog);
        }
        
        Database.insert(list_ExceptionLogs, false);
    }
    
    /**
    * @ author       :  Dinesh Chandra
    * @ description  :  This method is used to process the errors occured in DML operations.
    * @ params       :  list_SaveResults - List of Database.SaveResult records from DML operation
    *                   strOperationType - Type of DML operation
    * @ return       :  list_Errors - List of Error messages from the failed DML operations.
    **/
    public static List<String> processDMLErrors(
        List<Database.SaveResult> list_SaveResults,
        String strOperationType
    ) {
        List<String> list_Errors = new List<String>();
        for (Database.SaveResult objSaveResult : list_SaveResults) {
            if (!objSaveResult.isSuccess()) {
                for (Database.Error objError : objSaveResult.getErrors()) {
                    String strErrorMessage = strOperationType + ' failed for ' + 
                        objSaveResult.getId() + '. Error: ' + objError.getMessage() + 
                        '. Status Code: ' + objError.getStatusCode();
                    list_Errors.add(strErrorMessage);
                }
            }
        }
        
        return list_Errors;
    }
    
    /**
    * @ author       :  Ankit C
    * @ description  :  This method is used to process the errors occured in an upsert operation
    * @ params       :  list_SaveResults - List of Database.UpsertResult records from upsert operation
    *                   strOperationType - Type of DML operation
    * @ return       :  list_Errors - List of Error messages from the failed DML operations.
    **/
    public static List<String> processUpsertResult(List<Database.UpsertResult> list_SaveResults) {
        List<String> list_Errors = new List<String>();
        for (Database.UpsertResult objUpsertResult : list_SaveResults) {
            if (!objUpsertResult.isSuccess()) {
                for (Database.Error objError : objUpsertResult.getErrors()) {
                    String strErrorMessage = 'Upsert failed for ' + 
                        objUpsertResult.getId() + '. Error: ' + objError.getMessage() + 
                        '. Status Code: ' + objError.getStatusCode();
                    list_Errors.add(strErrorMessage);
                }
            }
        }
        
        return list_Errors;
    }

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to return fieldset information in string format
    * @ params       :  strSObjectName - Object Name
    *                   strFieldSetName - FieldSet Name
    * @ return       :  strFieldSet - fieldset objects in JSON string format
    **/
    public static String getFieldSet(String strSObjectName,String strFieldSetName) {
        String strFieldSet = '';
        SObjectType objToken = Schema.getGlobalDescribe().get(strSObjectName);
        Schema.DescribeSObjectResult objDescribe = objToken.getDescribe();
        Map<String, Schema.FieldSet> map_fieldSetNameToFieldSet = objDescribe.fieldSets.getMap();
        if(map_fieldSetNameToFieldSet.containsKey(strFieldSetName))
            for(Schema.FieldSetMember objField : map_fieldSetNameToFieldSet.get(strFieldSetName).getFields()) {
                    
                if(strFieldSet != ''){
                    strFieldSet += ',';
                }
                String jsonPart = '{';
                jsonPart += '"required":"' + (objField.getDBRequired() || objField.getRequired()) + '",';
                jsonPart += '"type":"' + (objField.getType()) + '",';
                jsonPart += '"label":"' + (objField.getLabel()) + '",';
                jsonPart += '"name":"' + objField.getFieldPath() + '"';
                jsonPart += '}';
                strFieldSet += jsonPart;
            }
        return '['+strFieldSet+']';
    }
    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to get the record type name and recordtypeId of a object
    * @ params       :  strObjectName - Object Name where the record types exist
    * @ return       :  Returns map of record type names by their record type Ids of that particular object.
    **/
    public static Map<Id, String> getRecordTypeIdToNameMap(String strObjectName) {
        Schema.DescribeSObjectResult objDescribeSObjectResult = Schema.getGlobalDescribe().get(strObjectName).getDescribe();
        Map<String, RecordTypeInfo> map_RecordTypeInfoByName = objDescribeSObjectResult.getRecordTypeInfosByDeveloperName();
        Map<Id, String> map_RecordTypeIdByDeveloperName = new Map<Id, String>();
        for (RecordTypeInfo objRecordTypeInfo : map_RecordTypeInfoByName.values()) {
                map_RecordTypeIdByDeveloperName.put(objRecordTypeInfo.getRecordTypeId(),objRecordTypeInfo.getName());         
        }        
        return map_RecordTypeIdByDeveloperName;
    }




}