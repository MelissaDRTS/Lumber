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
        Account a = new Account(Name = 'Test Account Name', VendorNumber__c='9999');
        insert a;

        Contact c = new Contact(LastName = 'Contact Last Name', AccountId = a.id);
        insert c;

        User user = new User();
        user.ProfileID = [Select Id From Profile Where Name = 'Installer Community Plus User'].id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test@domain.com';
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        user.IsActive = true;
        user.ContactId = c.Id;
        user.Vendor_Number__c = '9999';

        insert user;
        ServiceRequest.Service_Request_Details srd = createServiceRequest();
        setupHeader(srd);
        setupNotes(srd, 1);
        setupMilestonesBlank(srd);
        setupCustomerInfo(srd);
        setupShipTo(srd);
        setupSalesOrder(srd);

        ServiceRequest.serviceRequest(srd);

        Id serviceRequest = [SELECT Id FROM Service_Request__c].Id;

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
                LinkedEntityId = serviceRequest,
                ContentDocumentId = cvId.ContentDocumentId,
                ShareType = 'I'
        );

        insert cdl1;
        ContentVersion cvId2 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testVersion2.Id];

        ContentDocumentLink cdl2 = new ContentDocumentLink(
                LinkedEntityId = serviceRequest,
                ContentDocumentId = cvId2.ContentDocumentId,
                ShareType = 'I'
        );

        insert cdl2;

        Test.startTest();


        DocumentService.WorkDocumentTimeFrame timeFrame = new DocumentService.WorkDocumentTimeFrame();
        Datetime startDatetime = System.now().addMinutes(-60);
        Datetime endDateTime = System.now();

//
//        timeFrame.startTime = startDatetime.addHours(-5);
//        timeFrame.endTime = endDateTime.addHours(-5);

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

    private static ServiceRequest.Service_Request_Details createServiceRequest() {
        ServiceRequest.Service_Request_Details srd = new ServiceRequest.Service_Request_Details();
        srd.Milestone_Dates = new ServiceRequest.Milestone_Date();
        srd.Ship_To_Address = new ServiceRequest.Ship_To_Address();
        srd.Sales_Order_Info = new List<ServiceRequest.Sales_Order_Info>();
        srd.Customer_Info = new ServiceRequest.Customer_Info();
        srd.Notes = new List<ServiceRequest.Note>();
        srd.Header = new ServiceRequest.Service_Request_Header();

        return srd;
    }

    private static void setupHeader(ServiceRequest.Service_Request_Details srd) {
        ServiceRequest.Service_Request_Header header = srd.Header;
        header.ServiceRequestNumber = '1001';
        header.Status = 'Active';
        header.CreationDate = Date.valueOf('2019-09-26');
        header.StoreNumber = '100';
        header.StoreZipCode = '23233';
        header.VendorNumber = '9999';
        header.JobScheduleDate = Date.valueOf('2019-09-26');
    }

    private static void setupNotes(ServiceRequest.Service_Request_Details srd, Integer count) {
        List<ServiceRequest.Note> nl = srd.Notes;

        for(Integer i = 0; i < count; i++){
            ServiceRequest.Note sn = new ServiceRequest.Note();
            sn.noteDate = Date.valueOf('2019-09-26');
            sn.noteTime = Time.newInstance(13, 45, 05, 0);
            sn.noteText = 'Hello, World! Test Note!';
            nl.add(sn);
        }
    }

    private static void setupMilestonesBlank(ServiceRequest.Service_Request_Details srd) {
        ServiceRequest.Milestone_Date md = srd.Milestone_Dates;
    }

    private static void setupMilestonesFilled(ServiceRequest.Service_Request_Details srd) {
        ServiceRequest.Milestone_Date md = srd.Milestone_Dates;

        md.MeasureRequestReceived = Date.valueOf('2019-09-26');
        md.MeasureRequestSent = Date.valueOf('2019-09-26');
        md.MeasureScheduled = Date.valueOf('2019-09-26');
        md.MeasurementsReceived = Date.valueOf('2019-09-26');
        md.QuoteBuilt = Date.valueOf('2019-09-26');
        md.InstallationSold = Date.valueOf('2019-09-26');
        md.ThankYouCall = Date.valueOf('2019-09-26');
        md.InstallationPaperworkSent = Date.valueOf('2019-09-26');
        md.InstallationScheduled = Date.valueOf('2019-09-26');
        md.EstimatedCompletion = Date.valueOf('2019-09-26');
        md.Pre_CallMade = Date.valueOf('2019-09-26');
        md.InstallationCompleted = Date.valueOf('2019-09-26');
        md.Post_CallMade = Date.valueOf('2019-09-26');
        md.PGI_Invoiced = Date.valueOf('2019-09-26');
        md.Cancellation = Date.valueOf('2019-09-26');
    }

    private static void setupCustomerInfo(ServiceRequest.Service_Request_Details srd) {
        ServiceRequest.Customer_Info ci = srd.Customer_Info;
        ci.CustomerNumber = '99';
        ci.CustomerName = 'Test Person';
        ci.Street = '1234 Fake Street';
        ci.City = 'Richmond';
        ci.State = 'VA';
        ci.Country = 'US';
        ci.ZipCode = '23233';
        ci.Phone = '8045555555';

    }

    private static void setupShipTo(ServiceRequest.Service_Request_Details srd) {
        ServiceRequest.Ship_To_Address sa = srd.Ship_To_Address;
        sa.ShipToStreet = '1212 Fake Street';
        sa.ShipToCity = 'Henrico';
        sa.ShipToState = 'VA';
        sa.ShipToCountry = 'US';
        sa.ShipToZipCode = '24060';
    }

    private static void setupSalesOrder(ServiceRequest.Service_Request_Details srd) {
        List<ServiceRequest.Sales_Order_Info> soi = srd.Sales_Order_Info;

        ServiceRequest.Sales_Order_Info so = new ServiceRequest.Sales_Order_Info();
        so.OrderNumber = '2222';
        so.OrderDate = Date.valueOf('2019-09-26');
        so.OrderType = 'Install';

        soi.add(so);
    }


}
