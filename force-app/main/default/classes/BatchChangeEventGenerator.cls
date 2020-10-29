/**
 * Generates a create change event for all instances of the provided object type.
 * It gets the schema for the provided object type and generates a query that extracts
 * all field values. 
 * It publishes each batch of results as a list of serialized ChangeCaptureEvent objects.
 */
public with sharing class BatchChangeEventGenerator implements Database.Batchable<sObject>, Database.stateful {

    private String objectType;
    private Set<String> fields;
    private String changePublishUrl = '';
    private integer batchSize = 30;
    private Map<String,String> emptyMap = new Map<String,String>();

    private ChangeEventHandler handler = new ChangeEventHandler();

    public BatchChangeEventGenerator(String objectType) {
        this.objectType = objectType;
        Schema.DescribeSObjectResult describe = ((SObject)(Type.forName('Schema.'+objectType).newInstance())).getSObjectType().getDescribe();
        this.fields = describe.fields.getMap().keySet();
        if(!Test.isRunningTest()) {
            this.changePublishUrl = ChangeEventSettings__c.getInstance().changepublishurl__c;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ';
        String delim = '';
        for(String field: fields) {
            query = query + delim + field;
            delim = ',';
        }
        query = query + ' FROM ' + objectType + ' ORDER BY systemmodstamp';
        return Database.getQueryLocator(String.escapeSingleQuotes(query));
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<ChangeCaptureEvent> events = new List<ChangeCaptureEvent>();
        for(sObject obj: scope) {
            events.add(new ChangeCaptureEvent.ChangeCaptureEventBuilder()
                .userName('batch')
                .objectId((String)obj.get('id'))
                .objectType(this.objectType)
                .objectName((String)obj.get('name'))
                .action('C')
                .oldFieldValues(emptyMap)
                .newFieldValues(emptyMap)
                .fullPayload(generatePayload(obj))
                .createdDate((DateTime)obj.get('lastmodifieddate'))
                .build());
        }
        sendChangeEvents(events);
    }

    private void sendChangeEvents(List<ChangeCaptureEvent> events) {
        if(!events.isEmpty()) {
            ChangeCaptureEventPublisher.publish(ChangeCaptureEventUtils.batchSerializeToJson(events,batchSize), this.changePublishUrl);
        }
    }

    @testVisible private Map<String,Object> generatePayload(SObject obj) {
        Map<String,Object> changes = new Map<String,Object>();
        for(String field: fields) {
            if(obj.get(field) != null ) {
                changes.put(field,obj.get(field));
            }
        }
        return changes;
    }

    public void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                            TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(LoggingLevel.DEBUG, 'Job finished with status ' + job.Status);                            
   }

}
