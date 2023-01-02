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
public class DRL_LeadTriggerHelperTest {
    public static Boolean blnThrowExceptionWhileAddingCampaignMember = false;
    public static Boolean blnThrowExceptionWhileAddingProspect = false;
    /**
    * @ author       :  Deeksha Suvarna
    * @ description  :  This method is used to setup data for testing apex class 'DRL_LeadTriggerHelper'
    **/
    @TestSetup
    static void createData() {
        /**
        * @ author       :  Mahalakshmi S
        * @ description  :  This method is used to setup data for testing apex class 'DRL_LeadTriggerHelper'
        **/
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
            .setStatus('Open')
            .setCountry('India')
            .setReasonForDecline('Product Issues')
            .setUtmCampaign('Campaign 1005')
            .setUtmSource('Test_Source_1')
            .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('DRL_Lead'))
            .createLead();
        insert objLead;
    }

    /**
    * @ author       :  Deeksha Suvarna
    * @ description  :  This method is used to test the condition - Prospect does not exist, Child lead record is created.  
    **/
    @isTest
    private static void testLeadMethod() {
        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');

        Lead objLead = new DRL_TestUtility.LeadBuilder()
                .setFirstName('Test')
                .setLastName('Lead')
                .setEmail('testlead@yopmail.com')
                .setCompany('Absyz')
                .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('DRL_Lead'))
                .createLead();
        Test.startTest();
        insert objLead;
        Test.stopTest();

        List<Lead> list_leads = [SELECT 
                                Id,
                                Email
                                FROM Lead
                                WHERE RecordTypeId = :map_RecordTypeIdByDeveloperName.get('DRL_Prospect')];
        System.assert(!list_leads.isEmpty(), 'Prospect was not created!');
    }

    /**
    * @ author       :  Deeksha Suvarna
    * @ description  :  This method is used to test the condition - Prospect exist, Child lead record is created,.  
    **/
    @isTest
    private static void testLeadforExistingProspect() {
        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
        Lead objLead = [SELECT 
                        Id
                        FROM Lead
                        WHERE RecordTypeId = :map_RecordTypeIdByDeveloperName.get('DRL_Prospect')
                        LIMIT 1];
        Lead objNewLead = new DRL_TestUtility.LeadBuilder()
                .setFirstName('Test')
                .setLastName('User1')
                .setEmail('testuser5@yopmail.com')
                .setCompany('Absyz')
                .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('DRL_Lead'))
                .setStatus('Qualified')
                .createLead();    
        Test.startTest();
        objNewLead.Run_Automation__c='Yes';
        objNewLead.Prospect_Customer__c='Customer';
        insert objNewLead;
        Test.stopTest();

        List<Lead> list_leads = [SELECT 
                                Id,
                                Email
                                FROM Lead
                                WHERE RecordTypeId = :map_RecordTypeIdByDeveloperName.get('DRL_Lead') 
                                AND DRL_Email__c = 'testuser5@yopmail.com'
                                AND DRL_Prospect__c = :objLead.Id];
        System.assert(list_leads.size()==2, 'Lead failed to get linked to existing Prospect!');
    }

    /**
    * @ author       :  Deeksha Suvarna
    * @ description  :  Test method to cover catch blocks
    **/
    @isTest
    static void testExceptions() {
        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
        Lead objChildLead1 = new DRL_TestUtility.LeadBuilder()
                .setFirstName('Test')
                .setLastName('User')
                .setEmail('testuser1@yopmail.com')
                .setCompany('Absyz')
                .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('DRL_Lead'))
                .createLead();

        Lead objChildLead2 = new DRL_TestUtility.LeadBuilder()
                        .setFirstName('Test')
                        .setLastName('User')
                        .setEmail('testuser1@yopmail.com')
                        .setCompany('Absyz')
                        .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('DRL_Lead'))
                        .createLead();

        Test.startTest();
        blnThrowExceptionWhileAddingProspect = true;
        insert objChildLead1;
        blnThrowExceptionWhileAddingProspect = false;
        blnThrowExceptionWhileAddingCampaignMember = true;
        insert objChildLead2;
        blnThrowExceptionWhileAddingCampaignMember = false;
        Test.stopTest();
    }

    /**
    * @ author       :  Wafa Shaikh
    * @ description  :  This method is used to test the Prospect Status When the child Lead is updated 
    **/
    @isTest
    private static void testProspectStatus() {
        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
 
        Lead objLead = [SELECT 
                        Id,
                        Email,
                        Status,	
                        DRL_Prospect__c 
                        FROM Lead
                        WHERE Email = 'testuser5@yopmail.com' AND 
                        RecordTypeId = :map_RecordTypeIdByDeveloperName.get('DRL_Prospect') 
                       ];        
        Test.startTest();
        objLead.Status = 'Unqualified';
        update objLead;        
        Test.stopTest();
    } 

    /**
    * @ author       :  Kishore Pedireddy
    * @ description  :  This method is used to test the scenario updating Prospect Status based on Lead status
    **/
    @isTest
    private static void testAddProspectOnLeadOnEmailUpdate() {

        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
        Lead objLead = new DRL_TestUtility.LeadBuilder()
                .setFirstName('Test')
                .setLastName('User')
                .setCompany('Absyz')
                .setEmail('testuser5@yopmail.com')
                .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('DRL_Lead'))
                .createLead();
        
        Test.startTest();
        insert objLead;
        objLead = new Lead(Id = objLead.Id);
        objLead.Status = 'Unqualified';
        update objLead;
        Test.stopTest();  
        objLead = [SELECT Status,DRL_Prospect__r.Status FROM Lead WHERE Id =:objLead.Id] ;
        System.assert(objLead.DRL_Prospect__r.Status == objLead.Status, 'Prospect Status Update Failed');    
    }
}