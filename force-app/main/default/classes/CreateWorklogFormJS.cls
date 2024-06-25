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
                    recordData.Id__c = (String) logEntry.get('id');
                    recordData.Employee__c = employeeName;
                    recordData.JiraKey__c = (String) logEntry.get('jiraKey');
                    recordData.TimeSpent__c = (String) logEntry.get('timeSpent');
                    recordData.TimeSpentSeconds__c = (Decimal) logEntry.get('timeSpentSeconds');
                    
                    // Convert date to date type
                    String createdDateStr = (String) logEntry.get('createdDate');
                    Date createdDate = Date.valueOf(createdDateStr.substring(0, 10));
                    recordData.Created_Date__c = createdDate;
                    
                    // Convert time to time type
                    String createdTimeStr = (String) logEntry.get('createdTime');
                    Integer hours = Integer.valueOf(createdTimeStr.substring(0, 2));
                    Integer minutes = Integer.valueOf(createdTimeStr.substring(3, 5));
                    Integer seconds = Integer.valueOf(createdTimeStr.substring(6, 8));
                    Time createdTime = Time.newInstance(hours, minutes, seconds, 0);
                    recordData.Created_Time__c = createdTime;

                    // Add the record to the list
                    totalRecordData.add(recordData);
                }
            }

            // //Insert the data
            // if (!totalRecordData.isEmpty()) {
            //     Database.SaveResult[] insertResults = Database.insert(totalRecordData, false);
                
            //     // Handle any errors
            //     for (Database.SaveResult result : insertResults) {
            //         if (!result.isSuccess()) {
            //             // Log the error
            //             for (Database.Error error : result.getErrors()) {
            //                 System.debug('Error inserting record: ' + error.getMessage());
            //             }
            //         }
            //     }
            // }
            
            // Upsert the data using JiraKey__c as the external ID field
            if (!totalRecordData.isEmpty()) {
                Database.UpsertResult[] upsertResults = Database.upsert(totalRecordData, WorkLog__c.Fields.Id__c, false);
                
                // Handle any errors
                for (Database.UpsertResult result : upsertResults) {
                    if (!result.isSuccess()) {
                        // Log the error
                        for (Database.Error error : result.getErrors()) {
                            System.debug('Error upserting record: ' + error.getMessage());
                        }
                    }
                }
            }

        } catch (Exception e) {
            System.debug('Error processing logs: ' + e.getMessage());
        }
    }
}
