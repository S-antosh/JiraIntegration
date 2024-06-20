import { LightningElement, api,wire } from 'lwc';
import getProjectName from '@salesforce/apex/GetProjectDetails.getProjectName';
import performHttpRequestWithNamedCredential from '@salesforce/apex/JiraRestClient.performHttpRequestWithNamedCredential';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class MyComponent extends LightningElement {
    projectOptions = [];
 
    @wire(getProjectName)
    wiredProjectNames({ error, data }) {
        if (data) {
            this.projectOptions = [];
            data.forEach(mapItem => {
                const nameAddressMapper = mapItem.NameAddressMapper;
                Object.values(nameAddressMapper).forEach(projectName => {
                    this.projectOptions.push({ label: projectName, value: projectName });
                });
            });
        } else if (error) {
            console.error('Error fetching project names', error);
        }
    }
 
    handleProjectChange(event) {
        const selectedValue = event.detail.value;
        console.log(selectedValue);
        performHttpRequestWithNamedCredential({ selectedValues: selectedValue })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'All Jira records from Project ' + selectedValue +  ' has been saved',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error retrieving records',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
       
    }
       
}