/*******************************************************************************************************
* 
* @ Name            :   DRL_LeadTriggerHelperTest
* @ Purpose         :   Test class for DRL_LeadTriggerHelper
* @ Author          :   Deeksha Suvarna
*
*   Date            |  Developer Name						|  Version      |  Changes
* ======================================================================================================
*   04-11-2022      |  deeksha.suvarna@absyz.com    		|  1.0          |  Initial Version
*   08-11-2022      |  mahalakshmi.sadhanantham@absyz.com	|  2.0          |  Campaign record creation
*******************************************************************************************************/
@isTest
public class DRL_LeadTriggerHelperTest {
    public static Boolean blnThrowException = false;
    /**
    * @ author       :  Deeksha Suvarna
    * @ description  :  This method is used to setup data for testing apex class 'DRL_LeadTriggerHelper'
    **/
    @TestSetup
    static void createData(){
        /**
    	* @ author       :  Mahalakshmi S
    	* @ description  :  This method is used to setup data for testing apex class 'DRL_LeadTriggerHelper', for Story DRL-48
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
            .setEmail('testuser@yopmail.com')
            .setCompany('Absyz')
            .setUtmCampaign('Campaign 1005')
            .setUtmSorce('Test MDT 2')
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
                .setEmail('testuser@yopmail.com')
                .setCompany('Absyz')
                .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('DRL_Lead'))
                .createLead();    
        Test.startTest();
        insert objNewLead;
        Test.stopTest();

        List<Lead> list_leads = [SELECT 
                                Id,
                                Email
                                FROM Lead
                                WHERE RecordTypeId = :map_RecordTypeIdByDeveloperName.get('DRL_Lead') 
                                AND DRL_Email__c = 'testuser@yopmail.com'
                                AND DRL_Prospect__c =: objLead.Id];
        System.assert(!list_leads.isEmpty(), 'Lead failed to get linked to existing Prospect!');
    }

    /**
    * @ author       :  Deeksha Suvarna
    * @ description  :  Test method to cover catch blocks
    **/
    @isTest
    static void testExceptions() {
        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
        Lead objLead = new DRL_TestUtility.LeadBuilder()
                .setFirstName('Test')
                .setLastName('User')
                .setEmail('testuser1@yopmail.com')
                .setCompany('Absyz')
                .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('DRL_Lead'))
                .createLead();
        Test.startTest();
        blnThrowException = true;
        insert objLead;
        blnThrowException = false;
        Test.stopTest();
    }
}