@isTest
public class CampaignApproval_Test {

    @isTest
    public static void doApprovalTest(){
        Test.startTest();
        Campaign objCampaign = new Campaign( 
                                            Name = 'TEST',
                                            Allow_Mass_Email__c = 'Yes',
                                            Select_Approver__c = UserInfo.getUserId());
        insert objCampaign;
        PageReference myVfPage = Page.CampaignApproval;
        Test.setCurrentPage(myVfPage);        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',objCampaign.Id);
        CampaignApproval cm=new CampaignApproval();
        cm.doApproval();
        Test.stopTest();
    }
}