/*******************************************************************************************
* @author           Suman
* @version          1.0 
* @date             13-SEP-2022
* @Status           In-Progress
* @Class Name       BatchMapMasterToOppLineItemRecs
* @description      (TL-211)This batch shall query all ‘Opportunity Product’ and check which 'Master’ record satisfies 
					the criteria and update lookup in ‘Opportunity Product’ records.
*********************************************************************************************
 Version     Date      Team          Comments
*********************************************************************************************
* 1      Sep 2022    Suman          Initial Creation
*********************************************************************************************/

public class BatchMapMasterToOppLineItemRecs implements Database.Batchable<sObject>{
    MasterTagAndForecastPlanCreationHelper helper;
    //MasterTagAndForecastCreationSettings__mdt  masterTagSetting;
    String oppLineItemfilterQuery = MasterTagAndForeCastCreationConstant.EMPTY_STRING;
    String bookingProdfilterQuery = MasterTagAndForeCastCreationConstant.EMPTY_STRING;
    Id masterId;
    
    public BatchMapMasterToOppLineItemRecs(Id masterId, String oppLineItemfilterQueryString, String bookingProdfilterQueryString){
        helper = new MasterTagAndForecastPlanCreationHelper();
        //masterTagSetting = MasterTagAndForecastCreationSettings__mdt.getInstance('Master_Tag_Settings');
        this.oppLineItemfilterQuery = oppLineItemfilterQueryString; 
        this.bookingProdfilterQuery = bookingProdfilterQueryString; 
        this.masterId = masterId;
	}
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Master__c FROM OpportunityLineItem WHERE '+ oppLineItemfilterQuery + ' AND Master__c = NULL';
        System.debug(' @@@ Query - ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<OpportunityLineItem> oppLineItemRecList){
        System.debug('@@@ oppLineItemRecList - ' + oppLineItemRecList.size());
        
        List<OpportunityLineItem> toBeUpdatedoppLineItemList = new List<OpportunityLineItem>();
        for(OpportunityLineItem item : oppLineItemRecList){
            item.Master__c = masterId;
            toBeUpdatedoppLineItemList.add(item);
        }
        try{
            if(toBeUpdatedoppLineItemList.size() > 0)
                update toBeUpdatedoppLineItemList;
        }catch(Exception e){
            System.debug('Exception occured while inserting forecast records-BatchMapMasterToOppLineItemRecs!');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
        
    }
    
    public void finish(Database.BatchableContext BC){
        if(!String.isBlank(bookingProdfilterQuery))
        	database.executeBatch(new BatchMapMasterToProdBookingRecs(masterId, bookingProdfilterQuery));
    }    
}