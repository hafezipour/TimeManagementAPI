USE [TimeManagement_DEV]
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [FK_EmployeeShiftAssignmentWorkCodes_ShiftAssignment] FOREIGN KEY([ShiftAssignmentId])
    REFERENCES [dbo].[ShiftAssignment] ([Id])
    ON DELETE CASCADE,
 CONSTRAINT [FK_EmployeeShiftAssignmentWorkCodes_WorkCodes] FOREIGN KEY([WorkCodeId])
    REFERENCES [dbo].[WorkCodes] ([Id])
    ON DELETE NO ACTION
) ON [PRIMARY]
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [FK_EmployeeShiftAssignmentJobCodes_ShiftAssignment] FOREIGN KEY([ShiftAssignmentId])
    REFERENCES [dbo].[ShiftAssignment] ([Id])
    ON DELETE CASCADE,
 CONSTRAINT [FK_EmployeeShiftAssignmentJobCodes_JobCodes] FOREIGN KEY([JobCodeId])
    REFERENCES [dbo].[JobCodes] ([Id])
    ON DELETE NO ACTION
) ON [PRIMARY]
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [FK_EmployeeShiftAssignmentLabels_ShiftAssignment] FOREIGN KEY([ShiftAssignmentId])
    REFERENCES [dbo].[ShiftAssignment] ([Id])
    ON DELETE CASCADE,
 CONSTRAINT [FK_EmployeeShiftAssignmentLabels_Labels] FOREIGN KEY([LabelId])
    REFERENCES [dbo].[Labels] ([Id])
    ON DELETE NO ACTION
) ON [PRIMARY]
GO

