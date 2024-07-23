global class JiraRecordBatchProcessor implements Database.Batchable<sObject> {
    private List<Jira__c> jiraRecordsToUpdate;
    private List<Jira__c> jiraRecordsToInsert;

    global JiraRecordBatchProcessor(List<Jira__c> jiraRecordsToUpdate, List<Jira__c> jiraRecordsToInsert) {
        this.jiraRecordsToUpdate = jiraRecordsToUpdate;
        this.jiraRecordsToInsert = jiraRecordsToInsert;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<Id> idsToUpdate = new List<Id>();
        for (Jira__c jiraRecord : jiraRecordsToUpdate) {
            idsToUpdate.add(jiraRecord.Id);
        }
        // Convert the list of IDs to a set for binding
        Set<Id> idsToUpdateSet = new Set<Id>(idsToUpdate);
        String query = 'SELECT Id FROM Jira__c WHERE Id IN :idsToUpdateSet';
        return Database.getQueryLocator(query);
    }
    

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Jira__c> jiraRecords = (List<Jira__c>)scope;
        Database.SaveResult[] updateResults = Database.update(jiraRecords, false);
        for (Database.SaveResult sr : updateResults) {
            if (sr.isSuccess()) {
                System.debug('Successfully updated Jira record with ID: '+ sr.getId());
            } else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error updating Jira record: '+ err.getStatusCode() + ' ' +err.getMessage());
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        Database.SaveResult[] insertResults = Database.insert(jiraRecordsToInsert, false);
        for (Database.SaveResult sr : insertResults) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted Jira record with ID: '+ sr.getId());
            } else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error inserting Jira record: '+ err.getStatusCode() + ' '+ err.getMessage());
                }
            }
        }
    }
}