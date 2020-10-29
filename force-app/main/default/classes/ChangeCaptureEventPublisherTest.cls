@isTest
private with sharing class ChangeCaptureEventPublisherTest {
    
    @isTest private static void testSendPayload() {
        String payload = 'test';
        Test.startTest();
        ChangeCaptureEventPublisher.publish(payload, '');
        Test.stopTest();
        List<String> sentPayloads = ChangeCaptureEventPublisher.getSentPayloads();
        System.assertEquals(1, sentPayloads.size(), 'Sent payloads should have a size of 1');
        System.assertEquals(payload, sentPayloads.get(0), 'Sent payload should match input');
    }
    
}
