public with sharing class scheduleWorkLog  implements Schedulable  {
    public void execute (SchedulableContext context){
        CreateWorklogFormJS.createWorklogFormJS(LogService.getAllLogs());

    }

      
    public static void scheduleWorkLog() {
        
        CreateWorklogFormJS.createWorklogFormJS(LogService.getAllLogs());

    }
}