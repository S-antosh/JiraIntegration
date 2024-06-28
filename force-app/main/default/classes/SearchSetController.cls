public with sharing class SearchSetController {
    @AuraEnabled(cacheable=true)
    public static List<Search_Set__c> getSearchSets() {
        return [SELECT Id, Name, Employee_Names__c FROM Search_Set__c];
    }

    @AuraEnabled
    public static void saveSearchSet(String setName, String employeeNames) {
        Search_Set__c searchSet = new Search_Set__c();
        searchSet.Name = setName;
        searchSet.Employee_Names__c = employeeNames;
        insert searchSet;
    }

    @AuraEnabled
    public static void deleteSearchSet(Id searchSetId) {
        Search_Set__c searchSet = [SELECT Id FROM Search_Set__c WHERE Id = :searchSetId LIMIT 1];
        delete searchSet;
    }
    @AuraEnabled
    public static void updateSearchSet(Id searchSetId, String employeeNames) {
        Search_Set__c existingSet = [SELECT Id, Employee_Names__c FROM Search_Set__c WHERE Id = :searchSetId];
        existingSet.Employee_Names__c = employeeNames;
        update existingSet;
    }
}

