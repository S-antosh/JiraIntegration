public class WorklogProcessor {
    private static final String WORKLOG_ENDPOINT_URL_TEMPLATE = 'callout:JiraAuth/rest/api/3/issue/{key}/worklog';
   
    public static Map<String, Object> getWorklog(String jiraKey) {
        String worklogEndpoint = WORKLOG_ENDPOINT_URL_TEMPLATE.replace('{key}', jiraKey);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(worklogEndpoint);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
            if (res.getStatusCode() == 200) {
                
                return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            } else {
                System.debug('Error fetching worklog: ' + res.getStatusCode() + ' ' + res.getStatus());
            }
        } catch (Exception e) {
            System.debug('HTTP Request failed: ' + e.getMessage());
        }
        return null;
    }

    public static void processWorklogs(Set<String> jiraKeys) {
        for (String jiraKey : jiraKeys) {
            Map<String, Object> responseMap = getWorklog(jiraKey); // Fetch JSON response
            if (responseMap != null && responseMap.containsKey('worklogs')) {
                List<Object> worklogs = (List<Object>) responseMap.get('worklogs');

                for (Object worklogObj : worklogs) {
                    Map<String, Object> worklog = (Map<String, Object>) worklogObj;
                    String displayName = (String)((Map<String, Object>) worklog.get('author')).get('displayName');
                    String worklogDescription = extractDescription((Map<String, Object>) worklog.get('comment'));
                    String emailAddress = (String)((Map<String, Object>) worklog.get('author')).get('emailAddress');
                    String accountId = (String)((Map<String, Object>) worklog.get('author')).get('accountId');
                    Integer timeSpentSeconds = (Integer) worklog.get('timeSpentSeconds');
                    String originalDateTimeString = (String) worklog.get('created');
                    String timespent = (String) worklog.get('timeSpent');
                    DateTime standardDateTimeString = DateTime.valueOf(originalDateTimeString.replace('T', ' '));
                    Date createdDate = standardDateTimeString.date();
                    Time createdTime = standardDateTimeString.time();
                    String id = (String) worklog.get('id');
                    LogService.addLog(displayName, worklogDescription, emailAddress, accountId, timespent, jiraKey, timeSpentSeconds, createdDate, createdTime, id); 
                }
            } else {
                System.debug('No worklogs found for Jira key ' + jiraKey);
            }
        }
    }

    private static String extractDescription(Map<String, Object> comment) {
        String description = '';
        if (comment != null && comment.containsKey('content')) {
            List<Object> contentList = (List<Object>) comment.get('content');
            for (Object contentObj : contentList) {
                Map<String, Object> contentMap = (Map<String, Object>) contentObj;
                if (contentMap.containsKey('content')) {
                    List<Object> nestedContentList = (List<Object>) contentMap.get('content');
                    for (Object nestedContentObj : nestedContentList) {
                        Map<String, Object> nestedContentMap = (Map<String, Object>) nestedContentObj;
                        if (nestedContentMap.containsKey('text')) {
                            description += (String) nestedContentMap.get('text');
                        }
                    }
                }
            }
        }
        return description;
    }
}