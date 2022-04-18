/**
 * @Description: Utility class to be used for testing
 * @Author: Rohit
 * @Class Name: TestUtility
 */

public with sharing class TestUtility {
    public static final string STATUS_NEW = 'New';
    public static final string WORKING = 'Working';
    public static final string CLOSED = 'Closed';
    public static final string REPAIR = 'Repair';
    public static final string REQUEST_ORIGIN = 'Web';
    public static final string REQUEST_TYPE = 'Routine Maintenance';
    public static final string REQUEST_SUBJECT = 'Testing subject';
    
    /**
     * Desciption: Method to create Vehicle
     * Param: NULL
     * Return values: Vehicle__c
     */
    public static Vehicle__c createVehicle(){
        Vehicle__c Vehicle = new Vehicle__C(name = 'SuperTruck');
        return Vehicle;
    }
    
    /**
     * Desciption: Method to create Equipment
     * Param: NULL
     * Return values: Product2
     */
    public static Product2 createEq(){
        product2 equipment = new product2(name = 'SuperEquipment',
                                         lifespan_months__C = 10,
                                         maintenance_cycle__C = 10,
                                         replacement_part__c = true);
        return equipment;
    }
    
    /**
     * Desciption: Method to create Maintenance Request
     * Param: ID and ID
     * Return values: Case
     */
    public static Case createMaintenanceRequest(Id vehicleId, Id equipmentId){
        case cs = new case(Type=REPAIR,
                          Status=STATUS_NEW,
                          Origin=REQUEST_ORIGIN,
                          Subject=REQUEST_SUBJECT,
                          Equipment__c=equipmentId,
                          Vehicle__c=vehicleId);
        return cs;
    }
    
    /**
     * Desciption: Method to create Equipment Mainteanance Item (Work Part)
     * Param: ID and ID
     * Return values: Equipment_Maintenance_Item__c
     */
    public static Equipment_Maintenance_Item__c createWorkPart(Id equipmentId,Id requestId){
        Equipment_Maintenance_Item__c wp = new Equipment_Maintenance_Item__c(Equipment__c = equipmentId,
                                                                            Maintenance_Request__c = requestId);
        return wp;
    }

    /**
     * Desciption: Method to create User
     * Param: NULL
     * Return values: USER
     */
    public static User createUser() {
        Profile profileObj = [Select Id from Profile where name = 'System Administrator'];
            
        User userObj = new User(ProfileId = profileObj.Id,
                                Username = 'testtermsconditions12323@apexDept.com',
                                Alias = 'batman',
                                Email='testtermsconditions12323@apexDept.com',
                                EmailEncodingKey='UTF-8',
                                Firstname='Bruce',
                                Lastname='Wayne',
                                LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US',
                                TimeZoneSidKey='America/Chicago');
        return userObj;
    }//end of createUser
}//end of TestUtility