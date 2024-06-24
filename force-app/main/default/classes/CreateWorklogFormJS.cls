public with sharing class CreateWorklogFormJS {
    
    @AuraEnabled
    public static void createWorklogFormJS(String jsonResult) {
        List<WorkLog__c> totalRecordData = new List<WorkLog__c>();
        try {
            // Deserialize the JSON string into a generic map
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(jsonResult);

            // Iterate through each employee's log entries
            for (String employeeName : jsonData.keySet()) {
                List<Object> logEntries = (List<Object>) jsonData.get(employeeName);
                
                for (Object logEntryObj : logEntries) {
                    Map<String, Object> logEntry = (Map<String, Object>) logEntryObj;
                    WorkLog__c recordData = new WorkLog__c();
                    
                    // Map JSON fields to WorkLog__c fields
                    recordData.Employee__c = employeeName;
                    recordData.JiraKey__c = (String) logEntry.get('jiraKey');
                    recordData.TimeSpent__c = (String) logEntry.get('timeSpent');
                    recordData.TimeSpentSeconds__c = (Decimal) logEntry.get('timeSpentSeconds');
                    
                    // Combine createdDate and createdTime to create a DateTime field
                    // String createdDateStr = (String) logEntry.get('createdDate');
                    // String createdTimeStr = (String) logEntry.get('createdTime');
                    // DateTime createdDateTime = DateTime.valueOfGmt(createdDateStr + 'T' + createdTimeStr);
                    // recordData.Created_Date__c = createdDateTime;
                    
                    // Add the record to the list
                    totalRecordData.add(recordData);
                }
            }
            
            // Insert the data
            if (!totalRecordData.isEmpty()) {
                Database.SaveResult[] insertResults = Database.insert(totalRecordData, false);
                
                // Handle any errors
                for (Database.SaveResult result : insertResults) {
                    if (!result.isSuccess()) {
                        // Log the error
                        for (Database.Error error : result.getErrors()) {
                            System.debug('Error inserting record: ' + error.getMessage());
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error processing logs: ' + e.getMessage());
        }
    }
}