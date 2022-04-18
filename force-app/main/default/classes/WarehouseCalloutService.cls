/**
 * @Description: callout class for connection with the endpoint
 * @Author: Rohit
 * @Class Name: WarehouseCalloutService
 */

public with sharing class WarehouseCalloutService {

    //Future method in real scneario to callout the endpoint and send the request json
    //@future(callout=true)
    public static void runWarehouseEquipmentSync(){
        
        //variable declaration
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        List<Object> jsonResponse = new List<Object>();
        List<Product2> warehouseEq = new List<Product2>();
        List<Error_Log__c> errorLogList = new List<Error_Log__c>(); //list of error logs to be inserted while performing Dynamic DML operation
        
        request.setEndpoint(ConstantUtils.WAREHOUSE_URL);
        request.setMethod(ConstantUtils.GET);
        HttpResponse response = http.send(request);

        //to proceed if status code is 200
        if (response.getStatusCode() == 200 && 
            (Schema.sObjectType.Product2.isAccessible() && 
            Schema.sObjectType.Product2.fields.Replacement_Part__c.isAccessible() && 
            Schema.sObjectType.Product2.fields.Maintenance_Cycle__c.isAccessible() &&
            Schema.sObjectType.Product2.fields.Lifespan_Months__c.isAccessible() &&
            Schema.sObjectType.Product2.fields.Cost__c.isAccessible() &&
            Schema.sObjectType.Product2.fields.Warehouse_SKU__c.isAccessible() &&
            Schema.sObjectType.Product2.fields.Current_Inventory__c.isAccessible())){
            jsonResponse = (List<Object>)JSON.deserializeUntyped(response.getBody()); //deserializing the response body into list of Object
            
            //looping statement
            for (Object eq : jsonResponse){
                Map<String,Object> mapJson = (Map<String,Object>)eq;
                Product2 myEq = new Product2();
                myEq.Replacement_Part__c = (Boolean) mapJson.get(ConstantUtils.REPLACEMENT);
                myEq.Name = (String) mapJson.get(ConstantUtils.NAME);
                myEq.Maintenance_Cycle__c = (Integer) mapJson.get(ConstantUtils.MAINTENANCEPERIOD);
                myEq.Lifespan_Months__c = (Integer) mapJson.get(ConstantUtils.LIFESPAN);
                myEq.Cost__c = (Decimal) mapJson.get(ConstantUtils.LIFESPAN);
                myEq.Warehouse_SKU__c = (String) mapJson.get(ConstantUtils.SKU);
                myEq.Current_Inventory__c = (Double) mapJson.get(ConstantUtils.QUANTITY);
                warehouseEq.add(myEq);
            }//end of looping statement
            
            if (warehouseEq.size() > 0){
                //upserting the list of warehouse equipment
                Database.UpsertResult[] srListClonedWPs = database.upsert(warehouseEq, false);

                // Iterate through each returned result
                for (Database.UpsertResult sr : srListClonedWPs) {
                    if (sr.isSuccess()) {
                        //Success
                    }
                    else {
                        // Operation failed, so get all errors and create Error logs                 
                        for(Database.Error err : sr.getErrors()) {
                            Error_Log__c errorLog = ErrorLogger.createErrorLog(ConstantUtils.WAREHOUSECALLOUTSERVICE, err.getStatusCode() + ': ' + err.getMessage());
                            errorLogList.add(errorLog);
                        }
                    }
                }
                //inserting error logs
                database.insert(errorLogList, false);
            }
            
        } else {
            //Logging error for field acccessbility
            Error_Log__c errorLog = ErrorLogger.createErrorLog(ConstantUtils.WAREHOUSECALLOUTSERVICE, ConstantUtils.FLS_ERROR);
            errorLogList.add(errorLog);
        }
    }
}