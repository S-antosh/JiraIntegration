public class LogService {
    // Inner class to represent a log entry
    public class LogEntry {
        public String displayName { get; set; }
        public String timeSpent { get; set; }
        public Integer timeSpentSeconds { get; set; }
        public Date createdDate { get; set; }
        public Time createdTime { get; set; }
        public String jiraKey { get; set; }

        public LogEntry(String displayName,String timeSpent , String jiraKey, Integer timeSpentSeconds, Date createdDate, Time createdTime) {
            this.displayName = displayName;
            this.timeSpent=timeSpent;
            this.timeSpentSeconds = timeSpentSeconds;
            this.createdDate = createdDate;
            this.createdTime = createdTime;
            this.jiraKey = jiraKey;
        }
    }

    // Static Map to store person's log entries
    private static Map<String, List<LogEntry>> personLogs = new Map<String, List<LogEntry>>();

    public static void addLog(String displayName,String timeSpent, String jiraKey, Integer timeSpentSeconds, Date createdDate, Time createdTime) {
        LogEntry logEntry = new LogEntry(displayName, timeSpent,jiraKey, timeSpentSeconds, createdDate, createdTime);

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
    @AuraEnabled(cacheable=true)
    public static string  getAllLogs() {
       JiraRestClient.allProject();
        system.debug('*********************'+personLogs);
        string  data =JSON.serializePretty(personLogs);

        
        return data;
    }
}