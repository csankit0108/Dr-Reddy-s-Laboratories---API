/*******************************************************************************************************
* 
* @ Name            :   DRL_OpportunityTriggerHelperTest
* @ Purpose         :   Test class for DRL_OpportunityTriggerHelper
* @ Author          :   Deeksha Suvarna
*
*   Date            |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   24-11-2022      |  deeksha.suvarna@absyz.com            |  1.0          |  Initial Version
*******************************************************************************************************/
@isTest
public class DRL_OpportunityTriggerHelperTest {
    public static Boolean blnThrowException = false;
    public static String strModelDeveloperName = Label.CLDRL00001;
    
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
        
        Campaign objCampaign1 = new DRL_TestUtility.CampaignBuilder()
            .setCampaignName('Test Campaign1')
            .setAllowMassEmail('No')
            .setDescription('Test Campaign Description')
            .setCampaignCode('Campaign 1006')
            .setIsActive(true)
            .createCampaign();
        insert objCampaign1;
        
        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
        Lead objLead = new DRL_TestUtility.LeadBuilder()
            .setFirstName('Test')
            .setLastName('User')
            .setEmail('testuser@yopmail.com')
            .setCompany('Absyz')
            .setStatus('Open')
            .setCountry('India')
            .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('DRL_Lead'))
            .setSouceCampaignId(objCampaign1.Id) 
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
        Lead objLead = [SELECT 
                        ID 
                        FROM Lead 
                        LIMIT 1];
        
        Product2 objProduct = [SELECT 
                               Id 
                               FROM Product2 
                               LIMIT 1];
        
        Contact objContact = [SELECT 
                              Id, 
                              AccountId 
                              FROM Contact 
                              LIMIT 1];
        
        Campaign objCampaign = [SELECT 
                                Id 
                                FROM Campaign 
                                LIMIT 1];
        
        Campaign objCampaign1 = [SELECT 
                                 Id 
                                 FROM Campaign 
                                 LIMIT 1];
        
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
        CampaignInfluenceModel objCampaignInfluenceModel = [SELECT 
                                                            Id,
                                                            DeveloperName 
                                                            FROM CampaignInfluenceModel 
                                                            WHERE DeveloperName = :strModelDeveloperName];
        
        List<CampaignInfluence> list_CampaignInfluenceWhenStageSample = [SELECT 
                                                                         OpportunityId,
                                                                         ContactId,
                                                                         ModelId,
                                                                         CampaignId,
                                                                         Influence
                                                                         FROM CampaignInfluence 
                                                                         WHERE OpportunityId =: objOpportunity.Id
                                                                         AND ModelId =: objCampaignInfluenceModel.Id
                                                                         AND CampaignId=:objCampaign.Id];
        
        System.assertEquals(55, list_CampaignInfluenceWhenStageSample[0].Influence);
        DRL_OpportunityTriggerHelper.blnSkipOpportunityTrigger =false;
        
        objOpportunity.StageName = 'Planning';
        update objOpportunity;
        
        CampaignInfluence objCampaignInfluenceWhenStagePlanning = [SELECT 
                                                                   OpportunityId,
                                                                   ContactId,
                                                                   ModelId,
                                                                   CampaignId,
                                                                   Influence
                                                                   FROM CampaignInfluence 
                                                                   WHERE OpportunityId =: objOpportunity.Id
                                                                   AND ModelId =: objCampaignInfluenceModel.Id
                                                                   LIMIT 1];
        
        System.assertEquals(80, objCampaignInfluenceWhenStagePlanning.Influence);
        Test.stopTest();   
    }
    
    /**
* @ author       :  Deeksha
* @ description  :  This method is used to test the method to Calculate Influence Percentage in 'DRL_OpportunityTriggerHelper'
**/
    @isTest
    private static void testCalculateInfluenceCase2() {
        Lead objLead = [SELECT 
                        ID 
                        FROM Lead 
                        LIMIT 1];
        
        Product2 objProduct = [SELECT 
                               Id 
                               FROM Product2 
                               LIMIT 1];
        
        Contact objContact = [SELECT 
                              Id, 
                              AccountId 
                              FROM Contact 
                              LIMIT 1];
        
        Campaign objCampaign = [SELECT 
                                Id 
                                FROM Campaign 
                                LIMIT 1];
        
        Campaign objCampaign1 = [SELECT 
                                 Id 
                                 FROM Campaign 
                                 LIMIT 1];
        
        Opportunity objOpportunity = new DRL_TestUtility.OpportunityBuilder()
            .setName('Test Opportunity1')
            .setAccountId(objContact.AccountId)
            .setContactId(objContact.Id)
            .setProductId(objProduct.Id)
            .setStageName('Planning')
            .setCloseDate(System.today())
            .setPriceAtLaunch(1000)
            .setQuantityAtLaunch(10)
            .setLeadId(objLead.Id)
            .setLaunchYear('2000')
            .setSourceType('Primary Source')
            .createOpportunity();
        
        Test.startTest();
        insert objOpportunity;
        CampaignInfluenceModel objCampaignInfluenceModel = [SELECT 
                                                            Id,
                                                            DeveloperName 
                                                            FROM CampaignInfluenceModel 
                                                            WHERE DeveloperName = :strModelDeveloperName];
        
        List<CampaignInfluence> list_CampaignInfluenceWhenStagePlanning = [SELECT 
                                                                           OpportunityId,
                                                                           ContactId,
                                                                           ModelId,
                                                                           CampaignId,
                                                                           Influence
                                                                           FROM CampaignInfluence 
                                                                           WHERE OpportunityId =: objOpportunity.Id
                                                                           AND ModelId =: objCampaignInfluenceModel.Id
                                                                           AND CampaignId=:objCampaign1.Id];
        
        System.assertEquals(80, list_CampaignInfluenceWhenStagePlanning[0].Influence);
        Test.stopTest();   
    }
    
    /**
* @ author       :  Deeksha
* @ description  :  This method is used to test the method to Calculate Influence Percentage in 'DRL_OpportunityTriggerHelper'
**/
    @isTest
    private static void testCalculateInfluenceCase3() {
        Lead objLead = [SELECT 
                        ID 
                        FROM Lead 
                        LIMIT 1];
        
        Product2 objProduct = [SELECT 
                               Id 
                               FROM Product2 
                               LIMIT 1];
        
        Contact objContact = [SELECT 
                              Id, 
                              AccountId 
                              FROM Contact 
                              LIMIT 1];
        
        Campaign objCampaign = [SELECT 
                                Id 
                                FROM Campaign 
                                LIMIT 1];
        
        Campaign objCampaign1 = [SELECT 
                                 Id 
                                 FROM Campaign 
                                 LIMIT 1];
        
        Opportunity objOpportunity = new DRL_TestUtility.OpportunityBuilder()
            .setName('Test Opportunity1')
            .setAccountId(objContact.AccountId)
            .setContactId(objContact.Id)
            .setProductId(objProduct.Id)
            .setStageName('Lead Generation')
            .setCloseDate(System.today())
            .setPriceAtLaunch(1000)
            .setQuantityAtLaunch(10)
            .setLeadId(objLead.Id)
            .setLaunchYear('2000')
            .setSourceType('Primary Source')
            .createOpportunity();
        
        Test.startTest();
        insert objOpportunity;
        CampaignInfluenceModel objCampaignInfluenceModel = [SELECT 
                                                            Id,
                                                            DeveloperName 
                                                            FROM CampaignInfluenceModel 
                                                            WHERE DeveloperName = :strModelDeveloperName];
        
        List<CampaignInfluence> list_CampaignInfluenceWhenStageDiscussion = [SELECT 
                                                                             OpportunityId,
                                                                             ContactId,
                                                                             ModelId,
                                                                             CampaignId,
                                                                             Influence
                                                                             FROM CampaignInfluence 
                                                                             WHERE OpportunityId =: objOpportunity.Id
                                                                             AND ModelId =: objCampaignInfluenceModel.Id
                                                                             AND CampaignId=:objCampaign1.Id];
        
        System.assertEquals(10, list_CampaignInfluenceWhenStageDiscussion[0].Influence);
        DRL_OpportunityTriggerHelper.blnSkipOpportunityTrigger =false;
        objOpportunity.StageName = 'Development';
        update objOpportunity;
        
        CampaignInfluence objCampaignInfluenceWhenStageDevelopment = [SELECT 
                                                                      OpportunityId,
                                                                      ContactId,
                                                                      ModelId,
                                                                      CampaignId,
                                                                      Influence
                                                                      FROM CampaignInfluence 
                                                                      WHERE OpportunityId =: objOpportunity.Id
                                                                      AND ModelId =: objCampaignInfluenceModel.Id
                                                                      AND CampaignId =:objCampaign.Id
                                                                      LIMIT 1];
        
        System.assertEquals(80, objCampaignInfluenceWhenStageDevelopment.Influence);
        Test.stopTest();   
    }
    
    
    /**
* @ author       :  Deeksha Suvarna
* @ description  :  Test method to cover catch blocks
**/
    @isTest
    static void testExceptions() {
        Lead objLead = [SELECT 
                        ID 
                        FROM Lead 
                        LIMIT 1];
        
        Product2 objProduct = [SELECT 
                               Id 
                               FROM Product2 
                               LIMIT 1];
        
        Contact objContact = [SELECT 
                              Id, 
                              AccountId 
                              FROM Contact 
                              LIMIT 1];
        
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
    
    /**
* @ author       :  Subhodeep Sarkar
* @ description  :  This method is used to test  'campaignInfluenceAttributes.apxt'
**/
    
    @isTest
    static void testCampaignInfluenceAttributes(){
        
        Lead objLead = [SELECT 
                        ID, Email
                        FROM Lead 
                        LIMIT 1];
        
        
        Campaign objCampaign = [SELECT 
                                Id 
                                FROM Campaign 
                                LIMIT 1];
        
        Contact objContact = [SELECT 
                              Id, 
                              AccountId,Email
                              FROM Contact 
                              LIMIT 1];
        
        
        Product2 objProduct = [SELECT 
                               Id 
                               FROM Product2 
                               LIMIT 1];
        
        CampaignInfluenceModel objCampaignInfluenceModel = [SELECT 
                                                            Id,
                                                            DeveloperName 
                                                            FROM CampaignInfluenceModel 
                                                            WHERE DeveloperName = :strModelDeveloperName];
        
        
        
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
        
        insert objOpportunity;
        
        caseStaticVars.allowInfluenceInTrigger = true;
        CampaignInfluence objCampaignInfluence = new DRL_TestUtility.CampaignInfluenceBuilder()
            .setCampaignId(objCampaign.Id)
            .setOpportunityId(objOpportunity.Id)
            .setInfluence(2.00)
            .setModelId(objCampaignInfluenceModel.Id)
            .createCampaignInfluence();
        insert objCampaignInfluence;     
                
        caseStaticVars.allowInfluenceInTrigger = true;
        objCampaignInfluence.Pardot_Campaign_Status__c = 'Opened';
        update objCampaignInfluence;



    }
    
     /**
* @ author       :  Subhodeep Sarkar
* @ description  :  This method is used to test  'leadContentUpdate.apxt'
**/
    
     @isTest
    static void testLeadContentUpdate(){

        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
        
         Campaign objCampaign1 = [SELECT 
                                Id 
                                FROM Campaign 
                                LIMIT 1];

        Lead objLead1 = new DRL_TestUtility.LeadBuilder()
            .setFirstName('Test')
            .setLastName('User')
            .setEmail('testuser2@yopmail.com')
            .setCompany('Absyz')
            .setStatus('Open')
            .setCountry('India')
            .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('DRL_Lead'))
            .setSouceCampaignId(objCampaign1.Id) 
            .createLead();
        insert objLead1;

        Lead objLead2= new DRL_TestUtility.LeadBuilder()
            .setFirstName('Test')
            .setLastName('User')
            .setEmail('testuser@yopmail.com')
            .setCompany('Absyz')
            .setStatus('Open')
            .setCountry('India')
            .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('DRL_Lead'))
            .setSouceCampaignId(objCampaign1.Id) 
            .createLead();
        insert objLead2;
        
        Contact objContact = [SELECT 
                              Id, 
                              AccountId,Email
                              FROM Contact 
                              LIMIT 1];
        
        Test.startTest();
        Lead2Contact__c objLeadContact = new Lead2Contact__c();
        objLeadContact.Lead__c = objLead1.Id;
        objLeadContact.Contact__c = objContact.Id;
        insert objLeadContact;
        
        Lead2Contact__c objLeadContact1 = new Lead2Contact__c();
        objLeadContact1.Lead__c = objLead2.Id;
        objLeadContact1.Contact__c = objContact.Id;
        insert objLeadContact1;
        
        objLead1.Status = 'Unqualified';
        update objLead1;
        
        objLead2.Status = 'Unqualified';
        update objLead2;
        Test.stopTest();

    }
}