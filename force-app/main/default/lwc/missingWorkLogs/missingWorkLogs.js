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
    @track startDateError;
    @track endDateError;
    value=7;
    // Initialize dates as string in YYYY-MM-DD format
    endDate = new Date().toISOString().split('T')[0];
    startDate = new Date(new Date().setDate(new Date().getDate() - 7)).toISOString().split('T')[0];
    columns = columns;
    dateRangeOptions = [
        { label: 'Last 7 days', value: 7 },
        { label: 'Last 15 days', value: 15 },
        { label: 'Last 30 days', value: 30 }
    ];

    handleDaysChange(event) {
        const days = event.detail.value;
        this.value = Number(event.detail.value);
        this.startDate = new Date(new Date().setDate(new Date().getDate() - days)).toISOString().split('T')[0];
        this.endDate = new Date().toISOString().split('T')[0];
        this.validateDates();
    }

    @wire(getMissingWorkLogData, { startDate: '$startDate', endDate: '$endDate' })
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

    handleStartDateChange(event) {
        this.startDate = event.target.value;
        this.startDateError = '';
        if (new Date(this.startDate) > new Date()) {
            this.startDateError = 'Start Date should not be greater than today\'s Date';
        }
        this.validateDates();
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
        this.endDateError = '';
        if (new Date(this.endDate) < new Date(this.startDate)) {
            this.endDateError = 'End Date should be greater than Start Date';
        } else if (new Date(this.endDate) > new Date()) {
            this.endDateError = 'End Date should not be greater than today\'s Date';
        }
        this.validateDates();
    }

    validateDates() {
        if (this.startDate && this.endDate) {
            if (new Date(this.startDate) > new Date(this.endDate)) {
                this.endDateError = 'End Date should be greater than Start Date';
            }
        }
    }
}