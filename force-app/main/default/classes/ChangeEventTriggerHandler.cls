public with sharing class ChangeEventTriggerHandler {

    
    public static void handle() {
        if(ChangeEventSettings__c.getInstance().enabled__c) {
            doHandle();
        }
    }
    
    private static void doHandle() {

        ChangeEventHandler handler = new ChangeEventHandler();

        if(Trigger.isInsert) {
            handler.handleCreate(Trigger.newMap);    
        }
                
        if(Trigger.isUpdate) {
            handler.handleUpdate(Trigger.newMap,Trigger.oldMap);    
        }
        
        if(Trigger.isDelete) {
            handler.handleDelete(Trigger.oldMap);    
        }
        
        if(Trigger.isUndelete) {
            handler.handleCreate(Trigger.newMap);    
        }

    }

}