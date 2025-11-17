USE [TimeManagement_DEV]
GO
/****** Object:  StoredProcedure [dbo].[usp_AccrualTypes_GetShortList]    Script Date: 11/14/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      TimeManagement API
-- Create date: 11/14/2025
-- Description: Get short list of Accrual Types
-- =============================================
CREATE   PROCEDURE [dbo].[usp_AccrualTypes_GetShortList]
    @TenantId INT,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.Id AS id,
        a.TypeCode AS typeCode,
        a.TypeName AS typeName
    FROM AccrualTypes a
    WHERE a.TenantId = @TenantId
      AND (@IncludeInactive = 1 OR ISNULL(a.IsActive, 1) = 1)
    ORDER BY a.TypeName
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO

