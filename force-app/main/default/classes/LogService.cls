public class LogService {
    // Inner class to represent a log entry
    public class LogEntry {
        public String displayName { get; set; }
        public String worklogDescription { get; set; }
        public String timeSpent { get; set; }
        public Integer timeSpentSeconds { get; set; }
        public Date createdDate { get; set; }
        public Time createdTime { get; set; }
        public String jiraKey { get; set; }
        public String id { get;set; }
        public String emailAddress{ get; set; }
        public String accountId{ get; set; }

        public LogEntry(String displayName,String worklogDescription,String emailAddress,String accountId,String timeSpent , String jiraKey, Integer timeSpentSeconds, Date createdDate, Time createdTime,String id) {
            this.displayName = displayName;
            this.worklogDescription=worklogDescription;
            this.timeSpent=timeSpent;
            this.timeSpentSeconds = timeSpentSeconds;
            this.createdDate = createdDate;
            this.createdTime = createdTime;
            this.jiraKey = jiraKey;
            this.id = id;
            this.emailAddress=emailAddress;
            this.accountId=accountId;
        }
    }

    // Static Map to store person's log entries
    private static Map<String, List<LogEntry>> personLogs = new Map<String, List<LogEntry>>();

    public static void addLog(String displayName,String worklogDescription,String emailAddress,String accountId,String timeSpent, String jiraKey, Integer timeSpentSeconds, Date createdDate, Time createdTime,String id) {
        LogEntry logEntry = new LogEntry(displayName,worklogDescription,emailAddress,accountId, timeSpent,jiraKey, timeSpentSeconds, createdDate, createdTime, id);

        if (!personLogs.containsKey(displayName)) {
            // Initialize a new list for this person
            personLogs.put(displayName, new List<LogEntry>{ logEntry });
        } else {
            // Retrieve the existing list and add the new log entry
            List<LogEntry> logEntries = personLogs.get(displayName);
            logEntries.add(logEntry);
            personLogs.put(displayName, logEntries); // Ensure the map is updated
          
        }
    }

    @AuraEnabled(cacheable=true)
    public static string  getAllLogs() {
       JiraRestClient.allProject();
       JiraRecordBatchProcessor batchProcessor = new JiraRecordBatchProcessor(jiraGlobalVariables.jiraRecordsToUpdate, jiraGlobalVariables.jiraRecordsToInsert);
       Id batchId = Database.executeBatch(batchProcessor);
    

  
    
        string  data =JSON.serializePretty(personLogs);
        return data;
    }


}