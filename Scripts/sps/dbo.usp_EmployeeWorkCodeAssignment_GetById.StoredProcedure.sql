USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeWorkCodeAssignment_GetById]    Script Date: 12/8/2025 4:11:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*---------------------=========================================================================================================
CREATED BY			: Auto Generated
CREATED DATE 		: 12/8/2025
DESCRIPTION			: Get Employee Work Code Assignment by Id
PROCEDURE NAME		: usp_EmployeeWorkCodeAssignment_GetById
LAST UPDATED BY 	:
DATE LAST UPDATED 	:
EXEC [usp_EmployeeWorkCodeAssignment_GetById] 0, 0
---------------------=========================================================================================================+*/
CREATE   PROCEDURE [dbo].[usp_EmployeeWorkCodeAssignment_GetById]
(
    @Id int,
    @TenantId int
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ewca.Id as id,
        ewca.WorkCodeId as workCodeId,
        ewca.UserId as userId,
        ewca.IsActive as isActive,
        ewca.EffectiveDate as effectiveDate,
        ewca.ExpiryDate as expiryDate,
        ewca.CreatedBy as createdBy,
        ewca.UpdatedBy as updatedBy,
        ewca.DateCreated as dateCreated,
        ewca.DateUpdated as dateUpdated,
        wc.WorkCode as workCode,
        wc.WorkCodeName as workCodeName,
        wc.ColorCode as colorCode
    FROM EmployeeWorkCodeAssignment ewca
    LEFT JOIN WorkCodes wc ON ewca.WorkCodeId = wc.Id AND wc.TenantId = @TenantId
    WHERE ewca.Id = @Id
        AND ewca.TenantId = @TenantId
        AND ISNULL(ewca.IsActive, 1) = 1
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
END
GO

