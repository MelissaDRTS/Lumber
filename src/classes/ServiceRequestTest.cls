/**
 * @author Andrew McGuiness - andrew.mcguiness@rtslabs.com
 * @date  9/10/2019
 * @description
 */

@IsTest
private class ServiceRequestTest {

    // Test 0
    @IsTest
    static void testBlankSR() {
        ServiceRequest.Service_Request_Details srd = createServiceRequest();

        Test.startTest();
        String results = ServiceRequest.serviceRequest(srd);
        Test.stopTest();

        System.assert(results.contains('Failed to create Service_Request__c'));
    }

    // Test 1
    @IsTest
    static void testSingleSR() {


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

        String results;

        //System.RunAs(user) {


            Test.startTest();
            results = ServiceRequest.serviceRequest(srd);
            Test.stopTest();
            System.debug(results);

        //}
            System.assert(results.contains('Created or Updated Service_Request__c'));

            Service_Request__c serviceRequest = [SELECT Id FROM Service_Request__c][0];
            System.assertNotEquals(null, serviceRequest);

            // Verify the customer was created
            Contact customer = [
                    SELECT Id, Customer_Number__c, FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, Phone
                    FROM Contact WHERE Customer_Number__c = '99'
            ][0];

            System.assertNotEquals(null, customer);
            System.assertEquals(srd.Customer_Info.CustomerNumber, customer.Customer_Number__c);
            System.assertEquals(srd.Customer_Info.CustomerName, customer.FirstName + ' ' + customer.LastName);
            System.assertEquals(srd.Customer_Info.Street, customer.MailingStreet);
            System.assertEquals(srd.Customer_Info.City, customer.MailingCity);
            System.assertEquals(srd.Customer_Info.State, customer.MailingState);
            System.assertEquals(srd.Customer_Info.Country, customer.MailingCountry);
            System.assertEquals(srd.Customer_Info.ZipCode, customer.MailingPostalCode);
            System.assertEquals(srd.Customer_Info.Phone, customer.Phone);

            List<ContentDocumentLink> docLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :serviceRequest.Id];
            Set<Id> docIds = new Set<Id>();
            for (ContentDocumentLink cdl : docLinks) {
                docIds.add(cdl.ContentDocumentId);
            }
            List<ContentNote> contentNotes = [SELECT Id FROM ContentNote WHERE Id IN :docIds];
            System.assertNotEquals(null, contentNotes);
            System.assertEquals(1, contentNotes.size());

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

    // Test Many
    @IsTest

    static void testManySR() {

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

        ServiceRequest.Service_Request_Details srd2 = createServiceRequest();
        setupHeader(srd2);
        setupNotes(srd2, 3);
        setupMilestonesFilled(srd2);
        srd2.Milestone_Dates.MeasureRequestReceived = Date.valueOf('1800-01-01');
        srd2.Milestone_Dates.MeasureRequestSent = Date.valueOf('1800-01-01');
        srd2.Milestone_Dates.MeasureScheduled = Date.valueOf('1800-01-01');
        srd2.Milestone_Dates.MeasurementsReceived = Date.valueOf('1800-01-01');
        srd2.Milestone_Dates.QuoteBuilt = Date.valueOf('1800-01-01');
        srd2.Milestone_Dates.InstallationSold = Date.valueOf('1800-01-01');
        srd2.Milestone_Dates.ThankYouCall = Date.valueOf('1800-01-01');
        srd2.Milestone_Dates.InstallationPaperworkSent = Date.valueOf('1800-01-01');
        srd2.Milestone_Dates.InstallationScheduled = Date.valueOf('1800-01-01');
        srd2.Milestone_Dates.EstimatedCompletion = Date.valueOf('1800-01-01');
        srd2.Milestone_Dates.Pre_CallMade = Date.valueOf('1800-01-01');
        srd2.Milestone_Dates.InstallationCompleted = Date.valueOf('1800-01-01');
        srd2.Milestone_Dates.Post_CallMade = Date.valueOf('1800-01-01');
        srd2.Milestone_Dates.PGI_Invoiced = Date.valueOf('1800-01-01');
        srd2.Milestone_Dates.Cancellation = Date.valueOf('1800-01-01');
        setupCustomerInfo(srd2);
        setupShipTo(srd2);
        setupSalesOrder(srd2);

        Test.startTest();
        String results = ServiceRequest.serviceRequest(srd);
        System.assert(results.contains('Created or Updated Service_Request__c'));
        List<Service_Request__c> serviceRequests = [SELECT Id FROM Service_Request__c];
        System.assertNotEquals(null, serviceRequests);
        System.assertEquals(1, serviceRequests.size());

        // Verify the customer was created
        List<Contact> customers = [
                SELECT Id, Customer_Number__c, FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, Phone
                FROM Contact WHERE Customer_Number__c = '99'
        ];
        System.assertNotEquals(null, customers);
        System.assertEquals(1, customers.size());

        Contact customer = customers[0];
        System.assertEquals(srd.Customer_Info.CustomerNumber, customer.Customer_Number__c);
        System.assertEquals(srd.Customer_Info.CustomerName, customer.FirstName + ' ' + customer.LastName);
        System.assertEquals(srd.Customer_Info.Street, customer.MailingStreet);
        System.assertEquals(srd.Customer_Info.City, customer.MailingCity);
        System.assertEquals(srd.Customer_Info.State, customer.MailingState);
        System.assertEquals(srd.Customer_Info.Country, customer.MailingCountry);
        System.assertEquals(srd.Customer_Info.ZipCode, customer.MailingPostalCode);
        System.assertEquals(srd.Customer_Info.Phone, customer.Phone);


        List<ContentDocumentLink> docLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :serviceRequests[0].Id];
        Set<Id> docIds = new Set<Id>();
        for(ContentDocumentLink cdl : docLinks){
            docIds.add(cdl.ContentDocumentId);
        }
        List<ContentNote> contentNotes = [SELECT Id FROM ContentNote WHERE Id IN :docIds];
        System.assertNotEquals(null, contentNotes);
        System.assertEquals(1, contentNotes.size());

        results = ServiceRequest.serviceRequest(srd2);
        System.assert(results.contains('Created or Updated Service_Request__c'));

        Test.stopTest();



        serviceRequests = [SELECT Id, MeasureRequestReceived__c, MeasurementsReceived__c, Measure_Scheduled__c, MeasureRequestSent__c, QuoteBuilt__c, InstallationSold__c, Installation_Completed__c, InstallationPaperworkSent__c, Estimated_Completion__c, PGI_Invoiced__c, Pre_CallMade__c, Post_CallMade__c, Cancellation__c FROM Service_Request__c];
        System.assertNotEquals(null, serviceRequests);
        System.assertEquals(1, serviceRequests.size());

        // Verify the customer was created
        customers = [
                SELECT Id, Customer_Number__c, FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, Phone
                FROM Contact  WHERE Customer_Number__c = '99'
        ];
        System.assertNotEquals(null, customers);
        System.assertEquals(1, customers.size());

        customer = customers[0];
        System.assertEquals(srd2.Customer_Info.CustomerNumber, customer.Customer_Number__c);
        System.assertEquals(srd2.Customer_Info.CustomerName, customer.FirstName + ' ' + customer.LastName);
        System.assertEquals(srd2.Customer_Info.Street, customer.MailingStreet);
        System.assertEquals(srd2.Customer_Info.City, customer.MailingCity);
        System.assertEquals(srd2.Customer_Info.State, customer.MailingState);
        System.assertEquals(srd2.Customer_Info.Country, customer.MailingCountry);
        System.assertEquals(srd2.Customer_Info.ZipCode, customer.MailingPostalCode);
        System.assertEquals(srd2.Customer_Info.Phone, customer.Phone);


        Service_Request__c serviceRequest = serviceRequests[0];
        System.assertEquals(null, serviceRequest.MeasureRequestReceived__c);
        System.assertEquals(null, serviceRequest.MeasurementsReceived__c);
        System.assertEquals(null, serviceRequest.Measure_Scheduled__c);
        System.assertEquals(null, serviceRequest.MeasureRequestSent__c);
        System.assertEquals(null, serviceRequest.QuoteBuilt__c);
        System.assertEquals(null, serviceRequest.InstallationSold__c);
        System.assertEquals(null, serviceRequest.Installation_Completed__c);
        System.assertEquals(null, serviceRequest.InstallationPaperworkSent__c);
        System.assertEquals(null, serviceRequest.Estimated_Completion__c);
        System.assertEquals(null, serviceRequest.PGI_Invoiced__c);
        System.assertEquals(null, serviceRequest.Pre_CallMade__c);
        System.assertEquals(null, serviceRequest.Post_CallMade__c);
        System.assertEquals(null, serviceRequest.Cancellation__c);



        docLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :serviceRequests[0].Id];
        docIds = new Set<Id>();
        for(ContentDocumentLink cdl : docLinks){
            docIds.add(cdl.ContentDocumentId);
        }
        contentNotes = [SELECT Id FROM ContentNote WHERE Id IN :docIds];
        System.assertNotEquals(null, contentNotes);
        System.assertEquals(3, contentNotes.size());


    }

    // Test Reload
    @IsTest
    static void testSRReloading() {
        ServiceRequest.Service_Request_Details srd = createServiceRequest();

        Test.startTest();
        String results = ServiceRequest.serviceRequest(srd);
        Test.stopTest();

        System.assert(results.contains('Failed to create Service_Request__c'));
    }



}