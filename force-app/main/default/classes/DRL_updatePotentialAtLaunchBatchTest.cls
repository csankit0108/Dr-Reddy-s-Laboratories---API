/*******************************************************************************************************
* 
* @ Name            :   DRL_updatePotentialAtLaunchBatchTest
* @ Purpose         :   Test class for DRL_updatePotentialAtLaunchBatch
* @ Author          :   Deeksha Suvarna
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   10-11-2022      |  deeksha.suvarna@absyz.com    |  1.0          |  Initial Version
*
*******************************************************************************************************/

@isTest
public class DRL_updatePotentialAtLaunchBatchTest {
    public static Boolean blnThrowException = false;
    /**
    * @ author       :  Deeksha Suvarna
    * @ description  :  This method is used to setup data for testing batch class 'DRL_updatePotentialAtLaunchBatch'
    **/
    @TestSetup
    static void createData(){
        Account objAccount = new DRL_TestUtility.AccountBuilder()
            .setName('Test Account')
            .setIsParent(true)
            .createAccount();
        insert objAccount;

        Contact objContact = new DRL_TestUtility.ContactBuilder()
            .setFirstName('Test')
            .setLastName('Contact')
            .setAccountId(objAccount.Id)
            .createContact();
        insert objContact;
        
        Product2 objProduct = new DRL_TestUtility.ProductBuilder()
            .setName('Test Product')
            .createProduct();
        insert objProduct;

        Opportunity objOpportunity = new DRL_TestUtility.OpportunityBuilder()
            .setName('Test Opportunity')
            .setAccountId(objAccount.Id)
            .setContactId(objContact.Id)
            .setProductId(objProduct.Id)
            .setStageName('Discussion')
            .setCloseDate(System.today())
            .setPriceAtLaunch(1000)
            .setQuantityAtLaunch(10)
            .setLaunchYear('2000')
            .setSourceType('Primary Source')
            .createOpportunity();
        insert objOpportunity;
        
    }
    
    /**
    * @ author       :  Deeksha Suvarna
    * @ description  :  Test method to test the updatation of Potential at Launch Value on Opportunity record
    **/
    @isTest
    private static void testOpportunity() {
        
        Test.startTest();
        DRL_updatePotentialAtLaunchBatch objOpportunityUpdate = new DRL_updatePotentialAtLaunchBatch();
        Database.executeBatch(objOpportunityUpdate);
        Test.stopTest();
 
        Opportunity objOpportunity = [SELECT 
                                    Id,
                                    Amount 
                                    FROM Opportunity
                                    LIMIT 1];

        System.assertEquals(10000, objOpportunity.Amount);
    }

    /**
    * @ author       :  Deeksha Suvarna
    * @ description  :  Test method to cover catch block
    **/
    @isTest
    private static void testExceptions() {
        
        Test.startTest();
        blnThrowException = true;
        DRL_updatePotentialAtLaunchBatch objOpportunityUpdate = new DRL_updatePotentialAtLaunchBatch();
        Database.executeBatch(objOpportunityUpdate);
        Test.stopTest();
        blnThrowException = false;

    }
}
