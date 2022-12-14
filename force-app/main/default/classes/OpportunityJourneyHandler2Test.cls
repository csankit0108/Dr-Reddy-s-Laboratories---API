/*******************************************************************************************************
* 
* @ Name            :   OpportunityJourneyHandler2Test
* @ Purpose         :   Test class for OpportunityJourneyHandler2
* @ Author          :   Dinesh Chandra
*
*   Date            |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   12-12-2022      |  dinesh.chandra@absyz.com            |  1.0          |  Initial Version
*******************************************************************************************************/
@isTest
public class OpportunityJourneyHandler2Test {  
    /**
    * @ author       :  Dinesh Chandra
    * @ description  :  This method is used to setup data for testing apex class 'OpportunityJourneyHandler2'
    **/
    public static Boolean blnThrowException = false;
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
    }

    /**
    * @ author       :  Dinesh Chandra
    * @ description  :  This method is used to test the condition.  
    **/
    @isTest
    private static void testOpportunityMethod() {

        Content_Catalog__c objContent = new Content_Catalog__c();
        objContent.Active_Document__c = TRUE;
        objContent.Development_Stage__c = 'Available';
        objContent.Document_Category__c = 'Quality';
        objContent.Document_URL__c ='www.salesforce.com';
        objContent.Name = 'Test';
        objContent.Therapeutic_Category__c = 'Anti-Allergy';
        insert objContent;
        Opportunity objOpportunities = [SELECT Id FROM Opportunity LIMIT 1];
        List<Id> list_Ids = new List<Id>();
        list_Ids.add(objOpportunities.Id);
        Test.startTest();
        OpportunityJourneyHandler2.triggerJourney2(list_Ids);
        OpportunityJourneyHandler2.dummyTest();
        Test.stopTest();
    }

}