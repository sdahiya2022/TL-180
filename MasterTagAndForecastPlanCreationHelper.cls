/*******************************************************************************************
* @author           Suman
* @version          1.0 
* @date             13-SEP-2022
* @Status           In-Progress
* @Class Name       MasterTagAndForecastPlanCreationHelper
* @description      This will be a utility/helper class for batch - BatchMapMasterToOppLineItemRecs,
					BatchWeeklyForecastCreation,BatchYearlyPlanCreation.
*********************************************************************************************
 Version     Date      Team          Comments
*********************************************************************************************
* 1      Sep 2022    Suman          Initial Creation
*********************************************************************************************/
public class MasterTagAndForecastPlanCreationHelper {
    
    public Integer isoWeekNumber(Date value) {
        Integer daysSince1900_01_07 = Date.newInstance(1900, 1, 7).daysBetween(value);
        Integer dayNumber = Math.mod(daysSince1900_01_07, 7) + 1;
        
        Date dateForYear = value.addDays(Math.mod(8 - dayNumber, 7) - 3);
        Integer year = dateForYear.year();
        Date year_01_01 = Date.newInstance(year, 1, 1);
        
        Integer week = (Integer)Math.floor((year_01_01.daysBetween(value) + 
                                            Math.mod((Math.mod(Date.newInstance(1900, 1, 7).daysBetween(year_01_01), 7) + 1) + 1, 7) - 3) / 7 + 1);
        
        return week;
    }
    
    public Boolean checkIfRecCountWithActiveFlagTrueIsMoreThan5(Map<Id,Master__c> masterRecMap, Map<Id,Master__c> oldMasterRecMap){
        Integer recordCountWithActiveFlagTrue = 0;
        for(Id recId : masterRecMap.keySet()){
            if(masterRecMap.get(recId).Active__c && !oldMasterRecMap.get(recId).Active__c)
                recordCountWithActiveFlagTrue++;
            if(recordCountWithActiveFlagTrue == 5)
                return true;
        }
        return false;
    }
    
    public Boolean checkIfRecCountWithActiveFlagTrueIsMoreThan5(List<Master__c> masterRecList){
        Integer recordCountWithActiveFlagTrue = 0;
        for(Master__c newMasterRec : masterRecList){
            if(newMasterRec.Active__c)
                recordCountWithActiveFlagTrue++;
            if(recordCountWithActiveFlagTrue == 5)
                return true;
        }
        return false;
    }
    
}