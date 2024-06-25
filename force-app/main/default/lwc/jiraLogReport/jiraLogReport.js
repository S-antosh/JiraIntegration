import { LightningElement, track } from 'lwc';
import getAllLogs from '@salesforce/apex/LogService.getAllLogs';
import createWorklogFormJS from '@salesforce/apex/CreateWorklogFormJS.createWorklogFormJS';

export default class LogTable extends LightningElement {
    @track tableData = [];
    @track tableColumns = [];
    @track modalTableColumns = [];
    @track isLoading = false;
    @track showModal = false;
    @track selectedRow = {};
    @track filteredLogEntries = [];
    @track allLogs = []; // Store all logs prefetched
    startDate;
    endDate;
    searchTerm = '';
    @track startDateError = '';
    @track endDateError = '';
    @track elseError = '';

    connectedCallback() {
        this.prefetchLogs();
    }

    async prefetchLogs() {
        this.isLoading = true;
        try {
            const result = await getAllLogs();
            this.allLogs = JSON.parse(result); // Store the prefetched logs
            await createWorklogFormJS({ jsonResult: result });
        } catch (error) {
            console.error('Error fetching logs:', error);
        } finally {
            this.isLoading = false;
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

    handleEmployeeChange(event) {
        this.searchTerm = event.target.value.toLowerCase();
    }

    get filteredData() {
        if (!this.searchTerm) {
            return this.tableData;
        }
        const searchTerms = this.searchTerm.split(',').map(term => term.trim());
        return this.tableData.filter(record =>
            searchTerms.some(term => record.displayName.toLowerCase().includes(term))
        );
    }

    async fetchLogs() {
        this.validateDates();
        if (!this.startDateError && !this.endDateError && this.startDate && this.endDate) {
            this.isLoading = true; // Show the spinner
            try {
                const filteredLogs = this.filterLogsByDate(this.allLogs);
                this.generateColumns();
                this.processData(filteredLogs);
            } catch (error) {
                console.error('Error processing logs:', error);
            } finally {
                this.isLoading = false; // Hide the spinner
            }
        } else {
            this.elseError = 'please provide the correct dates';
        }
        this.validateDates();
    }

    filterLogsByDate(logs) {
        const startDate = new Date(this.startDate);
        const endDate = new Date(this.endDate);
        const filteredLogs = {};

        for (const displayName in logs) {
            if (logs.hasOwnProperty(displayName)) {
                const logEntries = logs[displayName].filter(entry => {
                    const createdDate = new Date(entry.createdDate);
                    return createdDate >= startDate && createdDate <= endDate;
                });
                if (logEntries.length > 0) {
                    filteredLogs[displayName] = logEntries;
                }
            }
        }

        return filteredLogs;
    }

    generateColumns() {
        const actions = [
            { label: 'Show Details', name: 'show_details' }
        ];
        this.tableColumns = [
            {
                type: 'action',
                typeAttributes: { rowActions: actions }
            },
            { label: 'Employee Name', fieldName: 'displayName', type: 'text' }
        ];

        this.modalTableColumns = [
            { label: 'JIRA Key', fieldName: 'jiraKey', type: 'text' }
        ];

        let currentDate = new Date(this.startDate);
        const endDate = new Date(this.endDate);

        while (currentDate <= endDate) {
            const dateString = currentDate.toISOString().split('T')[0];
            this.tableColumns.push({
                label: dateString,
                fieldName: dateString,
                type: 'text'
            });
            this.modalTableColumns.push({
                label: dateString,
                fieldName: dateString,
                type: 'text'
            });
            currentDate.setDate(currentDate.getDate() + 1);
        }

        this.tableColumns.push({
            label: 'Sum',
            fieldName: 'sum',
            type: 'text'
        });

        this.modalTableColumns.push({
            label: 'Sum',
            fieldName: 'sum',
            type: 'text'
        });
    }

    processData(logs) {
        const tableData = [];
        for (const displayName in logs) {
            if (logs.hasOwnProperty(displayName)) {
                const logEntries = logs[displayName];
                const rowData = { displayName, logEntries };
                let sum = 0;

                logEntries.forEach(logEntry => {
                    const createdDate = logEntry.createdDate.split('T')[0];
                    const logHours = this.formatTime(logEntry.timeSpentSeconds);
                    if (!rowData[createdDate]) {
                        rowData[createdDate] = '0d 0h 0m';
                    }
                    const [currentDays, currentHours, currentMinutes] = rowData[createdDate].match(/\d+/g).map(Number);
                    const [newDays, newHours, newMinutes] = logHours.match(/\d+/g).map(Number);
                    const totalMinutes = currentMinutes + newMinutes;
                    const totalHours = currentHours + newHours + Math.floor(totalMinutes / 60);
                    const totalDays = currentDays + newDays + Math.floor(totalHours / 8);
                    rowData[createdDate] = `${totalDays}d ${totalHours % 8}h ${totalMinutes % 60}m`;
                    sum += logEntry.timeSpentSeconds;
                });

                rowData.sum = this.formatTime(sum);

                this.tableColumns.forEach(column => {
                    if (!rowData[column.fieldName] && column.fieldName !== 'displayName' && column.fieldName !== 'sum') {
                        rowData[column.fieldName] = '0d 0h 0m';
                    }
                });

                tableData.push(rowData);
            }
        }
        this.tableData = tableData;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'show_details') {
            this.selectedRow = row;
            this.filteredLogEntries = this.filterLogEntriesByDate(row.logEntries);
            this.showModal = true;
            this.processModalData(this.filteredLogEntries);
        }
    }

    filterLogEntriesByDate(logEntries) {
        const startDate = new Date(this.startDate);
        const endDate = new Date(this.endDate);
        return logEntries.filter(entry => {
            const createdDate = new Date(entry.createdDate);
            return createdDate >= startDate && createdDate <= endDate;
        });
    }

    processModalData(logEntries) {
        const modalData = [];
        const jiraKeyMap = {};

        logEntries.forEach(logEntry => {
            const jiraKey = logEntry.jiraKey;
            if (!jiraKeyMap[jiraKey]) {
                jiraKeyMap[jiraKey] = { jiraKey, logEntries: [] };
            }
            jiraKeyMap[jiraKey].logEntries.push(logEntry);
        });

        for (const jiraKey in jiraKeyMap) {
            if (jiraKeyMap.hasOwnProperty(jiraKey)) {
                const logEntries = jiraKeyMap[jiraKey].logEntries;
                const rowData = { jiraKey, logEntries };
                let sum = 0;

                logEntries.forEach(logEntry => {
                    const createdDate = logEntry.createdDate.split('T')[0];
                    const logHours = this.formatTime(logEntry.timeSpentSeconds);
                    if (!rowData[createdDate]) {
                        rowData[createdDate] = '0d 0h 0m';
                    }
                    const [currentDays, currentHours, currentMinutes] = rowData[createdDate].match(/\d+/g).map(Number);
                    const [newDays, newHours, newMinutes] = logHours.match(/\d+/g).map(Number);
                    const totalMinutes = currentMinutes + newMinutes;
                    const totalHours = currentHours + newHours + Math.floor(totalMinutes / 60);
                    const totalDays = currentDays + newDays + Math.floor(totalHours / 8);
                    rowData[createdDate] = `${totalDays}d ${totalHours % 8}h ${totalMinutes % 60}m`;
                    sum += logEntry.timeSpentSeconds;
                });

                rowData.sum = this.formatTime(sum);

                this.modalTableColumns.forEach(column => {
                    if (!rowData[column.fieldName] && column.fieldName !== 'jiraKey' && column.fieldName !== 'sum') {
                        rowData[column.fieldName] = '0d 0h 0m';
                    }
                });

                modalData.push(rowData);
            }
        }
        this.filteredLogEntries = modalData;
    }
    closeModal() {
        this.showModal = false;
        this.selectedRow = {};
    }

    get isDateSelected() {
        return !(!this.startDateError && !this.endDateError && this.startDate && this.endDate);
    }

    get startDateClass() {
        return this.startDateError ? 'slds-has-error' : '';
    }

    get endDateClass() {
        return this.endDateError ? 'slds-has-error' : '';
    }
    get elseError() {
        return this.elseError ? 'slds-has-error' : '';
    }

    formatTime(seconds) {
        const days = Math.floor(seconds / 28800); // 28800 seconds in 8 hours
        seconds %= 28800;
        const hours = Math.floor(seconds / 3600);
        seconds %= 3600;
        const minutes = Math.floor(seconds / 60);
        return `${days}d ${hours}h ${minutes}m`;
    }

    exportHandler(){
        console.log('click vako xa ')
       
        const rows = this.filteredData;
        if (!rows || rows.length === 0) {
            return;
        }

        const columns = this.tableColumns.map(col => col.label);
        let csvContent = columns.join(",") + "\n";

        rows.forEach(row => {
            let rowData = this.tableColumns.map(col => row[col.fieldName]);
            csvContent += rowData.join(",") + "\n";
        });

       this.createLinkForDownload(csvContent);
    }
  
    createLinkForDownload(csvFile) {
        const downLink = document.createElement("a");
        downLink.href = "data:text/csv;charset=utf-8," + encodeURI(csvFile);
        downLink.target = '_blank';
        downLink.download = "DailyWorklogData.csv"
        downLink.click();
    }
}