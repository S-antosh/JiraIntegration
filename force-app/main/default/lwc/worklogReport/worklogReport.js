import { LightningElement, track } from 'lwc';
import getAllLogs from '@salesforce/apex/LogService.getAllLogs';

export default class WorklogReport extends LightningElement {
    @track tableData = [];
    @track tableColumns = [];
    @track isLoading = false;
    @track selectedMonthYear = '';
    @track searchTerm = '';
    @track selectMonthYearError = '';

    handleMonthYearChange(event) {
        this.selectedMonthYear = event.target.value;
        this.selectMonthYearError = '';
        if (new Date(this.selectedMonthYear) > new Date()) {
            this.selectMonthYearError = ' Date should not be greater than today\'s Date';
        }
       
    }
  
    handleEmployeeChange(event) {
        this.searchTerm = event.target.value.toLowerCase();
    }

    get filteredData() {
        if (!this.searchTerm) {
            return this.tableData;
        }
        return this.tableData.filter(record =>
            record.displayName.toLowerCase().includes(this.searchTerm)
        );
    }

    async fetchLogs() {
        if (this.selectedMonthYear&&!this.selectMonthYearError) {
            this.isLoading = true;
            try {
                const result = await getAllLogs();
                const logs = JSON.parse(result);
                this.generateColumns();
                this.processData(logs);
            } catch (error) {
                console.error('Error fetching logs:', error);
            } finally {
                this.isLoading = false;
            }
        } else {
            console.error('Please provide a month and year.');
        }
    }

    generateColumns() {
        this.tableColumns = [
            { label: 'S.No', fieldName: 'sNo', type: 'number' },
            { label: 'Name', fieldName: 'displayName', type: 'text' },
            { label: 'Working Days', fieldName: 'workingDays', type: 'number' },
            { label: 'Leave Taken', fieldName: 'leaveTaken', type: 'number' },
            { label: 'Actual Working Days', fieldName: 'actualWorkingDays', type: 'number' },
            { label: 'Expected Monthly Work Hrs', fieldName: 'expectedMonthlyWorkHrs', type: 'number' },
            { label: 'Expected Productive Working Hrs', fieldName: 'expectedProductiveWorkHrs', type: 'number' },
            { label: 'Actual Logged Hrs', fieldName: 'actualLoggedHrs', type: 'number' }
        ];
    }

    processData(logs) {
        const tableData = [];
        let sNo = 1;

        const [year, month] = this.selectedMonthYear.split('-');
        const workingDays = this.calculateWorkingDays(year, month);

        for (const displayName in logs) {
            if (logs.hasOwnProperty(displayName)) {
                const logEntries = logs[displayName];
                const leaveTaken = logEntries.reduce((total, entry) => total + (entry.leaveTaken || 0), 0);
                const actualWorkingDays = workingDays - leaveTaken;
                const expectedMonthlyWorkHrs = workingDays * 8;
                const expectedProductiveWorkHrs = workingDays * 6;

                const actualLoggedHrs = logEntries.reduce((total, entry) => {
                    const entryDate = new Date(entry.createdDate);
                    if (entryDate.getFullYear() === parseInt(year) && (entryDate.getMonth() + 1) === parseInt(month)) {
                        return total + (entry.timeSpentSeconds / 3600);
                    }
                    return total;
                }, 0);

                const rowData = {
                    sNo: sNo++,
                    displayName,
                    workingDays,
                    leaveTaken,
                    actualWorkingDays,
                    expectedMonthlyWorkHrs,
                    expectedProductiveWorkHrs,
                    actualLoggedHrs
                };

                tableData.push(rowData);
            }
        }
        this.tableData = tableData;
    }

    calculateWorkingDays(year, month) {
        const startDate = new Date(year, month - 1, 1);
        const endDate = new Date(year, month, 0);
        let count = 0;
        for (let d = startDate; d <= endDate; d.setDate(d.getDate() + 1)) {
            const day = d.getDay();
            if (day !== 0 && day !== 6) { // Exclude Sundays (0) and Saturdays (6)
                count++;
            }
        }
        return count;
    }

    ExportData() {
        // Ensure tableData is not empty
        if (!this.tableData || this.tableData.length === 0) {
            console.error('No data to export.');
            return;
        }
    
        try {
            // Step 1: Prepare CSV data
            const csvRows = [];
    
            // Add header row
            const headerRow = Object.keys(this.tableData[0]).join(',');
            csvRows.push(headerRow);
            console.log('Header row:', headerRow);
    
            // Add data rows
            this.tableData.forEach(row => {
                const values = Object.values(row).join(',');
                csvRows.push(values);
            });
            console.log('CSV Rows:', csvRows);
    
            // Step 2: Combine rows into CSV string
            const csvString = csvRows.join('\n');
            console.log('CSV String:', csvString);
    
            // Step 3: Create a data URI
            const dataUri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvString);
            console.log('Data URI created:', dataUri);
    
            // Step 4: Create a link element, trigger download
            const link = document.createElement('a');
            link.href = dataUri;
            link.download = 'export.csv';
            document.body.appendChild(link);
            link.click();
            console.log('Download triggered');
    
            // Step 5: Clean up
            document.body.removeChild(link);
            console.log('Cleanup done');
        } catch (error) {
            console.error('Error during CSV export:', error);
        }
    }
    
    get selectMonthYearError(){
        return this.selectMonthYearError?'slds-has-error':'';
    }
    
    
    
}