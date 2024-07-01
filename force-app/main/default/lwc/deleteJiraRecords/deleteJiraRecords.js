import { LightningElement, track } from 'lwc';
import deleteAllJiraRecords from '@salesforce/apex/JiraController.deleteAllJiraRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
export default class DeleteJiraRecords extends LightningElement {
 
    handleDelete() {
        deleteAllJiraRecords()
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'All Jira records have been deleted',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting records',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }
}