USE [StaffScheduling_DEV]
GO

/****** Object:  StoredProcedure [dbo].[usp_ShiftTrades_GetTradeRequests]    Script Date: 12/17/2025 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================  
-- Author:      Auto Generated
-- Create date: 2025-12-17  
-- Description: Get trade requests with server-side paging
-- =============================================  
CREATE OR ALTER PROCEDURE [dbo].[usp_ShiftTrades_GetTradeRequests]
    @UserId INT = NULL,
    @StatusCustomTableValueId INT = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(50) = 'DateCreated',
    @SortDirection NVARCHAR(4) = 'DESC',
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    ;WITH _rows AS (
        SELECT 
            st.Id AS id,
            st.FromUserId AS fromUserId,
            st.ToUserId AS toUserId,
            st.FromAssignmentId AS fromAssignmentId,
            st.ToAssignmentId AS toAssignmentId,
            st.StatusCustomTableValueId AS statusCustomTableValueId,
            st.RequestedAt AS requestedAt,
            st.ApprovedAt AS approvedAt,
            st.DateCreated AS dateCreated,
            ISNULL(saFrom.IsSwap, saTo.IsSwap) AS isSwap,
            -- From Assignment Schedule Fields
            fs.StartFrom AS fromScheduleStartFrom,
            fs.StartTime AS fromScheduleStartTime,
            fs.ValidUntil AS fromScheduleValidUntil,
            fs.EndTime AS fromScheduleEndTime,
            -- To Assignment Schedule Fields
            ts.StartFrom AS toScheduleStartFrom,
            ts.StartTime AS toScheduleStartTime,
            ts.ValidUntil AS toScheduleValidUntil,
            ts.EndTime AS toScheduleEndTime
        FROM ShiftTrades st
        LEFT JOIN ShiftAssignment saFrom ON saFrom.Id = st.FromAssignmentId AND saFrom.TenantId = @TenantId
        LEFT JOIN ShiftAssignment saTo ON saTo.Id = st.ToAssignmentId AND saTo.TenantId = @TenantId
        LEFT JOIN Schedules fs ON fs.SourceId = st.FromAssignmentId 
            AND fs.SourceType = 3 -- ShiftAssignment
            AND fs.TenantId = @TenantId
        LEFT JOIN Schedules ts ON ts.SourceId = st.ToAssignmentId 
            AND ts.SourceType = 3 -- ShiftAssignment
            AND ts.TenantId = @TenantId
        WHERE st.TenantId = @TenantId
            AND (@UserId IS NULL OR st.FromUserId = @UserId OR st.ToUserId = @UserId)
            AND (@StatusCustomTableValueId IS NULL OR st.StatusCustomTableValueId = @StatusCustomTableValueId)
    )
    SELECT 
        _rows.id,
        _rows.fromUserId,
        _rows.toUserId,
        _rows.fromAssignmentId,
        _rows.toAssignmentId,
        _rows.statusCustomTableValueId,
        _rows.requestedAt,
        _rows.approvedAt,
        _rows.dateCreated,
        _rows.isSwap,
        _rows.fromScheduleStartFrom,
        _rows.fromScheduleStartTime,
        _rows.fromScheduleValidUntil,
        _rows.fromScheduleEndTime,
        _rows.toScheduleStartFrom,
        _rows.toScheduleStartTime,
        _rows.toScheduleValidUntil,
        _rows.toScheduleEndTime,
        (SELECT COUNT(_rows.id) FROM _rows) AS totalCount
    FROM _rows
    ORDER BY 
        CASE WHEN @SortColumn = 'Id' AND @SortDirection = 'ASC' THEN _rows.id END ASC,
        CASE WHEN @SortColumn = 'Id' AND @SortDirection = 'DESC' THEN _rows.id END DESC,
        CASE WHEN @SortColumn = 'DateCreated' AND @SortDirection = 'ASC' THEN _rows.dateCreated END ASC,
        CASE WHEN @SortColumn = 'DateCreated' AND @SortDirection = 'DESC' THEN _rows.dateCreated END DESC,
        _rows.dateCreated DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
GO
