USE [TimeManagement_DEV]
GO

-- Add WorkCodeId column to AccrualRulesSlots table
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.AccrualRulesSlots') AND name = 'WorkCodeId')
BEGIN
    ALTER TABLE [dbo].[AccrualRulesSlots]
    ADD [WorkCodeId] [int] NULL;
    
    -- Add foreign key constraint
    ALTER TABLE [dbo].[AccrualRulesSlots] WITH CHECK ADD CONSTRAINT [FK_AccrualRulesSlots_WorkCodes] 
    FOREIGN KEY([WorkCodeId])
    REFERENCES [dbo].[WorkCodes] ([Id]);
    
    ALTER TABLE [dbo].[AccrualRulesSlots] CHECK CONSTRAINT [FK_AccrualRulesSlots_WorkCodes];
END
GO

