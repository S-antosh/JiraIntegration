trigger TimeDifferenceTrigger on Jira__c (before insert, before update) {
    for (Jira__c obj : Trigger.new) {
        if (obj.Actual_Time_Tracking__c != null && obj.Expected_Time_Tracking__c != null) {
            obj.Time_Difference__c = TimeDifferenceCalculator.calculateTimeDifference(obj.Actual_Time_Tracking__c, obj.Expected_Time_Tracking__c);
        }
    }
}