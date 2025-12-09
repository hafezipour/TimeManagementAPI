USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeWorkCodeAssignment_Save]    Script Date: 12/8/2025 4:11:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Auto Generated
-- Create date: 12/8/2025
-- Update date: 12/8/2025
-- Update by: Auto Generated 
-- Description: Save (Insert/Update) Employee Work Code Assignment
-- =============================================
CREATE   PROCEDURE [dbo].[usp_EmployeeWorkCodeAssignment_Save]
    @Json varchar(max),
    @UserId int,
    @TenantId int
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN

        DECLARE @Id int
        DECLARE @WorkCodeId int
        DECLARE @AssignmentUserId int
        DECLARE @IsActive bit
        DECLARE @EffectiveDate datetimeoffset(7)
        DECLARE @ExpiryDate datetimeoffset(7)

        -- Parse JSON
        SELECT
            @Id = id,
            @WorkCodeId = workCodeId,
            @AssignmentUserId = userId,
            @IsActive = isActive,
            @EffectiveDate = effectiveDate,
            @ExpiryDate = expiryDate
        FROM OPENJSON(@Json) WITH (
            id int,
            workCodeId int,
            userId int,
            isActive bit,
            effectiveDate datetimeoffset(7),
            expiryDate datetimeoffset(7)
        )

        -- Validate required fields
        IF @WorkCodeId IS NULL OR @WorkCodeId = 0
        BEGIN
            SELECT
                CAST(0 AS bit) as success,
                'Work Code is required' as message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ROLLBACK TRAN
            RETURN
        END

        IF @AssignmentUserId IS NULL OR @AssignmentUserId = 0
        BEGIN
            SELECT
                CAST(0 AS bit) as success,
                'Employee is required' as message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ROLLBACK TRAN
            RETURN
        END


        -- Check if Employee Work Code Assignment exists
        IF EXISTS (SELECT 1 FROM EmployeeWorkCodeAssignment WHERE Id = @Id AND TenantId = @TenantId)
        BEGIN
            -- Update existing Employee Work Code Assignment
            UPDATE EmployeeWorkCodeAssignment SET
                WorkCodeId = @WorkCodeId,
                UserId = @AssignmentUserId,
                IsActive = ISNULL(@IsActive, 1),
                ExpiryDate = @ExpiryDate,
                UpdatedBy = @UserId,
                DateUpdated = GETUTCDATE()
            WHERE Id = @Id AND TenantId = @TenantId

            SELECT
                @Id as id,
                CAST(1 AS bit) as success,
                'Employee Work Code Assignment updated successfully' as message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        END
        ELSE
        BEGIN
            -- Insert new Employee Work Code Assignment
            INSERT INTO EmployeeWorkCodeAssignment (
                TenantId,
                WorkCodeId,
                UserId,
                IsActive,
                EffectiveDate,
                ExpiryDate,
                CreatedBy,
                DateCreated
            )
            VALUES (
                @TenantId,
                @WorkCodeId,
                @AssignmentUserId,
                ISNULL(@IsActive, 1),
                GETUTCDATE(),
                @ExpiryDate,
                @UserId,
                GETUTCDATE()
            )

            SET @Id = SCOPE_IDENTITY()

            SELECT
                @Id as id,
                CAST(1 AS bit) as success,
                'Employee Work Code Assignment created successfully' as message
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        END

        COMMIT TRAN
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN

        SELECT
            CAST(0 AS bit) as success,
            ERROR_MESSAGE() as message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    END CATCH
END
GO

