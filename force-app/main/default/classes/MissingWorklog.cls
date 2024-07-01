public with sharing class MissingWorklog {
    @AuraEnabled(cacheable=true)
    public static Map<String, List<MissingWorkLogData>> getMissingWorkLogData(Integer days) {
        Date today = Date.today();
        Date sevendaysago = today.addDays(-days);

        List<WorkLog__c> worklogs = [SELECT Employee__c, emailAddress__c, Created_Date__c FROM WorkLog__c WHERE Created_Date__c >= :sevendaysago AND Created_Date__c <= :today];

        // Prepare a map to store dates of work logs for each employee
        Map<String, Set<Date>> employeeWorkLogs = new Map<String, Set<Date>>();
        Map<String, String> employeeEmails = new Map<String, String>();
        for (WorkLog__c worklog : worklogs) {
            if (!employeeWorkLogs.containsKey(worklog.Employee__c)) {
                employeeWorkLogs.put(worklog.Employee__c, new Set<Date>());
            }
            employeeWorkLogs.get(worklog.Employee__c).add(worklog.Created_Date__c);
            employeeEmails.put(worklog.Employee__c, worklog.emailAddress__c);
        }

        // Prepare the result map
        Map<String, List<MissingWorkLogData>> employeeMissingLogs = new Map<String, List<MissingWorkLogData>>();
        for (String employee : employeeWorkLogs.keySet()) {
            List<MissingWorkLogData> missingLogs = new List<MissingWorkLogData>();
            for (Date date1 = sevendaysago; date1 <= today; date1 = date1.addDays(1)) {
                if (!employeeWorkLogs.get(employee).contains(date1)) {
                    MissingWorkLogData missingLog = new MissingWorkLogData(
                        employee,
                        employeeEmails.get(employee),
                        date1
                    );
                    missingLogs.add(missingLog);
                }
            }
            employeeMissingLogs.put(employee, missingLogs);
        }

        System.debug(employeeMissingLogs);
        return employeeMissingLogs;
    }

    public class MissingWorkLogData {
        @AuraEnabled
        public String employee { get; set; }
        @AuraEnabled
        public String email { get; set; }
        @AuraEnabled
        public Date missingDate { get; set; }

        public MissingWorkLogData(String employee, String email, Date missingDate) {
            this.employee = employee;
            this.email = email;
            this.missingDate = missingDate;
        }
    }
}