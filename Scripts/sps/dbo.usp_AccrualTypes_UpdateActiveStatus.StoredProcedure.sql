USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualTypes_UpdateActiveStatus]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Update active flag for Accrual Type
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualTypes_UpdateActiveStatus]
    @AccrualTypeId INT,
    @IsActive BIT,
    @UserId INT,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE AccrualTypes
    SET
        IsActive = @IsActive,
        UpdatedBy = @UserId,
        DateUpdated = SYSUTCDATETIME()
    WHERE Id = @AccrualTypeId
      AND TenantId = @TenantId;

    IF @@ROWCOUNT = 0
    BEGIN
        SELECT
            CAST(0 AS BIT) AS success,
            'Accrual type not found.' AS message
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
        RETURN;
    END

    SELECT
        CAST(1 AS BIT) AS success,
        CONCAT('Accrual type ', CASE WHEN @IsActive = 1 THEN 'activated' ELSE 'deactivated' END, ' successfully.') AS message
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO



