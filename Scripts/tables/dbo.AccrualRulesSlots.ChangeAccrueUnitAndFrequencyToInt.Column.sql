USE [TimeManagement_DEV]
GO

-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/18/2025
-- Description: Change AccrueUnit and AccrueFrequency columns from VARCHAR to INT
-- =============================================

-- Step 1: Add temporary INT columns
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'AccrueUnitInt' AND Object_ID = Object_ID(N'dbo.AccrualRulesSlots'))
BEGIN
    ALTER TABLE [dbo].[AccrualRulesSlots]
    ADD [AccrueUnitInt] INT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'AccrueFrequencyInt' AND Object_ID = Object_ID(N'dbo.AccrualRulesSlots'))
BEGIN
    ALTER TABLE [dbo].[AccrualRulesSlots]
    ADD [AccrueFrequencyInt] INT NULL;
END
GO

-- Step 2: Migrate existing data from VARCHAR to INT
-- AccrueUnit mapping: 'minutes' = 1, 'hours' = 2
UPDATE [dbo].[AccrualRulesSlots]
SET [AccrueUnitInt] = CASE 
    WHEN [AccrueUnit] = 'minutes' THEN 1
    WHEN [AccrueUnit] = 'hours' THEN 2
    ELSE NULL
END
WHERE [AccrueUnitInt] IS NULL;
GO

-- AccrueFrequency mapping: 'year' = 1, 'quarter' = 2, 'month' = 3, 'months' = 4, 'days' = 5, 'hours worked' = 6
UPDATE [dbo].[AccrualRulesSlots]
SET [AccrueFrequencyInt] = CASE 
    WHEN [AccrueFrequency] = 'year' THEN 1
    WHEN [AccrueFrequency] = 'quarter' THEN 2
    WHEN [AccrueFrequency] = 'month' THEN 3
    WHEN [AccrueFrequency] = 'months' THEN 4
    WHEN [AccrueFrequency] = 'days' THEN 5
    WHEN [AccrueFrequency] = 'hours worked' THEN 6
    ELSE NULL
END
WHERE [AccrueFrequencyInt] IS NULL;
GO

-- Step 3: Make the new columns NOT NULL (after data migration)
UPDATE [dbo].[AccrualRulesSlots]
SET [AccrueUnitInt] = 2 -- Default to 'hours' if NULL
WHERE [AccrueUnitInt] IS NULL;
GO

UPDATE [dbo].[AccrualRulesSlots]
SET [AccrueFrequencyInt] = 1 -- Default to 'year' if NULL
WHERE [AccrueFrequencyInt] IS NULL;
GO

ALTER TABLE [dbo].[AccrualRulesSlots]
ALTER COLUMN [AccrueUnitInt] INT NOT NULL;
GO

ALTER TABLE [dbo].[AccrualRulesSlots]
ALTER COLUMN [AccrueFrequencyInt] INT NOT NULL;
GO

-- Step 4: Drop old VARCHAR columns
IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'AccrueUnit' AND Object_ID = Object_ID(N'dbo.AccrualRulesSlots'))
BEGIN
    ALTER TABLE [dbo].[AccrualRulesSlots]
    DROP COLUMN [AccrueUnit];
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'AccrueFrequency' AND Object_ID = Object_ID(N'dbo.AccrualRulesSlots'))
BEGIN
    ALTER TABLE [dbo].[AccrualRulesSlots]
    DROP COLUMN [AccrueFrequency];
END
GO

-- Step 5: Rename new columns to original names
EXEC sp_rename 'dbo.AccrualRulesSlots.AccrueUnitInt', 'AccrueUnit', 'COLUMN';
GO

EXEC sp_rename 'dbo.AccrualRulesSlots.AccrueFrequencyInt', 'AccrueFrequency', 'COLUMN';
GO

