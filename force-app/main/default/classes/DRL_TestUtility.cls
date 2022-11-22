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
    * @ Name     :  CampaignInfluence Builder
    * @ Purpose  :  To create CampaignInfluence record
    * @ Author   :  Dinesh Chandra
    **/
    public class CampaignInfluenceBuilder {
        private Id idCampaignId;
        private Id idOpportunityId;
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
        objCampaignInfluence.Influence = this.decInfluencePercentage;
        objCampaignInfluence.ModelId = this.idModelId;
        return objCampaignInfluence;
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
        private Id idRecordTypeId;
        
        public OpportunityBuilder() {
            this.strName = '';
            this.strStageName = '';
            this.strLaunchYear = '';
            this.strSourceType = '';
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
            return objOpportunity;
        }
    }
}