USE [TimeManagement_DEV]
GO

-- =============================================
-- Insert Sample Data for Columns Table
-- =============================================

-- Note: Update @TenantId and @CreatedBy with appropriate values for your environment
DECLARE @TenantId INT = 1;  -- Update with your tenant ID
DECLARE @CreatedBy INT = 1; -- Update with your user ID
DECLARE @CurrentDate DATETIMEOFFSET(7) = SYSDATETIMEOFFSET();

-- Insert Columns with Light Blue Background Color
INSERT INTO [dbo].[Columns] 
    ([ColumnName], [BackgroundColor], [CreatedBy], [DateCreated], [TenantId])
VALUES
    -- Monday Column
    ('Monday', '#BBDEFB', @CreatedBy, @CurrentDate, @TenantId),
    
    -- Tuesday Column
    ('Tuesday', '#BBDEFB', @CreatedBy, @CurrentDate, @TenantId),
    
    -- Wednesday Column
    ('Wednesday', '#BBDEFB', @CreatedBy, @CurrentDate, @TenantId),
    
    -- Thursday Column
    ('Thursday', '#BBDEFB', @CreatedBy, @CurrentDate, @TenantId),
    
    -- Friday Column
    ('Friday', '#BBDEFB', @CreatedBy, @CurrentDate, @TenantId),
    
    -- Saturday Column
    ('Saturday', '#BBDEFB', @CreatedBy, @CurrentDate, @TenantId),
    
    -- Sunday Column
    ('Sunday', '#BBDEFB', @CreatedBy, @CurrentDate, @TenantId),
    
    -- Morning Shift Column
    ('Morning Shift', '#BBDEFB', @CreatedBy, @CurrentDate, @TenantId),
    
    -- Afternoon Shift Column
    ('Afternoon Shift', '#BBDEFB', @CreatedBy, @CurrentDate, @TenantId),
    
    -- Night Shift Column
    ('Night Shift', '#BBDEFB', @CreatedBy, @CurrentDate, @TenantId);

GO

-- Verify the inserted data (Update TenantId in WHERE clause)
SELECT 
    Id,
    ColumnName,
    BackgroundColor,
    TenantId,
    DateCreated
FROM [dbo].[Columns]
WHERE TenantId = 1  -- Update with your tenant ID
ORDER BY ColumnName;

GO

