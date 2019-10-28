/**
* Created by melissaderricott on 10/9/19.
*/


public virtual class DownloadPDF {


    public static final String SALES_ORDER_INSTALL = 'Install Order';
    public static final String SALES_ORDER_MEASURE = 'Measure Order';
    public static final String PDF_TYPE_ASSESS = '\'Assess\'';
    public static final String PDF_TYPE_INSTALL = '\'Install\'';
    
    
    public static Boolean handlePdfDownload(Id recordId) {
        try {
            
            Sales_Order__c currentSalesOrder = getSalesOrder(recordId);
            
            List<Document> pdfDocumentStrings = (List<Document>) getPdfDocuments(currentSalesOrder.Type_of_Order__c, currentSalesOrder.Service_Request__c);
            
            List<ContentVersion> cvs = createContentVersion(pdfDocumentStrings);
            
            List<Database.UpsertResult> createResults = Database.upsert(cvs, false);
            
            List<ContentDocumentLink> cdl = createContentDocumentLinks(recordId, createResults);
            
            List<Database.UpsertResult> createCLResults = Database.upsert(cdl, false);
            System.debug(createCLResults);
            for(Database.UpsertResult result : createCLResults ) {
                
                if (result.isSuccess() == false) {
                    return false;
                }
            }
            return true;
        } catch(Exception e) {
            System.debug(e.getMessage());
            return false;
        }



    }

    public static Sales_Order__c getSalesOrder(Id recordId) {
        
        return [SELECT Id, Service_Request__c, Service_Request__r.ServiceRequestNumber__c, Type_of_Order__c FROM Sales_Order__c WHERE Id = :recordId];
    }
    

    public static string bearer() {

        Token_Credential__mdt bearCredential = [SELECT Client_Id__c,Client_Secret__c,DeveloperName,grant_type__c, Endpoint__c FROM Token_Credential__mdt WHERE DeveloperName ='Bearer'];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = bearCredential.Endpoint__c;
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Accept', 'application/json');
        String tokenPostBody = 'client_id=' + bearCredential.Client_Id__c + '&client_secret=' + bearCredential.Client_Secret__c + '&grant_type=' + bearCredential.grant_type__c;
        request.setBody(tokenPostBody);
        HttpResponse postResponse = http.send(request);
        //System.debug(postResponse.getBody());
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(postResponse.getBody());
        // System.debug(results.get('access_token'));
        String token = results.get('access_token').toString();

        return token;
    }

    public class Document {
        public String fileName;
        public String base64;
    }
    

    public static List<Document> getPdfDocuments(String SalesOrderType, String ServiceRequestId) {
        
        String singleQuote = '\'';
        String SRId = singleQuote + ServiceRequestId + SingleQuote;
        String SRType;
        if (SalesOrderType == SALES_ORDER_INSTALL){
            SRType = PDF_TYPE_INSTALL;
        } else if (SalesOrderType == SALES_ORDER_MEASURE){
            SRType = PDF_TYPE_ASSESS;
        }

        LiveLink__mdt liveLinkEndpoint = [SELECT Endpoint__c FROM LiveLink__mdt WHERE DeveloperName = 'LumberLiveLink' LIMIT 1];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = liveLinkEndpoint.Endpoint__c + '?SRId=' + SRId + '&SRType=' + SRType ;
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        String bearer = 'Bearer ' + bearer();
        // System.debug(bearer);
        request.setHeader('Authorization', bearer);
        HttpResponse response = http.send(request);
        Dom.Document doc = response.getBodyDocument();
        List<String> docs = new List<String>();
        List<Document> documents = new List<Document>();
        for (Dom.XMLNode entry : doc.getRootElement().getChildElements()) {
            
            
            for (Dom.XmlNode content : entry.getChildElements()) {
                
                for (Dom.XmlNode properties : content.getChildElements()) {
                    // System.debug(properties);
                    for (Dom.XmlNode document : properties.getChildElements()) {
                        Document newDocument = new Document();
                        
                        String base64 = properties.getChildElement('Document', 'http://schemas.microsoft.com/ado/2007/08/dataservices').getText();
                        //docs.add(base64);
                        //System.debug(base64);
                        String fileName = properties.getChildElement('Filename', 'http://schemas.microsoft.com/ado/2007/08/dataservices').getText();
                        newDocument.base64 = base64;
                        newDocument.fileName = fileName;
                        
                        documents.add(newDocument);
                        
                       break;
                    }
                }
            }
        }
        
        return documents;
    }

    
    public static List<ContentVersion> createContentVersion(List<Document> pdfData) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();

        for (DownloadPDF.Document pdf : pdfData) {
            ContentVersion contentVersion = new ContentVersion();

            List<String> fileEx = pdf.fileName.split('\\.');

            contentVersion.Title = pdf.fileName;
            contentVersion.VersionData = EncodingUtil.base64Decode(pdf.base64);
            contentVersion.PathOnClient = 'ionicLogo.' + fileEx[fileEx.size()-1];
            contentVersion.ContentLocation = 'S';
            
            contentVersions.add(contentVersion);
        }
        
        return contentVersions;
    }
    
    public static List<ContentDocumentLink> createContentDocumentLinks(Id recordId, List<Database.UpsertResult> results){
        Set<Id> contentVersionsIds = new Set<Id>();
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        
        for (Database.UpsertResult result : results){
            System.debug(result.isSuccess());
            if(result.isSuccess()){
                contentVersionsIds.add(result.getId());
                System.debug(contentVersionsIds);
            }
        }
        
        Map<Id, ContentVersion> contentDocumentIds = new Map<Id, ContentVersion> ([SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionsIds]);
        
        for(ID cv : contentDocumentIds.keySet()){

            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = contentDocumentIds.get(cv).ContentDocumentId;
            contentDocumentLink.LinkedEntityId = recordId;
            contentDocumentLink.ShareType = 'I';
            
            contentDocumentLinks.add(contentDocumentLink);
        }
        return contentDocumentLinks;
    }
}