/*******************************************************************************************
* @author           Suman
* @version          1.0 
* @date             19-SEP-2022
* @Status           In-Progress
* @Class Name       BatchYearlyPlanCreation
* @description      (TL-222)This batch shall create one Plan record for each active Master record.
*********************************************************************************************
 Version     Date      Team          Comments
*********************************************************************************************
* 1      Sep 2022    Suman          Initial Creation
*********************************************************************************************/
public class BatchYearlyPlanCreation implements Database.Batchable<sObject>{
    MasterTagAndForecastPlanCreationHelper helper;
    
    public BatchYearlyPlanCreation(){
        helper = new MasterTagAndForecastPlanCreationHelper();
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Name, Id FROM Master__c WHERE Active__c = true LIMIT 2';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Master__c> masterRecords){
        List<Plan__c> toBeCreatedPlanRecList = new List<Plan__c>();
        for(Master__c masterRec : masterRecords){
            Plan__c planRec = new Plan__c(Name = masterRec.Name + '_Plan_Y' + System.Today().year(),
                                                      Date__c = System.today(), Master__c = masterRec.Id, Owner__c = UserInfo.getUserId());
            toBeCreatedPlanRecList.add(planRec);
        }
        
        if(toBeCreatedPlanRecList.size() > 0){
            try{
                insert toBeCreatedPlanRecList;
            }catch(Exception e){
                System.debug('Exception occured while inserting plan records-BatchYearlyPlanCreation!');
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
            }
        }
        
    }
    
    public void finish(Database.BatchableContext BC){
    }
}