@isTest
private class ChangeEventHandlerTest {

    @isTest static void testHandleCreate() {
        ChangeEventHandler handler = new ChangeEventHandler(true, '');
        insert(new Account(name='Test'));
        List<Account> objects = getAccounts();
        Map<Id, sObject> newObjects = new Map<Id,sObject>();
        Account newObj = objects.get(0);
        newObjects.put(newObj.Id, newObj);
        handler.handleCreate(newObjects);
        List<ChangeCaptureEvent> sentEvents = handler.getSentChangeEvents();
        ChangeCaptureEvent sentEvent = sentEvents.get(0); // Most recent created event
        System.assert(sentEvent.getNewFieldValues().containsKey('name'), 'New values should contain name');
        System.assert(sentEvent.getOldFieldValues().isEmpty(), 'Old values should be empty');
        System.assert(sentEvent.getFullPayload().containsKey('name'), 'Full payload should contain name');
    }

    @isTest static void testHandleUpdate() {
        ChangeEventHandler handler = new ChangeEventHandler(true, '');
        insert(new Account(name='Test1'));
        insert(new Account(name='Test2'));
        List<Account> objects = getAccounts();
        Map<Id, sObject> newObjects = new Map<Id,sObject>();
        Account newObj = objects.get(1);
        newObjects.put(newObj.Id, newObj);

        Map<Id, sObject> oldObjects = new Map<Id,sObject>();
        Account oldObj = objects.get(0);
        oldObjects.put(newObj.Id, oldObj); // Spoof update on same object
        handler.handleUpdate(newObjects, oldObjects);
        List<ChangeCaptureEvent> sentEvents = handler.getSentChangeEvents();
        ChangeCaptureEvent sentEvent = sentEvents.get(0); // Most recent created event
        System.assert(sentEvent.getOldFieldValues().containsKey('name'), 'Old values should contain name');
        System.assert(sentEvent.getFullPayload().containsKey('name'), 'Full payload should contain name');
    }

    @isTest static void testHandleDelete() {
        ChangeEventHandler handler = new ChangeEventHandler(true, '');
        insert(new Account(name='Test1'));
        List<Account> objects = getAccounts();
        Map<Id, sObject> oldObjects = new Map<Id,sObject>();
        Account oldObj = objects.get(0);
        oldObjects.put(oldObj.Id, oldObj);
        handler.handleDelete(oldObjects);
        List<ChangeCaptureEvent> sentEvents = handler.getSentChangeEvents();
        ChangeCaptureEvent sentEvent = sentEvents.get(0); // Most recent created event
        System.assert(sentEvent.getNewFieldValues().isEmpty(), 'New values should be empty');
        System.assert(sentEvent.getOldFieldValues().containsKey('name'), 'Old values should contain name');
        System.assert(sentEvent.getFullPayload().containsKey('name'), 'Full payload should contain name');
    }
    
    @isTest static void testGetFieldNames() {
        ChangeEventHandler handler = new ChangeEventHandler(false, '');
        Account account = new Account();
        Set<String> fields = handler.getFieldNamesFromSchema(account);
        System.assert(fields.contains('name'), 'Fields should contain name');
    }
        
    @isTest static void testGetChangedFields() {
		ChangeEventHandler handler = new ChangeEventHandler(false, '');
        Account account = new Account(name = 'Test');
        Set<String> deltas = handler.getChangedFields(account);
        System.assert(deltas.contains('name'), 'Deltas should contain name');
        System.assertEquals(1, deltas.size(), 'Deltas should have one element');        
    }

    @isTest static void testGetLastModifiedBy() {
        ChangeEventHandler handler = new ChangeEventHandler(false, '');
        List<Account> accounts = new List<Account>();
        Account account = new Account(name = 'Test');
        accounts.add(account);
        insert(accounts);
        List<Account> savedAccounts = [SELECT id, lastmodifiedbyid FROM account];
        Map<Id,String> userNames = handler.getUserNames(savedAccounts);
        System.assertEquals(1, userNames.size(), 'userNames size should be 1');
    }

    @isTest static void testGetDeltasBetweenObjects() {
        ChangeEventHandler handler = new ChangeEventHandler(false, '');
        Account oldAccount = new Account(name = 'Test1');
        Account newAccount = new Account(name = 'Test2');
        Set<String> deltas = handler.getChangedFields(newAccount, oldAccount);
        System.assert(deltas.contains('name'), 'Deltas should contain name');
        System.assertEquals(1, deltas.size(), 'Deltas should contain 1 element');
    }

    @isTest static void testGetPayload() {
        ChangeEventHandler handler = new ChangeEventHandler(false, '');
        Account account = new Account(name = 'Test');
        Set<String> deltas = handler.getChangedFields(account);
        Map<String,Object> payload = handler.generatePayload(account, deltas);
        System.assert(payload.containsKey('name'), 'payload should contain name');
    }

    @isTest static void testGetFullPayload() {
        ChangeEventHandler handler = new ChangeEventHandler(true, '');
        Account account = new Account(name = 'Test');
        Map<String,Object> payload = handler.generateFullPayload(account);
        System.assert(payload.containsKey('name'), 'payload should contain name');
    }

    @isTest static void testConstructor() {
        ChangeEventHandler handler = new ChangeEventHandler();
        System.assertEquals(true, handler.getSendFullPayload(), 'Handler should send full payload');
    }

    private static List<Account> getAccounts() {
        Set<String> fields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().keySet();
        String query = 'SELECT ';
        String delimiter = '';
        for(String field: fields) {
            query = query + delimiter + field;
            delimiter = ',';
        }
        query = query + ' FROM account ORDER BY createddate DESC';
        return (List<Account>)Database.query(query);
    }

    
}