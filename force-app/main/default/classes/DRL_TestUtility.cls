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
}