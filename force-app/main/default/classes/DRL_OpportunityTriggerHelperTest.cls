/*******************************************************************************************************
* 
* @ Name            :   DRL_OpportunityTriggerHelperTest
* @ Purpose         :   Test class for DRL_OpportunityTriggerHelperV2
* @ Author          :   Kishore Pedireddy
*
*   Date            |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   11-02-2023      |  kishore.pedireddy@absyz.com            |  1.0          |  Initial Version
*******************************************************************************************************/
@isTest
public with sharing class DRL_OpportunityTriggerHelperTest {
    //Custom Label with Value 'DRL_APICampaignsDistributionModel'
	public static String strModelDeveloperName = Label.CLDRL00001;
    //Quering the Value of DeveloperName 
	public static CampaignInfluenceModel objCampaignInfluenceModel = [  SELECT 
                                                                        Id,
                                                                        DeveloperName 
                                                                        FROM CampaignInfluenceModel 
                                                                        WHERE DeveloperName = :strModelDeveloperName];
    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to setup data for testing class 'DRL_OpportunityTriggerHelperV2'
    **/
    @TestSetup
    static void createData() {

        Product2 objProduct = new DRL_TestUtility.ProductBuilder()
            .setName('Test Product')
            .createProduct();
        objProduct.ProductCode = '123445';
        insert objProduct;

        Account objAccount = new DRL_TestUtility.AccountBuilder()
            .setName('Test Account')
            .createAccount();
        insert objAccount;

        List<Contact> list_Contacts = new List<Contact>();        
        Contact objContact = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test')
            .setLastName('Contact1')
            .setAccountId(objAccount.Id)
            .createContact();
        objContact.Email = 'testuser1@yopmail.com';
        list_Contacts.add(objContact);
        objContact = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test')
            .setLastName('Contact2')
            .setAccountId(objAccount.Id)
            .createContact();
        objContact.Email = 'testuser2@yopmail.com';
        list_Contacts.add(objContact);
        insert list_Contacts;       

        List<Campaign> list_Campaigns = new List<Campaign>();
        Campaign objCampaign = new DRL_TestUtility.CampaignBuilder()
            .setCampaignName('Test Campaign1')
            .setAllowMassEmail('No')
            .setDescription('Test Campaign Description')
            .setCampaignCode('Campaign 1001')
            .setIsActive(true)
            .createCampaign();
        list_Campaigns.add(objCampaign);
        
        objCampaign = new DRL_TestUtility.CampaignBuilder()
            .setCampaignName('Test Campaign2')
            .setAllowMassEmail('No')
            .setDescription('Test Campaign Description')
            .setCampaignCode('Campaign 1002')
            .setIsActive(true)
            .createCampaign();
        list_Campaigns.add(objCampaign);
        insert list_Campaigns;

        List<CampaignMember> list_CampaignMembers = new List<CampaignMember>();
        CampaignMember objCampaignMember = new DRL_TestUtility.CampaignMemberBuilder()
            .setCampaignId(list_Campaigns[0].Id)
            .setContactId(list_Contacts[0].Id)
            .createCampaignMember();
        objCampaignMember.Status = 'Responded';
        list_CampaignMembers.add(objCampaignMember);
        objCampaignMember = new DRL_TestUtility.CampaignMemberBuilder()
            .setCampaignId(list_Campaigns[1].Id)
            .setContactId(list_Contacts[1].Id)
            .createCampaignMember();
        objCampaignMember.Status = 'Responded';
        list_CampaignMembers.add(objCampaignMember);
        insert list_CampaignMembers;

        Opportunity objOpportunity = new DRL_TestUtility.OpportunityBuilder()
            .setName('Test Opportunity1')
            .setAccountId(objContact.AccountId)
            .setContactId(list_Contacts[0].Id)
            .setProductId(objProduct.Id)
            .setStageName('Lead Generation')
            .setCloseDate(System.today())
            .setPriceAtLaunch(1000)
            .setQuantityAtLaunch(10)
            .setLaunchYear('2000')
            .setSourceType('Primary Source')
            .createOpportunity();
        objOpportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API').getRecordTypeId();
        objOpportunity.Target_Markets__c = 'North Asia';
        objOpportunity.Price__c = 10;
        objOpportunity.TotalOpportunityQuantity = 10;
        insert objOpportunity;
    }

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to test the method to Calculate Influence Percentage in 'DRL_OpportunityTriggerHelper'
    **/
    @isTest
    private static void testCalculateInfluenceCase1() {
        Opportunity objOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        objOpportunity.StageName = 'Bio batch ordered';
        update objOpportunity;
        Decimal decCampaignInfluence =  (decimal)[  SELECT 
                                                    SUM(Influence)sum 
                                                    FROM CampaignInfluence 
                                                    WHERE OpportunityId =:objOpportunity.Id 
                                                    AND ModelId =:objCampaignInfluenceModel.Id
                                                    GROUP BY OpportunityId][0].get('sum');        
        System.assert(decCampaignInfluence==100, 'Campaign Influence updated Incorrectly');
        Test.stopTest();
    }

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to test the method to Calculate Influence Percentage in 'DRL_OpportunityTriggerHelper'
    **/
    @isTest
    private static void testCalculateInfluenceCase2() {
        Opportunity objOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        objOpportunity.StageName = 'Bio batch delivered';
        update objOpportunity;
        Decimal decCampaignInfluence =  (decimal)[  SELECT 
                                                    SUM(Influence)sum 
                                                    FROM CampaignInfluence 
                                                    WHERE OpportunityId =:objOpportunity.Id 
                                                    AND ModelId =:objCampaignInfluenceModel.Id
                                                    GROUP BY OpportunityId][0].get('sum');        
        System.assert(decCampaignInfluence==100, 'Campaign Influence updated Incorrectly');
        Test.stopTest();
    }

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to test the method to Calculate Influence Percentage in 'DRL_OpportunityTriggerHelper'
    **/
    @isTest
    private static void testCalculateInfluenceCase3() {
        Opportunity objOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Campaign objCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign1' LIMIT 1];
        Contact objContact = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test')
            .setLastName('Contact3')
            .setAccountId(objAccount.Id)
            .createContact();
        objContact.Email = 'testuser3@yopmail.com';
        insert objContact;
        OpportunityContactRole objOpportunityContactRole = new OpportunityContactRole();
        objOpportunityContactRole.ContactId = objContact.Id;
        objOpportunityContactRole.Role = 'Influencer';
        objOpportunityContactRole.OpportunityId = objOpportunity.Id;
        insert objOpportunityContactRole;
        CampaignMember objCampaignMember = new DRL_TestUtility.CampaignMemberBuilder()
            .setCampaignId(objCampaign.Id)
            .setContactId(objContact.Id)
            .createCampaignMember();
        objCampaignMember.Status = 'Responded';
        insert objCampaignMember;
        Test.startTest();
        objOpportunity.StageName = 'Discussion';
        update objOpportunity;
        objOpportunity.StageName = 'Bio batch delivered';
        update objOpportunity;
        Decimal decCampaignInfluence =  (decimal)[  SELECT 
                                                    SUM(Influence)sum 
                                                    FROM CampaignInfluence 
                                                    WHERE OpportunityId =:objOpportunity.Id 
                                                    AND ModelId =:objCampaignInfluenceModel.Id
                                                    GROUP BY OpportunityId][0].get('sum');   
        System.assert(decCampaignInfluence==100, 'Campaign Influence updated Incorrectly');
        Test.stopTest();
    }

}