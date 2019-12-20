/**
 * Created by melissaderricott on 12/12/19.
 */



global class OvernightAttachmentQueryEmailController implements Schedulable {

    global void execute (SchedulableContext ctx) {

        List<String> listOfString = emailList();

        List<ContentDocumentLink> newDocuments = getContentDocumentLinks();

        List<String> getServiceNumbers = getServiceNumbers(newDocuments);

        String emailBody = createEmailBody(getServiceNumbers);

        Messaging.SendEmailResult[] sendEmailResults = composeEmail(listOfString, emailBody);


        inspectResults(sendEmailResults);

    }



    public Messaging.SendEmailResult[] composeEmail (List<String> emailList, String emailBody){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        Datetime dt = Datetime.now();
        Integer hours = dt.hour();
        Integer minutes = dt.minute();

        mail.setToAddresses(emailList);
        mail.setSubject('Service Requests Attachment Report for ' + hours + ':00');
        mail.setPlainTextBody(emailBody);


        return Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});

    }

    public List<String> emailList (){
        List<String> returnList = new List<String>();

        List<Email_Data__mdt> queryEmailData = new List<Email_Data__mdt>();
        queryEmailData = [SELECT Id, Recipient_Email__c From Email_Data__mdt];

        for(Email_Data__mdt email : queryEmailData){
            String em = email.Recipient_Email__c;
            returnList.add(em);
        }

        return returnList;

    }





        private static Boolean inspectResults (Messaging.SendEmailResult[] results){

            Boolean sendResult = true;

            for (Messaging.SendEmailResult res : results){
                if (res.isSuccess()){
                    System.debug('Email sent successfully');
                }
                else {
                    sendResult = false;
                    System.debug('The following errors occurred: ' + res.getErrors());
                }
            }
            return sendResult;
    }

    public List<ContentDocumentLink> getContentDocumentLinks(){

        Datetime startDatetime = Datetime.now().addHours(-10);
        Datetime endDatetime = Datetime.now();

        return [
                SELECT Id, LinkedEntityId, ContentDocument.Title, ContentDocument.LastModifiedDate
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN (SELECT Id FROM Service_Request__c)
                AND ContentDocument.LastModifiedDate <= :endDatetime
                AND ContentDocument.LastModifiedDate >= :startDatetime
                AND ContentDocument.title LIKE 'Signed_%'
        ];
    }

    public List<String> getServiceNumbers(List<ContentDocumentLink> contentDocumentLinks) {

        Set<Id> srIds = new Set<Id>();
        List<String> srNumbers = new List<String>();

        for(ContentDocumentLink entity : contentDocumentLinks){
            srIds.add(entity.LinkedEntityId);
        }

        List<Service_Request__c> srList = [SELECT Id, ServiceRequestNumber__c FROM Service_Request__c WHERE Id IN :srIds];


        for(Service_Request__c sr : srList){
            String srn = sr.ServiceRequestNumber__c;
            srNumbers.add(srn);
        }

        return srNumbers;

    }

    public String createEmailBody (List<String> srn ) {
        String result = '\n';

        if (srn.size() == 0) {
            result = 'No Service Requests were updated during this time frame.';
        } else {
            result = 'The following Service Requests have been updated: \n';
            for (String sr : srn) {
                result = result + sr + '\n';
            }
        }
            return result;
    }

}




