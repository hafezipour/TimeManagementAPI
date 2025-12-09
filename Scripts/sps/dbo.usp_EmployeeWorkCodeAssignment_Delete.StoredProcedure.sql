USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeWorkCodeAssignment_Delete]    Script Date: 12/8/2025 4:11:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Auto Generated
-- Create date: 12/8/2025
-- Description: Delete Employee Work Code Assignment
-- =============================================
CREATE   PROCEDURE [dbo].[usp_EmployeeWorkCodeAssignment_Delete]
      @Id int,
      @UserId int,
      @TenantId int
  AS
  BEGIN
      SET NOCOUNT ON;
      BEGIN TRY
          BEGIN TRAN

          -- Check if Employee Work Code Assignment exists and is not deleted
          IF EXISTS (SELECT 1 FROM EmployeeWorkCodeAssignment WHERE Id = @Id AND TenantId = @TenantId AND
  ISNULL(IsDeleted, 0) = 0)
          BEGIN
              -- Soft Delete Employee Work Code Assignment
              UPDATE EmployeeWorkCodeAssignment
              SET IsDeleted = 1,
                  DeletedOn = GETUTCDATE(),
                  UpdatedBy = @UserId,
                  DateUpdated = GETUTCDATE()
              WHERE Id = @Id AND TenantId = @TenantId

              SELECT
                  CAST(1 AS bit) as success,
                  'Employee Work Code Assignment deleted successfully' as message,
                  @Id as deletedId
              FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
          END
          ELSE
          BEGIN
              SELECT
                  CAST(0 AS bit) as success,
                  'Employee Work Code Assignment not found or already deleted' as message
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

