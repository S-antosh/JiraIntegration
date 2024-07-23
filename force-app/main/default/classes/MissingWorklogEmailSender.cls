public with sharing class MissingWorklogEmailSender {
    public static void sendMissingWorklogEmails() {
        Map<String, List<MissingWorklog.MissingWorkLogData>> employeeMissingLogs = MissingWorklog.getMissingWorkLogData(Date.today().addDays(-7),Date.today());

        for (String employee : employeeMissingLogs.keySet()) {
            List<MissingWorklog.MissingWorkLogData> missingLogs = employeeMissingLogs.get(employee);
            if (!missingLogs.isEmpty()) {
                // Assuming employee is the User Id, if not modify as required
                // Fetch the email from the first missing log entry (assuming all entries have the same email)
                String email = missingLogs[0].email;
                system.debug('^^^^'+email);

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { email });
                mail.setSubject('Missing Work Logs Notification');
                
                String body = 'Dear Employee,<br/><br/>You have missing work logs for the following dates:<br/><ul>';
                for (MissingWorklog.MissingWorkLogData missingLog : missingLogs) {
                    body += '<li>' + missingLog.missingDate + '</li>';
                }
                body += '</ul><br/>Please log your work for these dates as soon as possible.<br/><br/>Best regards,<br/>CQ Nepal';
                mail.setHtmlBody(body);
                system.debug('^^^^^'+body);
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }
}