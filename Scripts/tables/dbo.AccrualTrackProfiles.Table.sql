USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[AccrualTrackProfiles]    Script Date: 11/18/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/18/2025
-- Description: Accrual Track Profiles table (junction table linking tracks to profiles with ordering)
-- =============================================
CREATE TABLE [dbo].[AccrualTrackProfiles](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [AccrualTrackId] [int] NOT NULL,
    [AccrualProfileId] [int] NOT NULL,
    [SortOrder] [int] NOT NULL DEFAULT 0,
    [TenantId] [int] NOT NULL,
    [CreatedBy] [int] NOT NULL,
    [UpdatedBy] [int] NULL,
    [DateCreated] [datetimeoffset](7) NOT NULL,
    [DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_AccrualTrackProfiles] PRIMARY KEY CLUSTERED
(
    [Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AccrualTrackProfiles] ADD  CONSTRAINT [DF_AccrualTrackProfiles_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

ALTER TABLE [dbo].[AccrualTrackProfiles] ADD  CONSTRAINT [DF_AccrualTrackProfiles_SortOrder]  DEFAULT (0) FOR [SortOrder]
GO

-- Foreign Key Constraints
ALTER TABLE [dbo].[AccrualTrackProfiles] WITH CHECK ADD CONSTRAINT [FK_AccrualTrackProfiles_AccrualTracks] FOREIGN KEY([AccrualTrackId])
REFERENCES [dbo].[AccrualTracks] ([Id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[AccrualTrackProfiles] CHECK CONSTRAINT [FK_AccrualTrackProfiles_AccrualTracks]
GO

ALTER TABLE [dbo].[AccrualTrackProfiles] WITH CHECK ADD CONSTRAINT [FK_AccrualTrackProfiles_AccrualProfiles] FOREIGN KEY([AccrualProfileId])
REFERENCES [dbo].[AccrualProfiles] ([Id])
GO

ALTER TABLE [dbo].[AccrualTrackProfiles] CHECK CONSTRAINT [FK_AccrualTrackProfiles_AccrualProfiles]
GO

-- Indexes for better query performance
CREATE NONCLUSTERED INDEX [IX_AccrualTrackProfiles_TenantId] ON [dbo].[AccrualTrackProfiles]
(
    [TenantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_AccrualTrackProfiles_AccrualTrackId] ON [dbo].[AccrualTrackProfiles]
(
    [AccrualTrackId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_AccrualTrackProfiles_AccrualProfileId] ON [dbo].[AccrualTrackProfiles]
(
    [AccrualProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_AccrualTrackProfiles_SortOrder] ON [dbo].[AccrualTrackProfiles]
(
    [AccrualTrackId] ASC,
    [SortOrder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

-- Unique constraint to prevent duplicate profiles in the same track
CREATE UNIQUE NONCLUSTERED INDEX [IX_AccrualTrackProfiles_UniqueTrackProfile] ON [dbo].[AccrualTrackProfiles]
(
    [AccrualTrackId] ASC,
    [AccrualProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

