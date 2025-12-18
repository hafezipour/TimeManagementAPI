USE [StaffScheduling_DEV]
GO

-- Add columns to ShiftAssignment table for trade functionality
-- Check if columns exist before adding them

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ShiftAssignment]') AND name = 'IsTraded')
BEGIN
    ALTER TABLE [dbo].[ShiftAssignment]
    ADD [IsTraded] [bit] NULL DEFAULT 0;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ShiftAssignment]') AND name = 'TradingUserAssignmentId')
BEGIN
    ALTER TABLE [dbo].[ShiftAssignment]
    ADD [TradingUserAssignmentId] [int] NULL;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ShiftAssignment]') AND name = 'IsSwap')
BEGIN
    ALTER TABLE [dbo].[ShiftAssignment]
    ADD [IsSwap] [bit] NULL DEFAULT 0;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ShiftAssignment]') AND name = 'AcceptingUserAssignmentId')
BEGIN
    ALTER TABLE [dbo].[ShiftAssignment]
    ADD [AcceptingUserAssignmentId] [int] NULL;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ShiftAssignment]') AND name = 'TradeRequestId')
BEGIN
    ALTER TABLE [dbo].[ShiftAssignment]
    ADD [TradeRequestId] [int] NULL;
END
GO

-- Add foreign key constraint for TradeRequestId if needed
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ShiftAssignment_TradeRequestId_ShiftTrades')
BEGIN
    ALTER TABLE [dbo].[ShiftAssignment]
    WITH CHECK ADD CONSTRAINT [FK_ShiftAssignment_TradeRequestId_ShiftTrades]
    FOREIGN KEY([TradeRequestId])
    REFERENCES [dbo].[ShiftTrades] ([Id]);
END
GO

