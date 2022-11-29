/*******************************************************************************************************
* 
* @ Name            :   DRL_LeadTriggerHelperTest
* @ Purpose         :   Test class for DRL_LeadTriggerHelper
* @ Author          :   Deeksha Suvarna
*
*   Date            |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   04-11-2022      |  deeksha.suvarna@absyz.com            |  1.0          |  Initial Version
*   08-11-2022      |  mahalakshmi.sadhanantham@absyz.com   |  1.1          |  Campaign Record Creation
*******************************************************************************************************/
@isTest
public class DRL_OpportunityTriggerHelperTest {

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

        Opportunity objOpportunity = new DRL_TestUtility.OpportunityBuilder()
            .setName('Test Opportunity1')
            .setAccountId(objAccount.Id)
            .setContactId(objContact.Id)
            .setProductId(objProduct.Id)
            .setStageName('Lead Generation')
            .setCloseDate(System.today())
            .setPriceAtLaunch(1000)
            .setQuantityAtLaunch(10)
            .setLaunchYear('2000')
            .setSourceType('Primary Source')
            .createOpportunity();
        insert objOpportunity;
    }

    /**
    * @ author       :  Deeksha
    * @ description  :  This method is used to test the method to Calculate Influence Percentage in 'DRL_OpportunityTriggerHelper'
    **/
    @isTest
    private static void testCalculateInfluence() {
        
   		Opportunity objOpportunity = [SELECT 
                                    Id,
                                    StageName,
                                    Lead_Converted_From__c
                                    FROM Opportunity
                                    WHERE StageName='Lead Generation'];
        
        Test.startTest();
        Decimal decInfluencePercentage = DRL_OpportunityTriggerHelper.CalculateInfluencePercentage(objOpportunity);
        Test.stopTest();
        System.assertEquals(20, decInfluencePercentage);
    }
    
    /**
    * @ author       :  Deeksha
    * @ description  :  This method is used to test the method to Calculate Influence Percentage - when Opportunity stage is beyond Bio Batch Ordered in 'DRL_OpportunityTriggerHelper'
    **/
    @isTest
    private static void testCalculateInfluenceBeyondMetadata() {
        
   		Opportunity objOpportunity = [SELECT 
                                    Id,
                                    StageName,
                                    Lead_Converted_From__c
                                    FROM Opportunity];
        
        objOpportunity.StageName = 'Dropped';
        
        Test.startTest();
        Decimal decInfluencePercentage = DRL_OpportunityTriggerHelper.CalculateInfluencePercentage(objOpportunity);
        Test.stopTest();
        System.assertEquals(100, decInfluencePercentage);
    }

    /**
    * @ author       :  Deeksha
    * @ description  :  This method is used to test the method to Calculate Influence Percentage - when Lead Converted Opportunity stage is selected in 'DRL_OpportunityTriggerHelper'
    **/
    @isTest
    private static void testCalculateInfluenceLeadConvertedOpportunity() {
        Campaign objCampaign = [SELECT 
                                Id
                                FROM Campaign];

        Lead objLead = [SELECT
                        Id,
                        Email,
                        DRL_SourceCampaign__c
                        FROM Lead
                        WHERE Email='testuser@yopmail.com'];
        
        objLead.DRL_SourceCampaign__c = objCampaign.Id;
        update objLead;

        Opportunity objOpportunity = [SELECT 
                                    Id,
                                    StageName,
                                    Lead_Converted_From__c 
                                    FROM Opportunity
                                    WHERE StageName='Lead Generation'];

        objOpportunity.StageName = 'Sample';
        objOpportunity.Lead_Converted_From__c = objLead.Id;
        
        Test.startTest();
        Decimal decInfluencePercentage = DRL_OpportunityTriggerHelper.CalculateInfluencePercentage(objOpportunity);
        Test.stopTest();
        System.assertEquals(75, decInfluencePercentage);
    }
    
    /**
    * @ author       :  Deeksha
    * @ description  :  This method is used to test the method Calculate Influence Percentage - when Lead Converted Opportunity stage is beyond Bio Batch Ordered in 'DRL_OpportunityTriggerHelper'
    **/
    @isTest
    private static void testCalculateInfluenceLeadConvertedOpportunityBeyondMetadata() {
        Campaign objCampaign = [SELECT 
                                Id
                                FROM Campaign];

        Lead objLead = [SELECT
                        Id,
                        Email,
                        DRL_SourceCampaign__c
                        FROM Lead
                        WHERE Email='testuser@yopmail.com'];
        
        objLead.DRL_SourceCampaign__c = objCampaign.Id;
        update objLead;

        Opportunity objOpportunity = [SELECT 
                                    Id,
                                    StageName,
                                    Lead_Converted_From__c 
                                    FROM Opportunity
                                    WHERE StageName='Lead Generation'];

        objOpportunity.StageName = 'Dropped';
        objOpportunity.Lead_Converted_From__c = objLead.Id;
        
        
        Test.startTest();
        Decimal decInfluencePercentage = DRL_OpportunityTriggerHelper.CalculateInfluencePercentage(objOpportunity);
        Test.stopTest();
        System.assertEquals(100, decInfluencePercentage);
    }
}