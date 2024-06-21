public class LogService {
    // Inner class to represent a log entry
    public class LogEntry {
        public String displayName { get; set; }
        public String timeSpent { get; set; }
        public Integer timeSpentSeconds { get; set; }
        public Date createdDate { get; set; }
        public Time createdTime { get; set; }
        public String jiraKey { get; set; }

        public LogEntry(String displayName, String timeSpent, String jiraKey, Integer timeSpentSeconds, Date createdDate, Time createdTime) {
            this.displayName = displayName;
            this.timeSpent = timeSpent;
            this.timeSpentSeconds = timeSpentSeconds;
            this.createdDate = createdDate;
            this.createdTime = createdTime;
            this.jiraKey = jiraKey;
        }
    }

    // Static Map to store person's log entries
    private static Map<String, List<LogEntry>> personLogs = new Map<String, List<LogEntry>>();

    // Method to add a log entry to personLogs
    public static void addLog(String displayName, String timeSpent, String jiraKey, Integer timeSpentSeconds, Date createdDate, Time createdTime) {
        LogEntry logEntry = new LogEntry(displayName, timeSpent, jiraKey, timeSpentSeconds, createdDate, createdTime);

        if (!personLogs.containsKey(displayName)) {
            // Initialize a new list for this person
            personLogs.put(displayName, new List<LogEntry>{ logEntry });
        } else {
            // Retrieve the existing list and add the new log entry
            List<LogEntry> logEntries = personLogs.get(displayName);
            logEntries.add(logEntry);
            personLogs.put(displayName, logEntries); // Ensure the map is updated
            System.debug('Log added: ' + logEntry);
        }
    }

    // Method to insert WorkLog__c records based on stored log entries
public static void insertWorkLogs() {
    List<WorkLog__c> workLogsToInsert = new List<WorkLog__c>();

    for (List<LogEntry> entries : personLogs.values()) {
        for (LogEntry entry : entries) {
            WorkLog__c workLog = new WorkLog__c();
            workLog.Employee__c = entry.displayName;
            workLog.jiraKey__c = entry.jiraKey;
            workLog.timespent__c = entry.timeSpent;
            workLog.timeSpentSeconds__c = entry.timeSpentSeconds;
            workLog.created__c = DateTime.newInstance(entry.createdDate, entry.createdTime);
			
            // Add workLog to the list for bulk insertion
            workLogsToInsert.add(workLog);
            system.assert(false,'%%%%%%%%%%%%%'+workLogsToInsert);
           
        }
    }
    
	
    // Perform bulk insertion
    if (!workLogsToInsert.isEmpty()) {
        insert workLogsToInsert;
    }
}


    

    @AuraEnabled(cacheable=true)
    public static string  getAllLogs() {
       JiraRestClient.allProject();
        string  data =JSON.serializePretty(personLogs);
        insertWorkLogs();
        return data;
    }


}