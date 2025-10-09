USE [TimeManagement_DEV]
GO

-- =============================================
-- Table: HolidayAssignment
-- =============================================
CREATE TABLE [dbo].[HolidayAssignment](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [TenantId] [int] NOT NULL,
    [HolidayId] [int] NOT NULL,
    [JobCodeId] [int] NOT NULL,
    [UserId] [int] NOT NULL,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    [EffectiveDate] [datetimeoffset](7) NULL,
    [ExpiryDate] [datetimeoffset](7) NULL,
    [CreatedBy] [int] NOT NULL,
    [UpdatedBy] [int] NULL,
    [DateCreated] [datetimeoffset](7) NOT NULL,
    [DateUpdated] [datetimeoffset](7) NULL,
    CONSTRAINT [PK_HolidayAssignment] PRIMARY KEY CLUSTERED 
    (
        [Id] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- =============================================
-- Foreign Key Constraints
-- =============================================

-- FK to Holidays table
ALTER TABLE [dbo].[HolidayAssignment] WITH CHECK ADD CONSTRAINT [FK_HolidayAssignment_Holidays] 
FOREIGN KEY([HolidayId]) REFERENCES [dbo].[Holidays] ([Id])
GO
ALTER TABLE [dbo].[HolidayAssignment] CHECK CONSTRAINT [FK_HolidayAssignment_Holidays]
GO

-- FK to JobCodes table
ALTER TABLE [dbo].[HolidayAssignment] WITH CHECK ADD CONSTRAINT [FK_HolidayAssignment_JobCodes] 
FOREIGN KEY([JobCodeId]) REFERENCES [dbo].[JobCodes] ([Id])
GO
ALTER TABLE [dbo].[HolidayAssignment] CHECK CONSTRAINT [FK_HolidayAssignment_JobCodes]
GO

-- FK to Users table (for UserId)
ALTER TABLE [dbo].[HolidayAssignment] WITH CHECK ADD CONSTRAINT [FK_HolidayAssignment_Users_UserId] 
FOREIGN KEY([UserId]) REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[HolidayAssignment] CHECK CONSTRAINT [FK_HolidayAssignment_Users_UserId]
GO

-- FK to Users table (for CreatedBy)
ALTER TABLE [dbo].[HolidayAssignment] WITH CHECK ADD CONSTRAINT [FK_HolidayAssignment_Users_CreatedBy] 
FOREIGN KEY([CreatedBy]) REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[HolidayAssignment] CHECK CONSTRAINT [FK_HolidayAssignment_Users_CreatedBy]
GO

-- FK to Users table (for UpdatedBy)
ALTER TABLE [dbo].[HolidayAssignment] WITH CHECK ADD CONSTRAINT [FK_HolidayAssignment_Users_UpdatedBy] 
FOREIGN KEY([UpdatedBy]) REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[HolidayAssignment] CHECK CONSTRAINT [FK_HolidayAssignment_Users_UpdatedBy]
GO

-- =============================================
-- Indexes for better performance
-- =============================================

-- Index on TenantId for filtering
CREATE NONCLUSTERED INDEX [IX_HolidayAssignment_TenantId] ON [dbo].[HolidayAssignment]
(
    [TenantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

-- Index on HolidayId for filtering
CREATE NONCLUSTERED INDEX [IX_HolidayAssignment_HolidayId] ON [dbo].[HolidayAssignment]
(
    [HolidayId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

-- Index on JobCodeId for filtering
CREATE NONCLUSTERED INDEX [IX_HolidayAssignment_JobCodeId] ON [dbo].[HolidayAssignment]
(
    [JobCodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

-- Index on UserId for filtering
CREATE NONCLUSTERED INDEX [IX_HolidayAssignment_UserId] ON [dbo].[HolidayAssignment]
(
    [UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

-- Composite index for common queries
CREATE NONCLUSTERED INDEX [IX_HolidayAssignment_TenantId_HolidayId_JobCodeId_UserId] ON [dbo].[HolidayAssignment]
(
    [TenantId] ASC,
    [HolidayId] ASC,
    [JobCodeId] ASC,
    [UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
