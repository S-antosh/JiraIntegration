import { LightningElement, track } from 'lwc';

export default class MonthlyLogReport extends LightningElement {
  @track tableData = [];
  @track tableColumns = [];

  connectedCallback() {
    this.initializeColumns();
  }

  initializeColumns() {
    this.tableColumns = [
      { label: 'Employee Name', fieldName: 'displayName', type: 'text' },
      { label: 'Working Days', fieldName: 'workingDays', type: 'number' },
      { label: 'Leave Taken', fieldName: 'leaveTaken', type: 'number' },
      { label: 'Working Days (Actual)', fieldName: 'workingDaysActual', type: 'number' },
      { label: 'Expected Monthly Working Hrs', fieldName: 'expectedMonthlyHrs', type: 'number' },
      { label: 'Productive Working Hrs', fieldName: 'productiveHrs', type: 'number' },
      { label: 'Actual Working Hrs', fieldName: 'actualWorkingHrs', type: 'number' },
    ];
  }

  calculateExpectedWorkingHrs(workingDays) {
    return workingDays * 8;
  }

  calculateProductiveWorkingHrs(workingDays) {
    return workingDays * 6;
  }

  processData(data) {
    for (const row of data) {
      row.expectedMonthlyHrs = this.calculateExpectedWorkingHrs(row.workingDaysActual);
      row.productiveHrs = this.calculateProductiveWorkingHrs(row.workingDaysActual);
      // Implement logic to calculate actual working hours here (replace with your logic)
      row.actualWorkingHrs = 0; // Replace with actual working hour calculation
      this.tableData.push(row);
    }
  }

  // Replace this with your logic to fetch employee data
  fetchEmployeeData() {
    // Replace with your logic to fetch employee data and working days
    const employeeData = [
      { displayName: 'John Doe', workingDays: 20, leaveTaken: 2, workingDaysActual: 18 },
      { displayName: 'Jane Smith', workingDays: 22, leaveTaken: 1, workingDaysActual: 21 },
    ];
    this.processData(employeeData);
  }

  renderedCallback() {
    if (!this.tableData.length) {
      this.fetchEmployeeData();
    }
  }
}