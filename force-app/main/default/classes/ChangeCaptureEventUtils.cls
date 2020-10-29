public with sharing class ChangeCaptureEventUtils {

    public static List<String> batchSerializeToJson(List<ChangeCaptureEvent> events, integer batchSize) {
        if(events.size() < batchSize) {
            return new List<String>{JSON.serialize(events)};
        }
        List<String> payloads = new List<String>();
        List<ChangeCaptureEvent> batch = new List<ChangeCaptureEvent>();
        integer count = 0;
        integer currentBatchCount = 0;
        integer eventCount = events.size();
        while(count++ < eventCount) {
            batch.add(events.remove(0));
            if(++currentBatchCount == batchSize) {
                payloads.add(JSON.serialize(batch));
                batch.clear();
                currentBatchCount = 0;
            }    
        }
        if(!batch.isEmpty()) {
            payloads.add(JSON.serialize(batch));
        }
        return payloads;
    }

}
