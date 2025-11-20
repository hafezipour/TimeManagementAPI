USE [TimeManagement_DEV]
GO

-- Step 1: Drop the foreign key constraint for AccrualRuleId
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_AccrualTransactions_AccrualRules')
BEGIN
    ALTER TABLE [dbo].[AccrualTransactions]
    DROP CONSTRAINT [FK_AccrualTransactions_AccrualRules];
END
GO

-- Step 2: Drop AccrualRuleId column
ALTER TABLE [dbo].[AccrualTransactions]
DROP COLUMN [AccrualRuleId];
GO

-- Step 3: Add AccrualBankId column
ALTER TABLE [dbo].[AccrualTransactions]
ADD [AccrualBankId] INT NOT NULL;
GO

-- Step 4: Create foreign key relationship to AccrualBanks table
ALTER TABLE [dbo].[AccrualTransactions]
WITH CHECK ADD CONSTRAINT [FK_AccrualTransactions_AccrualBanks] 
FOREIGN KEY([AccrualBankId])
REFERENCES [dbo].[AccrualBanks] ([Id]);
GO

-- Step 5: Enable the constraint
ALTER TABLE [dbo].[AccrualTransactions]
CHECK CONSTRAINT [FK_AccrualTransactions_AccrualBanks];
GO

