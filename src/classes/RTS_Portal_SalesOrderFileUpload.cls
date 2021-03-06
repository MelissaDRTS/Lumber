/*
* Author: Alicia Chafee, RTS Labs.
* Date: 10/2019
* Description: This class is the controller for the RTS_Portal_ServiceRequestDocumentUpload_Cmp
* 				
* 
* 
*/

public class RTS_Portal_SalesOrderFileUpload {
    
    @AuraEnabled
    public static Boolean isSalesOrder(Id recId) {
        Schema.SObjectType obj = recId.getSObjectType();
        System.debug(obj);
        String objType = String.valueOf(obj);
        if (objType == 'Sales_Order__c') {
            return true;
        }
        
        return false;
    }
    
    @AuraEnabled
    public static String getRecordType(Id recId) {
        Sales_Order__c so = [SELECT Id, RecordTypeId, Service_Request__c FROM Sales_Order__c WHERE Id = :recId LIMIT 1];
        Id rtId = so.RecordTypeId;
        RecordType rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Id = :rtId LIMIT 1];
        return rt.DeveloperName;
        
    }
    
    @AuraEnabled
    public static Id getParentServiceRequest(Id recId) {
        Sales_Order__c so = [SELECT Id, RecordTypeId, Service_Request__c FROM Sales_Order__c WHERE Id = :recId LIMIT 1];
        return so.Service_Request__c;
        
    }
    
    @AuraEnabled
    public static Boolean renameFile(String fileObject) {
        System.debug('rename file function');
        FileObject fileObj = (FileObject) JSON.deserialize(fileObject, FileObject.class);
        System.debug(fileObj);
        
        try {
            fileObj.renameDocument();
            return true;
        } catch (Exception e) {
            System.debug(e);
        }
        return false;
        
    }
    
    @AuraEnabled
    public static Boolean updateSalesOrderFileCheckboxes(String fileType, Id salesOrderId) {
        Service_Request__c sr;
        Sales_Order__c so = [SELECT Id, MeasurementsReceived__c, Service_Request__c, Customer_Completion_Form__c, Installation_Change_Authorization__c, Installation_Change_Order__c, Lien_Waiver__c, Moisture_Reading__c, Project_Assessment_Form__c, Work_Order__c FROM Sales_Order__c WHERE Id = :salesOrderId LIMIT 1];
        if (fileType == 'IPProjectAssess') {
            sr = [SELECT Id, MeasurementsReceived__c FROM Service_Request__c WHERE Id = :so.Service_Request__c LIMIT 1];
            sr.MeasurementsReceived__c = Date.today();
            so.MeasurementsReceived__c = Date.today();
            so.Project_Assessment_Form__c = true;
        } else if (fileType == 'CustCompletion') {
            so.Customer_Completion_Form__c = true;
        } else if (fileType == 'InstChangeAuth') {
            so.Installation_Change_Authorization__c = true;
        } else if (fileType == 'ChangeOrder') {
            so.Installation_Change_Order__c = true;
        } else if (fileType == 'InstLienWaiver') {
            so.Lien_Waiver__c = true;
        } else if (fileType == 'MoistureReading') {
            so.Moisture_Reading__c = true;
        } else if (fileType == 'InstWorkOrder') {
            so.Work_Order__c = true;
        } else if (fileType == 'All_Doc_WITH_CO') {
            so.Project_Assessment_Form__c = true;
            so.Customer_Completion_Form__c = true;
            so.Installation_Change_Authorization__c = true;
            so.Installation_Change_Order__c = true;
            so.Lien_Waiver__c = true;
            so.Moisture_Reading__c = true;
            so.Work_Order__c = true;
        } else if (fileType == 'All_Doc_WITO_CO') {
            so.Project_Assessment_Form__c = true;
            so.Customer_Completion_Form__c = true;
            so.Installation_Change_Authorization__c = true;
            so.Lien_Waiver__c = true;
            so.Moisture_Reading__c = true;
            so.Work_Order__c = true;
        }
        try {
            update sr;
            update so;
            return true;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return false;
        }
        
    }
    
    public class FileObject {
        @AuraEnabled public Id documentId;
        @AuraEnabled public String fileType { get; set; }
        @AuraEnabled public String newFileName { get; set; }
        
        public FileObject() {
            
        }
        
        public FileObject(String fileType, String newFileName) {
            this.fileType = fileType;
            this.newFileName = newFileName;
        }
        
        private void renameDocument() {
            System.debug('here');
            System.debug(this.newFileName);
            ContentDocument doc = [SELECT Id, Title, FileType, FileExtension FROM ContentDocument WHERE Id = :this.documentId LIMIT 1];
            System.debug(doc);
            doc.Title = this.newFileName;
            
            update doc;
            ContentDocument newDoc = [SELECT Id, Title, FileType, FileExtension FROM ContentDocument WHERE Id = :this.documentId LIMIT 1];
            System.debug(newDoc);
        }
        
        
    }
    
}