public class BatchMapMasterToProdBookingRecs implements Database.Batchable<sObject>{
    MasterTagAndForecastPlanCreationHelper helper;
    //MasterTagAndForecastCreationSettings__mdt  masterTagSetting;
    String filterQuery = MasterTagAndForeCastCreationConstant.EMPTY_STRING;
    Id masterId;
    
    public BatchMapMasterToProdBookingRecs(Id masterId, String filterQueryString){
        helper = new MasterTagAndForecastPlanCreationHelper();
        //masterTagSetting = MasterTagAndForecastCreationSettings__mdt.getInstance('Master_Tag_Settings');
        this.filterQuery = filterQueryString; 
        this.masterId = masterId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Master__c FROM Bookings_Products__c WHERE '+ filterQuery + ' AND Master__c = NULL';
        System.debug(' @@@ Query - ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Bookings_Products__c> bookingProdRecList){
        System.debug('@@@ bookingProdRecList - ' + bookingProdRecList.size());
        
        List<Bookings_Products__c> toBeUpdatedBookProdItemList = new List<Bookings_Products__c>();
        for(Bookings_Products__c item : bookingProdRecList){
            item.Master__c = masterId;
            toBeUpdatedBookProdItemList.add(item);
        }
        try{
            if(toBeUpdatedBookProdItemList.size() > 0)
                update toBeUpdatedBookProdItemList;
        }catch(Exception e){
            System.debug('Exception occured while inserting forecast records-BatchMapMasterToProdBookingRecs!');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }    
}