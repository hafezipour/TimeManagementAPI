/* ----- dbo.AccrualBalance.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[AccrualBalance]    Script Date: 11/11/2025 8:00:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccrualBalance](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[AccrualTypeId] [int] NOT NULL,
	[CurrentBalance] [decimal](10, 2) NULL,
	[PendingBalance] [decimal](10, 2) NULL,
	[UsedBalance] [decimal](10, 2) NULL,
	[CarryOverBalance] [decimal](10, 2) NULL,
	[CarryOverExpiryDate] [date] NULL,
	[LastAccrualDate] [date] NULL,
	[LastUpdated] [datetime] NULL,
 CONSTRAINT [PK_AccrualBalance] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/* ----- dbo.AccrualRules.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[AccrualRules]    Script Date: 11/11/2025 8:00:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccrualRules](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[BusinessRuleId] [int] NOT NULL,
	[AccrualTypeId] [int] NOT NULL,
	[TimeEntryTypeId] [int] NOT NULL,
	[EffectivePyPeriodId] [int] NOT NULL,
	[RuleName] [varchar](255) NULL,
	[JobCodeId] [int] NOT NULL,
	[CustomTableEmployeeStatusId] [int] NULL,
	[YearsOfServiceMin] [decimal](5, 2) NULL,
	[YearsOfServiceMax] [decimal](5, 2) NULL,
	[AccrualRate] [decimal](10, 2) NULL,
	[RateType] [varchar](55) NULL,
	[CustomTableAccrualFrequencyId] [int] NULL,
	[AccrualUnit] [varchar](55) NULL,
	[MinHours] [decimal](10, 2) NULL,
	[MaxHours] [decimal](10, 2) NULL,
	[MaxBalance] [decimal](10, 2) NULL,
	[CarryOverLimit] [decimal](10, 2) NULL,
	[IsEnabled] [bit] NULL,
	[IsActive] [bit] NULL,
	[IsStopAccruingAtMax] [bit] NULL,
	[DeductionMultiplier] [decimal](5, 2) NULL,
	[WaitingPeriodDays] [int] NULL,
	[EffectiveDate] [date] NULL,
	[ExpiryDate] [date] NULL,
	[EmployeesYearsServedMin] [decimal](5, 2) NULL,
	[EmployeesYearsServedMax] [decimal](5, 2) NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_AccrualRules] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccrualRules] ADD  CONSTRAINT [DF_AccrualRules_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.AccrualTransactions.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[AccrualTransactions]    Script Date: 11/11/2025 8:00:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccrualTransactions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[AccrualTypeId] [int] NOT NULL,
	[TimeEntryId] [int] NOT NULL,
	[PayPeriodId] [int] NOT NULL,
	[CustomTableTransactionTypeId] [int] NULL,
	[Amount] [decimal](10, 2) NULL,
	[BalanceAfter] [decimal](10, 2) NULL,
	[ReferenceId] [int] NULL,
	[CustomTableReferenceTypeId] [int] NULL,
	[Description] [nvarchar](max) NULL,
	[ProcessedDate] [date] NULL,
	[Processedby] [int] NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL,
	[UpdatedAt] [datetimeoffset](7) NULL,
	[CreatedBy] [int] NULL,
	[UpdatedBy] [int] NULL,
	[AccrualRuleId] [int] NULL,
 CONSTRAINT [PK_AccrualTransactions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccrualTransactions] ADD  CONSTRAINT [DF_Holidays_AccrualTransactions]  DEFAULT (getdate()) FOR [CreatedAt]
GO
/* ----- dbo.AccrualTypes.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[AccrualTypes]    Script Date: 11/11/2025 8:00:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccrualTypes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[TypeCode] [varchar](55) NOT NULL,
	[TypeName] [varchar](255) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[CustomTableUnitId] [int] NULL,
	[CustomTableCategoryId] [int] NULL,
	[MaxBalance] [decimal](10, 2) NULL,
	[MaxCarryOver] [decimal](10, 2) NULL,
	[CarryOverExpiryMonths] [int] NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_AccrualTypes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccrualTypes] ADD  CONSTRAINT [DF_AccrualTypes_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

/* ----- dbo.AccrualProfiles.Table.sql ----- */
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

/* ----- dbo.AssisstantQualifiers.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[AssisstantQualifiers]    Script Date: 11/11/2025 8:00:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssisstantQualifiers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Code] [varchar](55) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[BackgroundColor] [varchar](7) NULL,
	[TextColor] [varchar](7) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_AssisstantQualifiers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssisstantQualifiers] ADD  CONSTRAINT [DF_AssisstantQualifiers_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

/* ----- dbo.AvailabilityPeriodShifts.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[AvailabilityPeriodShifts]    Script Date: 11/11/2025 8:00:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AvailabilityPeriodShifts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ScheduleId] [int] NOT NULL,
	[ShiftId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/* ----- dbo.BusinessRules.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[BusinessRules]    Script Date: 11/11/2025 8:00:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BusinessRules](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[RuleName] [varchar](255) NOT NULL,
	[CustomTableRuleTypeId] [int] NOT NULL,
	[JobCodeId] [int] NOT NULL,
	[TimeEntryTypeId] [int] NOT NULL,
	[Conditions] [nvarchar](max) NULL,
	[Actions] [nvarchar](max) NULL,
	[Priority] [int] NULL,
	[EffectiveDate] [date] NULL,
	[ExpiryDate] [date] NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_BusinessRules] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[BusinessRules] ADD  CONSTRAINT [DF_BusinessRules_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

/* ----- dbo.ClockInOut.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[ClockInOut]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClockInOut](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[ShiftAssignmentId] [int] NOT NULL,
	[ClockInTime] [datetime] NOT NULL,
	[ClockOutTime] [datetime] NOT NULL,
	[ClockInLocation] [varchar](200) NULL,
	[ClockOutLocation] [varchar](200) NULL,
	[ClockInMethod] [varchar](50) NULL,
	[ClockOutMethod] [varchar](50) NULL,
	[CustomTableStatusId] [int] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ClockInOut] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClockInOut] ADD  CONSTRAINT [DF_ClockInOut_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

/* ----- dbo.Columns.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[Columns]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Columns](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ColumnName] [nvarchar](50) NULL,
	[TenantId] [int] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
	[BackgroundColor] [nvarchar](10) NULL,
 CONSTRAINT [PK_Columns] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Columns] ADD  CONSTRAINT [DF_Columns_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

/* ----- dbo.ColumnShifts.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[ColumnShifts]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ColumnShifts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ColumnId] [int] NULL,
	[DayNumber] [int] NULL,
	[ShiftId] [int] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[TenantId] [int] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
	[LayoutId] [int] NULL,
 CONSTRAINT [PK_ColumnShifts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ColumnShifts] ADD  CONSTRAINT [DF_ColumnShifts_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.CustomTables.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[CustomTables]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomTables](
	[CustomTableID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](250) NULL,
	[TenantId] [int] NULL,
	[IsActive] [bit] NULL,
	[TypeName] [varchar](50) NULL,
 CONSTRAINT [PK_CustomTables] PRIMARY KEY CLUSTERED 
(
	[CustomTableID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/* ----- dbo.CustomTableValues.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[CustomTableValues]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomTableValues](
	[CustomTableValueID] [int] IDENTITY(1,1) NOT NULL,
	[CustomTableID] [int] NOT NULL,
	[Code] [varchar](4) NOT NULL,
	[ShortDescription] [varchar](75) NULL,
	[LongDescription] [varchar](255) NULL,
	[TenantId] [int] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_CustomValues] PRIMARY KEY CLUSTERED 
(
	[CustomTableValueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/* ----- dbo.DbOperationsAnalytics.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[DbOperationsAnalytics]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DbOperationsAnalytics](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[StoredProcedureName] [nvarchar](500) NOT NULL,
	[TimeSpent] [time](7) NOT NULL,
	[Query] [nvarchar](max) NOT NULL,
	[ProcParams] [nvarchar](max) NOT NULL,
	[AdditionalQuery] [nvarchar](max) NOT NULL,
	[Project] [nvarchar](max) NOT NULL,
	[StartedOn] [datetime] NOT NULL,
	[FinishedOn] [datetime] NOT NULL,
	[UserId] [int] NULL,
	[RoleId] [int] NULL,
	[TenantId] [int] NULL,
	[IsWindowService] [bit] NULL,
 CONSTRAINT [PK_DbOperationsAnalytics] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/* ----- dbo.EmployeeHourlyRates.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[EmployeeHourlyRates]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeHourlyRates](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[JobCodeId] [int] NOT NULL,
	[HourlyRate] [decimal](10, 2) NOT NULL,
	[EffectiveDate] [date] NULL,
	[ExpiryDate] [date] NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_EmployeeHourlyRates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmployeeHourlyRates] ADD  CONSTRAINT [DF_EmployeeHourlyRates_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.EmployeeJobCodeAssignment.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[EmployeeJobCodeAssignment]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeJobCodeAssignment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[JobCodeId] [int] NOT NULL,
	[IsActive] [bit] NULL,
	[EffectiveDate] [datetimeoffset](7) NULL,
	[ExpiryDate] [datetimeoffset](7) NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_EmployeeJobCodeAssignment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmployeeJobCodeAssignment] ADD  CONSTRAINT [DF_EmployeeJobCodeAssignment_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.EmployeeLabelAssignment.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[EmployeeLabelAssignment]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeLabelAssignment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[LabelId] [int] NOT NULL,
	[UserId] [int] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
	[EffectiveDate] [datetimeoffset](7) NULL,
	[ExpiryDate] [datetimeoffset](7) NULL,
	[IsDeleted] [bit] NULL,
	[DeletedBy] [int] NULL,
	[DeletedOn] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_EmployeeLabelAssignment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/* ----- dbo.EmployeeShiftAssignmentJobCodes.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[EmployeeShiftAssignmentJobCodes]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeShiftAssignmentJobCodes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[ShiftAssignmentId] [int] NOT NULL,
	[JobCodeId] [int] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_EmployeeShiftAssignmentJobCodes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/* ----- dbo.EmployeeShiftAssignmentLabels.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[EmployeeShiftAssignmentLabels]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeShiftAssignmentLabels](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[ShiftAssignmentId] [int] NOT NULL,
	[LabelId] [int] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_EmployeeShiftAssignmentLabels] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/* ----- dbo.EmployeeShiftAssignmentWorkCodes.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[EmployeeShiftAssignmentWorkCodes]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeShiftAssignmentWorkCodes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[ShiftAssignmentId] [int] NOT NULL,
	[WorkCodeId] [int] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_EmployeeShiftAssignmentWorkCodes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/* ----- dbo.EmployeeWorkCodeAssignment.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[EmployeeWorkCodeAssignment]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeWorkCodeAssignment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[WorkCodeId] [int] NOT NULL,
	[IsActive] [bit] NULL,
	[EffectiveDate] [datetimeoffset](7) NULL,
	[ExpiryDate] [datetimeoffset](7) NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_EmployeeWorkCodeAssignment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmployeeWorkCodeAssignment] ADD  CONSTRAINT [DF_EmployeeWorkCodeAssignment_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.Groups.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[Groups]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Groups](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[GroupName] [varchar](255) NOT NULL,
	[GroupTypeCustomTableValueId] [int] NULL,
	[Description] [nvarchar](max) NULL,
	[ColorCode] [varchar](7) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ShiftGroups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Groups] ADD  CONSTRAINT [DF_ShiftGroups_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

/* ----- dbo.HolidayAssignment.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[HolidayAssignment]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HolidayAssignment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[HolidayId] [int] NOT NULL,
	[UserId] [int] NULL,
	[JobCodeId] [int] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
	[EffectiveDate] [datetimeoffset](7) NULL,
	[ExpiryDate] [datetimeoffset](7) NULL,
	[IsDeleted] [bit] NULL,
	[DeletedBy] [int] NULL,
	[DeletedOn] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_HolidayAssignment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HolidayAssignment] ADD  CONSTRAINT [DF_HolidayAssignment_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[HolidayAssignment] ADD  CONSTRAINT [DF__HolidayAs__IsDel__2DB1C7EE]  DEFAULT ((0)) FOR [IsDeleted]
GO
/* ----- dbo.HolidayRules.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[HolidayRules]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HolidayRules](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[BusinessRuleId] [int] NOT NULL,
	[HolidayId] [int] NOT NULL,
	[CustomTablePayTypeId] [int] NULL,
	[Multiplier] [decimal](5, 2) NULL,
	[IsRequiresWork] [bit] NULL,
	[FloatingHolidayRules] [nvarchar](max) NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_HolidayRules] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[HolidayRules] ADD  CONSTRAINT [DF_HolidayRules_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.Holidays.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[Holidays]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Holidays](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[HolidayName] [varchar](255) NOT NULL,
	[HolidayDate] [date] NOT NULL,
	[ObservedDate] [date] NULL,
	[IsObserved] [bit] NULL,
	[IsFloating] [bit] NULL,
	[IsAppliesToAll] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
	[HolidayCode] [varchar](25) NULL,
 CONSTRAINT [PK_Holidays] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Holidays] ADD  CONSTRAINT [DF_Holidays_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

/* ----- dbo.JobCodes.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[JobCodes]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JobCodes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[JobCode] [varchar](50) NOT NULL,
	[JobTitle] [varchar](200) NOT NULL,
	[Description] [varchar](1000) NULL,
	[Category] [varchar](100) NULL,
	[IsExempt] [bit] NULL,
	[PayMultiplier] [decimal](10, 2) NULL,
	[PayRate] [decimal](10, 2) NULL,
	[DefaultHoursPerWeek] [decimal](5, 2) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
	[ColorCode] [varchar](20) NULL,
 CONSTRAINT [PK_JobCodes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JobCodes] ADD  CONSTRAINT [DF_JobCodes_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

/* ----- dbo.Labels.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[Labels]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Labels](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[LabelName] [varchar](100) NOT NULL,
	[LabelCode] [varchar](55) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ColorCode] [varchar](7) NULL,
	[IconCode] [varchar](55) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ShiftLabels] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Labels] ADD  CONSTRAINT [DF_ShiftLabels_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

/* ----- dbo.LayoutGridColumns.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[LayoutGridColumns]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LayoutGridColumns](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ColumnId] [int] NOT NULL,
	[RowNumber] [int] NULL,
	[ColumnNumber] [int] NULL,
	[LayoutId] [int] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[TenantId] [int] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_LayoutGridColumns] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LayoutGridColumns] ADD  CONSTRAINT [DF_LayoutGridColumns_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.Layouts.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[Layouts]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Layouts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[LayoutName] [nvarchar](50) NOT NULL,
	[Type] [int] NOT NULL,
	[Description] [nvarchar](500) NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
	[Rows] [int] NULL,
	[Columns] [int] NULL,
 CONSTRAINT [PK_Layouts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Layouts] ADD  CONSTRAINT [DF_Layouts_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

/* ----- dbo.OvertimeRules.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[OvertimeRules]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OvertimeRules](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[BusinessRuleId] [int] NOT NULL,
	[CustomTableThresoldTypeId] [int] NULL,
	[ThresoldHours] [decimal](10, 2) NULL,
	[Multipliers] [decimal](5, 2) NULL,
	[IsApplisToHolidays] [bit] NULL,
	[IsAppliesToWeekends] [bit] NULL,
	[MxOvertimeHours] [decimal](10, 2) NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_OvertimeRules] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OvertimeRules] ADD  CONSTRAINT [DF_OvertimeRules_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.PayPeriod.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[PayPeriod]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayPeriod](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[PeriodName] [varchar](255) NOT NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[PayDate] [date] NULL,
	[CustomTableFrequencyId] [int] NULL,
	[CustomTableStatusId] [int] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_PayPeriod] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayPeriod] ADD  CONSTRAINT [DF_PayPeriod_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

/* ----- dbo.Payroll.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[Payroll]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payroll](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[PayPeriodId] [int] NOT NULL,
	[RegularHours] [decimal](10, 2) NULL,
	[OvertimeHours] [decimal](10, 2) NULL,
	[DoubleTimeHours] [decimal](10, 2) NULL,
	[HolidayHours] [decimal](10, 2) NULL,
	[SickHours] [decimal](10, 2) NULL,
	[VacationHours] [decimal](10, 2) NULL,
	[PersonalHours] [decimal](10, 2) NULL,
	[OtherHours] [decimal](10, 2) NULL,
	[GrossPay] [decimal](12, 2) NULL,
	[NetPay] [decimal](12, 2) NULL,
	[TotalDeductions] [decimal](12, 2) NULL,
	[CustomTableStatusId] [int] NULL,
	[CalculatedAt] [datetime] NULL,
	[Approvedby] [int] NULL,
	[ApprovedAt] [datetime] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_Payroll] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Payroll] ADD  CONSTRAINT [DF_Payroll_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.PayrollItem.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[PayrollItem]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayrollItem](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[PayrollId] [int] NOT NULL,
	[CustomTableItemTypeId] [int] NULL,
	[ItemCode] [varchar](55) NULL,
	[ItemName] [varchar](255) NULL,
	[Amount] [decimal](10, 2) NULL,
	[Hours] [decimal](10, 2) NULL,
	[Rate] [decimal](10, 2) NULL,
	[IsPreTax] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DataUpdated] [datetimeoffset](7) NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_PayrollItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayrollItem] ADD  CONSTRAINT [DF_PayrollItem_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.RuleExecution.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[RuleExecution]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RuleExecution](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[TimeEntryId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[PayPeriodId] [int] NOT NULL,
	[CustomTableRuleTypeId] [int] NULL,
	[AppliedRules] [nvarchar](max) NULL,
	[CalculatedAmount] [decimal](12, 2) NULL,
	[CalculatedHours] [decimal](10, 2) NULL,
	[CustomTableStatusId] [int] NULL,
	[ProcessedAt] [datetime] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[CreatedAt] [datetime] NOT NULL,
	[UpdatedAt] [datetime] NULL,
 CONSTRAINT [PK_RuleExecution] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[RuleExecution] ADD  CONSTRAINT [DF_RuleExecution_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO

/* ----- dbo.RuleProcessingSteps.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[RuleProcessingSteps]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RuleProcessingSteps](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[RuleExecutionId] [int] NOT NULL,
	[StepName] [varchar](255) NOT NULL,
	[InputData] [nvarchar](max) NULL,
	[OutputData] [nvarchar](max) NULL,
	[CustomTableStatusId] [int] NULL,
	[ProcessedAt] [datetime] NULL,
	[ErrorMessage] [varchar](max) NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[CreatedAt] [datetime] NOT NULL,
	[UpdatedAt] [datetime] NULL,
 CONSTRAINT [PK_RuleProcessingSteps] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[RuleProcessingSteps] ADD  CONSTRAINT [DF_RuleProcessingSteps_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO

/* ----- dbo.ScheduleFrequencies.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[ScheduleFrequencies]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScheduleFrequencies](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[ScheduleId] [int] NOT NULL,
	[Day] [int] NULL,
	[DayType] [int] NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ScheduleFrequencies] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ScheduleFrequencies] ADD  CONSTRAINT [DF_ScheduleFrequencies_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.Schedules.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[Schedules]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Schedules](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[ScheduleName] [varchar](255) NOT NULL,
	[SourceType] [int] NOT NULL,
	[SourceId] [int] NOT NULL,
	[StartFrom] [date] NULL,
	[ValidUntil] [datetimeoffset](7) NULL,
	[StatusCustomTableValueId] [int] NULL,
	[Notes] [nvarchar](max) NULL,
	[ScheduleType] [int] NULL,
	[RepeatEvery] [int] NULL,
	[ScheduleWithoutTimes] [bit] NULL,
	[StartDate] [date] NULL,
	[StartTime] [time](7) NULL,
	[EndDate] [date] NULL,
	[EndTime] [time](7) NULL,
	[MaxOccurrences] [int] NULL,
	[EndType] [nvarchar](50) NULL,
	[Createdby] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_Schedules] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Schedules] ADD  CONSTRAINT [DF_Schedules_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.ShiftAssignment.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[ShiftAssignment]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShiftAssignment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[ShiftId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[StatusCustomTableValueId] [int] NULL,
	[Notes] [nvarchar](max) NULL,
	[AssignedAt] [datetimeoffset](7) NULL,
	[Assignedby] [int] NULL,
	[StartTime] [time](7) NULL,
	[EndTime] [time](7) NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
	[ScheduleId] [int] NULL,
 CONSTRAINT [PK_ShiftAssignment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_ShiftAssignment] UNIQUE NONCLUSTERED 
(
	[ScheduleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ShiftAssignment] ADD  CONSTRAINT [DF_ShiftAssignment_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.ShiftGroupAssignment.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[ShiftGroupAssignment]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShiftGroupAssignment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[ShiftId] [int] NOT NULL,
	[GroupId] [int] NOT NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ShiftGroupAssignment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ShiftGroupAssignment] ADD  CONSTRAINT [DF_ShiftGroupAssignment_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.ShiftJobCodeAssignment.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[ShiftJobCodeAssignment]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShiftJobCodeAssignment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[ShiftId] [int] NOT NULL,
	[JobCodeId] [int] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ShiftJobCodeAssignment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/* ----- dbo.Shifts.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[Shifts]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Shifts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[ShiftName] [varchar](255) NOT NULL,
	[ShiftCode] [varchar](55) NOT NULL,
	[MinimumPositions] [int] NULL,
	[MaxTimeOffs] [int] NULL,
	[Location] [varchar](255) NULL,
	[IsWorkShift] [bit] NULL,
	[IsSelfSchedulingEnabled] [bit] NULL,
	[IsSelfSchedulingRequiresAdminApprovals] [bit] NULL,
	[AdminIds] [varchar](500) NULL,
	[IsHideOpenSlots] [bit] NULL,
	[ShiftLabelId] [int] NULL,
	[BackgroundColour] [varchar](7) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
	[DisplayOrder] [int] NULL,
	[StatusCustomTableValueId] [int] NULL,
	[DateDeleted] [datetimeoffset](7) NULL,
	[DeletedBy] [int] NULL,
 CONSTRAINT [PK_Shifts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Shifts] ADD  CONSTRAINT [DF_Shifts_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.ShiftTrades.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[ShiftTrades]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShiftTrades](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[FromUserId] [int] NOT NULL,
	[ToUserId] [int] NOT NULL,
	[FromAssignmentId] [int] NOT NULL,
	[ToAssignmentId] [int] NOT NULL,
	[StatusCustomTableValueId] [int] NULL,
	[Result] [nvarchar](max) NULL,
	[IsNeedApproval] [bit] NULL,
	[IsNeedRejectionApproval] [bit] NULL,
	[IsAutoApprovalEligible] [bit] NULL,
	[IsRequireManagerApproval] [bit] NULL,
	[IsAllowPartialTrade] [bit] NULL,
	[MaxTradeDuration] [decimal](5, 2) NULL,
	[RequestedAt] [datetimeoffset](7) NULL,
	[ApprovedAt] [datetimeoffset](7) NULL,
	[Approvedby] [int] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ShiftTrades] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ShiftTrades] ADD  CONSTRAINT [DF_ShiftTrades_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.ShiftWorkCodeAssignment.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[ShiftWorkCodeAssignment]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShiftWorkCodeAssignment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[ShiftId] [int] NOT NULL,
	[WorkCodeId] [int] NOT NULL,
	[IsRequired] [bit] NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_ShiftWorkCodeAssignment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ShiftWorkCodeAssignment] ADD  CONSTRAINT [DF_ShiftWorkCodeAssignment_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.TimeEntries.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[TimeEntries]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TimeEntries](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[JobCodeId] [int] NOT NULL,
	[WorkCodeId] [int] NOT NULL,
	[TimeEntryTypeId] [int] NOT NULL,
	[ClockInOutId] [int] NOT NULL,
	[TimeSheetId] [int] NOT NULL,
	[HolidayId] [int] NOT NULL,
	[EntryDate] [datetimeoffset](7) NOT NULL,
	[StartTime] [time](7) NULL,
	[EndTime] [time](7) NULL,
	[BreakDuration] [decimal](5, 2) NULL,
	[TotalHours] [decimal](5, 2) NULL,
	[Description] [nvarchar](max) NULL,
	[ProjectCode] [varchar](100) NULL,
	[CostCenter] [varchar](100) NULL,
	[StatusCustomTableValueId] [int] NULL,
	[SubmittedAt] [datetimeoffset](7) NULL,
	[Approvedby] [int] NULL,
	[ApprovedAt] [datetimeoffset](7) NULL,
	[RejectionReason] [nvarchar](max) NULL,
	[Createdby] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_TimeEntries] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[TimeEntries] ADD  CONSTRAINT [DF_TimeEntries_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.TimeEntryTypes.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[TimeEntryTypes]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TimeEntryTypes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[TypeCode] [varchar](50) NOT NULL,
	[TypeName] [varchar](200) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[CategoryCustomTableValueId] [int] NULL,
	[IsPaid] [bit] NULL,
	[IsAccrualEligible] [bit] NULL,
	[AccrualFactor] [decimal](5, 2) NULL,
	[IsRequiresApproval] [bit] NULL,
	[MaxHoursPerDay] [decimal](5, 2) NULL,
	[MaxHoursPerWeek] [decimal](5, 2) NULL,
	[ColorCode] [varchar](7) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_TimeEntryTypes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[TimeEntryTypes] ADD  CONSTRAINT [DF_TimeEntryTypes_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

/* ----- dbo.TimeSheets.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[TimeSheets]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TimeSheets](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[PayPeriodId] [int] NOT NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[TotalRegularHours] [decimal](10, 2) NULL,
	[TotalOvertimeHours] [decimal](10, 2) NULL,
	[TotalLeaveHours] [decimal](10, 2) NULL,
	[CustomTableStatusId] [int] NULL,
	[SubmittedAt] [datetime] NULL,
	[ApprovedAt] [datetime] NULL,
	[RejectionReason] [nvarchar](max) NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_TimeSheets] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[TimeSheets] ADD  CONSTRAINT [DF_TimeSheets_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.TradeBoardListRules.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[TradeBoardListRules]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TradeBoardListRules](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[TradeBoardSettingsId] [int] NOT NULL,
	[JobCodeId] [int] NOT NULL,
	[RuleName] [varchar](255) NOT NULL,
	[RuleDescription] [nvarchar](max) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_TradeBoardListRules] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[TradeBoardListRules] ADD  CONSTRAINT [DF_TradeBoardListRules_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO
/* ----- dbo.TradeBoardSettings.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[TradeBoardSettings]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TradeBoardSettings](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[SettingsName] [varchar](255) NOT NULL,
	[IsLimitTradesToMatchingLists] [bit] NULL,
	[IsOnlyAllowDirectTrades] [bit] NULL,
	[IsRequireApprovalBeforeSent] [bit] NULL,
	[IsRequireApprovalAfterAccepted] [bit] NULL,
	[IsRequireSecondApproval] [bit] NULL,
	[IsApprovingUsersSeeOnlyTheirRequests] [bit] NULL,
	[IsEnableShiftSwapFeature] [bit] NULL,
	[IsColorCodeTradedShifts] [bit] NULL,
	[TradedShiftColorCode] [varchar](7) NULL,
	[IsRequireManualLedgerApproval] [bit] NULL,
	[IsUserSelectsApproval] [bit] NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_TradeBoardSettings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TradeBoardSettings] ADD  CONSTRAINT [DF_TradeBoardSettings_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

/* ----- dbo.WorkCodes.Table.sql ----- */
USE [TimeManagement_DEV]
GO
/****** Object:  Table [dbo].[WorkCodes]    Script Date: 11/11/2025 8:00:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkCodes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[WorkCode] [varchar](55) NOT NULL,
	[WorkCodeName] [varchar](255) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Category] [varchar](55) NULL,
	[ColorCode] [varchar](7) NULL,
	[TextColor] [varchar](7) NULL,
	[PayMultiplier] [decimal](10, 2) NULL,
	[PayRate] [decimal](10, 2) NULL,
	[IsDefault] [bit] NULL,
	[DisplayOrder] [int] NULL,
	[IsCountsTowardWeeklyLimit] [bit] NULL,
	[IsCountsTowardMonthlyLimit] [bit] NULL,
	[IsIncludeInCallbackRankings] [bit] NULL,
	[IsExcludesFromCallbacks] [bit] NULL,
	[IsTradeable] [bit] NULL,
	[MinTimeBufferHours] [decimal](5, 2) NULL,
	[MaxTimeBufferHours] [decimal](5, 2) NULL,
	[ExclusionRuleHours] [decimal](5, 2) NULL,
	[LimitPerEmployeePerYear] [int] NULL,
	[IsRequestable] [bit] NULL,
	[IsMasked] [bit] NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[UpdatedBy] [int] NULL,
	[DateCreated] [datetimeoffset](7) NOT NULL,
	[DateUpdated] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_WorkCodes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkCodes] ADD  CONSTRAINT [DF_WorkCode_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

/* ----- Foreign Key Constraints ----- */

ALTER TABLE [dbo].[AccrualBalance]  WITH CHECK ADD  CONSTRAINT [FK_AccrualBalance_AccrualTypes] FOREIGN KEY([AccrualTypeId])
REFERENCES [dbo].[AccrualTypes] ([Id])
GO
ALTER TABLE [dbo].[AccrualBalance] CHECK CONSTRAINT [FK_AccrualBalance_AccrualTypes]
GO

ALTER TABLE [dbo].[AccrualRules]  WITH CHECK ADD  CONSTRAINT [FK_AccrualRules_BusinessRules] FOREIGN KEY([BusinessRuleId])
REFERENCES [dbo].[BusinessRules] ([Id])
GO
ALTER TABLE [dbo].[AccrualRules] CHECK CONSTRAINT [FK_AccrualRules_BusinessRules]
GO

ALTER TABLE [dbo].[AccrualTransactions]  WITH CHECK ADD  CONSTRAINT [FK_AccrualTransactions_AccrualRules] FOREIGN KEY([AccrualRuleId])
REFERENCES [dbo].[AccrualRules] ([Id])
GO
ALTER TABLE [dbo].[AccrualTransactions] CHECK CONSTRAINT [FK_AccrualTransactions_AccrualRules]
GO
ALTER TABLE [dbo].[AccrualTransactions]  WITH CHECK ADD  CONSTRAINT [FK_AccrualTransactions_AccrualTypes] FOREIGN KEY([AccrualTypeId])
REFERENCES [dbo].[AccrualTypes] ([Id])
GO
ALTER TABLE [dbo].[AccrualTransactions] CHECK CONSTRAINT [FK_AccrualTransactions_AccrualTypes]
GO
ALTER TABLE [dbo].[AccrualTransactions]  WITH CHECK ADD  CONSTRAINT [FK_AccrualTransactions_PayPeriod] FOREIGN KEY([PayPeriodId])
REFERENCES [dbo].[PayPeriod] ([Id])
GO
ALTER TABLE [dbo].[AccrualTransactions] CHECK CONSTRAINT [FK_AccrualTransactions_PayPeriod]
GO
ALTER TABLE [dbo].[AccrualTransactions]  WITH CHECK ADD  CONSTRAINT [FK_AccrualTransactions_TimeEntries] FOREIGN KEY([TimeEntryId])
REFERENCES [dbo].[TimeEntries] ([Id])
GO
ALTER TABLE [dbo].[AccrualTransactions] CHECK CONSTRAINT [FK_AccrualTransactions_TimeEntries]
GO

ALTER TABLE [dbo].[AvailabilityPeriodShifts]  WITH CHECK ADD  CONSTRAINT [FK_AvailabilityPeriodShifts_Schedules] FOREIGN KEY([ScheduleId])
REFERENCES [dbo].[Schedules] ([Id])
GO
ALTER TABLE [dbo].[AvailabilityPeriodShifts] CHECK CONSTRAINT [FK_AvailabilityPeriodShifts_Schedules]
GO
ALTER TABLE [dbo].[AvailabilityPeriodShifts]  WITH CHECK ADD  CONSTRAINT [FK_AvailabilityPeriodShifts_Shifts] FOREIGN KEY([ShiftId])
REFERENCES [dbo].[Shifts] ([Id])
GO
ALTER TABLE [dbo].[AvailabilityPeriodShifts] CHECK CONSTRAINT [FK_AvailabilityPeriodShifts_Shifts]
GO

ALTER TABLE [dbo].[ColumnShifts]  WITH CHECK ADD  CONSTRAINT [FK_ColumnShifts_Columns] FOREIGN KEY([ColumnId])
REFERENCES [dbo].[Columns] ([Id])
GO
ALTER TABLE [dbo].[ColumnShifts] CHECK CONSTRAINT [FK_ColumnShifts_Columns]
GO
ALTER TABLE [dbo].[ColumnShifts]  WITH CHECK ADD  CONSTRAINT [FK_ColumnShifts_ColumnShifts] FOREIGN KEY([ShiftId])
REFERENCES [dbo].[Shifts] ([Id])
GO
ALTER TABLE [dbo].[ColumnShifts] CHECK CONSTRAINT [FK_ColumnShifts_ColumnShifts]
GO

ALTER TABLE [dbo].[CustomTableValues]  WITH CHECK ADD  CONSTRAINT [FK_CustomTableValues_CustomTables] FOREIGN KEY([CustomTableID])
REFERENCES [dbo].[CustomTables] ([CustomTableID])
GO
ALTER TABLE [dbo].[CustomTableValues] CHECK CONSTRAINT [FK_CustomTableValues_CustomTables]
GO

ALTER TABLE [dbo].[EmployeeHourlyRates]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeHourlyRates_JobCodes] FOREIGN KEY([JobCodeId])
REFERENCES [dbo].[JobCodes] ([Id])
GO
ALTER TABLE [dbo].[EmployeeHourlyRates] CHECK CONSTRAINT [FK_EmployeeHourlyRates_JobCodes]
GO

ALTER TABLE [dbo].[EmployeeJobCodeAssignment]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeJobCodeAssignment_JobCodes] FOREIGN KEY([JobCodeId])
REFERENCES [dbo].[JobCodes] ([Id])
GO
ALTER TABLE [dbo].[EmployeeJobCodeAssignment] CHECK CONSTRAINT [FK_EmployeeJobCodeAssignment_JobCodes]
GO

ALTER TABLE [dbo].[EmployeeShiftAssignmentJobCodes]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeShiftAssignmentJobCodes_JobCodes] FOREIGN KEY([JobCodeId])
REFERENCES [dbo].[JobCodes] ([Id])
GO
ALTER TABLE [dbo].[EmployeeShiftAssignmentJobCodes] CHECK CONSTRAINT [FK_EmployeeShiftAssignmentJobCodes_JobCodes]
GO
ALTER TABLE [dbo].[EmployeeShiftAssignmentJobCodes]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeShiftAssignmentJobCodes_ShiftAssignment] FOREIGN KEY([ShiftAssignmentId])
REFERENCES [dbo].[ShiftAssignment] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EmployeeShiftAssignmentJobCodes] CHECK CONSTRAINT [FK_EmployeeShiftAssignmentJobCodes_ShiftAssignment]
GO

ALTER TABLE [dbo].[EmployeeShiftAssignmentLabels]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeShiftAssignmentLabels_Labels] FOREIGN KEY([LabelId])
REFERENCES [dbo].[Labels] ([Id])
GO
ALTER TABLE [dbo].[EmployeeShiftAssignmentLabels] CHECK CONSTRAINT [FK_EmployeeShiftAssignmentLabels_Labels]
GO
ALTER TABLE [dbo].[EmployeeShiftAssignmentLabels]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeShiftAssignmentLabels_ShiftAssignment] FOREIGN KEY([ShiftAssignmentId])
REFERENCES [dbo].[ShiftAssignment] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EmployeeShiftAssignmentLabels] CHECK CONSTRAINT [FK_EmployeeShiftAssignmentLabels_ShiftAssignment]
GO

ALTER TABLE [dbo].[EmployeeShiftAssignmentWorkCodes]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeShiftAssignmentWorkCodes_ShiftAssignment] FOREIGN KEY([ShiftAssignmentId])
REFERENCES [dbo].[ShiftAssignment] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EmployeeShiftAssignmentWorkCodes] CHECK CONSTRAINT [FK_EmployeeShiftAssignmentWorkCodes_ShiftAssignment]
GO
ALTER TABLE [dbo].[EmployeeShiftAssignmentWorkCodes]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeShiftAssignmentWorkCodes_WorkCodes] FOREIGN KEY([WorkCodeId])
REFERENCES [dbo].[WorkCodes] ([Id])
GO
ALTER TABLE [dbo].[EmployeeShiftAssignmentWorkCodes] CHECK CONSTRAINT [FK_EmployeeShiftAssignmentWorkCodes_WorkCodes]
GO

ALTER TABLE [dbo].[EmployeeWorkCodeAssignment]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeWorkCodeAssignment_WorkCodes] FOREIGN KEY([WorkCodeId])
REFERENCES [dbo].[WorkCodes] ([Id])
GO
ALTER TABLE [dbo].[EmployeeWorkCodeAssignment] CHECK CONSTRAINT [FK_EmployeeWorkCodeAssignment_WorkCodes]
GO

ALTER TABLE [dbo].[HolidayAssignment]  WITH CHECK ADD  CONSTRAINT [FK_HolidayAssignment_Holidays] FOREIGN KEY([HolidayId])
REFERENCES [dbo].[Holidays] ([Id])
GO
ALTER TABLE [dbo].[HolidayAssignment] CHECK CONSTRAINT [FK_HolidayAssignment_Holidays]
GO
ALTER TABLE [dbo].[HolidayAssignment]  WITH CHECK ADD  CONSTRAINT [FK_HolidayAssignment_JobCodes] FOREIGN KEY([JobCodeId])
REFERENCES [dbo].[JobCodes] ([Id])
GO
ALTER TABLE [dbo].[HolidayAssignment] CHECK CONSTRAINT [FK_HolidayAssignment_JobCodes]
GO

ALTER TABLE [dbo].[HolidayRules]  WITH CHECK ADD  CONSTRAINT [FK_HolidayRules_BusinessRules] FOREIGN KEY([BusinessRuleId])
REFERENCES [dbo].[BusinessRules] ([Id])
GO
ALTER TABLE [dbo].[HolidayRules] CHECK CONSTRAINT [FK_HolidayRules_BusinessRules]
GO

ALTER TABLE [dbo].[LayoutGridColumns]  WITH CHECK ADD  CONSTRAINT [FK_LayoutGridColumns_Columns] FOREIGN KEY([ColumnId])
REFERENCES [dbo].[Columns] ([Id])
GO
ALTER TABLE [dbo].[LayoutGridColumns] CHECK CONSTRAINT [FK_LayoutGridColumns_Columns]
GO
ALTER TABLE [dbo].[LayoutGridColumns]  WITH CHECK ADD  CONSTRAINT [FK_LayoutGridColumns_Layouts] FOREIGN KEY([LayoutId])
REFERENCES [dbo].[Layouts] ([Id])
GO
ALTER TABLE [dbo].[LayoutGridColumns] CHECK CONSTRAINT [FK_LayoutGridColumns_Layouts]
GO

ALTER TABLE [dbo].[OvertimeRules]  WITH CHECK ADD  CONSTRAINT [FK_OverTimeRules_BusinessRules] FOREIGN KEY([Id])
REFERENCES [dbo].[BusinessRules] ([Id])
GO
ALTER TABLE [dbo].[OvertimeRules] CHECK CONSTRAINT [FK_OverTimeRules_BusinessRules]
GO

ALTER TABLE [dbo].[Payroll]  WITH CHECK ADD  CONSTRAINT [FK_Payroll_PayPeriod] FOREIGN KEY([PayPeriodId])
REFERENCES [dbo].[PayPeriod] ([Id])
GO
ALTER TABLE [dbo].[Payroll] CHECK CONSTRAINT [FK_Payroll_PayPeriod]
GO

ALTER TABLE [dbo].[PayrollItem]  WITH CHECK ADD  CONSTRAINT [FK_PayrollItem_Payroll] FOREIGN KEY([PayrollId])
REFERENCES [dbo].[Payroll] ([Id])
GO
ALTER TABLE [dbo].[PayrollItem] CHECK CONSTRAINT [FK_PayrollItem_Payroll]
GO

ALTER TABLE [dbo].[ScheduleFrequencies]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleFrequencies_Schedules] FOREIGN KEY([ScheduleId])
REFERENCES [dbo].[Schedules] ([Id])
GO
ALTER TABLE [dbo].[ScheduleFrequencies] CHECK CONSTRAINT [FK_ScheduleFrequencies_Schedules]
GO

ALTER TABLE [dbo].[Schedules]  WITH CHECK ADD  CONSTRAINT [FK_Schedules_Shifts] FOREIGN KEY([SourceId])
REFERENCES [dbo].[Shifts] ([Id])
GO
ALTER TABLE [dbo].[Schedules] CHECK CONSTRAINT [FK_Schedules_Shifts]
GO

ALTER TABLE [dbo].[ShiftAssignment]  WITH CHECK ADD  CONSTRAINT [FK_ShiftAssignment_Shifts] FOREIGN KEY([ShiftId])
REFERENCES [dbo].[Shifts] ([Id])
GO
ALTER TABLE [dbo].[ShiftAssignment] CHECK CONSTRAINT [FK_ShiftAssignment_Shifts]
GO

ALTER TABLE [dbo].[ShiftGroupAssignment]  WITH CHECK ADD  CONSTRAINT [FK_ShiftGroupAssignment_ShiftGroups] FOREIGN KEY([GroupId])
REFERENCES [dbo].[Groups] ([Id])
GO
ALTER TABLE [dbo].[ShiftGroupAssignment] CHECK CONSTRAINT [FK_ShiftGroupAssignment_ShiftGroups]
GO
ALTER TABLE [dbo].[ShiftGroupAssignment]  WITH CHECK ADD  CONSTRAINT [FK_ShiftGroupAssignment_Shifts] FOREIGN KEY([ShiftId])
REFERENCES [dbo].[Shifts] ([Id])
GO
ALTER TABLE [dbo].[ShiftGroupAssignment] CHECK CONSTRAINT [FK_ShiftGroupAssignment_Shifts]
GO

ALTER TABLE [dbo].[Shifts]  WITH CHECK ADD  CONSTRAINT [FK_Shifts_ShiftLabels] FOREIGN KEY([ShiftLabelId])
REFERENCES [dbo].[Labels] ([Id])
GO
ALTER TABLE [dbo].[Shifts] CHECK CONSTRAINT [FK_Shifts_ShiftLabels]
GO

ALTER TABLE [dbo].[ShiftTrades]  WITH CHECK ADD  CONSTRAINT [FK_ShiftTrades_FromAssignmentId_ShiftAssignment] FOREIGN KEY([FromAssignmentId])
REFERENCES [dbo].[ShiftAssignment] ([Id])
GO
ALTER TABLE [dbo].[ShiftTrades] CHECK CONSTRAINT [FK_ShiftTrades_FromAssignmentId_ShiftAssignment]
GO
ALTER TABLE [dbo].[ShiftTrades]  WITH CHECK ADD  CONSTRAINT [FK_ShiftTrades_ToAssignmentId_ShiftAssignment] FOREIGN KEY([ToAssignmentId])
REFERENCES [dbo].[ShiftAssignment] ([Id])
GO
ALTER TABLE [dbo].[ShiftTrades] CHECK CONSTRAINT [FK_ShiftTrades_ToAssignmentId_ShiftAssignment]
GO

ALTER TABLE [dbo].[ShiftWorkCodeAssignment]  WITH CHECK ADD  CONSTRAINT [FK_ShiftWorkCodeAssignment] FOREIGN KEY([ShiftId])
REFERENCES [dbo].[Shifts] ([Id])
GO
ALTER TABLE [dbo].[ShiftWorkCodeAssignment] CHECK CONSTRAINT [FK_ShiftWorkCodeAssignment]
GO
ALTER TABLE [dbo].[ShiftWorkCodeAssignment]  WITH CHECK ADD  CONSTRAINT [FK_ShiftWorkCodeAssignment_WorkCodes] FOREIGN KEY([WorkCodeId])
REFERENCES [dbo].[WorkCodes] ([Id])
GO
ALTER TABLE [dbo].[ShiftWorkCodeAssignment] CHECK CONSTRAINT [FK_ShiftWorkCodeAssignment_WorkCodes]
GO

ALTER TABLE [dbo].[TimeEntries]  WITH CHECK ADD  CONSTRAINT [FK_TimeEntries_ClockInOut] FOREIGN KEY([ClockInOutId])
REFERENCES [dbo].[ClockInOut] ([Id])
GO
ALTER TABLE [dbo].[TimeEntries] CHECK CONSTRAINT [FK_TimeEntries_ClockInOut]
GO
ALTER TABLE [dbo].[TimeEntries]  WITH CHECK ADD  CONSTRAINT [FK_TimeEntries_Holidays] FOREIGN KEY([HolidayId])
REFERENCES [dbo].[Holidays] ([Id])
GO
ALTER TABLE [dbo].[TimeEntries] CHECK CONSTRAINT [FK_TimeEntries_Holidays]
GO
ALTER TABLE [dbo].[TimeEntries]  WITH CHECK ADD  CONSTRAINT [FK_TimeEntries_JobCodes] FOREIGN KEY([JobCodeId])
REFERENCES [dbo].[JobCodes] ([Id])
GO
ALTER TABLE [dbo].[TimeEntries] CHECK CONSTRAINT [FK_TimeEntries_JobCodes]
GO
ALTER TABLE [dbo].[TimeEntries]  WITH CHECK ADD  CONSTRAINT [FK_TimeEntries_TimeEntryTypes] FOREIGN KEY([TimeEntryTypeId])
REFERENCES [dbo].[TimeEntryTypes] ([Id])
GO
ALTER TABLE [dbo].[TimeEntries] CHECK CONSTRAINT [FK_TimeEntries_TimeEntryTypes]
GO
ALTER TABLE [dbo].[TimeEntries]  WITH CHECK ADD  CONSTRAINT [FK_TimeEntries_WorkCodes] FOREIGN KEY([WorkCodeId])
REFERENCES [dbo].[WorkCodes] ([Id])
GO
ALTER TABLE [dbo].[TimeEntries] CHECK CONSTRAINT [FK_TimeEntries_WorkCodes]
GO

ALTER TABLE [dbo].[TimeSheets]  WITH CHECK ADD  CONSTRAINT [FK_TimeSheets_PayPeriod] FOREIGN KEY([PayPeriodId])
REFERENCES [dbo].[PayPeriod] ([Id])
GO
ALTER TABLE [dbo].[TimeSheets] CHECK CONSTRAINT [FK_TimeSheets_PayPeriod]
GO

ALTER TABLE [dbo].[TradeBoardListRules]  WITH CHECK ADD  CONSTRAINT [FK_TradeBoardListRules_TradeBoardSettings] FOREIGN KEY([TradeBoardSettingsId])
REFERENCES [dbo].[TradeBoardSettings] ([Id])
GO
ALTER TABLE [dbo].[TradeBoardListRules] CHECK CONSTRAINT [FK_TradeBoardListRules_TradeBoardSettings]
GO

