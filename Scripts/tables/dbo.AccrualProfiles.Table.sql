USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[AccrualProfiles]    Script Date: 11/11/2025 8:00:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccrualProfiles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[ProfileName] [varchar](255) NOT NULL,
	[IsBaseOnYearsServed] [bit] NOT NULL DEFAULT 0,
	[FromYears] [decimal](10, 2) NULL,
	[ToYears] [decimal](10, 2) NULL,
	[Description] [nvarchar](max) NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_AccrualProfiles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccrualProfiles] ADD  CONSTRAINT [DF_AccrualProfiles_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[AccrualProfiles] ADD  CONSTRAINT [DF_AccrualProfiles_IsBaseOnYearsServed]  DEFAULT (0) FOR [IsBaseOnYearsServed]
GO

-- Indexes for better query performance
CREATE NONCLUSTERED INDEX [IX_AccrualProfiles_TenantId] ON [dbo].[AccrualProfiles]
(
	[TenantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

