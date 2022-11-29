/*******************************************************************************************************
* 
* @ Name            :   DRL_LeadTriggerHelperTest
* @ Purpose         :   Test class for DRL_LeadTriggerHelper
* @ Author          :   Deeksha Suvarna
*
*   Date            |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   24-11-2022      |  deeksha.suvarna@absyz.com            |  1.0          |  Initial Version
*******************************************************************************************************/
@isTest
public class DRL_OpportunityTriggerHelperTest {
    public static Boolean blnThrowException = false;

    /**
    * @ author       :  Deeksha Suvarna
    * @ description  :  This method is used to setup data for testing class 'DRL_OpportunityTriggerHelper'
    **/
    @TestSetup
    static void createData() {

        Account objAccount = new DRL_TestUtility.AccountBuilder()
            .setName('Test Account')
            .createAccount();
        insert objAccount;

        Contact objContact = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test')
            .setLastName('Contact')
            .setAccountId(objAccount.Id)
            .createContact();
        insert objContact;
        
        Product2 objProduct = new DRL_TestUtility.ProductBuilder()
            .setName('Test Product')
            .createProduct();
        insert objProduct;

        Campaign objCampaign = new DRL_TestUtility.CampaignBuilder()
            .setCampaignName('Test Campaign')
            .setAllowMassEmail('No')
            .setDescription('Test Campaign Description')
            .setCampaignCode('Campaign 1005')
            .setIsActive(true)
            .createCampaign();
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

        CampaignMember objCampaignMember = new DRL_TestUtility.CampaignMemberBuilder()
            .setCampaignId(objCampaign.Id)
            .setContactId(objContact.Id)
            .createCampaignMember();
        insert objCampaignMember;

    }

    /**
    * @ author       :  Deeksha
    * @ description  :  This method is used to test the method to Calculate Influence Percentage in 'DRL_OpportunityTriggerHelper'
    **/
    @isTest
    private static void testCalculateInfluence() {
        Lead objLead = [SELECT ID FROM Lead LIMIT 1];
        Product2 objProduct = [SELECT Id FROM Product2 LIMIT 1];
        Contact objContact = [SELECT Id, AccountId FROM Contact LIMIT 1];
        Opportunity objOpportunity = new DRL_TestUtility.OpportunityBuilder()
            .setName('Test Opportunity1')
            .setAccountId(objContact.AccountId)
            .setContactId(objContact.Id)
            .setProductId(objProduct.Id)
            .setStageName('Sample')
            .setCloseDate(System.today())
            .setPriceAtLaunch(1000)
            .setQuantityAtLaunch(10)
            .setLeadId(objLead.Id)
            .setLaunchYear('2000')
            .setSourceType('Primary Source')
            .createOpportunity();
 
        Test.startTest();
        insert objOpportunity;
        
        CampaignInfluence objCampaignInfluenceWhenStageSample = [SELECT 
                                      OpportunityId,
                                      ContactId,
                                      Influence
                                      FROM CampaignInfluence 
                                      WHERE OpportunityId =: objOpportunity.Id];
        
        System.assertEquals(75, objCampaignInfluenceWhenStageSample.Influence);
        
        objOpportunity.StageName = 'Planning';
        update objOpportunity;
        
        CampaignInfluence objCampaignInfluenceWhenStageDropped = [SELECT 
                                      OpportunityId,
                                      ContactId,
                                      Influence
                                      FROM CampaignInfluence 
                                      WHERE OpportunityId =: objOpportunity.Id];
        
        System.assertEquals(100, objCampaignInfluenceWhenStageDropped.Influence);
        Test.stopTest();   
    }
    
    /**
    * @ author       :  Deeksha Suvarna
    * @ description  :  Test method to cover catch blocks
    **/
    @isTest
    static void testExceptions() {
        Lead objLead = [SELECT ID FROM Lead LIMIT 1];
        Product2 objProduct = [SELECT Id FROM Product2 LIMIT 1];
        Contact objContact = [SELECT Id, AccountId FROM Contact LIMIT 1];
        Opportunity objOpportunity = new DRL_TestUtility.OpportunityBuilder()
            .setName('Test Opportunity1')
            .setAccountId(objContact.AccountId)
            .setContactId(objContact.Id)
            .setProductId(objProduct.Id)
            .setStageName('Sample')
            .setCloseDate(System.today())
            .setPriceAtLaunch(1000)
            .setQuantityAtLaunch(10)
            .setLeadId(objLead.Id)
            .setLaunchYear('2000')
            .setSourceType('Primary Source')
            .createOpportunity();
        Test.startTest();
        blnThrowException = true;
        insert objOpportunity;
        blnThrowException = false;
        Test.stopTest();
    }
}