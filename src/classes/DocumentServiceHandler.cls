/**
 * Created by melissaderricott on 10/13/19.
 */

public with sharing class DocumentServiceHandler {

    public List<DocumentService.workDocumentData> handleGetDocuments(DocumentService.WorkDocumentTimeFrame timeFrame, List<String> errorLog){
        List<ContentDocumentLink> createContentDocumentLinks;
        //1
        try{
            createContentDocumentLinks =  getContentDocumentLinks(timeFrame.startTime, timeFrame.endTime);
        } catch (Exception e){
            errorLog.add('Exception: ' + e.getMessage());
        }
        //2
        Map<Id, Service_Request__c> createServiceRequestMap = getServiceRequestNumbers(createContentDocumentLinks);
        //3

        Map<String, Blob> createContentVersionMap = getBase64Data(createContentDocumentLinks);

        //4
        List<DocumentService.workDocumentData> results = new List<DocumentService.workDocumentData>();
        if(createContentDocumentLinks == null){
            errorLog.add('Failed to retrieve metadata for Documents');
        } else if(createContentDocumentLinks.size() == 0){
            errorLog.add('No results for specified timeframe.');
        } else {
            getWorkDocuments(createContentDocumentLinks, createServiceRequestMap, createContentVersionMap, errorLog, results);
        }


        return results;

    }
       //1. List of ContentDocumentLink for additional query (params start and end datetime)
    // Get list of ContentDocumentLinks from ServiceRequest__c.  These are the attached files from Service Request
    // Data in list:  ContentDocumentId (to get VersionData: base64), LinkedEntityId (ServiceRequest Id), SystemModStamp, Title of Document
    // Parse list to only include Signed documents

    private List<ContentDocumentLink> getContentDocumentLinks(Datetime startTime, Datetime endTime){
        Datetime tzStartTime = startTime.addHours(4);
        Datetime tzEndTime = endTime.addHours(4);

       return [
                SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.SystemModstamp
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN (SELECT Id FROM Service_Request__c)
                AND ContentDocument.SystemModstamp <= :tzEndTime
                AND ContentDocument.SystemModstamp >= :tzStartTime
                AND ContentDocument.title LIKE 'Signed_%'
       ];
    }

    ///2. Map of ServiceRequest Numbers (params list of ContentDocumentLink)
    /// Map<Id, String> ContentDocumentLink Id, ServiceRequestNumber__c

    private Map<Id, Service_Request__c> getServiceRequestNumbers(List<ContentDocumentLink> contentDocumentLinks){

        Set<Id> srIds = new Set<Id>();

        for(ContentDocumentLink entity : contentDocumentLinks){
            srIds.add(entity.LinkedEntityId);
        }

        Map<ID, Service_Request__c> serviceRequestMap = new Map<ID, Service_Request__c>([SELECT Id, ServiceRequestNumber__c FROM Service_Request__c WHERE Id IN :srIds]);

        return serviceRequestMap;
    }

    //3. Map<Id, Blob> ContentDocumentId, VersionData from query (Params ContentDocumentLink list)
    // Query ContentVersion for Blob
    private Map<String, Blob> getBase64Data(List<ContentDocumentLink> contentDocumentLinks){
        Set<Id> cdlIds = new Set<Id>();

        for(ContentDocumentLink contentDocumentId : contentDocumentLinks){
            cdlIds.add(contentDocumentId.ContentDocumentId);
        }

        Map<String, Blob> blobMap = new Map<String, Blob>();

        List<ContentVersion> listOfContent = [SELECT Id, ContentDocumentId, title, VersionData FROM ContentVersion Where ContentDocumentId IN :cdlIds];

        for (ContentVersion content: listOfContent){
            blobMap.put(content.ContentDocumentId, content.VersionData);
        }

        return blobMap;

    }


    //4. create Response (Params list of ContentDocumentLink, Map of ServiceRequestNumbers__c, Map of Blob) )
    //for ContentDocumentLink item: ContentDocumentLInk create response
    //Service Number = Map servicerequest.get(LinkedEntityId)
    //Blob = Map Blob.get(ContentDocumentId)
    //fileName = item.Content.title

    private void getWorkDocuments(List<ContentDocumentLink> contentDocumentLinks, Map<Id, Service_Request__c> serviceRequestMap, Map<String, Blob> contentVersionMap, List<String> errorLog, List<DocumentService.workDocumentData> results){

        for (ContentDocumentLink contentDocumentLink : contentDocumentLinks){
            try {
                DocumentService.WorkDocumentData response = new DocumentService.WorkDocumentData();

                response.data = contentVersionMap.get(contentDocumentLink.ContentDocumentId);
                response.serviceRequestId = serviceRequestMap.get(contentDocumentLink.LinkedEntityId).ServiceRequestNumber__c;
                response.fileName = contentDocumentLink.ContentDocument.title;

                results.add(response);

            } catch (Exception e){
                errorLog.add('Exception: ' + e.getMessage());
            }

        }

    }





}