import getMissingWorkLogData from '@salesforce/apex/MissingWorklog.getMissingWorkLogData';
import { LightningElement, track, wire } from 'lwc';

const columns = [
    { label: 'Employee', fieldName: 'employee' },
    { label: 'Email', fieldName: 'email', type: 'email' },
    { label: 'Missing Dates', fieldName: 'missingDates', type: 'text' }
];

export default class MissingWorkLogs extends LightningElement {
    @track workLogs; 
    @track error;
    columns = columns;
    @track days=7
    dateRangeOptions = [
        { label: '1 Week', value: 7 },
        { label: '15 Days', value: 15 }
    ];

    @wire(getMissingWorkLogData,{days:'$days'})
    wiredWorkLogs({ error, data }) {
        if (data) {
            this.workLogs = Object.keys(data).map(employee => {
                const missingLogs = data[employee];
                return {
                    id: employee,
                    employee: missingLogs[0].employee,
                    email: missingLogs[0].email,
                    missingDates: missingLogs.map(log => log.missingDate).join(', ')
                };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.workLogs = undefined;
        }
    }
    handleDaysChange(event) {
        this.days = event.detail.value;
    }
}