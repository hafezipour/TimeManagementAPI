using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using TimeManagement.Application.DTOs.ShiftTrades;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class ShiftTradesProcessor : BaseProcessor
{
    private readonly ShiftTradesRepository _shiftTradesRepository;

    public ShiftTradesProcessor(ShiftTradesRepository shiftTradesRepository)
    {
        _shiftTradesRepository = shiftTradesRepository;
    }

    /// <summary>
    /// Common method to process requests with ServiceName, MethodName, and JsonData
    /// </summary>
    /// <param name="serviceName">Name of the service</param>
    /// <param name="methodName">Method to execute</param>
    /// <param name="jsonData">JSON string data to be auto-translated to DTO</param>
    /// <returns>Result as JSON string</returns>
    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            return methodName.ToLower() switch
            {
                "sendtraderequest" => await SendTradeRequest(jsonData.FromJson<SendTradeRequest>()),
                _ => new { success = false, message = $"Unknown method: {methodName}" }.ToJson()
            };
        }
        catch (System.Text.Json.JsonException ex)
        {
            throw ex;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Send a trade request (mock implementation)
    /// </summary>
    public async Task<string> SendTradeRequest(SendTradeRequest request)
    {
        try
        {
            // Validate request
            if (request == null)
            {
                return new { success = false, message = "Request is required" }.ToJson();
            }

            if (!request.TradingEmployeeId.HasValue)
            {
                return new { success = false, message = "Trading employee is required" }.ToJson();
            }

            if (!request.TradingShiftId.HasValue)
            {
                return new { success = false, message = "Trading shift is required" }.ToJson();
            }

            if (!request.TradingAssignmentId.HasValue)
            {
                return new { success = false, message = "Trading assignment is required" }.ToJson();
            }

            if (!request.TradingDate.HasValue)
            {
                return new { success = false, message = "Trading date is required" }.ToJson();
            }

            // If it's a swap, validate accepting user fields
            if (request.IsSwap)
            {
                if (!request.AcceptingEmployeeId.HasValue)
                {
                    return new { success = false, message = "Accepting employee is required for swap" }.ToJson();
                }

                if (!request.AcceptingShiftId.HasValue)
                {
                    return new { success = false, message = "Accepting shift is required for swap" }.ToJson();
                }

                if (!request.AcceptingAssignmentId.HasValue)
                {
                    return new { success = false, message = "Accepting assignment is required for swap" }.ToJson();
                }

                if (!request.AcceptingDate.HasValue)
                {
                    return new { success = false, message = "Accepting date is required for swap" }.ToJson();
                }
            }

            // Convert request to JSON for repository
            var jsonData = JsonConvert.SerializeObject(request);

            // Call repository method
            var result = await _shiftTradesRepository.SendTradeRequest(
                jsonData,
                CurrentUser.LoginId,
                CurrentUser.TenantID
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error sending trade request: {ex.Message}" }.ToJson();
        }
    }
}

