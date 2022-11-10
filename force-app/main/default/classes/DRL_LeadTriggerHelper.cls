/*******************************************************************************************************
* 
* @ Name            :   DRL_LeadTriggerHelper
* @ Purpose         :   Apex class for prospect creation and field updation.
* @ Author          :   Ankit C
* @ Usage           :   1) If Prospect exist - link it to child lead.
                        2) If Prospect does not exist - Create prospect and link it to child.
* @ Test Class Name :   
*
*   Date            |  Developer Name							|  Version        
* ======================================================================================================
*  02-11-2022       |  ankit.c@absyz.com						|  1.0          
*  03-11-2022       |  deeksha.suvarna@absyz.com				|  2.0  
*  07-11-2022       |  mahalakshmi.sadhanantham@absyz.com		|  3.0  
*******************************************************************************************************/
public without sharing class DRL_LeadTriggerHelper {
    public static Boolean blnSkipTrigger = false;
    public static void processAfterInsert(List<Lead> list_Leads) {
        Schema.DescribeSObjectResult strDescription = Lead.sObjectType.getDescribe();
        Map<String, Schema.FieldSet> map_LeadFieldSet = strDescription.fieldSets.getMap();
        List<FieldSetMember> list_LeadFieldSetMember = map_LeadFieldSet.get('DRL_ProspectFields').getFields();
        List<Schema.sObjectField> list_LeadsObjectField = new List<Schema.sObjectField>();
        Map<String, Lead> map_LeadByEmail = new Map<String, Lead>();
        Map<String, Id> map_RecordTypeIdByDeveloperName = DRLUtil.getRecordTypeDeveloperNameIdMap('Lead');
        Map<String, Lead> map_LeadsToInsert = new Map<String, Lead>();
        List<Lead> list_ChildLeads = new List<Lead>();
        List<CampaignMember> list_CampaignMembers = new List<CampaignMember>();
        List<Lead> list_LeadsToUpdate = new List<Lead>();
        for (FieldSetMember objFields : list_LeadFieldSetMember) {
            list_LeadsObjectField.add(objFields.getSObjectField());
            
        }

        for (Lead objLead : [SELECT 
                             Id,
                             Email
                             FROM
                             Lead
                             WHERE RecordTypeId = :map_RecordTypeIdByDeveloperName.get('DRL_Prospect')
                             AND Id NOT IN :list_Leads
                             AND Email !=null
           
        ]) {
            map_LeadByEmail.put(objLead.Email, objLead);                    
        }
        
        try{
            for (Lead objLead : list_Leads) {
                if (!map_LeadByEmail.containsKey(objLead.Email)) {
                    //create prospect lead
                    Map<String, Object> map_LeadFieldByName = objLead.getPopulatedFieldsAsMap();
                    Lead objProspect = new Lead();
                    for( Schema.sObjectField objField : list_LeadsObjectField){
                        Schema.DescribeFieldResult dfr = objField.getDescribe();
                        string APIName = dfr.getName();
                        objProspect.put(APIName,map_LeadFieldByName.get(APIName));
                    }
                    objProspect.RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Prospect');
                    /*Lead objProspect = new Lead(
                        FirstName = objLead.FirstName,
                        LastName = objLead.LastName,
                        Company = objLead.Company,
                        Email = objLead.Email,
                        RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Prospect')
                    );*/
                    map_LeadsToInsert.put(objProspect.Email, objProspect);
                    list_ChildLeads.add(objLead);
                    system.debug('map_LeadFieldSet'+map_LeadFieldSet);
                    system.debug('strDescription'+strDescription);
                    system.debug('list_LeadFieldSetMember'+list_LeadFieldSetMember);
                    system.debug('list_LeadsObjectField'+list_LeadsObjectField);
                    system.debug('list_LeadsObjectField'+list_LeadsObjectField);
                } else {
                    Lead objLeadToUpdate = new Lead(Id = objLead.Id);
                    objLeadToUpdate.DRL_Prospect__c = map_LeadByEmail.get(objLead.Email).Id;
                    objLeadToUpdate.DRL_Email__c = objLead.Email;
                    objLeadToUpdate.Email = null;
                    objLeadToUpdate.RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Lead');
                    list_LeadsToUpdate.add(objLeadToUpdate);
                }
            }
            
            DRL_LeadTriggerHelper.blnSkipTrigger = true;
            // insert map_LeadsToInsert.values();
            
            for (Lead objLead : list_ChildLeads) {
                Lead objLeadToUpdate = new Lead(Id = objLead.Id);
                // if (map_LeadsToInsert.containsKey(objLead.Email)) {
                //     //objLeadToUpdate.DRL_Prospect__c = map_LeadsToInsert.get(objLead.Email).Id;
                // }
                objLeadToUpdate.DRL_Email__c = objLead.Email;
                objLeadToUpdate.Email = null;
                objLeadToUpdate.RecordTypeId = map_RecordTypeIdByDeveloperName.get('DRL_Lead');
                list_LeadsToUpdate.add(objLeadToUpdate);
            }
            
            update list_LeadsToUpdate;
            insert map_LeadsToInsert.values();

            for (Lead objLead : list_LeadsToUpdate) {
                if (objLead.DRL_Prospect__c == null && map_LeadsToInsert.containsKey(objLead.DRL_Email__c)) {
                    objLead.DRL_Prospect__c = map_LeadsToInsert.get(objLead.DRL_Email__c).Id;
                }
            }
            
            update list_LeadsToUpdate;
            /*
             * DRL-50
              *When a Source Campaign record is linked to the Child lead record, create a Campaign member record.
              *For new Campaign member record, populate
              *Campaign: Source campaign value on the child lead record.
              *Lead: Prospect parent record of the child lead record.
            */
            list_LeadsToUpdate = [SELECT 
                                  Id,
                                  RecordTypeId,
                                  DRL_Prospect__c,
                                  DRL_Source_Campaign__c 
                                  FROM Lead 
                                  WHERE Id 
                                  IN :list_LeadsToUpdate];
                for( Lead objLead : list_LeadsToUpdate){
                    if( 
                        objLead.RecordTypeId == map_RecordTypeIdByDeveloperName.get('DRL_Lead') &&
                        objLead.DRL_Source_Campaign__c!=null && objLead.DRL_Prospect__c != null
                    ){
                        CampaignMember objCampaignMember = new CampaignMember();
                        objCampaignMember.CampaignId = objLead.DRL_Source_Campaign__c;
                        objCampaignMember.LeadId = objLead.DRL_Prospect__c; 
                        list_CampaignMembers.add(objCampaignMember);
                    }
                }
                List<Database.SaveResult> list_Results = Database.insert(list_CampaignMembers, false);
                DRL_LeadTriggerHelper.blnSkipTrigger = false;

        } catch(Exception objException) {
            DRLUtil.logException(
                'DRL_LeadTriggerHelper',
                'processAfterInsert',
                objException,
                true
            );
        }
    }
    
  
    
    /*
     * DRL - 48
     * Check if the utm Source Campaign code on incoming lead record is matching with Campaign code on Campaign records.
     * If the match exist then update the Source Campaign field on the (child) lead record with the matched Campaign record.
	 *
     * DRL - 49
     * Check if the utm Source code on incoming lead record is matching with the custom metadata UTM Source records with parameter Lable.
     * If the match exist then the matched record Lead Source value to be updated on the Lead record Lead Source field.
	 */
    public static void populateSourceCampaign(List<Lead> list_leads){
        //Attributes for DRL-48
        set<String> set_CampaignCodes = new set<String>();
        map<String,Id> map_CampaignCodeWithCampaignID = new map<String,Id>();
        //Attributes for DRL-49
        set<String> set_SourceCodes = new set<String>();
        map<String,String> map_UtmSourcelablewithLeadSource = new map<String,String>();
        
        //Fetch campaign codes from Lead records in a SET(set_CampaignCodes)
        for(Lead objLead : list_leads){
            if(objLead.DRL_UTM_Campaign__c!=null){
               set_CampaignCodes.add(objLead.DRL_UTM_Campaign__c);
            }
            
            //DRL-49 Fetch source codes from Lead records in a SET(set_SourceCodes)
            if(objLead.DRL_UTM_Source__c!=null ){
                set_SourceCodes.add(objLead.DRL_UTM_Source__c);
            }
        }
        
        //Fetch campaign records which are in the set_CampaignCodes in a MAP(map_CampaignCodeWithCampaignID)
        for(Campaign objCampaign : [SELECT 
                                    Id, 
                                    Name,
                                    DRL_CampaignCode__c 
                                    FROM Campaign 
                                    WHERE DRL_CampaignCode__c IN: set_CampaignCodes 
                                    AND IsActive = true]){
                                        if(!map_CampaignCodeWithCampaignID.containsKey(objCampaign.DRL_CampaignCode__c)){
                                            map_CampaignCodeWithCampaignID.put(objCampaign.DRL_CampaignCode__c,objCampaign.Id);
                                        }
                                    }
        //DRL-49 Fetch Lable and LeadSource__c from UTM Source metadata records in a MAP(map_UtmSourcelablewithLeadSource)
        for(DRL_UTMSource__mdt mdtUTMsource : [SELECT
                                               Id,
                                               label,
                                               LeadSource__c 
                                               FROM DRL_UTMSource__mdt 
                                               WHERE label IN: set_SourceCodes ]){
                                                   if(!map_UtmSourcelablewithLeadSource.containsKey(mdtUTMsource.Label)){
                                                       map_UtmSourcelablewithLeadSource.put(mdtUTMsource.Label,mdtUTMsource.LeadSource__c);

                                                   }
                                               }
        
        //Assign the fetched campaign records to the Source campaign field on the Lead records
        for(Lead objLead : list_leads){
            if(map_CampaignCodeWithCampaignID.containsKey(objLead.DRL_UTM_Campaign__c)){
                objLead.DRL_Source_Campaign__c = map_CampaignCodeWithCampaignID.get(objLead.DRL_UTM_Campaign__c);
            }
            
            //DRL-49 Assign the fetched Lead source to the Lead record LeadSource field
            if(map_UtmSourcelablewithLeadSource.containsKey(objLead.DRL_UTM_Source__c)){
                objLead.LeadSource = map_UtmSourcelablewithLeadSource.get(objLead.DRL_UTM_Source__c);
            }
        }
    }  
    
}