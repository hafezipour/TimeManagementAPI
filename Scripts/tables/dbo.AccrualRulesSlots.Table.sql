USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[AccrualRulesSlots]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Accrual Rules Slots table (for multiple accrual rules per profile/type combination)
-- =============================================
CREATE TABLE [dbo].[AccrualRulesSlots](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [AccrualRuleId] [int] NOT NULL,
    [AccrueAmount] [decimal](10, 2) NOT NULL,
    [AccrueUnit] [varchar](50) NOT NULL,
    [AccrueFrequency] [varchar](50) NOT NULL,
    [SortOrder] [int] NOT NULL DEFAULT 0,
    [CreatedBy] [int] NOT NULL,
    [UpdatedBy] [int] NULL,
    [DateCreated] [datetimeoffset](7) NOT NULL,
    [DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_AccrualRulesSlots] PRIMARY KEY CLUSTERED
(
    [Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AccrualRulesSlots] ADD  CONSTRAINT [DF_AccrualRulesSlots_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

ALTER TABLE [dbo].[AccrualRulesSlots] ADD  CONSTRAINT [DF_AccrualRulesSlots_SortOrder]  DEFAULT (0) FOR [SortOrder]
GO

-- Foreign Key Constraints
ALTER TABLE [dbo].[AccrualRulesSlots] WITH CHECK ADD CONSTRAINT [FK_AccrualRulesSlots_AccrualRules] FOREIGN KEY([AccrualRuleId])
REFERENCES [dbo].[AccrualRules] ([Id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[AccrualRulesSlots] CHECK CONSTRAINT [FK_AccrualRulesSlots_AccrualRules]
GO

-- Indexes for better query performance
CREATE NONCLUSTERED INDEX [IX_AccrualRulesSlots_AccrualRuleId] ON [dbo].[AccrualRulesSlots]
(
    [AccrualRuleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_AccrualRulesSlots_SortOrder] ON [dbo].[AccrualRulesSlots]
(
    [AccrualRuleId] ASC,
    [SortOrder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

