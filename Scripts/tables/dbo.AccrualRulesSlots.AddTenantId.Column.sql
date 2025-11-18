USE [TimeManagement_DEV]
GO

-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/18/2025
-- Description: Add TenantId column to AccrualRulesSlots table
-- =============================================

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'TenantId' AND Object_ID = Object_ID(N'dbo.AccrualRulesSlots'))
BEGIN
    ALTER TABLE [dbo].[AccrualRulesSlots]
    ADD [TenantId] INT NOT NULL DEFAULT 0;
END
GO

-- Update existing records with TenantId from parent AccrualRules table
UPDATE ars
SET ars.TenantId = ar.TenantId
FROM [dbo].[AccrualRulesSlots] ars
INNER JOIN [dbo].[AccrualRules] ar ON ars.AccrualRuleId = ar.Id
WHERE ars.TenantId = 0 OR ars.TenantId IS NULL;
GO

-- Remove default constraint if it exists
DECLARE @ConstraintName NVARCHAR(200)
SELECT @ConstraintName = name
FROM sys.default_constraints
WHERE parent_object_id = OBJECT_ID('dbo.AccrualRulesSlots')
  AND parent_column_id = COLUMNPROPERTY(OBJECT_ID('dbo.AccrualRulesSlots'), 'TenantId', 'ColumnId')

IF @ConstraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE [dbo].[AccrualRulesSlots] DROP CONSTRAINT ' + @ConstraintName)
END
GO

-- Make TenantId NOT NULL (after data migration)
ALTER TABLE [dbo].[AccrualRulesSlots]
ALTER COLUMN [TenantId] INT NOT NULL;
GO

-- Add foreign key constraint to Tenants table if it exists
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Tenants' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_AccrualRulesSlots_Tenants' AND parent_object_id = OBJECT_ID('dbo.AccrualRulesSlots'))
    BEGIN
        ALTER TABLE [dbo].[AccrualRulesSlots] WITH CHECK ADD CONSTRAINT [FK_AccrualRulesSlots_Tenants] 
        FOREIGN KEY([TenantId])
        REFERENCES [dbo].[Tenants] ([Id])
    END
    
    ALTER TABLE [dbo].[AccrualRulesSlots] CHECK CONSTRAINT [FK_AccrualRulesSlots_Tenants]
END
GO

-- Add index for better query performance
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AccrualRulesSlots_TenantId' AND object_id = OBJECT_ID('dbo.AccrualRulesSlots'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_AccrualRulesSlots_TenantId] ON [dbo].[AccrualRulesSlots]
    (
        [TenantId] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
END
GO

