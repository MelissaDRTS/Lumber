/**
 * Created by melissaderricott on 11/4/19.
 */

@IsTest
private class DownloadPDFTest {
    @IsTest
    static void testBehavior() {

        User testUsr = [SELECT Id FROM User WHERE Name = 'RTS Labs'];

        Service_Request__c sRequest = new Service_Request__c(
                Name = 'Test Service Request',
                ServiceRequestNumber__c = '1234',
                Community_User__c = testUsr.Id
        );
        insert sRequest;

        RecordType rTypeId = [SELECT Id FROM RecordType WHERE Name = 'Install Order'];

        Sales_Order__c salesOrder = new Sales_Order__c(
                Name = 'Test Sales Order',
                SalesOrderNumber__c = '1245',
                Service_Request__c = srequest.Id,
                RecordTypeId = rTypeId.Id
        );
        insert salesOrder;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DownloadPDFMock());
        Boolean testResultsString = DownloadPDF.handlePdfDownload(salesOrder.Id);

        Test.stopTest();

        System.debug(testResultsString);


    }

}