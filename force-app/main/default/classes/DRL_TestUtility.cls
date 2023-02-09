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
    * @ Name     :  OpportunityContactRoleBuilder
    * @ Purpose  :  To create OpportunityContactRole
    * @ Author   :  Mahalakshmi S
    **/
    public class OpportunityContactRoleBuilder{
        private Id idContactId;
        private Id idOpportunityId;
        
        public OpportunityContactRoleBuilder() {
            
        }
        
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