public with sharing class JiraController {
    
    @AuraEnabled
    public static void deleteAllJiraRecords() {
        try {
            List<Jira__c> jiraRecords = [SELECT Id FROM Jira__c];
            delete jiraRecords;
        } catch (Exception e) {
            throw new AuraHandledException('Failed to delete Jira records: ' + e.getMessage());
        }
    }
}