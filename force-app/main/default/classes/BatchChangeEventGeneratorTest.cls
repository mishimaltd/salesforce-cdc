@isTest
private class BatchChangeEventGeneratorTest {
    
    private static Integer eventCount = 10;

    @testSetup static void setup() {
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < eventCount; i++ ) {
            accounts.add(new Account(name='Test_' + i));
        }
        insert(accounts);
    }
    
    @isTest static void testBatchGenerator() {
        Test.startTest();
        BatchChangeEventGenerator generator = new BatchChangeEventGenerator('Account');
        Id jobId = Database.executeBatch(generator,eventCount);
        Test.stopTest();
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                            TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :jobId];
        System.assertEquals(0,job.NumberOfErrors, 'All events should have been sent');
    }

}
