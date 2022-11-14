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
        
        public LeadBuilder() {
            this.strFirstName = '';
            this.strLastName = '';
            this.strEmail = '';
            this.strCompany = '';
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
        
        public Lead createLead() {
            Lead objLead = new Lead();
            objLead.FirstName = this.strFirstName;
            objLead.LastName = this.strLastName;
            objLead.Email = this.strEmail;
            objlead.Company = this.strCompany;
            objLead.RecordTypeId = this.idRecordTypeId;

            return objLead;
        }
    }

    /**
    * @ Name     :  AccountBuilder
    * @ Purpose  :  To create Account record
    * @ Author   :  Deeksha
    **/
    public class AccountBuilder {
        private String strName;
        private Boolean blnIsParent;
        public AccountBuilder() {
            this.strName = '';
            this.blnIsParent = false;
        }
        
        public AccountBuilder setName(String strValue) {
            this.strName = strValue;
            return this;
        }

        public AccountBuilder setIsParent(Boolean blnValue) {
            this.blnIsParent = blnValue;
            return this;
        }
        
        public Account createAccount() {
            Account objAccount = new Account();
            objAccount.Name = this.strName;
            objAccount.Is_Parent__c = this.blnIsParent;
            return objAccount;
        }
    }

    /**
    * @ Name     :  ContactBuilder
    * @ Purpose  :  To create Contact record
    * @ Author   :  Deeksha
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
        private Date dateCloseDate;
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

        public OpportunityBuilder setCloseDate(Date dateValue) {
            this.dateCloseDate = dateValue;
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
            objOpportunity.CloseDate = this.dateCloseDate;
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