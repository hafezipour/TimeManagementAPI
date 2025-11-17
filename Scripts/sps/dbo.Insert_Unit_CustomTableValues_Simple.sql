USE [TimeManagement_DEV]
GO

-- =============================================
-- Simple Insert Script: Unit Custom Table and Values
-- Description: Creates "Unit" custom table with Minutes and Hours values
-- Note: Set @TenantId to your specific tenant ID or NULL for all tenants
-- =============================================

DECLARE @TenantId INT = NULL; -- CHANGE THIS to your tenant ID (e.g., 100000003) or leave NULL
DECLARE @CustomTableID INT;

BEGIN TRANSACTION;

BEGIN TRY
    -- Step 1: Insert or get Custom Table "Unit"
    IF NOT EXISTS (SELECT 1 FROM CustomTables WHERE Name = 'Unit' AND (@TenantId IS NULL OR TenantId = @TenantId))
    BEGIN
        INSERT INTO CustomTables (Name, TenantId, IsActive, TypeName)
        VALUES ('Unit', @TenantId, 1, 'Unit');
        
        SET @CustomTableID = SCOPE_IDENTITY();
        PRINT 'Created Custom Table "Unit" with ID: ' + CAST(@CustomTableID AS VARCHAR(10));
    END
    ELSE
    BEGIN
        SELECT @CustomTableID = CustomTableID 
        FROM CustomTables 
        WHERE Name = 'Unit' AND (@TenantId IS NULL OR TenantId = @TenantId);
        PRINT 'Using existing Custom Table "Unit" with ID: ' + CAST(@CustomTableID AS VARCHAR(10));
    END

    -- Step 2: Insert "Minutes" value
    IF NOT EXISTS (
        SELECT 1 FROM CustomTableValues 
        WHERE CustomTableID = @CustomTableID 
        AND Code = 'MIN' 
        AND (@TenantId IS NULL OR TenantId = @TenantId)
    )
    BEGIN
        INSERT INTO CustomTableValues (CustomTableID, Code, ShortDescription, LongDescription, TenantId, IsActive)
        VALUES (@CustomTableID, 'MIN', 'Min', 'Minutes', @TenantId, 1);
        PRINT 'Inserted "Minutes" with ID: ' + CAST(SCOPE_IDENTITY() AS VARCHAR(10));
    END
    ELSE
    BEGIN
        PRINT '"Minutes" already exists - skipped.';
    END

    -- Step 3: Insert "Hours" value
    IF NOT EXISTS (
        SELECT 1 FROM CustomTableValues 
        WHERE CustomTableID = @CustomTableID 
        AND Code = 'HRS' 
        AND (@TenantId IS NULL OR TenantId = @TenantId)
    )
    BEGIN
        INSERT INTO CustomTableValues (CustomTableID, Code, ShortDescription, LongDescription, TenantId, IsActive)
        VALUES (@CustomTableID, 'HRS', 'Hr', 'Hours', @TenantId, 1);
        PRINT 'Inserted "Hours" with ID: ' + CAST(SCOPE_IDENTITY() AS VARCHAR(10));
    END
    ELSE
    BEGIN
        PRINT '"Hours" already exists - skipped.';
    END

    COMMIT TRANSACTION;
    PRINT 'SUCCESS: Unit custom table and values created successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

