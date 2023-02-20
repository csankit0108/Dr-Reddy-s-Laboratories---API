/*******************************************************************************************************
* 
* @ Name            :   DRLUtilTest
* @ Purpose         :   Test class for DRLUtil
* @ Author          :   Wafa Shaikh
********************************************************************************************************/
@isTest
public class DRLUtilTest {
    /**
    * @ author       :  Wafa
    * @ description  :  Method to create test data 
    **/
    @TestSetup
    static void createData() {
        Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];

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
            .setUsername('test2023@test.drl.com')
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
            .createPQTQuotation();
        insert objPQTQuote;

        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('PQT_Master_Data__c');
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
        insert objPQTMasterData;
        
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
        insert objPQTMasterData1;        
    }
    
    /**
    * @ author       :  Wafa
    * @ description  :  Test method for getApprovalMatrix() 
    **/
    @isTest
    private static void testGetApprovalMatrix() {
        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('PQT_Master_Data__c');
        List<PQT_Master_Data__c> newList = [SELECT Id,
                                            PQT_Plant_Name__c,
                                            PQT_L1_Approver__c
                                            FROM PQT_Master_Data__c
                                            WHERE PQT_Plant_Name__c = 'Test Plant'] ;
        
        System.assert(!newList.isEmpty(), 'List is empty');
        PQT_Quotation__c objPQTQoutation = [SELECT Id,
                                            PQT_Price_Book__c,
                                            OwnerId
                                            FROM PQT_Quotation__c
                                            WHERE PQT_Price_Book__c = 'Japan'];                           
        
        Test.startTest();
        DRLUtil.getApprovalMatrix(objPQTQoutation);
        Test.stopTest(); 
    }
    
    /**
    * @ author       :  Wafa
    * @ description  :  Test method for formattedCurrencyString() 
    **/
    @isTest
    private static void testFormattedCurrencyString() { 
        Test.startTest();
        DRLUtil.formattedCurrencyString('INR - 9,99,999.00','99999.00');
        DRLUtil.formattedCurrencyString('EUR - 999.999,00','99999.00'); 
        DRLUtil.formattedCurrencyString('USD - 999.999,00','99999.00'); 
        DRLUtil.formattedCurrencyString('USD - 999.999,00','-99999.00'); 
        Test.stopTest();
    }
    
    /**
    * @ author       :  Wafa
    * @ description  :  Test method for logDMLException() 
    **/
    @isTest
    private static void testLogDMLException() {  
        List<String> list_ErrorMessages = new List<String> {'Attempt to de-reference a null object','Script-thrown exception'};
        Test.startTest();
        DRLUtil.logDMLException('DRL_LeadTriggerHelper','processAfterInsert',list_ErrorMessages);
        Test.stopTest();
    }

    /**
    * @ author       :  Wafa
    * @ description  :  Test method for logException() 
    **/
    @isTest
    private static void testLogException() {  
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

    /**
    * @ author       :  Wafa
    * @ description  :  Test method for getRecordTypeIdToNameMap() 
    **/
    @isTest
    private static void testGetRecordTypeIdToNameMap( ) { 
        Test.startTest();
        DRLUtil.getRecordTypeIdToNameMap('Lead');
        Test.stopTest();
    }

    /**
    * @ author       :  Wafa
    * @ description  :  Test method for getFieldSet() 
    **/
    @isTest
    private static void testGetFieldSet( ) { 
        Test.startTest();
        DRLUtil.getFieldSet('Account','LeadConvertFields');
        Test.stopTest();
    }

    /**
    * @ author       :  Wafa
    * @ description  :  Test method for testLogDMLException() 
    **/
    @IsTest
    private static void testLogDMLException2() {
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

    /**
    * @ author       :  Wafa
    * @ description  :  Test method for processUpsertResult() 
    **/
    @IsTest
    private static void testProcessUpsertResult() {
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

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  Test method for processDeleteResult() 
    **/
    @IsTest
    private static void testProcessDeleteResult() {
        List<Account> list_Accounts = [SELECT Id FROM Account WHERE Name = 'Test ACC'];
        delete list_Accounts;
        DRL_ExceptionLog__c objExceptionLog = new DRL_ExceptionLog__c();
        Test.startTest();
        List<Database.DeleteResult> list_SaveResults = Database.delete(list_Accounts, false);
        List<String> list_Errors = DRLUtil.processDeleteResult(list_SaveResults); 
        DRLUtil.logDMLException(
            'DRLUtilTest',
            'testProcessDeleteResult',
            list_Errors
        );
        Test.stopTest();
    }
}