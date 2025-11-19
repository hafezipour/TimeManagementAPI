USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[EmployeeAccrualSettings]    Script Date: 11/18/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/18/2025
-- Description: Employee Accrual Settings table (stores accrual track/profile assignments for employees)
-- =============================================
CREATE TABLE [dbo].[EmployeeAccrualSettings](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [UserId] [int] NOT NULL,
    [AccrualTrackId] [int] NULL,
    [AccrualProfileId] [int] NULL,
    [AccrualStartDate] [date] NOT NULL,
    [TenantId] [int] NOT NULL,
    [CreatedBy] [int] NOT NULL,
    [UpdatedBy] [int] NULL,
    [DateCreated] [datetimeoffset](7) NOT NULL,
    [DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_EmployeeAccrualSettings] PRIMARY KEY CLUSTERED
(
    [Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[EmployeeAccrualSettings] ADD  CONSTRAINT [DF_EmployeeAccrualSettings_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

-- Foreign Key Constraints
-- Note: Assuming Users table exists (adjust table name if different)
-- ALTER TABLE [dbo].[EmployeeAccrualSettings] WITH CHECK ADD CONSTRAINT [FK_EmployeeAccrualSettings_Users] FOREIGN KEY([UserId])
-- REFERENCES [dbo].[Users] ([Id])
-- GO
-- ALTER TABLE [dbo].[EmployeeAccrualSettings] CHECK CONSTRAINT [FK_EmployeeAccrualSettings_Users]
-- GO

ALTER TABLE [dbo].[EmployeeAccrualSettings] WITH CHECK ADD CONSTRAINT [FK_EmployeeAccrualSettings_AccrualTracks] FOREIGN KEY([AccrualTrackId])
REFERENCES [dbo].[AccrualTracks] ([Id])
GO

ALTER TABLE [dbo].[EmployeeAccrualSettings] CHECK CONSTRAINT [FK_EmployeeAccrualSettings_AccrualTracks]
GO

ALTER TABLE [dbo].[EmployeeAccrualSettings] WITH CHECK ADD CONSTRAINT [FK_EmployeeAccrualSettings_AccrualProfiles] FOREIGN KEY([AccrualProfileId])
REFERENCES [dbo].[AccrualProfiles] ([Id])
GO

ALTER TABLE [dbo].[EmployeeAccrualSettings] CHECK CONSTRAINT [FK_EmployeeAccrualSettings_AccrualProfiles]
GO

ALTER TABLE [dbo].[EmployeeAccrualSettings] WITH CHECK ADD CONSTRAINT [FK_EmployeeAccrualSettings_Tenants] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Tenants] ([Id])
GO

ALTER TABLE [dbo].[EmployeeAccrualSettings] CHECK CONSTRAINT [FK_EmployeeAccrualSettings_Tenants]
GO

-- Indexes for better query performance
CREATE NONCLUSTERED INDEX [IX_EmployeeAccrualSettings_TenantId] ON [dbo].[EmployeeAccrualSettings]
(
    [TenantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_EmployeeAccrualSettings_UserId] ON [dbo].[EmployeeAccrualSettings]
(
    [UserId] ASC,
    [TenantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_EmployeeAccrualSettings_AccrualTrackId] ON [dbo].[EmployeeAccrualSettings]
(
    [AccrualTrackId] ASC
)WHERE [AccrualTrackId] IS NOT NULL
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_EmployeeAccrualSettings_AccrualProfileId] ON [dbo].[EmployeeAccrualSettings]
(
    [AccrualProfileId] ASC
)WHERE [AccrualProfileId] IS NOT NULL
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

-- Unique constraint: One accrual setting per user per tenant
-- Note: This assumes one accrual setting per user. If multiple settings per user are allowed, remove this constraint.
CREATE UNIQUE NONCLUSTERED INDEX [IX_EmployeeAccrualSettings_UniqueUser] ON [dbo].[EmployeeAccrualSettings]
(
    [UserId] ASC,
    [TenantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

