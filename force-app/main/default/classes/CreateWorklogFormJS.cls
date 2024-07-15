public with sharing class CreateWorklogFormJS {
    
    @AuraEnabled
    public static void createWorklogFormJS(String jsonResult) {
        List<WorkLog__c> totalRecordData = new List<WorkLog__c>();
        try {
            // Deserialize the JSON string into a generic map
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(jsonResult);
            
            list<Jira__c> jiras=[select id,Name from Jira__c ];

            // Iterate through each employee's log entries
            for (String employeeName : jsonData.keySet()) {
                List<Object> logEntries = (List<Object>) jsonData.get(employeeName);
                
                for (Object logEntryObj : logEntries) {
                    Map<String, Object> logEntry = (Map<String, Object>) logEntryObj;
                    WorkLog__c recordData = new WorkLog__c();
                    
                   String email=(String) logEntry.get('emailAddress');
                   
                    list<Employee__c> employeeData=[select id from  Employee__c where Email__c=:email];
                 
                    ID empId;
                    if (employeeData.size()==0){
                        
                        Employee__c emp= new  Employee__c();
                        emp.Name=employeeName;
                        emp.Email__c=(String) logEntry.get('emailAddress');
                        emp.Check_UI_or_Apex__c=false;
                        system.debug(emp);
                        insert emp;
                       
                        empId=emp.Id;

                    }else{
                        for(Employee__c emp:employeeData){
                            empId=emp.Id;
                            system.debug(empId);
                            break;
                        }
                    }


                   

                   String jirakey= (String) logEntry.get('jiraKey');
                  
                   id jiraid;
                   if(jiras.size()!=0){
                    for(Jira__c jira:jiras){
                        if(jira.Name==jirakey){
                            jiraid=jira.Id;
                        }
                    }
                   }



                    
                    // Map JSON fields to WorkLog__c fields
                    recordData.Id__c = (String) logEntry.get('id');
                    recordData.Employee__c = employeeName;
                    recordData.Work_Description__c=(String) logEntry.get('worklogDescription');
                    recordData.Employees__c=empId;
                    recordData.JiraKey__c = (String) logEntry.get('jiraKey');
                    recordData.TimeSpent__c = (String) logEntry.get('timeSpent');
                    recordData.TimeSpentSeconds__c = (Decimal) logEntry.get('timeSpentSeconds');
                    recordData.emailAddress__c = (String) logEntry.get('emailAddress');
                    recordData.Employee_Jira_Id__c = (String) logEntry.get('accountId');
                    
                    // Convert date to date type
                    String createdDateStr = (String) logEntry.get('createdDate');
                    Date createdDate = Date.valueOf(createdDateStr.substring(0, 10));
                    recordData.Created_Date__c = createdDate;
                    
                    // Convert time to time type
                    String createdTimeStr = (String) logEntry.get('createdTime');
                    Integer hours = Integer.valueOf(createdTimeStr.substring(0, 2));
                    Integer minutes = Integer.valueOf(createdTimeStr.substring(3, 5));
                    Integer seconds = Integer.valueOf(createdTimeStr.substring(6, 8));
                    Time createdTime = Time.newInstance(hours, minutes, seconds, 0);
                    recordData.Created_Time__c = createdTime;
                    recordData.Created_Edited_Through_UI__c=false;
                   recordData.Jira__c=jiraid;

                    // Add the record to the list
                    totalRecordData.add(recordData);
                }
            }

            
            // Upsert the data using JiraKey__c as the external ID field
            if (!totalRecordData.isEmpty()) {
                Database.UpsertResult[] upsertResults = Database.upsert(totalRecordData, WorkLog__c.Fields.Id__c, false);
                
                // Handle any errors
                for (Database.UpsertResult result : upsertResults) {
                    if (!result.isSuccess()) {
                        // Log the error
                        for (Database.Error error : result.getErrors()) {
                            System.debug('Error upserting record: ' + error.getMessage());
                        }
                    }
                }
            }

        } catch (Exception e) {
            System.debug('Error processing logs: ' + e.getMessage());
        }


        for(Worklog__c worklog:totalRecordData){
            worklog.Created_Edited_Through_UI__c=true;
        }
        update totalRecordData;
    }
}