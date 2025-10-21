USE [TimeManagement_DEV]
GO

/****** Object:  StoredProcedure [dbo].[usp_InitializeLayouts]    Script Date: 10/21/2025 12:19:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*---------------------=========================================================================================================
CREATED BY			: System
CREATED DATE 		: 10/21/2025
DESCRIPTION			: Initialize default layouts (Daily, Weekly, Monthly) for a tenant if they don't exist
LAST UPDATED BY 	:
DATE LAST UPDATED 	: 
---------------------=========================================================================================================+*/
CREATE PROCEDURE [dbo].[usp_InitializeLayouts]
    @TenantId INT
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
        -- Validate input parameter
        IF @TenantId IS NULL OR @TenantId <= 0
        BEGIN
            RAISERROR('Invalid TenantId parameter. TenantId must be a positive integer.', 16, 1)
            RETURN
        END

        -- Insert all layouts in a single statement
        INSERT INTO [dbo].[Layouts] (
            [TenantId], 
            [LayoutName], 
            [Type], 
            [Description], 
            [CreatedBy], 
            [DateCreated], 
            [UpdatedBy], 
            [DateUpdated], 
            [Rows], 
            [Columns]
        )
        SELECT * 
        FROM 
        (
            SELECT 
                @TenantId as [TenantId],
                'Daily Layout' as [LayoutName],
                1 as [Type], -- 1 for Daily
                'Default daily scheduling layout for staff scheduling' as [Description],
                @TenantId as [CreatedBy], -- Using TenantId as CreatedBy for system initialization
                GETUTCDATE() as [DateCreated],
                NULL as [UpdatedBy],
                NULL as [DateUpdated],
                24 as [Rows], -- 24 hours in a day
                7 as [Columns] -- 7 days in a week
            UNION 
            SELECT 
                @TenantId as [TenantId],
                'Weekly Layout' as [LayoutName],
                2 as [Type], -- 2 for Weekly
                'Default weekly scheduling layout for staff scheduling' as [Description],
                @TenantId as [CreatedBy],
                GETUTCDATE() as [DateCreated],
                NULL as [UpdatedBy],
                NULL as [DateUpdated],
                NULL as [Rows], -- Will be set by user
                NULL as [Columns] -- Will be set by user
            UNION 
            SELECT 
                @TenantId as [TenantId],
                'Monthly Layout' as [LayoutName],
                3 as [Type], -- 3 for Monthly
                'Default monthly scheduling layout for staff scheduling' as [Description],
                @TenantId as [CreatedBy],
                GETUTCDATE() as [DateCreated],
                NULL as [UpdatedBy],
                NULL as [DateUpdated],
                NULL as [Rows], -- Will be set by user
                NULL as [Columns] -- Will be set by user
        ) as X 
        WHERE NOT EXISTS (
            SELECT 1 FROM [dbo].[Layouts] as l 
            WHERE l.[TenantId] = @TenantId 
            AND l.[LayoutName] = X.[LayoutName] 
            AND l.[Type] = X.[Type]
        )

        -- Return success message with count of inserted records
        SELECT 
            'Layouts initialized successfully for TenantId: ' + CAST(@TenantId AS NVARCHAR(10)) as Message,
            @@ROWCOUNT as RecordsInserted

    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END

GO
