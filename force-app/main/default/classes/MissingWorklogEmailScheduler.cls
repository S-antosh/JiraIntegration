public class MissingWorklogEmailScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        MissingWorklogEmailSender.sendMissingWorklogEmails();
    }
}