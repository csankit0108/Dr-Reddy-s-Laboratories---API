/*******************************************************************************************************
* 
* @ Name            :   DRL_OpportunityContactRoleTriggerTest
* @ Purpose         :   Test class for DRL_OpportunityContactRoleTriggerHelper
* @ Author          :   Mahalakshmi Sadhananthan
*
*   Date            |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   08-02-2023      |  mahalakshmi.sadhanantham@absyz.com   |  1.0          |  Initial Version
*******************************************************************************************************/

@isTest
public class DRL_OpportunityContactRoleTriggerTest {
    public static Boolean blnThrowExceptionWhileCalculatingInfluence = false;
    public static Boolean blnThrowExceptionWhileAddingDuplicate = false;
    public static Boolean blnThrowExceptionWhileDeletingContactRole = false;
    public static Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
    //Custom Label with Value 'DRL_APICampaignsDistributionModel'
	public static String strModelDeveloperName = Label.CLDRL00001;
    //Quering the Value of DeveloperName 
	public static CampaignInfluenceModel objCampaignInfluenceModel = [  SELECT 
                                                                        Id,
                                                                        DeveloperName 
                                                                        FROM CampaignInfluenceModel 
                                                                        WHERE DeveloperName = :strModelDeveloperName]; 
    /**
    * @ author       :  Mahalakshmi S
    * @ description  :  This method is used to setup data for testing apex class 'DRL_OpportunityContactRoleTriggerHelper'
    **/                                                                        
    @TestSetup
    static void createData() {
        
        Account objAccount = new DRL_TestUtility.AccountBuilder()
            .setName('Test Account')
            .createAccount();
        insert objAccount;
        

        List<Contact> list_Contacts = new List<Contact>();
        Contact objContact = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test')
            .setLastName('Contact')
            .setAccountId(objAccount.Id)
            .createContact();
        objContact.Email = 'testuser@yopmail.com';
        list_Contacts.add(objContact);
        
        Contact objContact_2 = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test')
            .setLastName('Contact_2')
            .setAccountId(objAccount.Id)
            .createContact();
        objContact_2.Email = 'testuser2@yopmail.com';
        list_Contacts.add(objContact_2);
        
        Contact objContact_3 = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test')
            .setLastName('Contact_3')
            .setAccountId(objAccount.Id)
            .createContact();
        objContact_3.Email = 'testuser3@yopmail.com';
        list_Contacts.add(objContact_3);

        Contact objContact5 = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test')
            .setLastName('Contact6')
            .setAccountId(objAccount.Id)
            .createContact();
        objContact5.Email = 'testusercontact5@yopmail.com';
        list_Contacts.add(objContact5);
        insert list_Contacts;
        
        List<Product2> list_Products = new List<Product2>();
        Product2 objProduct = new DRL_TestUtility.ProductBuilder()
            .setName('Test Product')
            .createProduct();
        objProduct.ProductCode = '123445';
        list_Products.add(objProduct);
        
        Product2 objProduct1 = new Product2();
        objProduct1.Name = 'Abacavir';
        objProduct1.ProductCode = '12345';
        objProduct1.PQT_Product_Cluster__c = 'Abacavir Base';
        list_Products.add(objProduct1);
        insert list_Products;
        
        List<Campaign> list_Campaigns = new List<Campaign>();
        Campaign objCampaign = new DRL_TestUtility.CampaignBuilder()
            .setCampaignName('Test Campaign')
            .setAllowMassEmail('No')
            .setDescription('Test Campaign Description')
            .setCampaignCode('Campaign 1005')
            .setIsActive(true)
            .createCampaign();
        objCampaign.Product__c = objProduct.Id;        
        list_Campaigns.add(objCampaign); 
        
        Campaign objCampaign1 = new DRL_TestUtility.CampaignBuilder()
            .setCampaignName('Test Campaign1')
            .setAllowMassEmail('No')
            .setDescription('Test Campaign Description')
            .setCampaignCode('Campaign 1006')
            .setIsActive(true)
            .createCampaign();
        objCampaign1.Product__c = objProduct.Id;      
        list_Campaigns.add(objCampaign1);  
        insert list_Campaigns;
        
        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
        List<Lead> list_Leads = new List<Lead>();
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
        list_Leads.add(objLead);
        
        Lead objLead1 = new DRL_TestUtility.LeadBuilder()
            .setFirstName('Test')
            .setLastName('User1')
            .setEmail('testuserlead@yopmail.com')
            .setCompany('Absyz')
            .setUtmCampaign('Campaign 1005')
            .setStatus('Open')
            .setCountry('India')
            .setReasonForDecline('Product Issues')
            .setUtmCampaign('Campaign 1005')
            .setUtmSource('Test_Source_1')
            .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('DRL_Lead'))
            .createLead();
        objLead1.Select_Country__c = 'India';
        objLead1.DRL_SourceCampaign__c = objCampaign.Id;
        list_Leads.add(objLead1);
        insert list_Leads;
        
        objLead1 = [SELECT DRL_Prospect__c FROM Lead WHERE Id =: objLead1.Id];
        Lead objProspect = [SELECT Id FROM Lead WHERE Id =: objLead1.DRL_Prospect__c ];  
        
        CampaignMember objCampaignMember = new DRL_TestUtility.CampaignMemberBuilder()
            .setCampaignId(objCampaign1.Id)
            .setContactId(objContact5.Id)
            .createCampaignMember();
        objCampaignMember.Status = 'Responded';
        insert objCampaignMember;
          
        Contact objContact4 = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test')
            .setLastName('Contact4')
            .setAccountId(objAccount.Id)
            .createContact();
        objContact4.Email = 'testcontact4@yopmail.com';
        objContact4.Lead_Converted_From__c = objLead1.DRL_Prospect__c;
        insert objContact4;
        
        Test.startTest();
        List<Opportunity> list_Opportunity = new List<Opportunity>();
        Opportunity objOpportunity1 = new DRL_TestUtility.OpportunityBuilder()
            .setName('Test Opportunity1')
            .setAccountId(objContact4.AccountId)
            .setProductId(objProduct.Id)
            .setStageName('Lead Generation')
            .setCloseDate(System.today())
            .setPriceAtLaunch(1000)
            .setQuantityAtLaunch(10)
            .setLaunchYear('2002')
            .setSourceType('Primary Source')
            .createOpportunity();
        objOpportunity1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API').getRecordTypeId();
        objOpportunity1.Target_Markets__c = 'North Asia';
        objOpportunity1.Price__c = 10;
        objOpportunity1.TotalOpportunityQuantity = 10;
        
        list_Opportunity.add(objOpportunity1);
       	
        Opportunity objOpportunity3 = new DRL_TestUtility.OpportunityBuilder()
            .setName('Test Opportunity8')
            .setAccountId(objContact.AccountId)
            .setProductId(objProduct.Id)
            .setStageName('Lead Generation')
            .setCloseDate(System.today())
            .setPriceAtLaunch(1000)
            .setQuantityAtLaunch(10)
            .setLaunchYear('2003')
            .setSourceType('Primary Source')
            .createOpportunity();
        objOpportunity3.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API').getRecordTypeId();
        objOpportunity3.Target_Markets__c = 'Europe';
        objOpportunity3.Price__c = 10;
        objOpportunity3.TotalOpportunityQuantity = 10;
        list_Opportunity.add(objOpportunity3);
        
        Map<String, Id> map_OppRecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Opportunity');
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
            .setRecordTypeId(map_OppRecordTypeIdByDeveloperName.get('API'))
            .createOpportunity();
        list_Opportunity.add(objOpportunity);
        insert list_Opportunity;
        
        List<CampaignMember> list_CampaignMember = [SELECT 
                                                   Id,
                                                   LeadId,
                                                   ContactId,
                                                   CampaignId
                                                   FROM
                                                   CampaignMember
                                                   WHERE
                                                   LeadId =:objProspect.Id];
        
        if(!list_CampaignMember.isEmpty()) {
            list_CampaignMember[0].Status = 'Responded';
            update list_CampaignMember;
        }
        
        DRL_ConvertLeadProspectController.ConvertLeadDataWrapper objresponse = new DRL_ConvertLeadProspectController.ConvertLeadDataWrapper();
        objresponse =  DRL_ConvertLeadProspectController.convertLead(objLead1.Id, objAccount, objContact4, objOpportunity1,new List<Opportunity> {},new List<Lead> {}, new List<DRL_ConvertLeadProspectController.ContentCatalog> {},'',new Map<String,List<DRL_ConvertLeadProspectController.ContentCatalog>> (), new Map<String,String> ());
        Test.stopTest();
        
        Lead objLead2 = new DRL_TestUtility.LeadBuilder()
            .setFirstName('Test')
            .setLastName('User2')
            .setEmail('testuserlead1@yopmail.com')
            .setCompany('Absyz')
            .setUtmCampaign('Campaign 1005')
            .setStatus('Open')
            .setCountry('India')
            .setReasonForDecline('Product Issues')
            .setUtmCampaign('Campaign 1005')
            .setUtmSource('Test_Source_1')
            .setRecordTypeId(map_RecordTypeIdByDeveloperName.get('DRL_Lead'))
            .createLead();
        objLead2.Select_Country__c = 'India';
        objLead2.DRL_SourceCampaign__c = objCampaign.Id;
        insert objLead2;
        
        objLead2 = [SELECT DRL_Prospect__c FROM Lead WHERE Id =: objLead2.Id];
        Lead objProspect2 = [SELECT Id FROM Lead WHERE Id =: objLead2.DRL_Prospect__c ];       
        
        Contact objContact8 = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test')
            .setLastName('Contact8')
            .setAccountId(objAccount.Id)
            .createContact();
        objContact8.Email = 'testcontact@yopmail.com';
        insert objContact8;
        
       
        List<CampaignMember> list_CampaignMember1 = [SELECT 
                                                   Id,
                                                   LeadId,
                                                   ContactId,
                                                   CampaignId
                                                   FROM
                                                   CampaignMember
                                                   WHERE
                                                   LeadId =:objProspect2.Id];
        
        if(!list_CampaignMember1.isEmpty()) {
            list_CampaignMember1[0].Status = 'Responded';
            update list_CampaignMember1;
        }       
        
        List<OpportunityContactRole> list_OpportunityContactRoles = new List<OpportunityContactRole>();
        OpportunityContactRole objOpportunityContactRole = new DRL_TestUtility.OpportunityContactRoleBuilder()
            .setOpportunityId(objOpportunity.Id)
            .setContactId(objContact.Id)
            .createOpportunityContactRole();
        list_OpportunityContactRoles.add(objOpportunityContactRole);
        
        OpportunityContactRole objOpportunityContactRole_2 = new DRL_TestUtility.OpportunityContactRoleBuilder()
            .setOpportunityId(objOpportunity.Id)
            .setContactId(objContact_2.Id)
            .createOpportunityContactRole();
        list_OpportunityContactRoles.add(objOpportunityContactRole_2);
        
        OpportunityContactRole objOpportunityContactRole_3 = new DRL_TestUtility.OpportunityContactRoleBuilder()
            .setOpportunityId(objOpportunity.Id)
            .setContactId(objContact_3.Id)
            .createOpportunityContactRole();
            list_OpportunityContactRoles.add(objOpportunityContactRole_3);
        insert list_OpportunityContactRoles;
        
        CampaignInfluenceModel objCampaignInfluenceModel = [SELECT 
                                                            Id,
                                                            DeveloperName 
                                                            FROM CampaignInfluenceModel 
                                                            WHERE DeveloperName = :Label.CLDRL00001];
        List<CampaignInfluence> list_CampaignInfluence = new List<CampaignInfluence>();        
        CampaignInfluence objCampaignInfluence = new DRL_TestUtility.CampaignInfluenceBuilder()
            .setCampaignId(objCampaign.Id)
            .setOpportunityId(objOpportunity.Id)
            .setContactId(objContact.Id)
            .setInfluence(22)
            .setModelId(objCampaignInfluenceModel.Id)
            .createCampaignInfluence();
        list_CampaignInfluence.add(objCampaignInfluence);
        
        CampaignInfluence objCampaignInfluence_2 = new DRL_TestUtility.CampaignInfluenceBuilder()
            .setCampaignId(objCampaign.Id)
            .setOpportunityId(objOpportunity.Id)
            .setContactId(objContact_2.Id)
            .setInfluence(44)
            .setModelId(objCampaignInfluenceModel.Id)
            .createCampaignInfluence();
        list_CampaignInfluence.add(objCampaignInfluence_2);
        
        CampaignInfluence objCampaignInfluence_3 = new DRL_TestUtility.CampaignInfluenceBuilder()
            .setCampaignId(objCampaign.Id)
            .setOpportunityId(objOpportunity.Id)
            .setContactId(objContact_3.Id)
            .setInfluence(5)
            .setModelId(objCampaignInfluenceModel.Id)
            .createCampaignInfluence();
        list_CampaignInfluence.add(objCampaignInfluence_3);
        insert list_CampaignInfluence;
    }
    
    /**
    * @ author       :  Mahalakshmi S
    * @ description  :  This method is used to test the condition - Validation to prevent duplicate contacts from being added to the same opportunity  
    **/
    @isTest
    private static void testDuplicateContactInsertionMethod() {
        Test.startTest();
        Contact objContact = [SELECT 
                              Id
                              FROM Contact
                              WHERE LastName = 'Contact' 
                              LIMIT 1];
         
        Opportunity objOpportunity = [SELECT 
                                      Id
                                      FROM Opportunity 
                                      LIMIT 1];
        
        
        try{
            OpportunityContactRole objOpportunityContactRole = new DRL_TestUtility.OpportunityContactRoleBuilder()
                .setOpportunityId(objOpportunity.Id)
                .setContactId(objContact.Id)
                .createOpportunityContactRole();
            Insert objOpportunityContactRole;
            
        }catch(Exception objException) {
            Assert.isTrue(objException.getMessage().contains(System.Label.CLDRL00025),'Trigger Exception Handling');
        }
        Test.stopTest();
    }
    
    /**
    * @ author       :  Mahalakshmi S
    * @ description  :  This method is used to test the condition - Process on Recalculating after Contact is Deleted from Contact role  
    **/
    @isTest
    private static void testDeleteContactfromContactRoleMethod() {
        Test.startTest();
        Contact objContact = [SELECT 
                              Id,
                              LastName
                              FROM Contact
                              WHERE LastName = 'Contact_3'
                              LIMIT 1
                             ];
        
        Map<String, Id> map_OppRecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Opportunity');
        Opportunity objOpportunity = [SELECT 
                                      Id
                                      FROM Opportunity
                                      WHERE RecordTypeId = :map_OppRecordTypeIdByDeveloperName.get('API')
                                      LIMIT 1
                                     ];
        
        List<OpportunityContactRole> objOpportunityContactRole = [SELECT 
                                                            Id,
                                                            ContactId
                                                            FROM OpportunityContactRole
                                                            WHERE ContactId =: objContact.Id
                                                            LIMIT 1
                                                           ];
        
        delete objOpportunityContactRole;
        Test.stopTest();          
    }
    
    /**
	* @ author       :  Deeksha Suvarna
	* @ description  :  This method is used to test the condition - Campaign Influence Calculation on insertion of Opportunity Contact Role
	**/
    
    @isTest
    private static void CalculateInfluenceCase1() {
        Test.startTest();
        Opportunity objOpportunity = [SELECT Id FROM Opportunity WHERE StageName = 'Lead Generation' AND Planned_Year__c = '2002' LIMIT 1];
   
        
        List<OpportunityContactRole> list_OpportunityContactRole = [SELECT 
                                                                   Id,
                                                                   ContactId
                                                                   FROM
                                                                   OpportunityContactRole
                                                                   WHERE OpportunityId =:objOpportunity.Id];
                
        Decimal decCampaignInfluence =  (decimal)[  SELECT 
                                                    SUM(Influence)sum 
                                                    FROM CampaignInfluence 
                                                    WHERE OpportunityId =:objOpportunity.Id 
                                                    AND ModelId =:objCampaignInfluenceModel.Id
                                                    GROUP BY OpportunityId][0].get('sum');   
        System.assert(decCampaignInfluence==20, 'Campaign Influence updated Incorrectly');
        Test.stopTest();
    }
    
    /**
	* @ author       :  Deeksha Suvarna
	* @ description  :  This method is used to test the condition - Campaign Influence Calculation on insertion of Opportunity Contact Role
	**/
    
    @isTest
    private static void CalculateInfluenceCase2() {
        Test.startTest();
        Opportunity objOpportunity = [SELECT Id FROM Opportunity WHERE StageName = 'Lead Generation' AND Planned_Year__c = '2002' LIMIT 1];
   		Account objAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Campaign objCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign1' LIMIT 1];
        
        
        objOpportunity.StageName = 'Discussion';
        update objOpportunity;
		Contact objContact = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test')
            .setLastName('Contact3')
            .setAccountId(objAccount.Id)
            .createContact();
        objContact.Email = 'testusercontact3@yopmail.com';
        insert objContact;
        CampaignMember objCampaignMember = new DRL_TestUtility.CampaignMemberBuilder()
            .setCampaignId(objCampaign.Id)
            .setContactId(objContact.Id)
            .createCampaignMember();
        objCampaignMember.Status = 'Responded';
        insert objCampaignMember;
        
        
        OpportunityContactRole objOpportunityContactRole = new OpportunityContactRole();
        objOpportunityContactRole.ContactId = objContact.Id;
        objOpportunityContactRole.Role = 'Influencer';
        objOpportunityContactRole.OpportunityId = objOpportunity.Id;
        insert objOpportunityContactRole;
        
        
        List<OpportunityContactRole> list_OpportunityContactRole = [SELECT 
                                                                   Id,
                                                                   ContactId
                                                                   FROM
                                                                   OpportunityContactRole
                                                                   WHERE OpportunityId =:objOpportunity.Id];
                
        Decimal decCampaignInfluence =  (decimal)[  SELECT 
                                                    SUM(Influence)sum 
                                                    FROM CampaignInfluence 
                                                    WHERE OpportunityId =:objOpportunity.Id 
                                                    AND ModelId =:objCampaignInfluenceModel.Id
                                                    GROUP BY OpportunityId][0].get('sum');   
        System.assert(decCampaignInfluence==55, 'Campaign Influence updated Incorrectly');
        
        Test.stopTest();
    }   
    
    
    
    /**
	* @ author       :  Deeksha Suvarna
	* @ description  :  This method is used to test the condition - Campaign Influence Calculation on insertion of Opportunity Contact Role
	**/
    
    @isTest
    private static void CalculateInfluenceCase3() {
		Test.startTest();
        Product2 objProduct = [SELECT Id, Name FROM Product2 WHERE ProductCode = '12345' LIMIT 1];
        User objUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Id idAPIRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('API').getRecordTypeId();
        Campaign objCampaign = [SELECT Id FROM Campaign WHERE Name ='Test Campaign'];
        Campaign objCampaign1 = [SELECT Id FROM Campaign WHERE Name ='Test Campaign1'];
        
        System.runAs(objUser){   
            Lead objLead = new Lead();
            objLead.Company = 'Raghu Ram Enterprises';
            objLead.Select_Country__c = 'India';
            objLead.LastName = 'Raghu Ram';
            objLead.email = 'raghuram@email.test.com';
            objLead.Status = 'Open';
            objLead.Product_Lookup__c = objProduct.Id;
            objLead.DRL_SourceCampaign__c = objCampaign.Id;
            insert objLead;    

            Lead objProspect = [SELECT 
                                Id 
                                FROM Lead 
                                WHERE Email = 'raghuram@email.test.com' 
                                AND RecordType.DeveloperName = 'DRL_Prospect' LIMIT 1]; 
                   
            List<CampaignMember> list_CampaignMember = [SELECT 
                                                       Id,
                                                       LeadId,
                                                       ContactId,
                                                       CampaignId
                                                       FROM
                                                       CampaignMember
                                                       WHERE
                                                       LeadId =:objProspect.Id];
        
            if(!list_CampaignMember.isEmpty()) {
                list_CampaignMember[0].Status = 'Responded';
                update list_CampaignMember;                
            }
            CampaignMember objCampaignMember = new DRL_TestUtility.CampaignMemberBuilder()
                .setCampaignId(objCampaign1.Id)
                .createCampaignMember();
                objCampaignMember.LeadId = objProspect.Id;
                objCampaignMember.Status = 'Responded';
            insert objCampaignMember;

            Account objAccount = new Account();
            objAccount.Name = objLead.Company;
            objAccount.Industry__c = 'Generics';
			
            Contact objContact = new Contact();
            objContact.LastName = objLead.LastName;
            objContact.email = objLead.email;
            objContact.Job_Level__c = 'CXO/Head';
            objContact.Department__c = 'Regulatory'; 
			
            DRL_ConvertLeadProspectController.ConvertLeadDataWrapper objResponse = DRL_ConvertLeadProspectController.getLeadDetails(String.valueOf(objLead.Id));

            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Name = objLead.Company+' '+ objProduct.Name;
            objOpportunity.RecordTypeId = idAPIRecordTypeId;
            objOpportunity.CurrencyIsoCode = 'EUR';
            objOpportunity.Target_Markets__c = 'North Asia';
            objOpportunity.CloseDate = System.today().addDays(2);
            objOpportunity.StageName = 'Lead Generation';

            //Convert Lead
            objResponse = DRL_ConvertLeadProspectController.convertLead(
                String.valueOf(objLead.Id),
                objAccount,
                objContact,
                objOpportunity,
                null,
                null,
                objResponse.catList, 
                'Immediately',
                null,
                null
            );
            Test.stopTest();
        }      
    } 
    
    @isTest
    public static void testExceptions() {

        DRL_OpportunityContactRoleTriggerTest.blnThrowExceptionWhileCalculatingInfluence = true;
        DRL_OpportunityContactRoleTriggerTest.blnThrowExceptionWhileAddingDuplicate = true;
        DRL_OpportunityContactRoleTriggerTest.blnThrowExceptionWhileDeletingContactRole = true;
        Campaign objCampaign = [SELECT Id FROm Campaign LIMIT 1];

        Opportunity objOpportunity = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Contact objContact = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test')
            .setLastName('Contact_4')
            .setAccountId(objOpportunity.AccountId)
            .createContact();
        objContact.Email = 'testuser4@yopmail.com';
        insert objContact;

        CampaignMember objCampaignMember = new DRL_TestUtility.CampaignMemberBuilder()
            .setCampaignId(objCampaign.Id)
            .setContactId(objContact.Id)
            .createCampaignMember();
        objCampaignMember.Status = 'Responded';
        insert objCampaignMember;

        OpportunityContactRole objOpportunityContactRole = new DRL_TestUtility.OpportunityContactRoleBuilder()
            .setOpportunityId(objOpportunity.Id)
            .setContactId(objContact.Id)
            .createOpportunityContactRole();
        Insert objOpportunityContactRole;
        delete objOpportunityContactRole;        
    }
}