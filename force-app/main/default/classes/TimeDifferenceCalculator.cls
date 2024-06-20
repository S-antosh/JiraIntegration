public class TimeDifferenceCalculator {
    /*
     * @description: method to convert 'X days Y hours Z minutes' to total minutes
     * @author: Diya Shrestha
     */ 
    public static Integer convertToMinutes(String timeString) {
        /*
         * @description: initialize hours and minutes
         */
        Integer days = 0;
        Integer hours = 0;
        Integer minutes = 0;
        /*
         * @description: extract days (trim<-remove any leading or trailing whitespaces from the extracted substring, timeString.indexOf(' days') means index just before ' days')
         */
        if (timeString.contains(' days')) {
            String daysString = timeString.substring(0, timeString.indexOf(' days')).trim();
            days = Integer.valueOf(daysString);
        }
        /*
         * @description: extract hours (+5 indicates ' days' index sum)
         */
        if (timeString.contains(' hours')) {
            String hoursString = timeString.substring(timeString.indexOf(' days') + 5, timeString.indexOf(' hours')).trim();
            hours = Integer.valueOf(hoursString);
        }
        /*
         * @description: extract minutes (+6 indicates ' hours' index sum)
         */
        if (timeString.contains(' minutes')) {
            String minutesString = timeString.substring(timeString.indexOf(' hours') + 6, timeString.indexOf(' minutes')).trim();
            minutes = Integer.valueOf(minutesString);
        }
        /*
         * @description: Convert the total time to minutes
         */
        return (days * 8 * 60) + (hours * 60) + minutes;
    }
    /*
     * @description: Method to convert total minutes back to 'X days Y hours Z minutes' format
     */
    public static String convertToTimeFormat(Integer totalMinutes) {
        Integer days = totalMinutes / (8 * 60);
        totalMinutes = Math.mod(totalMinutes, 8 * 60); 
        Integer hours = totalMinutes / 60; 
        Integer minutes = Math.mod(totalMinutes, 60);
        return days + ' days ' + hours + ' hours ' + minutes + ' minutes';
    }
    /*
     * @description: Method to calculate the difference between two time strings
     */
    public static String calculateTimeDifference(String timeString1, String timeString2) {
        Integer minutes1 = convertToMinutes(timeString1);
        Integer minutes2 = convertToMinutes(timeString2);
 
        Integer differenceInMinutes = minutes2 - minutes1;
        return convertToTimeFormat(differenceInMinutes);
    }
}