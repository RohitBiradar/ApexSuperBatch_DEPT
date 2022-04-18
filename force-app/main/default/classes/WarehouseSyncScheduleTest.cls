/**
 * @Description: test class for TESTING WarehouseSyncSchedule class
 * @Author: Rohit
 * @Class Name: WarehouseSyncScheduleTest
 */

@isTest
public class WarehouseSyncScheduleTest {
   
    //test method 
    @isTest 
    public static void WarehousescheduleTest(){
        //setting up schedule time
        String scheduleTime = '00 00 01 * * ?';

        //test start
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        String jobID=System.schedule('Warehouse Time To Schedule to Test', scheduleTime, new WarehouseSyncSchedule());
        Test.stopTest(); //test stops

        //Contains schedule information for a scheduled job. CronTrigger is similar to a cron job on UNIX systems.
        // This object is available in API version 17.0 and later.
        CronTrigger a=[SELECT Id FROM CronTrigger where NextFireTime > today];

        //assert statement
        System.assertEquals(jobID, a.Id,'Schedule ');
       
    }
}