/*******************************************************************************************************
* 
* @ Name            :   DRLUtilTest
* @ Purpose         :   Test class for DRLUtil
* @ Author          :   Wafa Shaikh
********************************************************************************************************/

@isTest
public with sharing class DRLUtilTest {
@TestSetup
static void createData() {
    Profile objProfile = [Select Id, Name from Profile where Name ='System Administrator'];
    
   

   User objUser = new DRL_TestUtility.UserBuilder()
    .setFirstName('Test')
    .setLastName('User')
    .setEmail('TestUser@gmail.com')
    .setDefaultGroupNotificationFrequency('D')
    .setDigestFrequency('D')
    .setEmailEncodingKey('ISO-8859-1')
    .setLanguageLocaleKey('en_US')
    .setLocaleSidKey('en_US')
    .setProfileId(objProfile.Id)
    .setTimeZoneSidKey('America/Los_Angeles')
    .setUsername('test2023@gmail.com')
    .setUserPermissionsCallCenterAutoLogin(False)
    .setUserPermissionsMarketingUser(True)
    .setUserPermissionsOfflineUser(False)
    .setAlias('guest')
    .createUser();
    insert objUser; 
    

    Account objAccount = new DRL_TestUtility.AccountBuilder()
    .setName('Test ACC')
    .createAccount();
    insert objAccount;
    
    Contact objContact = new DRL_TestUtility.ContactBuilder()
    .setFirstName('TEST')
    .setLastName('Contact')
    .setAccountId(objAccount.Id)
    .createContact();
    insert objContact;

     
    PQT_Quotation__c objPQTQuote = new DRL_TestUtility.PQTQuotationBuilder()
    .setCustomerId(objAccount.Id)
    .setContactId(objContact.Id)
    .setRegion('Japan')
    .setOwerId(objUser.Id)
    //.strCurrency('EUR')
    .createPQTQuotation();
    insert objPQTQuote;

   
    

   Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('PQT_Master_Data__c');
   system.debug('map ' + map_RecordTypeIdByDeveloperName );
    PQT_Master_Data__c objPQTMasterData= new DRL_TestUtility.PQTMasterDataBuilder()
     .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('User_Approval_Matrix')) 
    .setPQTL1ApproverName(objUser.Id)
    .setPQTL1BApproverName(objUser.Id)
    .setPQTL2ApproverName(objUser.Id)
    .setPQTL3ApproverName(objUser.Id)
    .setPQTL4ApproverName(objUser.Id)
    .setPQTL3BFinanceBUHeadName(objUser.Id)
    .setPQTPlantName('Test Plant')
    .createPQTMasterData();
     Insert objPQTMasterData;

     PQT_Master_Data__c objPQTMasterData1= new DRL_TestUtility.PQTMasterDataBuilder()
     .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('Region_Approval_Matrix')) 
    .setPQTL1ApproverName(objUser.Id)
    .setPQTL1BApproverName(objUser.Id)
    .setPQTL2ApproverName(objUser.Id)
    .setPQTL3ApproverName(objUser.Id)
    .setPQTL4ApproverName(objUser.Id)
    .setPQTL3BFinanceBUHeadName(objUser.Id)
    .setPQTPlantName('Test Plant')
    .createPQTMasterData();
     Insert objPQTMasterData1;

     DRL_ExceptionLog__c objExceptionLog = new DRL_TestUtility.ExceptionLogBuilder()
     //.setClassName('DRL_LeadTriggerHelper')
     .setExceptionType('System.NullPointerException')
     .createExceptionLog();
     insert objExceptionLog;
     

}

@isTest
private static void getApprovalMatrix() {
    Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('PQT_Master_Data__c');
    List<PQT_Master_Data__c> newList = [SELECT Id,
                                       PQT_Plant_Name__c,
                                       PQT_L1_Approver__c
                                        FROM PQT_Master_Data__c
                                        WHERE PQT_Plant_Name__c = 'Test Plant'  ] ;
                                            
                                        System.assert(!newList.isEmpty(), 'List is empty');
    PQT_Quotation__c objPQTQoutation = [SELECT Id,
                                       PQT_Price_Book__c,
                                       OwnerId
                                       FROM PQT_Quotation__c
                                       WHERE PQT_Price_Book__c = 'Japan'];                           

   test.startTest();

   DRLUtil.getApprovalMatrix(objPQTQoutation);

   test.stopTest(); 

}

@isTest
private static void formattedCurrencyString() { 
   test.startTest();
   DRLUtil.formattedCurrencyString('INR - 9,99,999.00','99999.00');
    DRLUtil.formattedCurrencyString('EUR - 999.999,00','99999.00'); 
    DRLUtil.formattedCurrencyString('USD - 999.999,00','99999.00'); 
    DRLUtil.formattedCurrencyString('USD - 999.999,00','-99999.00'); 
    test.stopTest();
    
}

@isTest
private static void logDMLException() {  
    List<String> list_ErrorMessages = new List<String> {'Attempt to de-reference a null object','Script-thrown exception'};
   test.startTest();
   DRLUtil.logDMLException('DRL_LeadTriggerHelper','processAfterInsert',list_ErrorMessages);
    test.stopTest();
    
}
@isTest
private static void logException() {  
    Account objAccount = new Account();
    DRL_ExceptionLog__c objExceptionLog = new DRL_ExceptionLog__c();
        Test.startTest();
        try {
            // This DML will fail as Name is required.
            insert objAccount;
        } catch (Exception objException) {
            objExceptionLog = DRLUtil.logException(
                'DRL_LeadTriggerHelper',
                'processAfterInsert',
                objException,
                true
            );
        }
        Test.stopTest();
  }
  @isTest
private static void getRecordTypeIdToNameMap( ) { 
    Test.startTest();
    DRLUtil.getRecordTypeIdToNameMap('Lead');
    Test.stopTest();

}
@isTest
private static void getFieldSet( ) { 
    Test.startTest();
    DRLUtil.getFieldSet('Account','LeadConvertFields');

    Test.stopTest();

}
@IsTest
    private static void testLogDMLException() {
        List<Account> list_Accounts = new List<Account>();
        list_Accounts.add(new Account());
        DRL_ExceptionLog__c objExceptionLog = new DRL_ExceptionLog__c();
        Test.startTest();
        List<Database.SaveResult> list_SaveResults = Database.insert(list_Accounts, false);
        List<String> list_Errors = DRLUtil.processDMLErrors(list_SaveResults, 'Insert');
        DRLUtil.logDMLException(
            'DRL_LeadTriggerHelper',
            'processAfterInsert',
            list_Errors
        );

        Test.stopTest();
        
    }
    @IsTest
    private static void processUpsertResult() {
       List<Account> list_Accounts = new List<Account>();
        list_Accounts.add(new Account());
        DRL_ExceptionLog__c objExceptionLog = new DRL_ExceptionLog__c();
        Test.startTest();
        List<Database.UpsertResult> list_SaveResults = Database.upsert(list_Accounts, false);
        List<String> list_Errors = DRLUtil.processUpsertResult(list_SaveResults); 
        DRLUtil.logDMLException(
            'DRL_LeadTriggerHelper',
            'processAfterInsert',
            list_Errors
        );
        Test.stopTest();
        
}
}