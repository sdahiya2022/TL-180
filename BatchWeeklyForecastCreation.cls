/*******************************************************************************************
* @author           Suman
* @version          1.0 
* @date             15-SEP-2022
* @Status           In-Progress
* @Class Name       BatchWeeklyForecastCreation
* @description      (TL-217)This batch shall create one Forecast record for each active Master record.
*********************************************************************************************
 Version     Date      Team          Comments
*********************************************************************************************
* 1      Sep 2022    Suman          Initial Creation
*********************************************************************************************/
public class BatchWeeklyForecastCreation implements Database.Batchable<sObject>{
    MasterTagAndForecastPlanCreationHelper helper;
    
    public BatchWeeklyForecastCreation(){
        helper = new MasterTagAndForecastPlanCreationHelper();
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Name, Id FROM Master__c WHERE Active__c = true';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Master__c> masterRecords){
        List<Forecast__c> toBeCreatedForecastRecList = new List<Forecast__c>();
        for(Master__c masterRec : masterRecords){
            Forecast__c forecastRec = new Forecast__c(Name = masterRec.Name + '_Forecast_W' + helper.isoWeekNumber(System.today()) + '_Y' + System.Today().year(),
                                                      Date__c = System.today(), Master__c = masterRec.Id, Owner__c = UserInfo.getUserId());
            toBeCreatedForecastRecList.add(forecastRec);
        }
        
        if(toBeCreatedforecastRecList.size() > 0){
            try{
                insert toBeCreatedForecastRecList;
            }catch(Exception e){
                System.debug('Exception occured while inserting forecast records-BatchWeeklyForecastCreation!');
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
            }
        }
        
    }
    
    public void finish(Database.BatchableContext BC){
    }
}