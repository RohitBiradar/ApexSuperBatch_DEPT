/**
 * @Description: callout class for TESTING connection with the endpoint
 * @Author: Rohit
 * @Class Name: WarehouseCalloutServiceMock
 */

@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock {
    // implement http mock callout
    global static HttpResponse respond(HttpRequest request){
        //Assert statement
        System.assertEquals(ConstantUtils.WAREHOUSE_URL, request.getEndpoint());
        System.assertEquals(ConstantUtils.GET, request.getMethod());
        
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"_id":"55d66226726b611100aaf741","replacement":false,"quantity":5,"name":"Generator 1000 kW","maintenanceperiod":365,"lifespan":120,"cost":5000,"sku":"100003"}]');
        response.setStatusCode(200);
        return response;
    }
}