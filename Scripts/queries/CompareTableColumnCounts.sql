USE [TimeManagement_DEV]
GO

-- Query to compare table column counts with expected values
-- This query will show:
-- 1. Tables that exist but have different column counts
-- 2. Tables that are missing
-- 3. Tables that have matching column counts

WITH ExpectedTables AS (
    SELECT 'AccrualBanks' AS tableName, 14 AS expectedColumnCount UNION ALL
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
ActualTables AS (
    SELECT 
        t.name AS tableName,
        COUNT(c.column_id) AS actualColumnCount
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    LEFT JOIN sys.columns c ON t.object_id = c.object_id
    WHERE s.name = 'dbo'
    GROUP BY t.name
)
SELECT 
    COALESCE(e.tableName, a.tableName) AS tableName,
    e.expectedColumnCount,
    a.actualColumnCount,
    CASE 
        WHEN a.tableName IS NULL THEN 'MISSING - Table does not exist'
        WHEN e.tableName IS NULL THEN 'EXTRA - Table exists but not in expected list'
        WHEN e.expectedColumnCount = a.actualColumnCount THEN 'MATCH'
        ELSE 'DIFFERENCE - Column count mismatch'
    END AS status,
    CASE 
        WHEN a.actualColumnCount IS NOT NULL AND e.expectedColumnCount IS NOT NULL 
        THEN a.actualColumnCount - e.expectedColumnCount
        ELSE NULL
    END AS columnDifference
FROM ExpectedTables e
FULL OUTER JOIN ActualTables a ON e.tableName = a.tableName
ORDER BY 
    CASE 
        WHEN a.tableName IS NULL THEN 1
        WHEN e.tableName IS NULL THEN 2
        WHEN e.expectedColumnCount = a.actualColumnCount THEN 3
        ELSE 2
    END,
    COALESCE(e.tableName, a.tableName);

-- Summary of differences
SELECT 
    COUNT(CASE WHEN status LIKE 'DIFFERENCE%' THEN 1 END) AS tablesWithColumnCountDifferences,
    COUNT(CASE WHEN status LIKE 'MISSING%' THEN 1 END) AS missingTables,
    COUNT(CASE WHEN status LIKE 'EXTRA%' THEN 1 END) AS extraTables,
    COUNT(CASE WHEN status = 'MATCH' THEN 1 END) AS matchingTables
FROM (
    SELECT 
        COALESCE(e.tableName, a.tableName) AS tableName,
        CASE 
            WHEN a.tableName IS NULL THEN 'MISSING - Table does not exist'
            WHEN e.tableName IS NULL THEN 'EXTRA - Table exists but not in expected list'
            WHEN e.expectedColumnCount = a.actualColumnCount THEN 'MATCH'
            ELSE 'DIFFERENCE - Column count mismatch'
        END AS status
    FROM ExpectedTables e
    FULL OUTER JOIN ActualTables a ON e.tableName = a.tableName
) AS summary;

