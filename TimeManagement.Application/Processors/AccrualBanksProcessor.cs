using System.Text.Json;
using System.Text.Json.Serialization;
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

    private async Task<CheckAndCreateBanksResponse> CheckAndCreateBank(List<CheckAndCreateBanksRequest> requests)
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
            var settingsJson = await _employeeAccrualSettingsRepository.GetEmployeeAccrualSettings(request.UserId, CurrentUser.TenantID);

            if (string.IsNullOrEmpty(settingsJson))
            {
                return new { success = false, message = "Employee accrual settings not found." }.ToJson();
            }

            // Parse the settings
            var settings = JsonSerializer.Deserialize<List<JsonElement>>(settingsJson);
            if (settings == null || settings.Count == 0)
            {
                return new { success = false, message = "Employee accrual settings not found." }.ToJson();
            }

            var setting = settings[0];
            var userId = setting.GetProperty("userId").GetInt32();

            int? accrualProfileId = null;
            int? accrualTrackId = null;
            string? accrualStartDate = null;

            if (setting.TryGetProperty("accrualProfileId", out var accrualProfileIdElement))
            {
                if (accrualProfileIdElement.ValueKind != JsonValueKind.Null)
                {
                    accrualProfileId = accrualProfileIdElement.GetInt32();
                }
            }

            if (setting.TryGetProperty("accrualTrackId", out var accrualTrackIdElement))
            {
                if (accrualTrackIdElement.ValueKind != JsonValueKind.Null)
                {
                    accrualTrackId = accrualTrackIdElement.GetInt32();
                }
            }

            if (setting.TryGetProperty("accrualStartDate", out var accrualStartDateElement))
            {
                if (accrualStartDateElement.ValueKind != JsonValueKind.Null)
                {
                    accrualStartDate = accrualStartDateElement.GetString();
                }
            }

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
                        var profiles = JsonSerializer.Deserialize<List<JsonElement>>(profileJson);
                        if (profiles != null && profiles.Count > 0)
                        {
                            var profile = profiles[0];
                            if (profile.TryGetProperty("profileName", out var profileNameElement) && profileNameElement.ValueKind != JsonValueKind.Null)
                            {
                                currentAccrualProfileName = profileNameElement.GetString() ?? string.Empty;
                            }
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
                var (profileId, profileName) = await GetAccrualProfileIdFromTrack(accrualTrackId.Value, accrualStartDate, CurrentUser.TenantID);
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
            var result = await _accrualBanksRepository.GetAccrualBanks(
                userId,
                resolvedAccrualProfileId,
                CurrentUser.TenantID);

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

    private async Task<(int profileId, string profileName)> GetAccrualProfileIdFromTrack(int accrualTrackId, string accrualStartDate, int tenantId)
    {
        try
        {
            // Get the accrual track with profiles
            var trackJson = await _accrualTracksRepository.GetAccrualTracks(accrualTrackId, tenantId);

            if (string.IsNullOrEmpty(trackJson))
            {
                return (0, string.Empty);
            }

            var tracks = JsonSerializer.Deserialize<List<JsonElement>>(trackJson);
            if (tracks == null || tracks.Count == 0)
            {
                return (0, string.Empty);
            }

            var track = tracks[0];
            if (!track.TryGetProperty("profiles", out var profilesElement))
            {
                return (0, string.Empty);
            }

            List<JsonElement> profiles;
            if (profilesElement.ValueKind == JsonValueKind.String)
            {
                // If profiles is a JSON string, parse it
                profiles = JsonSerializer.Deserialize<List<JsonElement>>(profilesElement.GetString() ?? "[]");
            }
            else if (profilesElement.ValueKind == JsonValueKind.Array)
            {
                // If profiles is already an array, use it directly
                profiles = JsonSerializer.Deserialize<List<JsonElement>>(profilesElement.GetRawText());
            }
            else
            {
                return (0, string.Empty);
            }

            if (profiles == null || profiles.Count == 0)
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

            // Find matching profile
            var sortedProfiles = profiles.OrderBy(p =>
            {
                if (p.TryGetProperty("fromYears", out var fromYearsElement) && fromYearsElement.ValueKind != JsonValueKind.Null)
                {
                    return fromYearsElement.GetDecimal();
                }
                return 0;
            }).ToList();

            foreach (var profile in sortedProfiles)
            {
                decimal from = 0;
                decimal? to = null;
                int profileId = 0;
                string profileName = string.Empty;

                if (profile.TryGetProperty("fromYears", out var fromYearsElement) && fromYearsElement.ValueKind != JsonValueKind.Null)
                {
                    from = fromYearsElement.GetDecimal();
                }

                if (profile.TryGetProperty("toYears", out var toYearsElement) && toYearsElement.ValueKind != JsonValueKind.Null)
                {
                    to = toYearsElement.GetDecimal();
                }

                if (profile.TryGetProperty("accrualProfileId", out var profileIdElement) && profileIdElement.ValueKind != JsonValueKind.Null)
                {
                    profileId = profileIdElement.GetInt32();
                }

                if (profile.TryGetProperty("profileName", out var profileNameElement) && profileNameElement.ValueKind != JsonValueKind.Null)
                {
                    profileName = profileNameElement.GetString() ?? string.Empty;
                }

                if (to == null)
                {
                    // No upper limit
                    if (yearsServed >= from)
                    {
                        return (profileId, profileName);
                    }
                }
                else
                {
                    if (yearsServed >= from && yearsServed <= to.Value)
                    {
                        return (profileId, profileName);
                    }
                }
            }

            // If no match, return first profile
            if (sortedProfiles.Count > 0)
            {
                var firstProfile = sortedProfiles[0];
                int firstProfileId = 0;
                string firstNameValue = string.Empty;

                if (firstProfile.TryGetProperty("accrualProfileId", out var firstProfileIdElement) && firstProfileIdElement.ValueKind != JsonValueKind.Null)
                {
                    firstProfileId = firstProfileIdElement.GetInt32();
                }

                if (firstProfile.TryGetProperty("profileName", out var firstNameElement) && firstNameElement.ValueKind != JsonValueKind.Null)
                {
                    firstNameValue = firstNameElement.GetString() ?? string.Empty;
                }

                if (firstProfileId > 0)
                {
                    return (firstProfileId, firstNameValue);
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

