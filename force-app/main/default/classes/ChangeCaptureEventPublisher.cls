public with sharing class ChangeCaptureEventPublisher {

    private static String apiKeyHeaderName = 'dummy';
    private static String apiKey = '';

    // For testing support
    private static List<String> sentPayloads = new List<String>();

    static {
        if(!Test.isRunningTest()) {
            apiKeyHeaderName = ChangeEventSettings__c.getInstance().publishapiheadername__c;
            apiKey = ChangeEventSettings__c.getInstance().publishapikey__c;
        }
    }

    public static void publish(String payload, String changePublishUrl) {
        publish(new List<String>{payload}, changePublishUrl);
    }

    public static void publish(List<String> payloads, String changePublishUrl) {
        if(System.isBatch()) {
            // Enqueue callout if running in batch context
            System.enqueueJob(new AsyncChangeEventPublisher(payloads, changePublishUrl));
        } else {
            // Publish callout for non-batch context
            for(String payload: payloads) {
                publishAsync(payload, changePublishUrl);
            }
        }
    }

    @future (callout=true)
    public static void publishAsync(String json, String changePublishUrl) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(changePublishUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader(apiKeyHeaderName, apiKey);
        req.setBody(json);
        if(!Test.isRunningTest()) {
            HttpResponse res = http.send(req);
            System.debug(LoggingLevel.DEBUG, 'Reponse status: ' + res.getStatus());
        } else {
            sentPayloads.add(json);
        }
    }

    @testVisible private static List<String> getSentPayloads() {
        return sentPayloads;
    }

    // Queueable change event processor
    public class AsyncChangeEventPublisher implements Queueable {
    
        private List<String> payloads;
        private String url;
    
        public AsyncChangeEventPublisher(List<String> payloads, String url) {
            this.payloads = payloads;
            this.url = url;
        }
    
        public void execute(QueueableContext context) {
            for(String payload: payloads) {
                ChangeCaptureEventPublisher.publishAsync(payload, url);
            }
        }
    }

}
