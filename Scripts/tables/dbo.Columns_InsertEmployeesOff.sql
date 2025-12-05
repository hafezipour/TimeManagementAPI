USE [TimeManagement_DEV]
GO

-- =============================================
-- Insert "Employees Off" Column
-- =============================================

-- Note: Update @TenantId and @CreatedBy with appropriate values for your environment
DECLARE @TenantId INT = 1;  -- Update with your tenant ID
DECLARE @CreatedBy INT = 1;  -- Update with your user ID

-- Insert "Employees Off" Column with Very Light Blue Background Color
INSERT INTO [dbo].[Columns] 
    ([ColumnName], [BackgroundColor], [CreatedBy], [TenantId])
VALUES
    ('Employees Off', '#E1F5FE', @CreatedBy, @TenantId);

GO

-- Verify the inserted data
SELECT 
    Id,
    ColumnName,
    BackgroundColor,
    TenantId,
    DateCreated
FROM [dbo].[Columns]
WHERE ColumnName = 'Employees Off'
    AND TenantId = @TenantId;

GO

