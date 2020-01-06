/**
 * Created by melissaderricott on 12/18/19.
 */

@IsTest
private class AttachmentQueryEmailControllerTest {

    static testmethod void testScheduleApex() {

        Test.startTest();


        Service_Request__c sr = new Service_Request__c();
        sr.Name = 'Test SR';
        sr.ServiceRequestNumber__c = '0000';

        insert sr;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test document';
        cv.VersionData = Blob.toPdf('This is a sample document');
        cv.PathOnClient = 'iconicLogo.pdf';
        cv.ContentLocation =  'S';

        insert cv;

        ContentVersion testCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = testCV.ContentDocumentId;
        cdl.LinkedEntityId = sr.Id;
        cdl.ShareType = 'I';

        insert cdl;


        String jobId = System.schedule('testBasicScheduledApex','0 0 0 3 9 ? 2025',new AttachmentQueryEmailController());

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id =:jobId];

        System.assertEquals('0 0 0 3 9 ? 2025', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2025-09-03 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();

        System.assertEquals('Test document', [SELECT Id, Title FROM ContentVersion WHERE Id =:cv.Id].Title);

        System.assertEquals('Test SR', [SELECT Id, Name FROM Service_Request__c WHERE Id = :sr.Id].Name);

    }
}