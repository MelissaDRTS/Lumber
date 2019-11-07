/**
 * Created by melissaderricott on 11/4/19.
 */

@IsTest
global class DownloadPDFMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req){






        String testString = 'Hello World';
        Blob testBlob = Blob.valueOf(testString);
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        resp.setHeader('Accept', 'application/json');
        resp.setBody('true');
        resp.setStatus('Ok');
        resp.setStatusCode(200);
        return resp;
    }
}

