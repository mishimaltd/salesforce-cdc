@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class ChangeEventHandler {
    
    private boolean sendFullPayload = true;
    private string changePublishUrl = '';
    private integer batchSize = 30;

    private List<ChangeCaptureEvent> sentChangeEvents = new List<ChangeCaptureEvent>();

    public ChangeEventHandler() {
        if(!Test.isRunningTest()) {
            this.sendFullPayload = ChangeEventSettings__c.getInstance().sendfullpayload__c;
            this.changePublishUrl = ChangeEventSettings__c.getInstance().changepublishurl__c;
        }
    }

    @testVisible private ChangeEventHandler(boolean sendFullPayload, String changePublishUrl) {
        this.sendFullPayload = sendFullPayload;
        this.changePublishUrl = changePublishUrl;
    }
  
    public void handleCreate(Map<Id,SObject> newEvents) {
        List<ChangeCaptureEvent> events = new List<ChangeCaptureEvent>();
        Map<Id,String> userNames = getUserNames(newEvents.values());
        for(Id objId: newEvents.keySet()) {
            SObject obj = newEvents.get(objId);
            Set<String> changedFields = getChangedFields(obj);
            events.add(new ChangeCaptureEvent.ChangeCaptureEventBuilder()
                .userName(userNames.get(obj.id))
                .objectId(obj.id)
                .objectType(obj.getSObjectType().getDescribe().getName())
                .objectName((String)obj.get('name'))
                .action('U')
                .oldFieldValues(new Map<String,Object>())
                .newFieldValues(generatePayload(obj, changedFields))
                .fullPayload(generateFullPayload(obj))
                .createdDate((DateTime)obj.get('lastmodifieddate'))
                .build());
        }
        sendChangeEvents(events);
    }
    
    public void handleUpdate(Map<Id,SObject> newEvents, Map<Id,SObject> oldEvents) {
        List<ChangeCaptureEvent> events = new List<ChangeCaptureEvent>();
        Map<Id,String> userNames = getUserNames(newEvents.values());
        for(Id objId: newEvents.keySet()) {
            SObject newObj = newEvents.get(objId);
            SObject oldObj = oldEvents.get(objId);
            Set<String> changedFields = getChangedFields(newObj, oldObj);
            events.add(new ChangeCaptureEvent.ChangeCaptureEventBuilder()
                .userName(userNames.get(newObj.id))
                .objectId(newObj.id)
                .objectType(newObj.getSObjectType().getDescribe().getName())
                .objectName((String)newObj.get('name'))
                .action('U')
                .oldFieldValues(generatePayload(oldObj, changedFields))
                .newFieldValues(generatePayload(newObj, changedFields))
                .fullPayload(generateFullPayload(newObj))
                .createdDate((DateTime)newObj.get('lastmodifieddate'))
                .build());
        }
		sendChangeEvents(events);
    }
    
    public void handleDelete(Map<Id,SObject> oldEvents) {
        List<ChangeCaptureEvent> events = new List<ChangeCaptureEvent>();
        Map<Id,String> userNames = getUserNames(oldEvents.values());
        for(Id objId: oldEvents.keySet()) {
            SObject obj = oldEvents.get(objId);
            events.add(new ChangeCaptureEvent.ChangeCaptureEventBuilder()
                .userName(userNames.get(obj.id))
                .objectId(obj.id)
                .objectType(obj.getSObjectType().getDescribe().getName())
                .objectName((String)obj.get('name'))
                .action('U')
                .oldFieldValues(generateFullPayload(obj))
                .newFieldValues(new Map<String,Object>())
                .fullPayload(generateFullPayload(obj))
                .createdDate(DateTime.now())
                .build());
        }
        sendChangeEvents(events);
    }

    private void sendChangeEvents(List<ChangeCaptureEvent> events) {
        if(!events.isEmpty()) {
            ChangeCaptureEventPublisher.publish(ChangeCaptureEventUtils.batchSerializeToJson(events,batchSize), this.changePublishUrl);
            this.sentChangeEvents.addAll(events);
        }
    }

    @testVisible private Set<String> getChangedFields(SObject obj) {
        Set<String> deltas = new Set<String>();
        for(String schemaField: getFieldNamesFromSchema(obj)) {
            if(obj.get(schemaField) != null) {
                deltas.add(schemaField);
            }
        }
        return deltas;
    }

    @testVisible private Set<String> getChangedFields(SObject newObj, SObject oldObj) {
        Set<String> deltas = new Set<String>();
        for(String schemaField: getFieldNamesFromSchema(newObj)) {
            if(newObj.get(schemaField) == null && oldObj.get(schemaField) == null) {
                continue; // Skip field
            }
            if(newObj.get(schemaField) == null && oldObj.get(schemaField) != null ) {
                deltas.add(schemaField);
            } else if (newObj.get(schemaField) != null && oldObj.get(schemaField) == null ) {
                deltas.add(schemaField);
            } else if (!newObj.get(schemaField).equals(oldObj.get(schemaField))) {
                deltas.add(schemaField);
            }
        }
        return deltas;
    }
   
    @testVisible private Set<String> getFieldNamesFromSchema(SObject obj) {
      	return obj.getSObjectType().getDescribe().fields.getMap().keySet();
    }
        
    @testVisible private Map<String,Object> generatePayload(SObject obj, Set<String> changedFields) {
        Map<String,Object> changes = new Map<String,Object>();
        for(String changedField: changedFields) {
            changes.put(changedField, obj.get(changedField));
        }
        return changes;
    }

    @testVisible private Map<String,Object> generateFullPayload(SObject obj) {
        Map<String,Object> changes = new Map<String,Object>();
        if(sendFullPayload) {
            for(String field: getFieldNamesFromSchema(obj)) {
                changes.put(field,obj.get(field));
            }
        }
        return changes;
    }
    
    @testVisible private Map<Id,String> getUserNames(List<SObject> objects) {
        // Extract last modified by user ids from objects
        Set<Id> userIds = new Set<Id>();
        for(SObject obj: objects) {
            userIds.add((Id)obj.get('LastModifiedById'));
        }

        // Lookup usernames for user ids and map to user names
        List<User> users = [SELECT id, name FROM user WHERE id in :userIds];
        Map<Id,String> userNames = new Map<Id,String>();
        for(User user: users) {
            userNames.put(user.id, user.name);
        }

        // Map last modified by user ids to user names from user records
        Map<Id,String> objectUserNames = new Map<Id,String>();
        for(SObject obj: objects) {
            objectUserNames.put(obj.id, userNames.get((Id)obj.get('LastModifiedById')));
        }
        return objectUserNames;
    }
    
    public boolean getSendFullPayload() {
        return sendFullPayload;
    }

    @testVisible private List<ChangeCaptureEvent> getSentChangeEvents() {
        return sentChangeEvents;
    }

}
