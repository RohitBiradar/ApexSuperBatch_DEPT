/**
 * @Description: Schedulable class for scheduling the equipement creation
 * @Author: Rohit
 * @Class Name: WarehouseSyncSchedule
 */

global class WarehouseSyncSchedule implements Schedulable {

    /**
     * Desciption: execute method to call WarehouseCalloutService.runWarehouseEquipmentSync
     * Param: SchedulableContext
     * Return values: null
     */
    global void execute(SchedulableContext ctx) {
        
        //calling callout class
        WarehouseCalloutService.runWarehouseEquipmentSync();
    }
}