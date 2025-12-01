using DbOperations;
using WebPortal.EF.Repository.DataBaseRepo;
using WebPortal.ViewModel;

namespace TimeManagement.Infra.Repositories;

public class AccrualTracksRepository
{
    private readonly EfDbOperationsRepository _dbOperations;

    public AccrualTracksRepository(EfDbOperationsRepository dbOperations)
    {
        _dbOperations = dbOperations;
    }

    public async Task<string> GetAccrualTracks(int? accrualTrackId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "AccrualTrackId", Value = accrualTrackId },
                new SqlParameterModel { Name = "AccrualTrackIdsJson", Value = null },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualTracks_Get", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> GetAccrualTracksByIds(string accrualTrackIdsJson, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "AccrualTrackId", Value = null },
                new SqlParameterModel { Name = "AccrualTrackIdsJson", Value = accrualTrackIdsJson },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualTracks_Get", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> SaveAccrualTrack(string json, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "Json", Value = json },
                new SqlParameterModel { Name = "UserId", Value = userId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualTracks_Save", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    public async Task<string> DeleteAccrualTrack(int accrualTrackId, int userId, int tenantId)
    {
        try
        {
            List<SqlParameterModel> param = new()
            {
                new SqlParameterModel { Name = "AccrualTrackId", Value = accrualTrackId },
                new SqlParameterModel { Name = "UserId", Value = userId },
                new SqlParameterModel { Name = "TenantId", Value = tenantId }
            };

            return await _dbOperations.ExecuteDataSetAsync("usp_AccrualTracks_Delete", param);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}

