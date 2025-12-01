using System.Text.Json;
using System.Text.Json.Serialization;
using TimeManagement.Application.DTOs.AccrualProfiles;
using TimeManagement.Application.DTOs.AccrualTracks;
using TimeManagement.Application.DTOs.EmployeeAccrualSettings;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class AccrualBanksProcessor : BaseProcessor
{
    private readonly AccrualBanksRepository _accrualBanksRepository;
    private readonly EmployeeAccrualSettingsRepository _employeeAccrualSettingsRepository;
    private readonly AccrualTracksRepository _accrualTracksRepository;
    private readonly AccrualProfilesRepository _accrualProfilesRepository;
    private readonly AccrualTransactionsProcessor _accrualTransactionsProcessor;

    private static readonly JsonSerializerOptions JsonOptions = new JsonSerializerOptions
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        PropertyNameCaseInsensitive = true
    };

    public AccrualBanksProcessor(
        AccrualBanksRepository accrualBanksRepository,
        EmployeeAccrualSettingsRepository employeeAccrualSettingsRepository,
        AccrualTracksRepository accrualTracksRepository,
        AccrualProfilesRepository accrualProfilesRepository,
        AccrualTransactionsProcessor accrualTransactionsProcessor)
    {
        _accrualBanksRepository = accrualBanksRepository;
        _employeeAccrualSettingsRepository = employeeAccrualSettingsRepository;
        _accrualTracksRepository = accrualTracksRepository;
        _accrualProfilesRepository = accrualProfilesRepository;
        _accrualTransactionsProcessor = accrualTransactionsProcessor;
    }

    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "adjustbalance" => await AdjustBalance(jsonData.FromJson<AdjustBalanceRequest>()),
                "getaccrualbanks" => await GetAccrualBanks(jsonData.FromJson<GetAccrualBanksRequest>()),
                _ => new { success = false, message = $"Unknown method: {methodName}" }.ToJson()
            };
        }
        catch (JsonException ex)
        {
            throw ex;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    #region Balance Adjustments

    private async Task<string> AdjustBalance(AdjustBalanceRequest? request)
    {
        // Step 1: Check and create bank if needed
        var checkRequest = new CheckAndCreateBanksRequest
        {
            UserId = request!.UserId!.Value,
            AccrualProfileId = request.AccrualProfileId ?? 0,
            AccrualTrackId = request.AccrualTrackId,
            AccrualTypeId = request.AccrualTypeId ?? 0,
            AccrualRuleId = request.AccrualRuleId,
            AccrualRulesSlotId = request.AccrualRuleSlotId
        };

        var bankInfo = await CheckAndCreateBank(new List<CheckAndCreateBanksRequest> { checkRequest });

        // Step 2: Update balances
        var updateRequest = new UpdateBalancesRequest
        {
            BankId = bankInfo.BankId,
            UserId = request.UserId.Value,
            AccrualProfileId = request.AccrualProfileId ?? 0,
            AccrualRulesSlotId = request.AccrualRuleSlotId,
            CurrentBalance = bankInfo.CurrentBalance,
            Operator = request.Operator,
            AdjustmentAmount = request.Balance,
            Notes = request.Notes
        };

        var updateResult = await UpdateBalance(new List<UpdateBalancesRequest> { updateRequest });

        // Deserialize update result to get the response
        var updateResponses = JsonSerializer.Deserialize<List<UpdateBalancesResponse>>(updateResult, JsonOptions);
        var updateResponse = updateResponses![0];

        // Step 3: Log transaction
        var logRequest = new LogTransactionsRequest
        {
            BankId = updateResponse.BankId,
            UserId = updateResponse.UserId,
            AccrualProfileId = updateResponse.AccrualProfileId,
            AccrualRulesSlotId = updateResponse.AccrualRulesSlotId,
            OldBalance = updateResponse.OldBalance,
            NewBalance = updateResponse.NewBalance,
            Operator = updateResponse.Operator,
            AdjustmentAmount = updateResponse.AdjustmentAmount,
            Notes = updateResponse.Notes
        };

        _accrualTransactionsProcessor.SetCurrentUser(CurrentUser);
        var logResult = await _accrualTransactionsProcessor.LogTransactions(new List<LogTransactionsRequest> { logRequest });

        return logResult;
    }

    public async Task<CheckAndCreateBanksResponse> CheckAndCreateBank(List<CheckAndCreateBanksRequest> requests)
    {
        var json = requests.ToJson();
        var result = await _accrualBanksRepository.CheckAndCreateBanks(
            json,
            CurrentUser.LoginId,
            CurrentUser.TenantID);

        var checkData = JsonSerializer.Deserialize<List<CheckAndCreateBanksResponse>>(result, JsonOptions);
        return checkData![0];
    }

    private async Task<string> UpdateBalance(List<UpdateBalancesRequest> requests)
    {
        var json = requests.ToJson();
        return await _accrualBanksRepository.UpdateBalances(
            json,
            CurrentUser.LoginId,
            CurrentUser.TenantID);
    }

    #endregion

    #region Get Employee Accrual Banks

    private async Task<string> GetAccrualBanks(GetAccrualBanksRequest? request)
    {
        try
        {
            if (request == null || request.UserId <= 0)
            {
                return new { success = false, message = "User Id is required." }.ToJson();
            }

            // Step 1: Get EmployeeAccrualSettings by UserId
            var settingsJson = await _employeeAccrualSettingsRepository.GetEmployeeAccrualSettings(request.UserId, CurrentUser.TenantID.ToString());

            if (string.IsNullOrEmpty(settingsJson))
            {
                return new { success = false, message = "Employee accrual settings not found." }.ToJson();
            }

            // Deserialize the settings
            var settings = JsonSerializer.Deserialize<List<EmployeeAccrualSettingsResponse>>(settingsJson, JsonOptions);
            if (settings == null || settings.Count == 0)
            {
                return new { success = false, message = "Employee accrual settings not found." }.ToJson();
            }

            var setting = settings[0];
            var userId = setting.UserId;
            var accrualProfileId = setting.AccrualProfileId;
            var accrualTrackId = setting.AccrualTrackId;
            var accrualStartDate = setting.AccrualStartDate?.ToString("yyyy-MM-dd");

            int resolvedAccrualProfileId = 0;
            string currentAccrualProfileName = string.Empty;
            int? resolvedAccrualTrackId = null;

            // Method 1: If accrualProfileId exists directly, use it
            if (accrualProfileId.HasValue && accrualProfileId.Value > 0)
            {
                resolvedAccrualProfileId = accrualProfileId.Value;
                // Get profile name
                try
                {
                    var profileJson = await _accrualProfilesRepository.GetAccrualProfiles(resolvedAccrualProfileId, CurrentUser.TenantID);
                    if (!string.IsNullOrEmpty(profileJson))
                    {
                        var profiles = JsonSerializer.Deserialize<List<AccrualProfileResponse>>(profileJson, JsonOptions);
                        if (profiles != null && profiles.Count > 0)
                        {
                            currentAccrualProfileName = profiles[0].ProfileName ?? string.Empty;
                        }
                    }
                }
                catch
                {
                    // If profile name cannot be retrieved, continue with empty string
                    currentAccrualProfileName = string.Empty;
                }
            }
            // Method 2: If accrualTrackId exists, get the track and find matching profile
            else if (accrualTrackId.HasValue && accrualTrackId.Value > 0 && !string.IsNullOrEmpty(accrualStartDate))
            {
                var trackJson = await _accrualTracksRepository.GetAccrualTracks(accrualTrackId, CurrentUser.TenantID);
                var tracks = JsonSerializer.Deserialize<List<AccrualTrackResponse>>(trackJson, JsonOptions);
                var (profileId, profileName) = await GetAccrualProfileIdFromTrack(tracks[0], accrualTrackId.Value, accrualStartDate, CurrentUser.TenantID);
                if (profileId <= 0)
                {
                    return new { success = false, message = "Unable to determine accrual profile from track." }.ToJson();
                }
                resolvedAccrualProfileId = profileId;
                currentAccrualProfileName = profileName;
                resolvedAccrualTrackId = accrualTrackId.Value; // Store track ID when profile comes from track
            }
            else
            {
                return new { success = false, message = "Unable to determine accrual profile. Please check accrual settings." }.ToJson();
            }

            // Step 2: Get Accrual Banks with resolved profile ID
            var result = await _accrualBanksRepository.GetAccrualBanks(userId, resolvedAccrualProfileId, CurrentUser.TenantID);

            // Parse the result to return as part of response
            var banksData = JsonSerializer.Deserialize<object>(result);
            return new
            {
                result = banksData,
                currentAccrualProfileId = resolvedAccrualProfileId,
                currentAccrualProfileName = currentAccrualProfileName,
                currentAccrualTrackId = resolvedAccrualTrackId
            }.ToJson();
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving accrual banks: {ex.Message}" }.ToJson();
        }
    }

    private async Task<(int profileId, string profileName)> GetAccrualProfileIdFromTrack(AccrualTrackResponse track, int accrualTrackId, string accrualStartDate, int tenantId)
    {
        try
        {
            List<AccrualTrackProfileResponse> profiles;
            if (string.IsNullOrEmpty(track.Profiles))
            {
                return (0, string.Empty);
            }

            profiles = JsonSerializer.Deserialize<List<AccrualTrackProfileResponse>>(track.Profiles, JsonOptions)
                ?? new List<AccrualTrackProfileResponse>();

            if (profiles.Count == 0)
            {
                return (0, string.Empty);
            }

            // Calculate years served
            var startDate = DateTime.Parse(accrualStartDate);
            var now = DateTime.UtcNow;
            var yearsServed = now.Year - startDate.Year;
            if (now.Month < startDate.Month || (now.Month == startDate.Month && now.Day < startDate.Day))
            {
                yearsServed--;
            }
            yearsServed = Math.Max(0, yearsServed);

            // Find matching profile - sort by FromYears
            var sortedProfiles = profiles
                .OrderBy(p => p.FromYears ?? 0)
                .ToList();

            foreach (var profile in sortedProfiles)
            {
                var from = profile.FromYears ?? 0;
                var to = profile.ToYears;

                if (to == null)
                {
                    // No upper limit
                    if (yearsServed >= from)
                    {
                        return (profile.AccrualProfileId, profile.ProfileName ?? string.Empty);
                    }
                }
                else
                {
                    if (yearsServed >= from && yearsServed <= to.Value)
                    {
                        return (profile.AccrualProfileId, profile.ProfileName ?? string.Empty);
                    }
                }
            }

            // If no match, return first profile
            if (sortedProfiles.Count > 0)
            {
                var firstProfile = sortedProfiles[0];
                if (firstProfile.AccrualProfileId > 0)
                {
                    return (firstProfile.AccrualProfileId, firstProfile.ProfileName ?? string.Empty);
                }
            }

            return (0, string.Empty);
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }


    #endregion

}

