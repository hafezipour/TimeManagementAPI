using DbOperations;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class AccrualProfilesRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public AccrualProfilesRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    public async Task<string> GetAccrualProfiles(int? accrualProfileId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "AccrualProfileId", Value = accrualProfileId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualProfiles_Get", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> SaveAccrualProfile(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "Json", Value = json },
                new SqlParameterModel { Name = "UserId", Value = userId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualProfiles_Save", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> DeleteAccrualProfile(int accrualProfileId, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "AccrualProfileId", Value = accrualProfileId },
                new SqlParameterModel { Name = "UserId", Value = userId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualProfiles_Delete", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> GetAccrualProfilesShortList(int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualProfiles_GetShortList", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Gets accrual profiles by profile IDs and/or track IDs
    /// Returns all profiles that match the provided profile IDs OR belong to the provided track IDs
    /// Returns all profile table columns including: id, profileName, isBaseOnYearsServed, fromYears, toYears, description, createdBy, updatedBy, dateCreated, dateUpdated, tenantId
    /// </summary>
    /// <param name="accrualProfileIdsJson">JSON array of profile IDs (e.g., "[1, 2, 3]") or null</param>
    /// <param name="accrualTrackIdsJson">JSON array of track IDs (e.g., "[1, 2, 3]") or null</param>
    /// <param name="tenantId">Tenant ID</param>
    /// <returns>JSON string containing all matching profiles with all profile table columns</returns>
    public async Task<string> GetAccrualProfilesByProfileOrTrackIds(string? accrualProfileIdsJson, string? accrualTrackIdsJson, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "AccrualProfileIdsJson", Value = accrualProfileIdsJson ?? (object)DBNull.Value },
                new SqlParameterModel { Name = "AccrualTrackIdsJson", Value = accrualTrackIdsJson ?? (object)DBNull.Value },
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualProfiles_GetByProfileOrTrackIds", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

