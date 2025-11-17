USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualTypes_Get]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Get Accrual Types
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualTypes_Get]
    @AccrualTypeId INT = NULL,
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.Id AS id,
        a.TypeCode AS typeCode,
        a.TypeName AS typeName,
        a.Description AS description,
        a.CustomTableUnitId AS customTableUnitId,
        unit.CustomTableID AS customTableId,
        unit.LongDescription AS customTableUnitName,
        unit.ShortDescription AS customTableUnitShortName,
        a.IsActive AS isActive,
        a.CreatedBy AS createdBy,
        a.UpdatedBy AS updatedBy,
        a.DateCreated AS dateCreated,
        a.DateUpdated AS dateUpdated
    FROM AccrualTypes a
    LEFT JOIN CustomTableValues unit WITH (NOLOCK) ON unit.CustomTableValueID = a.CustomTableUnitId
    WHERE a.TenantId = @TenantId
      AND (@AccrualTypeId IS NULL OR a.Id = @AccrualTypeId)
    ORDER BY a.TypeName
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO



