/**
 * @author Andrew McGuiness - andrew.mcguiness@rtslabs.com
 * @date  9/10/2019
 * @description
 *
 * Edit
 */

global without sharing class DocumentService {
    global class WorkDocumentTimeFrame {
        webservice Datetime startTime;
        webService Datetime endTime;
    }

    global class WorkDocumentData {
        webservice String serviceRequestId;
        webService String fileName;
        webservice Blob data;

    }

    global class  DocumentServiceResponse {
        webservice Integer workDocumentsCount;
        webservice List<WorkDocumentData> workDocumentsData;
        webservice List<String> errors;
    }

    webservice static DocumentServiceResponse getNewServiceDocuments(WorkDocumentTimeFrame timeFrame) {
       DocumentServiceHandler handler =  new DocumentServiceHandler();

        DocumentServiceResponse dsr = new DocumentServiceResponse();

        dsr.errors = new List<String>();
        dsr.workDocumentsData = handler.handleGetDocuments(timeFrame, dsr.errors);
        dsr.workDocumentsCount = dsr.workDocumentsData.size();

        return dsr;
    }
}