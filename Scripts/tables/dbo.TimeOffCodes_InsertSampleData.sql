USE [TimeManagement_DEV]
GO

-- =============================================
-- Insert Sample Data for TimeOffCodes Table
-- =============================================

-- Note: Update @TenantId and @CreatedBy with appropriate values for your environment
DECLARE @TenantId INT = 1;  -- Update with your tenant ID
DECLARE @CreatedBy INT = 1; -- Update with your user ID
DECLARE @CurrentDate DATETIMEOFFSET(7) = SYSDATETIMEOFFSET();

-- Insert Time Off Codes
INSERT INTO [dbo].[TimeOffCodes] 
    ([Name], [Code], [BackgroundColor], [TextColor], [IsRequestable], [CreatedBy], [DateCreated], [TenantId])
VALUES
    -- Vacation Time Off
    ('Vacation', 'VAC', '#4A90E2', '#FFFFFF', 1, @CreatedBy, @CurrentDate, @TenantId),
    
    -- Sick Leave
    ('Sick Leave', 'SICK', '#E74C3C', '#FFFFFF', 1, @CreatedBy, @CurrentDate, @TenantId),
    
    -- Personal Day
    ('Personal Day', 'PERS', '#9B59B6', '#FFFFFF', 1, @CreatedBy, @CurrentDate, @TenantId),
    
    -- Bereavement Leave
    ('Bereavement', 'BER', '#34495E', '#FFFFFF', 1, @CreatedBy, @CurrentDate, @TenantId),
    
    -- Jury Duty
    ('Jury Duty', 'JURY', '#F39C12', '#FFFFFF', 1, @CreatedBy, @CurrentDate, @TenantId),
    
    -- Family Medical Leave
    ('FMLA', 'FMLA', '#16A085', '#FFFFFF', 1, @CreatedBy, @CurrentDate, @TenantId),
    
    -- Unpaid Leave
    ('Unpaid Leave', 'UNPD', '#95A5A6', '#FFFFFF', 1, @CreatedBy, @CurrentDate, @TenantId),
    
    -- Compensatory Time
    ('Comp Time', 'COMP', '#3498DB', '#FFFFFF', 1, @CreatedBy, @CurrentDate, @TenantId),
    
    -- Military Leave
    ('Military Leave', 'MIL', '#2C3E50', '#FFFFFF', 1, @CreatedBy, @CurrentDate, @TenantId),
    
    -- Educational Leave
    ('Educational Leave', 'EDU', '#E67E22', '#FFFFFF', 1, @CreatedBy, @CurrentDate, @TenantId);

GO

GO

-- Verify the inserted data (Update TenantId in WHERE clause)
SELECT 
    Id,
    Name,
    Code,
    BackgroundColor,
    TextColor,
    IsRequestable,
    TenantId,
    DateCreated
FROM [dbo].[TimeOffCodes]
WHERE TenantId = 1  -- Update with your tenant ID
ORDER BY Name;

GO

