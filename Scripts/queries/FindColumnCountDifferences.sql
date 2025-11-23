-- Manual comparison of the two lists provided
-- This will help identify any tables with different column counts

-- List 1 (Expected/First list)
WITH List1 AS (
    SELECT 'AccrualBanks' AS tableName, 14 AS colCount UNION ALL
    SELECT 'AccrualProfiles', 11 UNION ALL
    SELECT 'AccrualRules', 11 UNION ALL
    SELECT 'AccrualRulesSlots', 13 UNION ALL
    SELECT 'AccrualTrackProfiles', 9 UNION ALL
    SELECT 'AccrualTracks', 7 UNION ALL
    SELECT 'AccrualTransactions', 13 UNION ALL
    SELECT 'AccrualTypes', 14 UNION ALL
    SELECT 'AssisstantQualifiers', 12 UNION ALL
    SELECT 'AvailabilityPeriodShifts', 4 UNION ALL
    SELECT 'BusinessRules', 16 UNION ALL
    SELECT 'ClockInOut', 15 UNION ALL
    SELECT 'Columns', 8 UNION ALL
    SELECT 'ColumnShifts', 11 UNION ALL
    SELECT 'CustomTables', 5 UNION ALL
    SELECT 'CustomTableValues', 7 UNION ALL
    SELECT 'DbOperationsAnalytics', 13 UNION ALL
    SELECT 'EmployeeAccrualSettings', 11 UNION ALL
    SELECT 'EmployeeHourlyRates', 12 UNION ALL
    SELECT 'EmployeeJobCodeAssignment', 11 UNION ALL
    SELECT 'EmployeeLabelAssignment', 13 UNION ALL
    SELECT 'EmployeeShiftAssignmentJobCodes', 8 UNION ALL
    SELECT 'EmployeeShiftAssignmentLabels', 8 UNION ALL
    SELECT 'EmployeeShiftAssignmentWorkCodes', 8 UNION ALL
    SELECT 'EmployeeWorkCodeAssignment', 11 UNION ALL
    SELECT 'Groups', 11 UNION ALL
    SELECT 'HolidayAssignment', 14 UNION ALL
    SELECT 'HolidayRules', 12 UNION ALL
    SELECT 'Holidays', 13 UNION ALL
    SELECT 'JobCodes', 16 UNION ALL
    SELECT 'Labels', 12 UNION ALL
    SELECT 'LayoutGridColumns', 11 UNION ALL
    SELECT 'Layouts', 11 UNION ALL
    SELECT 'OvertimeRules', 13 UNION ALL
    SELECT 'PayPeriod', 12 UNION ALL
    SELECT 'Payroll', 23 UNION ALL
    SELECT 'PayrollItem', 14 UNION ALL
    SELECT 'RuleExecution', 15 UNION ALL
    SELECT 'RuleProcessingSteps', 13 UNION ALL
    SELECT 'ScheduleFrequencies', 10 UNION ALL
    SELECT 'Schedules', 22 UNION ALL
    SELECT 'ShiftAssignment', 15 UNION ALL
    SELECT 'ShiftGroupAssignment', 9 UNION ALL
    SELECT 'ShiftJobCodeAssignment', 8 UNION ALL
    SELECT 'Shifts', 23 UNION ALL
    SELECT 'ShiftTrades', 21 UNION ALL
    SELECT 'ShiftWorkCodeAssignment', 10 UNION ALL
    SELECT 'TimeEntries', 26 UNION ALL
    SELECT 'TimeEntryTypes', 18 UNION ALL
    SELECT 'TimeSheets', 17 UNION ALL
    SELECT 'TradeBoardListRules', 11 UNION ALL
    SELECT 'TradeBoardSettings', 19 UNION ALL
    SELECT 'WorkCodes', 28
),
-- List 2 (Actual/Second list)
List2 AS (
    SELECT 'AccrualBanks' AS tableName, 14 AS colCount UNION ALL
    SELECT 'AccrualProfiles', 11 UNION ALL
    SELECT 'AccrualRules', 11 UNION ALL
    SELECT 'AccrualRulesSlots', 13 UNION ALL
    SELECT 'AccrualTrackProfiles', 9 UNION ALL
    SELECT 'AccrualTracks', 7 UNION ALL
    SELECT 'AccrualTransactions', 13 UNION ALL
    SELECT 'AccrualTypes', 14 UNION ALL
    SELECT 'AssisstantQualifiers', 12 UNION ALL
    SELECT 'AvailabilityPeriodShifts', 4 UNION ALL
    SELECT 'BusinessRules', 16 UNION ALL
    SELECT 'ClockInOut', 15 UNION ALL
    SELECT 'Columns', 8 UNION ALL
    SELECT 'ColumnShifts', 11 UNION ALL
    SELECT 'CustomTables', 5 UNION ALL
    SELECT 'CustomTableValues', 7 UNION ALL
    SELECT 'DbOperationsAnalytics', 13 UNION ALL
    SELECT 'EmployeeAccrualSettings', 11 UNION ALL
    SELECT 'EmployeeHourlyRates', 12 UNION ALL
    SELECT 'EmployeeJobCodeAssignment', 11 UNION ALL
    SELECT 'EmployeeLabelAssignment', 13 UNION ALL
    SELECT 'EmployeeShiftAssignmentJobCodes', 8 UNION ALL
    SELECT 'EmployeeShiftAssignmentLabels', 8 UNION ALL
    SELECT 'EmployeeShiftAssignmentWorkCodes', 8 UNION ALL
    SELECT 'EmployeeWorkCodeAssignment', 11 UNION ALL
    SELECT 'Groups', 11 UNION ALL
    SELECT 'HolidayAssignment', 14 UNION ALL
    SELECT 'HolidayRules', 12 UNION ALL
    SELECT 'Holidays', 13 UNION ALL
    SELECT 'JobCodes', 16 UNION ALL
    SELECT 'Labels', 12 UNION ALL
    SELECT 'LayoutGridColumns', 11 UNION ALL
    SELECT 'Layouts', 11 UNION ALL
    SELECT 'OvertimeRules', 13 UNION ALL
    SELECT 'PayPeriod', 12 UNION ALL
    SELECT 'Payroll', 23 UNION ALL
    SELECT 'PayrollItem', 14 UNION ALL
    SELECT 'RuleExecution', 15 UNION ALL
    SELECT 'RuleProcessingSteps', 13 UNION ALL
    SELECT 'ScheduleFrequencies', 10 UNION ALL
    SELECT 'Schedules', 22 UNION ALL
    SELECT 'ShiftAssignment', 15 UNION ALL
    SELECT 'ShiftGroupAssignment', 9 UNION ALL
    SELECT 'ShiftJobCodeAssignment', 8 UNION ALL
    SELECT 'Shifts', 23 UNION ALL
    SELECT 'ShiftTrades', 21 UNION ALL
    SELECT 'ShiftWorkCodeAssignment', 10 UNION ALL
    SELECT 'TimeEntries', 26 UNION ALL
    SELECT 'TimeEntryTypes', 18 UNION ALL
    SELECT 'TimeSheets', 17 UNION ALL
    SELECT 'TradeBoardListRules', 11 UNION ALL
    SELECT 'TradeBoardSettings', 19 UNION ALL
    SELECT 'WorkCodes', 28
)
SELECT 
    COALESCE(l1.tableName, l2.tableName) AS tableName,
    l1.colCount AS list1ColumnCount,
    l2.colCount AS list2ColumnCount,
    CASE 
        WHEN l1.colCount = l2.colCount THEN 'MATCH'
        WHEN l1.tableName IS NULL THEN 'Only in List 2'
        WHEN l2.tableName IS NULL THEN 'Only in List 1'
        ELSE 'DIFFERENT'
    END AS status,
    ABS(COALESCE(l1.colCount, 0) - COALESCE(l2.colCount, 0)) AS difference
FROM List1 l1
FULL OUTER JOIN List2 l2 ON l1.tableName = l2.tableName
WHERE l1.colCount != l2.colCount 
   OR l1.tableName IS NULL 
   OR l2.tableName IS NULL
ORDER BY status, tableName;

