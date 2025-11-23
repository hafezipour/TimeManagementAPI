USE [TimeManagement_DEV]
GO

-- Query to get all table names with column counts
SELECT 
    t.TABLE_SCHEMA AS schemaName,
    t.TABLE_NAME AS tableName,
    COUNT(c.COLUMN_NAME) AS columnCount
FROM INFORMATION_SCHEMA.TABLES t
LEFT JOIN INFORMATION_SCHEMA.COLUMNS c 
    ON t.TABLE_SCHEMA = c.TABLE_SCHEMA 
    AND t.TABLE_NAME = c.TABLE_NAME
WHERE t.TABLE_TYPE = 'BASE TABLE'
GROUP BY t.TABLE_SCHEMA, t.TABLE_NAME
ORDER BY t.TABLE_SCHEMA, t.TABLE_NAME;

-- Alternative using sys tables (more detailed)
SELECT 
    s.name AS schemaName,
    t.name AS tableName,
    COUNT(c.column_id) AS columnCount
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
LEFT JOIN sys.columns c ON t.object_id = c.object_id
GROUP BY s.name, t.name
ORDER BY s.name, t.name;

