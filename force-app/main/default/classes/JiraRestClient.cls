public class JiraRestClient {
    
    private static final String ENDPOINT_URL = 'callout:JiraAuth/rest/api/3/search?jql=';
    private static final String CUSTOMFIELD_START_DATE = 'customfield_10020.';
    private static final String CUSTOMFIELD_PLANNED_END_DATE = 'customfield_10048';
    private static final String CUSTOMFIELD_DUE_DATE = 'duedate';
    @AuraEnabled
    public static void allProject() {
        // Get the list of project details
        List<Map<String, Map<String, String>>> projectDetailsList = GetProjectDetails.getProjectName();
        
        // Extract project names
        List<String> projectNames = new List<String>();
        
        for (Map<String, Map<String, String>> projectDetailsMap : projectDetailsList) {
            // Get the 'NameAddressMapper' map
            Map<String, String> nameAddressMapper = projectDetailsMap.get('NameAddressMapper');
            if (nameAddressMapper != null) {
                // Loop through the 'NameAddressMapper' map and extract project names
                for (String address : nameAddressMapper.keySet()) {
                    String projectName = nameAddressMapper.get(address);
                    projectNames.add(projectName);
                }
            }
        }
        
        //Pass the project Name by looping into selectedValues
        for (String projectName : projectNames) {
          
            performHttpRequestWithNamedCredential(projectName);
        }
    }
    @AuraEnabled
    public static String performHttpRequestWithNamedCredential(String selectedValues) {
        // frontend bata select vako value chai airakheko xa hai
       
        HttpResponse res;
        String responseBody = '';
        String projectData;

        // Retrieve project details		-- idAddressmapper ra nameAddressmapper haru chai eta hunxan hai
        List<Map<String, Map<String, String>>> projectMapList = GetProjectDetails.getProjectName();
        
        // like the name suggests yo method called vayera chai selected Project Address pairakheko xa yo string le
        String selectedProjectAddress = getSelectedProjectAddress(projectMapList, selectedValues);

        // Perform the HTTP request with the selected project address
        if (selectedProjectAddress != null) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(ENDPOINT_URL + selectedProjectAddress);
          
            req.setMethod('GET');

            // Create HTTP connection
            Http http = new Http();
            try {
                res = http.send(req);

                // Handle the response
                if (res.getStatusCode() == 200) {
                    // Successful request
                  
                    
                    responseBody = res.getBody();
                    
                    //so response body ako hunxa tellai chai deserialize ra parse garne kaam hunxa aba 
                    projectData = processIssues(responseBody);
                } else {
                    // Handle errors
                    System.debug('Error: ' + res.getStatusCode() + ' ' + res.getStatus());
                }
            } catch (Exception e) {
                System.debug('HTTP Request failed: ' + e.getMessage());
            }
        } else {
            System.debug('Selected project not found');
        }

        return responseBody;
    }

    private static String getSelectedProjectAddress(List<Map<String, Map<String, String>>> projectMapList, String selectedValues) {
        for (Map<String, Map<String, String>> projectMap : projectMapList) {
            Map<String, String> nameAddressMapper = projectMap.get('NameAddressMapper');
            for (String address : nameAddressMapper.keySet()) {
                String projectName = nameAddressMapper.get(address);
                if (projectName.equals(selectedValues)) {
                    return address;
                }
            }
        }
        return null;
    }

    private static String processIssues(String responseBody) {
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        
        // yelle chai key-value pair ma separate handido raixa, hamlai chai issues vanne key chaiyeko ho jun chai hami line 77 ma garirakheko xam.
        
        
        List<Object> issuesList = (List<Object>) jsonMap.get('issues');
        
        List<Jira__c> jiraRecordsToUpdate = new List<Jira__c>();
        List<Jira__c> jiraRecordsToInsert = new List<Jira__c>();

        
        // Collect Jira keys from the all the issues in json to query existing records
        Set<String> jiraKeys = new Set<String>();
        for (Object issueObj : issuesList) {
            Map<String, Object> issue = (Map<String, Object>) issueObj;
            jiraKeys.add((String) issue.get('key'));
        }
       
      
        // Process worklogs for all Jira keys
        WorklogProcessor.processWorklogs(jiraKeys);
        
        // // Query existing Jira records
        // Map<String, Jira__c> existingJiraRecords = new Map<String, Jira__c>();
        // // yelle chai just existing records jun chai aile json file ma ako kura sanga name match khanxa tyo records haru lai chai save garera rakhne kaam garxa
        // // yesto garera update garnu parne records haru kk cha tyo chai sabai eutai thau ma rakhdinxa jalle chai upsert lagauna sajilo pardinxa
        // if (!jiraKeys.isEmpty()) {
        //     for (Jira__c existingRecord : [SELECT Id, Name, Type__c, Summary__c, Status__c, Reporter__c, Assignee__c, StartDate__c, Expected_Time_Tracking__c, DueDate__c, ParentName__c, Actual_Time_Tracking__c , Aggregate_Time_Tracking__c FROM Jira__c WHERE Name IN :jiraKeys]) {
        //         existingJiraRecords.put(existingRecord.Name, existingRecord);
        //     }
        // }

        // // Process all issues
        // for (Object issueObj : issuesList) {
        //     Map<String, Object> issue = (Map<String, Object>) issueObj;
        //     Map<String, Object> fields = (Map<String, Object>) issue.get('fields');
            
        //     // Create new Jira record from issue-- start ma euta jira record chai banxa jalle chai json ko particular issue ko value haru store garera rakhxa
        //     // yesto kina gareko ta? first mai issue haru lai assignment dera rakhnu vanda ta just name matrai compare garera ani balla issue new cha vane chai create garna deko vaye vai halthyo ni!
        //     // ho tara name same ayo vane further comparison garna sajilo parxa ni hasChanges ma gareko jasto ani either way hamle createIssueRecord banaunai parxa so tyo method ko full utilization garamnata vanera pani rakheko ho. 
        //     Jira__c newJiraRecord = createIssueRecord(issue, fields);

        //     // Check if the record exists and has changes
        //     if (existingJiraRecords.containsKey(newJiraRecord.Name)) {

        //         Jira__c existingRecord = existingJiraRecords.get(newJiraRecord.Name);
        //         if (hasChanges(existingRecord, newJiraRecord)) {
        //             newJiraRecord.Id = existingRecord.Id;  // Set Id to update existing record
                  
        //             jiraRecordsToUpdate.add(newJiraRecord);
        //         }
        //     } else {
        //         jiraRecordsToInsert.add(newJiraRecord);
        //     }
        // }

        // // Upsert records
        // System.debug('Upserting Jira Records:');
        // upsertJiraRecords(jiraRecordsToUpdate, jiraRecordsToInsert);

        return 'Processed JSON';
    }

    // private static void upsertJiraRecords(List<Jira__c> jiraRecordsToUpdate, List<Jira__c> jiraRecordsToInsert) {
    //     if (!jiraRecordsToUpdate.isEmpty()) {
    //         Database.SaveResult[] updateResults = Database.update(jiraRecordsToUpdate, false);

    //         // Handle update results
    //         for (Database.SaveResult sr : updateResults) {
    //             if (sr.isSuccess()) {
    //                 System.debug('Successfully updated Jira record with ID: ' + sr.getId());
    //             } else {
    //                 for (Database.Error err : sr.getErrors()) {
    //                     System.debug('Error updating Jira record: ' + err.getStatusCode() + ' - ' + err.getMessage());
    //                 }
    //             }
    //         }
    //     }

    //     if (!jiraRecordsToInsert.isEmpty()) {
    //         Database.SaveResult[] insertResults = Database.insert(jiraRecordsToInsert, false);

    //         // Handle insert results
    //         for (Database.SaveResult sr : insertResults) {
    //             if (sr.isSuccess()) {
    //                 System.debug('Successfully inserted Jira record with ID: ' + sr.getId());
    //             } else {
    //                 for (Database.Error err : sr.getErrors()) {
    //                     System.debug('Error inserting Jira record: ' + err.getStatusCode() + ' - ' + err.getMessage());
    //                 }
    //             }
    //         }
    //     }
    // }

//     private static Jira__c createIssueRecord(Map<String, Object> issue, Map<String, Object> fields) {
//     Jira__c jiraRecord = new Jira__c();

//     // Populate fields for the issue
//     jiraRecord.Name = (String) issue.get('key');
//     jiraRecord.Type__c = fields != null && fields.containsKey('issuetype') ? (String) ((Map<String, Object>) fields.get('issuetype')).get('name') : null;
//     jiraRecord.Summary__c = fields != null && fields.containsKey('summary') ? (String) fields.get('summary') : null;
//     jiraRecord.Status__c = fields != null && fields.containsKey('status') ? (String) ((Map<String, Object>) fields.get('status')).get('name') : null;
//     jiraRecord.Reporter__c = getUserByName(fields != null && fields.containsKey('reporter') ? (String) ((Map<String, Object>) fields.get('reporter')).get('displayName') : null);
// 	// Ensure fields is not null
//     if (fields != null) {
//         // Check if fields contains 'assignee' and if 'assignee' is not null
//         if (fields.containsKey('assignee') && fields.get('assignee') != null) {
//             // Cast 'assignee' to Map and check if it contains 'displayName' and if 'displayName' is not null
//             Map<String, Object> assigneeMap = (Map<String, Object>) fields.get('assignee');
//             if (assigneeMap.containsKey('displayName') && assigneeMap.get('displayName') != null) {
//                 // Get the displayName
//                 String displayName = (String) assigneeMap.get('displayName');
//                 jiraRecord.Assignee__c = getUserByName(displayName);
//             } else {
//                 // Handle the case where 'displayName' is not present or null
//                 jiraRecord.Assignee__c = getUserByName(null);
//             }
//         } else {
//             // Handle the case where 'assignee' is not present or null
//             jiraRecord.Assignee__c = getUserByName(null);
//         }
//     } else {
//         // Handle the case where fields is null
//         jiraRecord.Assignee__c = getUserByName(null);
//     }

   
//     // Safely parse Start Date
//     String startDateString = fields != null && fields.containsKey(CUSTOMFIELD_START_DATE) ? (String) fields.get(CUSTOMFIELD_START_DATE) : null;
//   //  jiraRecord.StartDate__c = Date.today();
//   //  jiraRecord.DueDate__c = Date.today(); // Assuming you want to set it to the current date.
 
//     if (fields != null) {
//             if (fields.containsKey(CUSTOMFIELD_START_DATE) && (String) fields.get(CUSTOMFIELD_START_DATE) != null ) {
//                 String startDateStr = (String) fields.get(CUSTOMFIELD_START_DATE);
//                 jiraRecord.StartDate__c = parseDate(startDateStr);
//             }else{
//                 jiraRecord.StartDate__c = Date.today();
//             }
//             if (fields.containsKey(CUSTOMFIELD_DUE_DATE)&& (String) fields.get(CUSTOMFIELD_DUE_DATE) != null ) {
//                 String dueDateStr = (String) fields.get(CUSTOMFIELD_DUE_DATE);
//                 jiraRecord.DueDate__c = parseDate(dueDateStr);
//             }else{
//                 jiraRecord.DueDate__c = Date.today(); 
//             }
//      }
 
//      Integer AggregateTimeSpend = fields != null && fields.containsKey('aggregatetimespent') ? (Integer) fields.get('aggregatetimespent') : null;
//     jiraRecord.Aggregate_Time_Tracking__c = AggregateTimeSpend != null ? convertSecondsToDHMS(AggregateTimeSpend) : null;

//     Integer timeSpentSeconds = fields != null && fields.containsKey('timespent') ? (Integer) fields.get('timespent') : null;
//     jiraRecord.Actual_Time_Tracking__c = timeSpentSeconds != null ? convertSecondsToDHMS(timeSpentSeconds) : null;
//     String endDateString = (String) fields.get(CUSTOMFIELD_PLANNED_END_DATE) != null && fields.containsKey(CUSTOMFIELD_PLANNED_END_DATE) ? (String) fields.get(CUSTOMFIELD_PLANNED_END_DATE) : null;


//     // Assumig you want to set it to the current date.
//     jiraRecord.ParentName__c = fields != null && fields.containsKey('parent') ? (String) ((Map<String, Object>) fields.get('parent')).get('key') : null;

//     Integer actualTimeInSeconds = fields != null && fields.containsKey('aggregatetimeoriginalestimate') ? (Integer) fields.get('aggregatetimeoriginalestimate') : null;
//     jiraRecord.Expected_Time_Tracking__c = actualTimeInSeconds != null ? convertSecondsToDHMS(actualTimeInSeconds) : null;

//     return jiraRecord;
// }
    
//     private static Boolean hasChanges(Jira__c existingRecord, Jira__c newRecord) {
//         return existingRecord.Type__c != newRecord.Type__c ||
//                existingRecord.Summary__c != newRecord.Summary__c ||
//                existingRecord.Status__c != newRecord.Status__c ||
//                existingRecord.Reporter__c != newRecord.Reporter__c ||
//                existingRecord.Assignee__c != newRecord.Assignee__c ||
//                existingRecord.StartDate__c != newRecord.StartDate__c ||
//                existingRecord.Expected_Time_Tracking__c != newRecord.Expected_Time_Tracking__c ||
//                existingRecord.DueDate__c != newRecord.DueDate__c ||
//                existingRecord.ParentName__c != newRecord.ParentName__c ||
//                existingRecord.Actual_Time_Tracking__c != newRecord.Actual_Time_Tracking__c||
//                existingRecord.Aggregate_Time_Tracking__c!=newRecord.Aggregate_Time_Tracking__c;
               
//     }

//     private static String convertSecondsToDHMS(Integer totalSeconds) {
//         if (totalSeconds == null) {
//             return null;
//         }
        
//         Integer days = totalSeconds / (8 * 3600);
//         Integer remainder = totalSeconds - (days * 8 * 3600);
//         Integer hours = remainder / 3600;
//         remainder = remainder - (hours * 3600);
//         Integer minutes = remainder / 60;
    
//         return days + ' days ' + hours + ' hours ' + minutes + ' minutes ';
//     }

//     private static String getUserByName(String displayName) {
//         if (displayName != null) {
//             List<User> users = [SELECT Id FROM User WHERE Name = :displayName LIMIT 1];
//             if (!users.isEmpty()) {
//                 return users[0].Id;
//             }
//         }
//         return '005dL000002kfyJQAQ'; // Default user ID if not found
//     }
//     private static Date parseDate(String dateString) {
//     	if (String.isNotEmpty(dateString)) {
//             try {
//                 // Adjust the date format if necessary to match the format of dateString
//                 return Date.valueOf(dateString);
//             } catch (Exception e) {
//                 System.debug('Date parsing failed: ' + e.getMessage());
//             }
//     	}
//     	return null;
// 	}
 }