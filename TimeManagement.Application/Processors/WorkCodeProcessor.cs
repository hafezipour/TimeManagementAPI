using System.Text.Json;
using Grpc.Core;
using TimeManagement.Application.DTOs;
using TimeManagement.Application.Extensions;

namespace TimeManagement.Application.Processors;

public class WorkCodeProcessor : BaseProcessor
{
    /// <summary>
    /// Common method to process requests with ServiceName, MethodName, and JsonData
    /// </summary>
    /// <param name="serviceName">Name of the service</param>
    /// <param name="methodName">Method to execute (Add, Update, Delete)</param>
    /// <param name="jsonData">JSON string data to be auto-translated to DTO</param>
    /// <param name="context">gRPC ServerCallContext for authentication</param>
    /// <returns>Result as JSON string</returns>
    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData, ServerCallContext? context = null)
    {
        try
        {
            // Authenticate if context is provided
            if (context != null)
            {
                bool isAuthenticated = await AuthenticateRequest(context);
                if (!isAuthenticated)
                {
                    return new { success = false, message = "Unauthorized" }.ToJson();
                }
            }

            var dto = jsonData.FromJson<WorkCodeDto>();

            if (dto == null)
            {
                return new { success = false, message = "Invalid JSON data" }.ToJson();
            }

            return methodName.ToLower() switch
            {
                "add" => await Add(dto),
                "update" => await Update(dto),
                "delete" => await Delete(dto.Id),
                _ => new { success = false, message = $"Unknown method: {methodName}" }.ToJson()
            };
        }
        catch (JsonException ex)
        {
            return new { success = false, message = $"JSON parsing error: {ex.Message}" }.ToJson();
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error processing request: {ex.Message}" }.ToJson();
        }
    }

    /// <summary>
    /// Add a new Work Code
    /// </summary>
    public async Task<string> Add(WorkCodeDto workCodeDto)
    {
        // Mock implementation
        await Task.Delay(10); // Simulate async operation

        // Mock: Generate a new ID
        workCodeDto.Id = new Random().Next(1000, 9999);
        workCodeDto.CreatedDate = DateTime.UtcNow;

        var result = new
        {
            success = true,
            message = "Work Code added successfully",
            data = workCodeDto
        };

        return result.ToJson();
    }

    /// <summary>
    /// Update an existing Work Code
    /// </summary>
    public async Task<string> Update(WorkCodeDto workCodeDto)
    {
        // Mock implementation
        await Task.Delay(10); // Simulate async operation

        workCodeDto.ModifiedDate = DateTime.UtcNow;

        var result = new
        {
            success = true,
            message = $"Work Code with ID {workCodeDto.Id} updated successfully",
            data = workCodeDto
        };

        return result.ToJson();
    }

    /// <summary>
    /// Delete a Work Code by ID
    /// </summary>
    public async Task<string> Delete(int id)
    {
        // Mock implementation
        await Task.Delay(10); // Simulate async operation

        var result = new
        {
            success = true,
            message = $"Work Code with ID {id} deleted successfully",
            deletedId = id
        };

        return result.ToJson();
    }

    /// <summary>
    /// Get Work Code by ID (bonus method)
    /// </summary>
    public async Task<string> GetById(int id)
    {
        // Mock implementation
        await Task.Delay(10); // Simulate async operation

        var mockData = new WorkCodeDto
        {
            Id = id,
            WorkCode = $"WORK-{id}",
            WorkDescription = $"Mock Work Code Description for {id}",
            Category = "General",
            IsActive = true,
            CreatedDate = DateTime.UtcNow.AddDays(-30)
        };

        var result = new
        {
            success = true,
            message = "Work Code retrieved successfully",
            data = mockData
        };

        return result.ToJson();
    }

    /// <summary>
    /// Get all Work Codes (bonus method)
    /// </summary>
    public async Task<string> GetAll()
    {
        // Mock implementation
        await Task.Delay(10); // Simulate async operation

        var mockDataList = new List<WorkCodeDto>
        {
            new WorkCodeDto
            {
                Id = 1,
                WorkCode = "WORK-001",
                WorkDescription = "Regular Work",
                Category = "Standard",
                IsActive = true,
                CreatedDate = DateTime.UtcNow.AddDays(-60)
            },
            new WorkCodeDto
            {
                Id = 2,
                WorkCode = "WORK-002",
                WorkDescription = "Overtime Work",
                Category = "Overtime",
                IsActive = true,
                CreatedDate = DateTime.UtcNow.AddDays(-45)
            }
        };

        var result = new
        {
            success = true,
            message = "Work Codes retrieved successfully",
            data = mockDataList
        };

        return result.ToJson();
    }
}

