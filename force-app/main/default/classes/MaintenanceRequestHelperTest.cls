/**
 * @Description: Test class of MaintenanceRequestHelper
 * @Author: Rohit
 * @Class Name: MaintenanceRequestHelperTest
 */
@istest
public with sharing class MaintenanceRequestHelperTest {
    
    /**
     * Desciption:method to test the positive use case of MaintenanceRequestHelper
     * Param: Null
     * Return values: null
     */
    @istest
    private static void testMaintenanceRequestPositive(){
        User userObj = TestUtility.createUser();
        insert userObj;
        
        System.runas(userObj) {
            Vehicle__c vehicle = TestUtility.createVehicle();
            insert vehicle;
            id vehicleId = vehicle.Id; 
            
            Product2 equipment = TestUtility.createEq();
            insert equipment;
            id equipmentId = equipment.Id;
            
            case somethingToUpdate = TestUtility.createMaintenanceRequest(vehicleId,equipmentId);
            insert somethingToUpdate;
            
            Equipment_Maintenance_Item__c workP = TestUtility.createWorkPart(equipmentId,somethingToUpdate.id);
            insert workP;
            
            test.startTest();
            somethingToUpdate.status = TestUtility.CLOSED;
            update somethingToUpdate;
            test.stopTest();
            
            Case newReq = [Select id, subject, type, Equipment__c, Date_Reported__c, Vehicle__c, Date_Due__c
                        from case
                        where status =:TestUtility.STATUS_NEW];
            
            Equipment_Maintenance_Item__c workPart = [select id
                                                    from Equipment_Maintenance_Item__c
                                                    where Maintenance_Request__c =:newReq.Id];
            
            //assert statements
            system.assert(workPart != null);
            system.assert(newReq.Subject != null);
            system.assertEquals(newReq.Type, TestUtility.REQUEST_TYPE);
            SYSTEM.assertEquals(newReq.Equipment__c, equipmentId);
            SYSTEM.assertEquals(newReq.Vehicle__c, vehicleId);
            SYSTEM.assertEquals(newReq.Date_Reported__c, system.today());
        }
    }
    
    /**
     * Desciption:method to test the negative use case of MaintenanceRequestHelper
     * Param: Null
     * Return values: null
     */
    @istest
    private static void testMaintenanceRequestNegative(){
        User userObj = TestUtility.createUser();
        insert userObj;
        
        System.runas(userObj) {
            Vehicle__C vehicle = TestUtility.createVehicle();
            insert vehicle;
            id vehicleId = vehicle.Id;
            
            product2 equipment = TestUtility.createEq();
            insert equipment;
            id equipmentId = equipment.Id;
            
            case emptyReq = TestUtility.createMaintenanceRequest(vehicleId,equipmentId);
            insert emptyReq;
            
            Equipment_Maintenance_Item__c workP = TestUtility.createWorkPart(equipmentId, emptyReq.Id);
            insert workP;
            
            test.startTest();
            emptyReq.Status = TestUtility.WORKING;
            update emptyReq;
            test.stopTest();
            
            list<case> allRequest = [select id 
                                    from case];
            
            Equipment_Maintenance_Item__c workPart = [select id 
                                                    from Equipment_Maintenance_Item__c 
                                                    where Maintenance_Request__c = :emptyReq.Id];
            //assert statements
            system.assert(workPart != null);
            system.assert(allRequest.size() == 1);
        }
    }

    /**
     * Desciption:method to test the bulk scenario case of MaintenanceRequestHelper
     * Param: Null
     * Return values: null
     */
    @istest
    private static void testMaintenanceRequestBulk(){
        User userObj = TestUtility.createUser();
        insert userObj;
        
        System.runas(userObj) {
            list<Vehicle__C> vehicleList = new list<Vehicle__C>();
            list<Product2> equipmentList = new list<Product2>();
            list<Equipment_Maintenance_Item__c> workPartList = new list<Equipment_Maintenance_Item__c>();
            list<case> requestList = new list<case>();
            list<id> oldRequestIds = new list<id>();
            
            for(integer i = 0; i < 300; i++){
            vehicleList.add(TestUtility.createVehicle());
                equipmentList.add(TestUtility.createEq());
            }
            insert vehicleList;
            insert equipmentList;
            
            for(integer i = 0; i < 300; i++){
                requestList.add(TestUtility.createMaintenanceRequest(vehicleList.get(i).id, equipmentList.get(i).id));
            }
            insert requestList;
            
            for(integer i = 0; i < 300; i++){
                workPartList.add(TestUtility.createWorkPart(equipmentList.get(i).id, requestList.get(i).id));
            }
            insert workPartList;
            
            test.startTest();
            for(case req : requestList){
                req.Status = TestUtility.CLOSED;
                oldRequestIds.add(req.Id);
            }
            update requestList;
            test.stopTest();
            
            list<case> allRequests = [select id
                                    from case
                                    where status =: TestUtility.STATUS_NEW];
            
            list<Equipment_Maintenance_Item__c> workParts = [select id
                                                            from Equipment_Maintenance_Item__c
                                                            where Maintenance_Request__c in: oldRequestIds];
            //assert statements
            system.assert(allRequests.size() == 300);
        }
    }
}