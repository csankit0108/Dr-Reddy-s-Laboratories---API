/*******************************************************************************************************
* 
* @ Name            :   CampaignMemberStatusTest
* @ Purpose         :   Test class for CampaignMemberStatus Trigger
* @ Author          :   Dinesh Chandra
*
*   Date            |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   12-12-2022      |  dinesh.chandra@absyz.com            |  1.0          |  Initial Version
*******************************************************************************************************/
@isTest
public class CampaignMemberStatusTest {
    /**
    * @ author       :  Dinesh Chandra
    * @ description  :  This method is used to setup data for testing apex trigger 'CampaignMemberStatus'
    **/
    public static Boolean blnThrowException = false;
    @TestSetup
    static void createData() {

        Account objAccount = new DRL_TestUtility.AccountBuilder()
            .setName('Test Account')
            .createAccount();
        insert objAccount;

        Account objAccount2 = new DRL_TestUtility.AccountBuilder()
            .setName('Test Account 2')
            .createAccount();
        insert objAccount2;

        Contact objContact = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test')
            .setLastName('Contact')
            .setAccountId(objAccount.Id)
            .createContact();
        insert objContact;

        Contact objContact2 = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test2')
            .setLastName('Contact2')
            .setAccountId(objAccount2.Id)
            .createContact();
        insert objContact2;
            
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
            
        Campaign objCampaign2 = new DRL_TestUtility.CampaignBuilder()
            .setCampaignName('Test Campaign2')
            .setAllowMassEmail('No')
            .setDescription('Test Campaign Description2')
            .setCampaignCode('Campaign 1006')
            .setIsActive(true)
            .createCampaign();
        insert objCampaign2;

        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');

        Lead objLead = new DRL_TestUtility.LeadBuilder()
            .setFirstName('Test')
            .setLastName('User')
            .setEmail('testuser5@yopmail.com')
            .setCompany('Absyz')
            .setUtmCampaign('Campaign 1005')
            .setUtmSource('Test MDT 2')
            .setStatus('Converted')
            .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('DRL_Lead'))
            .setCountry('India')
            .setReasonForDecline('Product Issues')
            .setUtmCampaign('Campaign 1005')
            .setUtmSource('Test MDT 2')
            .setSouceCampaignId(objCampaign.Id)
            .createLead();
        insert objLead;

        Opportunity objOpportunity = new DRL_TestUtility.OpportunityBuilder()
            .setName('Test Opportunity')
            .setAccountId(objAccount.Id)
            .setContactId(objContact.Id)
            .setProductId(objProduct.Id)
            .setStageName('Development')
            .setCloseDate(System.today())
            .setPriceAtLaunch(1000)
            .setQuantityAtLaunch(10)
            .setLaunchYear('2000')
            .setLeadId(objLead.Id)
            .setSourceType('Primary Source')
            .setConvertedContactId(objContact.Id)
            .setOppJourneyContentIds2('testing;')
            .createOpportunity();
        insert objOpportunity;

        CampaignMember objCampaignMember = new DRL_TestUtility.CampaignMemberBuilder()
            .setCampaignId(objCampaign.Id)
            .setContactId(objContact.Id)
            .setPardotStatus('Opened Mail')
            .createCampaignMember();
        insert objCampaignMember;
    }
    
    /**
    * @ author       :  Dinesh Chandra
    * @ description  :  This method is used to test the condition.  
    **/
    @isTest
    private static void testCampaignInfluenceMethod() {
        Campaign objCampaign = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Campaign2' ];
        CampaignMember objCampaignMember = [SELECT Id,ContactId FROM CampaignMember WHERE ContactId != null LIMIT 1];
        Test.startTest();
        update objCampaignMember;
        Test.stopTest();
    }
}