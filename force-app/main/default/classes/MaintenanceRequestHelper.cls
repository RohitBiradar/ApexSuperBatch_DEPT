/**
 * @Description: Helper class to be called in MaintenanceRequest trigger
 * @Author: Rohit
 * @Class Name: MaintenanceRequestHelper
 */

public with sharing class MaintenanceRequestHelper {

    /**
     * Desciption: Method to update the workorders when status is changed to closed where WorkOrder type could be Repair or Routine Maintenance
     * Param: List<Case> and  Map<Id,Case> nonUpdCaseMap
     * Return values: null
     */
    public static void updateworkOrders(List<Case> updWorkOrders, Map<Id,Case> nonUpdCaseMap) {

        //Variable declaration
        Set<Id> validIds = new Set<Id>(); //Set of ID to hold the caseIds of cases with Type: Repair OR Routine Maintenance
        List<Case> newCases = new List<Case>(); //List of cases to hold child cases record
        Map<Id,Decimal> maintenanceCycles = new Map<ID,Decimal>();
        Map<Id,Case> closedCasesMap = new Map<Id,Case>(); 
        List<Equipment_Maintenance_Item__c> clonedWPs = new List<Equipment_Maintenance_Item__c>();
        List<Error_Log__c> errorLogList = new List<Error_Log__c>(); //list of error logs to be inserted while performing Dynamic DML operation
        
        
        //Capturing WorkOrder Ids in the list with type Repair or Routine Maintenance and status changed to Closed
        for (Case caseInstance : updWorkOrders){
            if (nonUpdCaseMap.get(caseInstance.Id).Status != ConstantUtils.CLOSED && caseInstance.Status == ConstantUtils.CLOSED 
            && (caseInstance.Type == ConstantUtils.REPAIR || caseInstance.Type == ConstantUtils.ROUTINEMAINTENANCE)){
                validIds.add(caseInstance.Id); // assigning the case Id to the set
            }
        } // end of looping into the list of new cases
        
        //Null check to avoid null pointer exception
        if (!validIds.isEmpty() && 
            (Schema.sObjectType.Case.isAccessible() && 
            Schema.sObjectType.Case.fields.Vehicle__c.isAccessible() && 
            Schema.sObjectType.Case.fields.Equipment__c.isAccessible() && 
            Schema.sObjectType.Case.isQueryable() &&
            Schema.sObjectType.Product2.isAccessible() &&
            Schema.sObjectType.Product2.fields.Maintenance_Cycle__c.isAccessible() && 
            Schema.sObjectType.Equipment_Maintenance_Item__c.isAccessible() &&
            Schema.sObjectType.Equipment_Maintenance_Item__c.fields.Equipment__c.isAccessible() &&
            Schema.sObjectType.Equipment_Maintenance_Item__c.fields.Quantity__c.isAccessible() &&
            Schema.sObjectType.Equipment_Maintenance_Item__c.fields.Maintenance_Request__c.isAccessible())){

            //Setting up Map with the query to get the Work Order and its related child records - Equipment Mainenance
            closedCasesMap = new Map<Id,Case>([SELECT Id, Vehicle__c, Equipment__c, Equipment__r.Maintenance_Cycle__c, 
                                                          (SELECT Id,Equipment__c,Quantity__c 
                                                           FROM Equipment_Maintenance_Items__r) 
                                                         FROM Case 
                                                          WHERE Id IN :validIds]);
            
            //Using AggregateResult to get the Min value of Maintenance_Cycle__c for DUE DATE
            AggregateResult[] results = [SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c)cycle 
                                        FROM Equipment_Maintenance_Item__c 
                                        WHERE Maintenance_Request__c IN :ValidIds 
                                        GROUP BY Maintenance_Request__c];
            
            for (AggregateResult ar : results){ 
                maintenanceCycles.put((Id) ar.get(ConstantUtils.MAINTENANCEREQUEST), (Decimal) ar.get(ConstantUtils.CYCLE));
            }
            
            //Child WorkOrder gets created for each WorkOrder that gets Closed
            newCases.addAll(createChildCase(closedCasesMap.values(), maintenanceCycles));
            
            //inserting the new child cases
            Database.SaveResult[] srList = database.insert(newCases, false);
            // Iterate through each returned result
            errorLogList.addAll(dynamicDML(srList));
            
            
            //Cloning Equipment_Maintenance_Item__c for each closed Cases
            clonedWPs.addAll(cloneMaintenanceForEachClosedCase(newCases, closedCasesMap));
           
            //Dynamic Insertion
            Database.SaveResult[] srListClonedWPs = database.insert(clonedWPs, false);
            // Iterate through each returned result
            errorLogList.addAll(dynamicDML(srListClonedWPs));
        } else {
            //Logging error for field acccessbility
            Error_Log__c errorLog = ErrorLogger.createErrorLog(ConstantUtils.MAINTENANCEREQUESTHELPER, ConstantUtils.FLS_ERROR);
            errorLogList.add(errorLog);
        }

        //inserting error logs
        database.insert(errorLogList, false);
    } // end of method: updateworkOrders

    /**
     * Desciption: Method to create child case for each closed case
     * Param: List<Case> and  Map<Id,Decimal>
     * Return values: List<Case>
     */
    public static List<Case> createChildCase(List<Case> closedCasesList, Map<Id,Decimal> maintenanceCycles) {
        List<Case> newCases = new List<Case>();
        for(Case closedCaseInstance : closedCasesList){
            Case newCase = new Case (
                ParentId = closedCaseInstance.Id,
                Status = ConstantUtils.NEW_CONSTANT,
                Subject = ConstantUtils.ROUTINEMAINTENANCE,
                Type = ConstantUtils.ROUTINEMAINTENANCE,
                Vehicle__c = closedCaseInstance.Vehicle__c,
                Equipment__c =closedCaseInstance.Equipment__c,
                Origin = ConstantUtils.WEB,
                Date_Reported__c = Date.Today()
                
            );
            
            //Setting Due Date according to the maintenance cycle
            If (maintenanceCycles.containskey(closedCaseInstance.Id)){
                newCase.Date_Due__c = Date.today().addDays((Integer) maintenanceCycles.get(closedCaseInstance.Id));
            }
            
            newCases.add(newCase); //adding to the list of new cases
        }
        return newCases;
    }//end of method createChildCase

    /**
     * Desciption: Method to capture error logs while performing dynamic DML operation
     * Param: Database.SaveResult[]
     * Return values: List<Error_Log__c>
     */
    public static List<Error_Log__c> dynamicDML(Database.SaveResult[] srList){
        List<Error_Log__c> errorLogList = new List<Error_Log__c>();
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors and create Error logs              
                for(Database.Error err : sr.getErrors()) {
                    Error_Log__c errorLog = ErrorLogger.createErrorLog(ConstantUtils.MAINTENANCEREQUESTHELPER, err.getStatusCode() + ': ' + err.getMessage());
                    errorLogList.add(errorLog);
                }
            }
        }
        return errorLogList;
    }// end of method - dynamicDML
    
    /**
     * Desciption: Method to clone Maintenance Request For Each Closed Case
     * Param: Database.SaveResult[]
     * Return values: List<Error_Log__c>
     */
    public static List<Equipment_Maintenance_Item__c> cloneMaintenanceForEachClosedCase(List<Case> newCases, Map<Id,Case> closedCasesMap) {
        List<Equipment_Maintenance_Item__c> clonedWPs = new List<Equipment_Maintenance_Item__c>();
        for (Case newCaseInstance : newCases){
            for (Equipment_Maintenance_Item__c wp : closedCasesMap.get(newCaseInstance.ParentId).Equipment_Maintenance_Items__r){
                Equipment_Maintenance_Item__c wpClone = wp.clone();
                wpClone.Maintenance_Request__c = newCaseInstance.Id;
                clonedWPs.add(wpClone);
            }
        }
        return clonedWPs;
    }// end of method - cloneMaintenanceForEachClosedCase

} // end of class- MaintenanceRequestHelper