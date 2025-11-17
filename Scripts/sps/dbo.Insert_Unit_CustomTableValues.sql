USE [TimeManagement_DEV]
GO

-- =============================================
-- Script: Insert Unit Custom Table and Values
-- Description: Creates "Unit" custom table with Minutes and Hours values
-- =============================================

DECLARE @TenantId INT = NULL; -- Set to specific tenant ID or NULL for all tenants
DECLARE @CustomTableID INT;
DECLARE @UnitTableName VARCHAR(250) = 'Unit';

-- Check if Custom Table "Unit" already exists
IF NOT EXISTS (SELECT 1 FROM CustomTables WHERE Name = @UnitTableName AND (@TenantId IS NULL OR TenantId = @TenantId))
BEGIN
    -- Insert Custom Table "Unit"
    INSERT INTO CustomTables (Name, TenantId, IsActive, TypeName)
    VALUES (@UnitTableName, @TenantId, 1, 'Unit');
    
    SET @CustomTableID = SCOPE_IDENTITY();
    
    PRINT 'Custom Table "Unit" created with ID: ' + CAST(@CustomTableID AS VARCHAR(10));
END
ELSE
BEGIN
    -- Get existing Custom Table ID
    SELECT @CustomTableID = CustomTableID 
    FROM CustomTables 
    WHERE Name = @UnitTableName AND (@TenantId IS NULL OR TenantId = @TenantId);
    
    PRINT 'Custom Table "Unit" already exists with ID: ' + CAST(@CustomTableID AS VARCHAR(10));
END

-- Insert "Minutes" value if it doesn't exist
IF NOT EXISTS (
    SELECT 1 FROM CustomTableValues 
    WHERE CustomTableID = @CustomTableID 
    AND Code = 'MIN' 
    AND (@TenantId IS NULL OR TenantId = @TenantId)
)
BEGIN
    INSERT INTO CustomTableValues (CustomTableID, Code, ShortDescription, LongDescription, TenantId, IsActive)
    VALUES (@CustomTableID, 'MIN', 'Min', 'Minutes', @TenantId, 1);
    
    PRINT 'Custom Table Value "Minutes" inserted with ID: ' + CAST(SCOPE_IDENTITY() AS VARCHAR(10));
END
ELSE
BEGIN
    PRINT 'Custom Table Value "Minutes" already exists.';
END

-- Insert "Hours" value if it doesn't exist
IF NOT EXISTS (
    SELECT 1 FROM CustomTableValues 
    WHERE CustomTableID = @CustomTableID 
    AND Code = 'HRS' 
    AND (@TenantId IS NULL OR TenantId = @TenantId)
)
BEGIN
    INSERT INTO CustomTableValues (CustomTableID, Code, ShortDescription, LongDescription, TenantId, IsActive)
    VALUES (@CustomTableID, 'HRS', 'Hr', 'Hours', @TenantId, 1);
    
    PRINT 'Custom Table Value "Hours" inserted with ID: ' + CAST(SCOPE_IDENTITY() AS VARCHAR(10));
END
ELSE
BEGIN
    PRINT 'Custom Table Value "Hours" already exists.';
END

PRINT 'Script completed successfully.';
GO

