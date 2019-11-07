/**
 * @author Andrew McGuiness - andrew.mcguiness@rtslabs.com
 * @date  9/10/2019
 * @description
 */
@IsTest
private class DocumentServiceTest {
    @IsTest
    static void testEmpty() {
        Test.startTest();
        DocumentService.WorkDocumentTimeFrame timeFrame = new DocumentService.WorkDocumentTimeFrame();
        timeFrame.startTime = System.now().addMinutes(-15).addHours(-4);
        timeFrame.endTime = System.now().addHours(-4);

        DocumentService.DocumentServiceResponse serviceDocuments = DocumentService.getNewServiceDocuments(timeFrame);
        Test.stopTest();

        System.assertNotEquals(null, serviceDocuments);
        System.assertEquals(0, serviceDocuments.workDocumentsCount);

        System.debug(serviceDocuments);
    }


    @IsTest
    static void testFetch() {
        User testUser = [SELECT Id, Name  FROM User WHERE Name = 'RTS Labs'];

        Service_Request__c testSRequest = new Service_Request__c(
                Name = 'Test Service Request',
                Community_User__c = testUser.Id
        );


        insert testSRequest;

        // Test Document WITH the proper formatting.
        ContentVersion testVersion = new ContentVersion(
                Title = 'Signed_User Named Document_install_1234',
                //PathOnClient = 'C:\\TEST_TEST\\THIS IS A TEST.pdf',
                VersionData = Blob.valueOf('Hello World'),
                PathOnClient = 'ionicLogo.pdf',
                ContentLocation = 'S'
        );
        insert testVersion;

        // Test Document without the proper formatting.
        ContentVersion testVersion2 = new ContentVersion(
                Title = 'Test without cool format',
                //PathOnClient = 'C:\\TEST_TEST\\THIS IS A TEST.pdf',
                VersionData = Blob.valueOf('Hello World'),
                PathOnClient = 'ionicLogo.pdf',
                ContentLocation = 'S'
        );
        insert testVersion2;
        ContentVersion cvId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testVersion.Id];

        ContentDocumentLink cdl1 = new ContentDocumentLink(
                LinkedEntityId = testSRequest.Id,
                ContentDocumentId = cvId.ContentDocumentId,
                ShareType = 'I'
        );

        insert cdl1;
        ContentVersion cvId2 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testVersion2.Id];

        ContentDocumentLink cdl2 = new ContentDocumentLink(
                LinkedEntityId = testSRequest.Id,
                ContentDocumentId = cvId2.ContentDocumentId,
                ShareType = 'I'
        );

        insert cdl2;

        Test.startTest();
        DocumentService.WorkDocumentTimeFrame timeFrame = new DocumentService.WorkDocumentTimeFrame();
        Datetime startDatetime = System.now().addMinutes(-60);
        Datetime endDateTime = System.now();


        timeFrame.startTime = startDatetime.addHours(-4);
        timeFrame.endTime = endDateTime.addHours(-4);

        System.debug(timeFrame);

        DocumentService.DocumentServiceResponse serviceDocuments = DocumentService.getNewServiceDocuments(timeFrame);
        Test.stopTest();


        System.assertNotEquals(null, serviceDocuments);
        System.assertEquals(1, serviceDocuments.workDocumentsCount);
        System.debug(serviceDocuments);

        DocumentService.DocumentServiceResponse wd = serviceDocuments;
        System.debug(wd.workDocumentsCount);
        System.debug(wd.workDocumentsData);
        System.debug(wd.errors);

    }

}
