USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_CustomTableValues_GetShortList]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Get short list of custom table values
-- =============================================
CREATE   PROCEDURE [dbo].[usp_CustomTableValues_GetShortList]
    @CustomTableId INT = NULL,
    @TenantId INT,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        v.CustomTableValueID AS id,
        v.CustomTableID AS customTableId,
        t.Name AS customTableName,
        v.Code AS code,
        v.ShortDescription AS shortDescription,
        v.LongDescription AS longDescription,
        v.IsActive AS isActive
    FROM CustomTableValues v
    INNER JOIN CustomTables t ON t.CustomTableID = v.CustomTableID
    WHERE (@CustomTableId IS NULL OR v.CustomTableID = @CustomTableId)
      AND (@IncludeInactive = 1 OR ISNULL(v.IsActive, 1) = 1)
      AND (t.TenantId IS NULL OR t.TenantId = @TenantId)
      AND (v.TenantId IS NULL OR v.TenantId = @TenantId)
    ORDER BY t.Name, v.LongDescription, v.ShortDescription
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO



