/*********************************************************************************************************************
* 
* @ Name            :  DRL_TestUtility
* @ Purpose         :  This is utility class which can be used to create test data for test classes
* @ Author          :  Deeksha Suvarna
*
*   Date            |  Developer Name                 |  Version      |  Changes
* =====================================================================================================================
*   04-07-2022      |  deeksha.suvarna@absyz.com      |  1.0          |  Initial Version
*
***********************************************************************************************************************/@isTest
public class DRL_TestUtility { 
    /**
    * @ Name     :  LeadBuilder
    * @ Purpose  :  To create Lead record
    * @ Author   :  Deeksha
    **/
    public class LeadBuilder {
        private String strFirstName;
        private String strLastName;
        private String strEmail;
        private String strCompany;
        private Id idRecordTypeId;
        private String strUTMCampaign;
        private String strUTMSource;
        private Id idProspectId;
        private String strStatus;
        private String strCountry; 
        private String strReasonForDecline;
        private Id idSourceCampaignId;
        
        public LeadBuilder() {
            this.strFirstName = '';
            this.strLastName = '';
            this.strEmail = '';
            this.strCompany = '';
            this.strUTMCampaign = '';
            this.strUTMSource = '';
            this.strStatus = '';
            this.strCountry = '';
            this.strReasonForDecline = '';
        } 
        
        public LeadBuilder setFirstName(String strValue) {
            this.strFirstName = strValue;
            return this;
        }
        
        public LeadBuilder setLastName(String strValue) {
            this.strLastName = strValue;
            return this;
        }


        public LeadBuilder setEmail(String strValue) {
            this.strEmail = strValue;
            return this;
        }

        public LeadBuilder setCompany(String strValue) {
            this.strCompany = strValue;
            return this;
        }

        public LeadBuilder setRecordTypeId(Id idValue) {
            this.idRecordTypeId = idValue;
            return this;
        }
        
        public LeadBuilder setUtmCampaign(String strValue) {
            this.strUTMCampaign = strValue;
            return this;
        }

        public LeadBuilder setUtmSource(String strValue) {
            this.strUTMSource = strValue;
            return this;
        }
        public LeadBuilder setProspectId(Id idValue) {
            this.idProspectId = idValue;
            return this;
        }
        public LeadBuilder setSouceCampaignId(Id idValue) {
            this.idSourceCampaignId = idValue;
            return this;
        }
        public LeadBuilder setStatus (String strValue) {
            this.strStatus = strValue;
            return this;
        }
        public LeadBuilder setCountry (String strValue) {
            this.strCountry = strValue;
            return this;
        }
        
         public LeadBuilder setReasonForDecline(String strValue) {
            this.strReasonForDecline = strValue;
            return this;
        }        
        public Lead createLead() {
            Lead objLead = new Lead();
            objLead.FirstName = this.strFirstName;
            objLead.LastName = this.strLastName;
            objLead.Email = this.strEmail;
            objlead.Company = this.strCompany;
            objLead.DRL_UTMCampaign__c = this.strUTMCampaign;
            objlead.DRL_UTMSource__c = this.strUTMSource;
            objLead.RecordTypeId = this.idRecordTypeId;
            objLead.DRL_Prospect__c = this.idProspectId;
            objLead.Status = this.strStatus;
            objLead.Country = this.strCountry;
            objLead.Reason_for_Decline__c = this.strReasonForDecline;
            objLead.DRL_SourceCampaign__c = this.idSourceCampaignId;
            return objLead;
        }
    }
    
    /**
    * @ Name     :  CampaignBuilder
    * @ Purpose  :  To create Campaign record
    * @ Author   :  Mahalakshmi S
    **/
    public class CampaignBuilder {
        private String strCampaignName;
        private String strAllowMassEmail;
        private String strCurrency;
        private String strDescription;
        private String strCampaignCode;
        private Boolean blnIsActive;

        public CampaignBuilder() {
            this.strCampaignName = '';
            this.strAllowMassEmail = '';
            this.strCurrency = '';
            this.strDescription = '';
            this.strCampaignCode = '';
            this.blnIsActive = false;
            
        }
        
        public CampaignBuilder setCampaignName(String strValue) {
            this.strCampaignName = strValue;
            return this;
        }
        
        public CampaignBuilder setAllowMassEmail(String strValue) {
            this.strAllowMassEmail = strValue;
            return this;
        }

        public CampaignBuilder setCurrency(String strValue) {
            this.strCurrency = strValue;
            return this;
        }

        public CampaignBuilder setDescription(String strValue) {
            this.strDescription = strValue;
            return this;
        }
        
        public CampaignBuilder setCampaignCode(String strValue) {
            this.strCampaignCode = strValue;
            return this;
        }
        
        public CampaignBuilder setIsActive(Boolean blnValue) {
            this.blnIsActive = blnValue;
            return this;
        }

        public Campaign createCampaign() {
            Campaign objCampaign = new Campaign();
            objCampaign.Name = this.strCampaignName;
            objCampaign.Allow_Mass_Email__c = this.strAllowMassEmail;
            objCampaign.CurrencyIsoCode = this.strCurrency;
            objCampaign.Description = this.strDescription;
            objCampaign.DRL_CampaignCode__c = this.strCampaignCode;
            objCampaign.IsActive = this.blnIsActive;
            
            return objCampaign;
        }
    }
    /**
    * @ Name     :  CampaignInfluenceModel Builder
    * @ Purpose  :  To create CampaignInfluenceModel record
    * @ Author   :  Dinesh Chandra
    **/
    public class CampaignInfluenceModelBuilder {
        private Id idModelId;

        public CampaignInfluenceModelBuilder() {
            this.idModelId = '';
        }

        public CampaignInfluenceModelBuilder setModelId(Id idValue) {
            this.idModelId = idValue;
            return this;
        }

        public CampaignInfluenceModel createCampaignInfluenceModel() {
            CampaignInfluenceModel objCampaignInfluenceModel = new CampaignInfluenceModel();
            objCampaignInfluenceModel.Id = this.idModelId;
            return objCampaignInfluenceModel;
        }
    }

    /**
    * @ Name     :  CampaignMemberBuilder
    * @ Purpose  :  To create CampaignMember record
    * @ Author   :  Dinesh Chandra
    **/
    public class CampaignMemberBuilder {
        private Id idContactId;
        private Id idCampaignId;
        private String strPardotStatus;

        public CampaignMemberBuilder() {
            this.strPardotStatus = '';
        }

        public CampaignMemberBuilder setCampaignId(Id idValue) {
            this.idCampaignId = idValue;
            return this;
        }

        public CampaignMemberBuilder setContactId(Id idValue) {
            this.idContactId = idValue;
            return this;
        }

        public CampaignMemberBuilder setPardotStatus(String strValue) {
            this.strPardotStatus = strValue;
            return this;
        }

        public CampaignMember createCampaignMember() {
            CampaignMember objCampaignMember = new CampaignMember();
            objCampaignMember.CampaignId = this.idCampaignId;
            objCampaignMember.ContactId = this.idContactId;
            objCampaignMember.Pardot_Campaign_Status__c = this.strPardotStatus;
            return objCampaignMember;
        }
    }

    
    /**
    * @ Name     :  CampaignInfluence Builder
    * @ Purpose  :  To create CampaignInfluence record
    * @ Author   :  Dinesh Chandra
    **/
    public class CampaignInfluenceBuilder {
        private Id idCampaignId;
        private Id idOpportunityId;
        private Id idContactId;
        private Decimal decInfluencePercentage;
        private Id idModelId;

        public CampaignInfluenceBuilder setCampaignId(Id idValue) {
            this.idCampaignId = idValue;
            return this;
        }

        public CampaignInfluenceBuilder setOpportunityId(Id idValue) {
            this.idOpportunityId = idValue;
            return this;
        }

        public CampaignInfluenceBuilder setInfluence(Decimal decInfluencePercentage) {
            this.decInfluencePercentage = decInfluencePercentage;
            return this;
        }

        public CampaignInfluenceBuilder setModelId(Id idValue) {
            this.idModelId = idValue;
            return this;
        }
        
        public CampaignInfluence createCampaignInfluence() {
            CampaignInfluence objCampaignInfluence = new CampaignInfluence();
            objCampaignInfluence.CampaignId = this.idCampaignId;
            objCampaignInfluence.OpportunityId = this.idOpportunityId;
            objCampaignInfluence.ContactId = this.idContactId;
            objCampaignInfluence.Influence = this.decInfluencePercentage;
            objCampaignInfluence.ModelId = this.idModelId;
            return objCampaignInfluence;
        }

        public CampaignInfluenceBuilder setContactId(Id idValue) {
            this.idContactId = idValue;
            return this;
        }
} 

    /**
    * @ Name     :  AccountBuilder
    * @ Purpose  :  To create Account record
    * @ Author   :  Deeksha
    **/
    public class AccountBuilder {
        private String strName;

        public AccountBuilder() {
            this.strName = '';
        }
        
        public AccountBuilder setName(String strValue) {
            this.strName = strValue;
            return this;
        } 

        public Account createAccount() {
            Account objAccount = new Account();
            objAccount.Name = this.strName;
            objAccount.Is_Parent__c = true;
            return objAccount;
        }
    }

    /**
    * @ Name     :  ContactBuilder
    * @ Purpose  :  To create Contact record
    * @ Author   :  Ankit C
    **/
    public class ContactBuilder {
        private String strFirstName;
        private String strLastName;
        private Id idAccountId;
        
        public ContactBuilder() {
            this.strFirstName = '';
            this.strLastName = '';
        }
        
        public ContactBuilder setFirstName(String strValue) {
            this.strFirstName = strValue;
            return this;
        }
        
        public ContactBuilder setLastName(String strValue) {
            this.strLastName = strValue;
            return this;
        }
        
        public ContactBuilder setAccountId(Id idValue) {
            this.idAccountId = idValue;
            return this;
        }

        public Contact createContact() {
            Contact objContact = new Contact();
            objContact.FirstName = this.strFirstName;
            objContact.LastName = this.strLastName;
            objContact.AccountId = this.idAccountId;
            return objContact;
        }
    }

    /**
    * @ Name     :  ProductBuilder
    * @ Purpose  :  To create Product record
    * @ Author   :  Deeksha
    **/
    public class ProductBuilder {
        private String strName;
        
        public ProductBuilder() { 
            this.strName = '';
        }
        
        public ProductBuilder setName(String strValue) {
            this.strName = strValue;
            return this;
        }
        
        public Product2 createProduct() {
            Product2 objProduct = new Product2();
            objProduct.Name = this.strName;
            return objProduct;
        }
    }

    /**
    * @ Name     :  Opportunity Builder
    * @ Purpose  :  To create Opprtunity record
    * @ Author   :  Deeksha
    **/
    public class OpportunityBuilder {
        private String strName;
        private String strStageName;
        private String strLaunchYear;
        private String strSourceType;
        private Decimal decPriceAtLaunch;
        private Decimal decQuantityAtLaunch;
        private Date dtCloseDate;
        private Id idContactId;
        private Id idAccountId;
        private Id idProductId;
        private Id idLeadId;
        private Id idRecordTypeId;
        private Id idConvertedContactId;
        private String strOppJourneyContentIds2;
        
        public OpportunityBuilder() {
            this.strName = '';
            this.strStageName = '';
            this.strLaunchYear = '';
            this.strSourceType = '';
            this.strOppJourneyContentIds2 = '';
        }
        
        public OpportunityBuilder setName(String strValue) {
            this.strName = strValue;
            return this;
        }
        
        public OpportunityBuilder setContactId(Id idValue) {
            this.idContactId = idValue;
            return this;
        }

        public OpportunityBuilder setAccountId(Id idValue) {
            this.idAccountId = idValue;
            return this;
        }

        public OpportunityBuilder setProductId(Id idValue) {
            this.idProductId = idValue;
            return this;
        }

        public OpportunityBuilder setLeadId(Id idValue) {
            this.idLeadId = idValue;
            return this;
        }

        public OpportunityBuilder setStageName(String strValue) {
            this.strStageName = strValue;
            return this;
        }

        public OpportunityBuilder setLaunchYear(String strValue) {
            this.strLaunchYear = strValue;
            return this;
        }

        public OpportunityBuilder setSourceType(String strValue) {
            this.strSourceType = strValue;
            return this;
        }

        public OpportunityBuilder setCloseDate(Date dtValue) {
            this.dtCloseDate = dtValue;
            return this;
        }

        public OpportunityBuilder setPriceAtLaunch(Decimal decValue) {
            this.decPriceAtLaunch = decValue;
            return this;
        }

        public OpportunityBuilder setQuantityAtLaunch(Decimal decValue) {
            this.decQuantityAtLaunch = decValue;
            return this;
        }

        public OpportunityBuilder setConvertedContactId(Id idValue) {
            this.idConvertedContactId = idValue;
            return this;
        }

        public OpportunityBuilder setOppJourneyContentIds2(String strValue) {
            this.strOppJourneyContentIds2 = strValue;
            return this;
        }

        public OpportunityBuilder setRecordTypeId(Id idValue) {
            this.idRecordTypeId = idValue;
            return this;
        }

        public Opportunity createOpportunity() {
            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Name = this.strName;
            objOpportunity.CloseDate = this.dtCloseDate;
            objOpportunity.Planned_Price_at_Launch__c = this.decPriceAtLaunch;
            objOpportunity.Planned_Qty_at_launch__c = this.decQuantityAtLaunch;
            objOpportunity.Planned_Year__c = this.strLaunchYear;
            objOpportunity.Source_type__c = this.strSourceType;
            objOpportunity.StageName = this.strStageName;
            objOpportunity.AccountId = this.idAccountId;
            objOpportunity.Contact__c = this.idContactId;
            objOpportunity.Product__c = this.idProductId;
            objOpportunity.Lead_Converted_From__c = this.idLeadId;
            objOpportunity.Converted_Contact__c = this.idConvertedContactId;
            objOpportunity.Opp_Journey_Content_Ids2__c = this.strOppJourneyContentIds2;
            return objOpportunity;
        }
    }

    /**
    * @ Name     :  User Builder
    * @ Purpose  :  To create User record
    * @ Author   :  Wafa Shaikh
    **/  
    public class UserBuilder {
        private String strFirstName;
        private String strLastName;
        private String strEmail;
        private String strDefaultGroupNotificationFrequency;
        private String strDigestFrequency;
        private String strEmailEncodingKey;
        private String strLanguageLocaleKey; 
        private String strLocaleSidKey;
        private String strProfileId;
        private String strTimeZoneSidKey;
        private String strUsername;
        private Boolean blnUserPermissionsCallCenterAutoLogin;
        private Boolean blnUserPermissionsMarketingUser;
        private Boolean blnUserPermissionsOfflineUser;
        private Boolean blnUserPermissionsWirelessUser;
        private String strAlias; 
        
        public UserBuilder() {
            this.strFirstName = '';
            this.strLastName = '';
            this.strEmail = '';
            this.strDefaultGroupNotificationFrequency = '';
            this.strDigestFrequency = '';
            this.strEmailEncodingKey = '';
            this.strLanguageLocaleKey = '';
            this.strLocaleSidKey = '';
            this.strProfileId = '';
            this.strTimeZoneSidKey = '';
            this.strUsername = '';
            this.strAlias = '';
        }

        public UserBuilder setFirstName(String  strValue) {
            this.strFirstName = strValue;
            return this;
        }

        public UserBuilder setLastName(String strValue) {
            this.strLastName = strValue;
            return this;
        }

        public UserBuilder setEmail(String strValue) {
            this.strEmail = strValue;
            return this;
        }
        
        public UserBuilder setDefaultGroupNotificationFrequency(String strValue) {
            this.strDefaultGroupNotificationFrequency = strValue;
            return this;
        }
        
        public UserBuilder setDigestFrequency(String strValue) {
            this.strDigestFrequency = strValue;
            return this;
        }

        public UserBuilder setEmailEncodingKey(String strValue) {
            this.strEmailEncodingKey = strValue;
            return this;
        } 

        public UserBuilder setLanguageLocaleKey(String strValue) {
            this.strLanguageLocaleKey  = strValue;
            return this;
        } 

        public UserBuilder setLocaleSidKey(String strValue) {
            this.strLocaleSidKey  = strValue;
            return this;
        } 
        
        public UserBuilder setProfileId(String strValue) {
            this.strProfileId  = strValue;
            return this;
        } 
        
        public UserBuilder setTimeZoneSidKey(String strValue) {
            this.strTimeZoneSidKey  = strValue;
            return this;
        }
        
        public UserBuilder setUsername(String strValue) {
            this.strUsername = strValue;
            return this;
        }
        
        public UserBuilder setUserPermissionsCallCenterAutoLogin(Boolean blnValue) {
            this.blnUserPermissionsCallCenterAutoLogin = blnValue;
            return this;
        }
        
        public UserBuilder setUserPermissionsMarketingUser(Boolean blnValue) {
            this.blnUserPermissionsMarketingUser = blnValue;
            return this;
        }
        
        public UserBuilder setUserPermissionsOfflineUser(Boolean blnValue) {
            this.blnUserPermissionsOfflineUser = blnValue;
            return this;
        }
        
        public UserBuilder setUserPermissionsWirelessUser(Boolean blnValue) {
            this.blnUserPermissionsWirelessUser = blnValue;
            return this;
        }
        
        public UserBuilder setAlias(String strValue) {
            this.strAlias = strValue;
            return this;
        }
        
        public User createUser() {
            User objUser = new User(); 
            objUser.FirstName = this.strFirstName;
            objUser.LastName = this.strLastName;
            objUser.Email = this.strEmail;
            objUser.DefaultGroupNotificationFrequency = this.strDefaultGroupNotificationFrequency;
            objUser.DigestFrequency = this.strDigestFrequency;
            objUser.EmailEncodingKey = this.strEmailEncodingKey;
            objUser.LanguageLocaleKey = this.strLanguageLocaleKey;
            objUser.LocaleSidKey = this.strLocaleSidKey;
            objUser.ProfileId = this.strProfileId;
            objUser.TimeZoneSidKey = this.strTimeZoneSidKey;
            objUser.Username = this.strUsername;
            objUser.UserPermissionsCallCenterAutoLogin = this.blnUserPermissionsCallCenterAutoLogin;
            objUser.UserPermissionsMarketingUser = this.blnUserPermissionsMarketingUser;
            objUser.UserPermissionsOfflineUser = this.blnUserPermissionsOfflineUser;
            objUser.Alias = this.strAlias;
            return objUser;
        }
    }
    
    /**
    * @ Name     :  ProfileBuilder
    * @ Purpose  :  To create Profile record
    * @ Author   :  Wafa Shaikh
    **/ 
    public class ProfileBuilder {
        private String strName;
        private String strUserType; 
        
        public ProfileBuilder() {
            this.strName = '';
            this.strUserType = '';
        }

        public ProfileBuilder setName(String  strValue) {
            this.strName = strValue;
            return this;
        } 

        public ProfileBuilder setUserType(String  strValue) {
            this.strUserType = strValue;
            return this;
        } 
        
        public Profile createProfile() {
            Profile objProfile = new Profile();
            objProfile.Name =  this.strName;
            return objProfile;
        }
    }
    
    /**
    * @ Name     :  PQTQuotationBuilder
    * @ Purpose  :  To create PQT_Quotation__c record
    * @ Author   :  Wafa Shaikh
    **/ 
    public class PQTQuotationBuilder{
        private Id idCustomerId;
        private Id idContactId;
        private String strRegion;
        private String strCurrency;
        private Id idOwnerId;
        
        public  PQTQuotationBuilder() {
            this.strRegion = '';
            this.strCurrency = '';
        }

        public PQTQuotationBuilder setCustomerId(Id idValue) {
            this.idCustomerId = idValue;
            return this;
        }

        public PQTQuotationBuilder setContactId(Id idValue) {
            this.idContactId = idValue;
            return this;
        } 

        public PQTQuotationBuilder setRegion(String strValue) {
            this.strRegion = strValue;
            return this;
        }  

        public PQTQuotationBuilder setCurrency(String strValue) {
            this.strCurrency = strValue;
            return this;
        }  

        public PQTQuotationBuilder setOwerId(Id idValue) {
            this.idOwnerId = idValue;
            return this;
        }

        public PQT_Quotation__c createPQTQuotation() { 
            PQT_Quotation__c objPQTQuote = new PQT_Quotation__c();
            objPQTQuote.PQT_Contact__c = this.idContactId;
            objPQTQuote.PQT_Customer__c = this.idCustomerId;
            objPQTQuote.PQT_Price_Book__c = this.strRegion;
            objPQTQuote.CurrencyIsoCode = this.strCurrency;
            objPQTQuote.OwnerId = this.idOwnerId;
            return objPQTQuote;
        }
    }

    /**
    * @ Name     :  PQTMasterDataBuilder
    * @ Purpose  :  To create PQT_Master_Data__c record
    * @ Author   :  Wafa Shaikh
    **/ 
    public class PQTMasterDataBuilder {
        private String idRecordTypeId;
        private String idPQTL1ApproverName;
        private String idPQTL1BApproverName;
        private String idPQTL2ApproverName;
        private String idPQTL3ApproverName; 
        private String idPQTL4ApproverName;
        private String idPQTL3BFinanceBUHeadName;
        private String strPQTPlantName;
        
        public PQTMasterDataBuilder() {
            this.strPQTPlantName = '';
            this.idRecordTypeId = '';
        }

        public PQTMasterDataBuilder setRecordTypeId(String strValue) {
            this.idRecordTypeId = strValue;
            return this;
        } 

        public PQTMasterDataBuilder setPQTL1ApproverName(String strValue) {
            this.idPQTL1ApproverName = strValue;
            return this;
        }
        
        public PQTMasterDataBuilder setPQTL1BApproverName(String strValue) {
            this.idPQTL1BApproverName = strValue;
            return this;
        }

        public PQTMasterDataBuilder setPQTL2ApproverName(String strValue) {
            this.idPQTL2ApproverName = strValue;
            return this;
        }

        public PQTMasterDataBuilder setPQTL3ApproverName(String strValue) {
            this.idPQTL3ApproverName = strValue;
            return this;
        }
        
        public PQTMasterDataBuilder setPQTL4ApproverName(String strValue) {
            this.idPQTL4ApproverName = strValue;
            return this;
        }
        
        public PQTMasterDataBuilder setPQTL3BFinanceBUHeadName(String strValue) {
            this.idPQTL3BFinanceBUHeadName = strValue;
            return this;
        }
        
        public PQTMasterDataBuilder setPQTPlantName(String strValue) {
            this.strPQTPlantName = strValue;
            return this;
        }
        
        public PQT_Master_Data__c createPQTMasterData() {
            PQT_Master_Data__c objPQTMasterData = new PQT_Master_Data__c();
            objPQTMasterData.RecordTypeId = this.idRecordTypeId;
            objPQTMasterData.PQT_L1_Approver__c = this.idPQTL1ApproverName;
            objPQTMasterData.PQT_L1_B_Approver__c = this.idPQTL1BApproverName;
            objPQTMasterData.PQT_L2_Approver__c = this.idPQTL2ApproverName;
            objPQTMasterData.PQT_L3_Approver__c = this.idPQTL3ApproverName;
            objPQTMasterData.PQT_L4_Approver__c = this.IdPQTL4ApproverName;
            objPQTMasterData.PQT_L3B_Finance_BU_Head__c = this.idPQTL3BFinanceBUHeadName;
            objPQTMasterData.PQT_Plant_Name__c = this.strPQTPlantName;
            return  objPQTMasterData;
        }
    }

    /**
    * @ Name     :  AccountTeam Builder
    * @ Purpose  :  To create Account_Team__c record
    * @ Author   :  Dinesh Chandra
    **/
    public class AccountTeamBuilder {
        private String strMomAccess;
        private String strOpportunityAccess;
        private String strAccountAccess;
        private Id idUserId;
        private Id idAccountId;
        
        public AccountTeamBuilder() {
            this.strMomAccess = '';
            this.strOpportunityAccess = '';
            this.strAccountAccess = '';
        }
        
        
        public AccountTeamBuilder setUserId(Id idValue) {
            this.idUserId = idValue;
            return this;
        }

        public AccountTeamBuilder setAccountId(Id idValue) {
            this.idAccountId = idValue;
            return this;
        }


        public AccountTeamBuilder setMomAccess(String strValue) {
            this.strMomAccess = strValue;
            return this;
        }

        public AccountTeamBuilder setOpportunityAccess(String strValue) {
            this.strOpportunityAccess = strValue;
            return this;
        }

        public AccountTeamBuilder setAccountAccess(String strValue) {
            this.strAccountAccess = strValue;
            return this;
        }


        public Account_Team__c createAccountTeam() {
            Account_Team__c objAccountTeam = new Account_Team__c();
            objAccountTeam.User__c = this.idUserId;
            objAccountTeam.Account__c = this.idAccountId;
            objAccountTeam.Account_Access__c = this.strAccountAccess;
            objAccountTeam.Opportunity_Access__c = this.strOpportunityAccess;
            objAccountTeam.Minutes_Of_Meeting_Access__c = this.strMomAccess;
            return objAccountTeam;
        }
    }

    /**
    * @ Name     :  MoMBuilder
    * @ Purpose  :  To create Minutes_Of_Meeting__c record
    * @ Author   :  Dinesh Chandra
    **/
    public class MomBuilder {
        private date dtMomDate;
        private Id idAccountId;
        
        public MomBuilder setMomDate(Date dtValue) {
            this.dtMomDate = dtValue;
            return this;
        }

        public MomBuilder setAccountId(Id idValue) {
            this.idAccountId = idValue;
            return this;
        }
        
        public Minutes_Of_Meeting__c createMom() {
            Minutes_Of_Meeting__c objMom = new Minutes_Of_Meeting__c();
            objMom.MOM_Date__c = dtMomDate;
            objMom.Account__c = this.idAccountId;
            return objMom;
        }
    }

    /**
    * @ Name     :  OpportunityContactRoleBuilder
    * @ Purpose  :  To create OpportunityContactRole
    * @ Author   :  Mahalakshmi S
    **/
    public class OpportunityContactRoleBuilder{
        private Id idContactId;
        private Id idOpportunityId;
        
        public OpportunityContactRoleBuilder setContactId(Id idValue) {
            this.idContactId = idValue;
            return this;
        }

        public OpportunityContactRoleBuilder setOpportunityId(Id idValue) {
            this.idOpportunityId = idValue;
            return this;
        } 

        public OpportunityContactRole createOpportunityContactRole() {
            OpportunityContactRole objOpportunityContactRole = new OpportunityContactRole();
            objOpportunityContactRole.OpportunityId = this.idOpportunityId;
            objOpportunityContactRole.ContactId = this.idContactId;
            return objOpportunityContactRole;
        }
    }
}