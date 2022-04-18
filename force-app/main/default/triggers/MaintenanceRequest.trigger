/**
 * @Description: trigger on object Case
 * @Author: Rohit
 * @Trigger Name: MaintenanceRequest
 */
trigger MaintenanceRequest on Case (before update, after update) {
    if(Trigger.isUpdate && Trigger.isAfter){
        //call to updated the workorder logic from helper class
        MaintenanceRequestHelper.updateWorkOrders(Trigger.New, Trigger.OldMap);
    }
}