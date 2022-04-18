/**
 * @Description: Apex class for creating Error logs
 * @Author: Rohit
 * @Class Name: ErrorLogger
 */

public with sharing class ErrorLogger {

    /**
     * Desciption: Method to create error logs
     * Param: Class Name and Error message
     * Return values: Error_Log__c
     */
    public STATIC Error_Log__c createErrorLog(String className, String errorMessage) {
        Error_Log__c errorLog = new Error_Log__c();
        errorLog.Class_Name__c = className;
        errorLog.Error_message__c = errorMessage;
        errorLog.User_Name__c = UserInfo.getUserId();
        return errorLog;
    }
}