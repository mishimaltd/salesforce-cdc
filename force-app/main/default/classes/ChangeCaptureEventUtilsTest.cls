@isTest
public with sharing class ChangeCaptureEventUtilsTest {
    
    @isTest private static void testGeneratePayloads() {
        integer batchSize = 5;
        integer eventCount = 32;
        List<ChangeCaptureEvent> events = new List<ChangeCaptureEvent>();
        for(integer i = 0; i < eventCount; i++) {
            events.add(new ChangeCaptureEvent.ChangeCaptureEventBuilder().build());
        }
        List<String> payloads = ChangeCaptureEventUtils.batchSerializeToJson(events, batchSize);
        System.assertEquals(7, payloads.size(), 'Payloads should be 7');
    }

    @isTest private static void testGenerateSmallPayloads() {
        integer batchSize = 5;
        integer eventCount = 1;
        List<ChangeCaptureEvent> events = new List<ChangeCaptureEvent>();
        for(integer i = 0; i < eventCount; i++) {
            events.add(new ChangeCaptureEvent.ChangeCaptureEventBuilder().build());
        }
        List<String> payloads = ChangeCaptureEventUtils.batchSerializeToJson(events, batchSize);
        System.assertEquals(1, payloads.size(), 'Payloads should be 1');
    }

}
