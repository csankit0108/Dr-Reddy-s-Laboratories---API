/*******************************************************************************************************
*  
* @ Name            :   DRL_CampaignInfluenceHelperTest
* @ Purpose         :   Test class for DRL_CampaignInfluenceAttributesHelper
* @ Author          :   Dinesh Chandra
*
*   Date            |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   15-11-2022      |  dinesh.chandra@absyz.com            |  1.0          |  Initial Version
*******************************************************************************************************/
@isTest
public class DRL_CampaignInfluenceHelperTest {
    /**
    * @ author       :  Dinesh Chandra
    * @ description  :  This method is used to setup data for testing apex class 'DRL_CampaignInfluenceAttributesHelper'
    **/
    public static Boolean blnThrowException = false;
    @TestSetup
    static void createData() { 
    Campaign objCampaign = new DRL_TestUtility.CampaignBuilder()
        .setCampaignName('Test Campaign')
        .setAllowMassEmail('No')
        .setDescription('Test Campaign Description')
        .setIsActive(true)
        .createCampaign();
    insert objCampaign;
     
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

    Opportunity objOpportunity = new DRL_TestUtility.OpportunityBuilder()
        .setName('Test Opportunity')
        .setAccountId(objAccount.Id)
        .setContactId(objContact.Id)
        .setProductId(objProduct.Id)
        .setStageName('Discussion')
        .setCloseDate(System.today())
        .setPriceAtLaunch(1000)
        .setQuantityAtLaunch(10)
        .setLaunchYear('2000')
        .setSourceType('Primary Source')
        .createOpportunity();
    insert objOpportunity;
    }

    /**
    * @ author       :  Dinesh Chandra
    * @ description  :  This method is used to test the condition - Insert CampaignInfluence Record.  
    **/
    @isTest
    private static void testCampaignMethod() {
        Campaign objCampaign = [SELECT Id FROM Campaign LIMIT 1];
        Opportunity objOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        CampaignInfluenceModel objCampaignInfluenceModel = [SELECT Id,IsActive FROM CampaignInfluenceModel WHERE IsActive = true LIMIT 1];
        CampaignInfluence objCampaignInfluence = new DRL_TestUtility.CampaignInfluenceBuilder()
            .setCampaignId(objCampaign.Id)
            .setOpportunityId(objOpportunity.Id)
            .setInfluence(40.00)
            .setModelId(objCampaignInfluenceModel.Id)
            .createCampaignInfluence();
        Test.startTest();
        insert objCampaignInfluence;
        Test.stopTest();
    }

     /**
    * @ author       :  Dinesh Chandra
    * @ description  :  Test method to cover catch blocks
    **/
    @isTest
    static void testExceptions() {
        Campaign objCampaign = [SELECT Id FROM Campaign LIMIT 1];
        Opportunity objOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        CampaignInfluenceModel objCampaignInfluenceModel = [SELECT Id,IsActive FROM CampaignInfluenceModel WHERE IsActive = true LIMIT 1];
        CampaignInfluence objCampaignInfluence = new DRL_TestUtility.CampaignInfluenceBuilder()
            .setCampaignId(objCampaign.Id)
            .setOpportunityId(objOpportunity.Id)
            .setInfluence(40.00)
            .setModelId(objCampaignInfluenceModel.Id)
            .createCampaignInfluence();
        Test.startTest();
        blnThrowException = true;
        insert objCampaignInfluence;
        Test.stopTest();
    }
}
