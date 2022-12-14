/*******************************************************************************************************
* 
* @ Name            :   AccountTeamAccessHelperTest
* @ Purpose         :   Test class for AccountTeamAccessHelper
* @ Author          :   Dinesh Chandra
*
*   Date            |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   12-12-2022      |  dinesh.chandra@absyz.com            |  1.0          |  Initial Version
*******************************************************************************************************/
@isTest
public class AccountTeamAccessHelperTest {
    /**
    * @ author       :  Dinesh Chandra
    * @ description  :  This method is used to setup data for testing apex class 'AccountTeamAccessHelper'
    **/
    @TestSetup
    static void createData() {  
        
        Account objAccount = new DRL_TestUtility.AccountBuilder()
            .setName('Test Account')
            .createAccount();
        insert objAccount;
            
        Opportunity objOpportunity = new DRL_TestUtility.OpportunityBuilder()
            .setName('Test Opportunity')
            .setAccountId(objAccount.Id)
            .setStageName('Discussion')
            .setCloseDate(System.today())
            .setPriceAtLaunch(1000)
            .setQuantityAtLaunch(10)
            .setLaunchYear('2000')
            .setSourceType('Primary Source')
            .createOpportunity();
        insert objOpportunity;

        Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

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

        Account_Team__c objAccountTeam = new DRL_TestUtility.AccountTeamBuilder()
            .setAccountAccess('Read/Write')
            .setMomAccess('Read/Write')
            .setOpportunityAccess('Read/Write')
            .setUserId(objUser.Id)
            .setAccountId(objAccount.Id)
            .createAccountTeam();
        insert objAccountTeam;

        Minutes_Of_Meeting__c objMom = new DRL_TestUtility.MomBuilder()
            .setAccountId(objAccount.Id)
            .setMomDate(System.today())
            .createMom();
        insert objMom;

}
 
    /**
    * @ author       :  Dinesh Chandra
    * @ description  :  This method is used to test the condition.  
    **/
    @isTest
    private static void testAccountTeamMethod() {
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        String strAccountId = objAccount.Id;
        Test.startTest();
        AccountTeamAccessHelper.accountTeamAccess(strAccountId);
        Test.stopTest();
    }
}