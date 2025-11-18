USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[AccrualTracks]    Script Date: 11/18/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/18/2025
-- Description: Accrual Tracks table (groups of accrual profiles in a specific order)
-- =============================================
CREATE TABLE [dbo].[AccrualTracks](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [TenantId] [int] NOT NULL,
    [Name] [varchar](255) NOT NULL,
    [CreatedBy] [int] NOT NULL,
    [UpdatedBy] [int] NULL,
    [DateCreated] [datetimeoffset](7) NOT NULL,
    [DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_AccrualTracks] PRIMARY KEY CLUSTERED
(
    [Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AccrualTracks] ADD  CONSTRAINT [DF_AccrualTracks_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

-- Indexes for better query performance
CREATE NONCLUSTERED INDEX [IX_AccrualTracks_TenantId] ON [dbo].[AccrualTracks]
(
    [TenantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_AccrualTracks_Name] ON [dbo].[AccrualTracks]
(
    [TenantId] ASC,
    [Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

