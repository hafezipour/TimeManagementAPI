USE [TimeManagement_DEV]
GO

-- Add AccrueFrequencyValue column to AccrualRulesSlots table
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.AccrualRulesSlots') AND name = 'AccrueFrequencyValue')
BEGIN
    ALTER TABLE [dbo].[AccrualRulesSlots]
    ADD [AccrueFrequencyValue] [int] NULL;
END
GO

