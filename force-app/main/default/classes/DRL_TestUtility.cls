/*********************************************************************************************************************************************
* 
* @ Name            :  DRL_TestUtility
* @ Purpose         :  This is utility class which can be used to create test data for test classes
* @ Author          :  Deeksha Suvarna
*
*   Date            |  Developer Name                 		|  Version      |  Changes
* ============================================================================================================================================
*   04-07-2022      |  deeksha.suvarna@absyz.com     		|  1.0          |  Initial Version
*	08-11-2022		|  mahalakshmi.sadhanantham@absyz.com	|  1.1          |  Added UTM campaign and UTM Source fields and Campaign Builder
**********************************************************************************************************************************************/
@isTest
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
        
        public LeadBuilder() {
            this.strFirstName = '';
            this.strLastName = '';
            this.strEmail = '';
            this.strCompany = '';
            this.strUTMCampaign = '';
            this.strUTMSource = '';
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
        
        public LeadBuilder setUtmCampaign(String strValue) {
            this.strUTMCampaign = strValue;
            return this;
        }

        public LeadBuilder setUtmSorce(String strValue) {
            this.strUTMSource = strValue;
            return this;
        }

        public LeadBuilder setRecordTypeId(Id idValue) {
            this.idRecordTypeId = idValue;
            return this;
        }
        
        public Lead createLead() {
            Lead objLead = new Lead();
            objLead.FirstName = this.strFirstName;
            objLead.LastName = this.strLastName;
            objLead.Email = this.strEmail;
            objlead.Company = this.strCompany;
            objLead.DRL_UTM_Campaign__c = this.strUTMCampaign;
            objlead.DRL_UTM_Source__c = this.strUTMSource;
            objLead.RecordTypeId = this.idRecordTypeId;
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
        private Boolean blnisActive;

        
        public CampaignBuilder() {
            this.strCampaignName = '';
            this.strAllowMassEmail = '';
            this.strCurrency = '';
            this.strDescription = '';
            this.strCampaignCode = '';
            this.blnisActive = false;
            
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
            this.blnisActive = blnValue;
            return this;
        }

        public Campaign createCampaign() {
            Campaign objCampaign = new Campaign();
            objCampaign.Name = this.strCampaignName;
            objCampaign.Allow_Mass_Email__c = this.strAllowMassEmail;
            objCampaign.CurrencyIsoCode = this.strCurrency;
            objCampaign.Description = this.strDescription;
            objCampaign.DRL_CampaignCode__c = this.strCampaignCode;
            objCampaign.IsActive = this.blnisActive;
            
            return objCampaign;
        }
    }
}