/*******************************************************************************************************
* 
* @ Name            :   DRL_OppContactRoleTriggerHelperTest
* @ Purpose         :   Test class for DRL_OpportunityContactRoleTriggerHelper
* @ Author          :   Mahalakshmi Sadhananthan
*
*   Date            |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   08-02-2023      |  mahalakshmi.sadhanantham@absyz.com   |  1.0          |  Initial Version
*******************************************************************************************************/

@isTest
public class DRL_OppContactRoleTriggerHelperTest {

    @TestSetup
    static void createData() {
        /**
        * @ author       :  Mahalakshmi S
        * @ description  :  This method is used to setup data for testing apex class 'DRL_OpportunityContactRoleTriggerHelper'
        **/
        Account objAccount = new DRL_TestUtility.AccountBuilder()
            .setName('Test Account')
            .createAccount();
        insert objAccount;
        
        Contact objContact = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test')
            .setLastName('Contact')
            .setAccountId(objAccount.Id)
            .createContact();
        objContact.Email = 'testuser@yopmail.com';
        insert objContact;
        
        Product2 objProduct = new DRL_TestUtility.ProductBuilder()
            .setName('Test Product')
            .createProduct();
        objProduct.ProductCode = '123445';
        insert objProduct;
        
        Campaign objCampaign = new DRL_TestUtility.CampaignBuilder()
            .setCampaignName('Test Campaign')
            .setAllowMassEmail('No')
            .setDescription('Test Campaign Description')
            .setCampaignCode('Campaign 1005')
            .setIsActive(true)
            .createCampaign();
        objCampaign.Product__c = objProduct.Id;        
        insert objCampaign;
        
        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
        Lead objLead = new DRL_TestUtility.LeadBuilder()
            .setFirstName('Test')
            .setLastName('User')
            .setEmail('testuser@yopmail.com')
            .setCompany('Absyz')
            .setStatus('Open')
            .setCountry('India')
            .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('DRL_Lead'))
            .setSouceCampaignId(objCampaign.Id) 
            .createLead();
        insert objLead;
        
        Opportunity objOpportunity = new DRL_TestUtility.OpportunityBuilder()
            .setName('Test Opportunity')
            .setAccountId(objAccount.Id)
            .setProductId(objProduct.Id)
            .setStageName('Sample')
            .setCloseDate(System.today())
            .setPriceAtLaunch(1000)
            .setQuantityAtLaunch(10)
            .setLeadId(objLead.Id)
            .setLaunchYear('2000')
            .setSourceType('Primary Source')
            .createOpportunity();
        insert objOpportunity;
        
         OpportunityContactRole OpportunityContactRole = new DRL_TestUtility.OpportunityContactRoleBuilder()
            .setOpportunityId(objOpportunity.Id)
            .setContactId(objContact.Id)
            .createOpportunityContactRole();
        Insert OpportunityContactRole;
        
    }
    /**
    * @ author       :  Mahalakshmi S
    * @ description  :  This method is used to test the condition - Validation to prevent duplicate contacts from being added to the same opportunity  
    **/
    @isTest
    private static void testLeadMethod() {
        Contact objContact = [SELECT 
                              Id
                              FROM Contact 
                              LIMIT 1];
        Opportunity objOpportunity = [SELECT 
                              Id
                              FROM Opportunity 
                              LIMIT 1];
        Test.startTest();
        
        try{
            OpportunityContactRole OpportunityContactRole = new DRL_TestUtility.OpportunityContactRoleBuilder()
            .setOpportunityId(objOpportunity.Id)
            .setContactId(objContact.Id)
            .createOpportunityContactRole();
        Insert OpportunityContactRole;
        }catch(Exception objException) {
            Assert.isTrue(objException.getMessage().contains(System.Label.Contact_Role_Validation_Message),'Trigger Exception Handling');
        }
        Test.stopTest();
    }
    
}