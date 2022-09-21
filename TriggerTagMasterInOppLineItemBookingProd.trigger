/*******************************************************************************************
* @author           Suman
* @version          1.0 
* @date             20-SEP-2022
* @Status           In-Progress
* @Class Name       TriggerTagMasterInOppLineItemBookingProd
* @description      
*********************************************************************************************
 Version     Date      Team          Comments
*********************************************************************************************
* 1      Sep 2022    Suman          Initial Creation
*********************************************************************************************/
trigger TriggerTagMasterInOppLineItemBookingProd on Master__c (after insert,after update) {
    public MasterTagAndForecastPlanCreationHelper helper = new MasterTagAndForecastPlanCreationHelper();
    
    if(Trigger.isInsert && helper.checkIfRecCountWithActiveFlagTrueIsMoreThan5(Trigger.New))
        Trigger.New[0].addError('More than 5 records with \'Active\' flag as true not allowed ! Either insert less than 5 records or make the flag \'Active\' false for records more than 5.');
    else if(Trigger.isUpdate && helper.checkIfRecCountWithActiveFlagTrueIsMoreThan5(Trigger.NewMap, Trigger.OldMap))
        Trigger.New[0].addError('More than 5 records with \'Active\' flag as true not allowed ! Either update less than 5 records or make the flag \'Active\' false for records more than 5.');
    
    for(Master__c masterRec : Trigger.New){
        if(String.isBlank(Trigger.NewMap.get(masterRec.Id).Opportunity_Product_Filter__c) && String.isBlank(Trigger.NewMap.get(masterRec.Id).Booking_Product_Query_Filter__c) )
            continue;
        
        if(Trigger.NewMap.get(masterRec.Id).Active__c){
            if(Trigger.isUpdate && Trigger.OldMap.get(masterRec.Id).Active__c)//If its an update, check if flag has been changed from false to true. If not, ignore those records
                continue;
            Boolean isOLIBatchExecuting = (([SELECT COUNT() FROM AsyncApexJob WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE Name = 'BatchMapMasterToOppLineItemRecs') AND (Status = 'Holding' OR Status = 'Queued' OR Status = 'Preparing' Or Status = 'Processing')]) == 0) ? false : true ;
            Boolean isBPBatchExecuting = (([SELECT COUNT() FROM AsyncApexJob WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE Name = 'BatchMapMasterToProdBookingRecs') AND (Status = 'Holding' OR Status = 'Queued' OR Status = 'Preparing' Or Status = 'Processing')]) == 0) ? false : true ;
            if(isOLIBatchExecuting || isBPBatchExecuting){
                masterRec.addError('Batch job(s) to tag Master in Opportunity Product/Booking Product is/are already running. Please try after some time!!');
                System.debug('@@@ Batch job -BatchMapMasterToOppLineItemRecs/BatchMapMasterToProdBookingRecs - already running!!');
                return;
            }
            if(String.isBlank(Trigger.NewMap.get(masterRec.Id).Opportunity_Product_Filter__c))
                database.executeBatch(new BatchMapMasterToProdBookingRecs(masterRec.Id, masterRec.Booking_Product_Query_Filter__c ));
            else    
            	database.executeBatch(new BatchMapMasterToOppLineItemRecs(masterRec.Id, masterRec.Opportunity_Product_Filter__c, masterRec.Booking_Product_Query_Filter__c ));
        }
        
    }
    
    
}