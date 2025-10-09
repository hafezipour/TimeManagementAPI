using System.Text.Json;
using TimeManagement.Application.DTOs;
using TimeManagement.Application.Extensions;

namespace TimeManagement.Application.Processors;

public class HolidayProcessor : BaseProcessor
{
    /// <summary>
    /// Common method to process requests with ServiceName, MethodName, and JsonData
    /// </summary>
    /// <param name="serviceName">Name of the service</param>
    /// <param name="methodName">Method to execute (Add, Update, Delete)</param>
    /// <param name="jsonData">JSON string data to be auto-translated to DTO</param>
    /// <returns>Result as JSON string</returns>
    public async Task<string> ProcessRequest(string serviceName, string methodName, string jsonData)
    {
        try
        {
            var dto = jsonData.FromJson<HolidayDto>();

            if (dto == null)
            {
                return new { success = false, message = "Invalid JSON data" }.ToJson();
            }

            return methodName.ToLower() switch
            {
                "add" => await Add(dto),
                "update" => await Update(dto),
                "delete" => await Delete(dto.Id),
                "getbyid" => await GetById(dto.Id),
                "getall" => await GetAll(),
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
    /// Add a new Holiday
    /// </summary>
    public async Task<string> Add(HolidayDto holidayDto)
    {
        // Mock implementation
        await Task.Delay(10); // Simulate async operation

        // Mock: Generate a new ID
        holidayDto.Id = new Random().Next(1000, 9999);
        holidayDto.CreatedDate = DateTime.UtcNow;

        // Example: Access CurrentUser from BaseProcessor
        // if (CurrentUser != null)
        // {
        //     Console.WriteLine($"User {CurrentUser.UserName} (ID: {CurrentUser.LoginId}) from Tenant {CurrentUser.TenantID} is adding a holiday");
        // }

        var result = new
        {
            success = true,
            message = "Holiday added successfully",
            data = holidayDto,
            // Optional: Include user info in response
            // createdBy = CurrentUser?.UserName
        };

        return result.ToJson();
    }

    /// <summary>
    /// Update an existing Holiday
    /// </summary>
    public async Task<string> Update(HolidayDto holidayDto)
    {
        // Mock implementation
        await Task.Delay(10); // Simulate async operation

        holidayDto.ModifiedDate = DateTime.UtcNow;

        var result = new
        {
            success = true,
            message = $"Holiday with ID {holidayDto.Id} updated successfully",
            data = holidayDto
        };

        return result.ToJson();
    }

    /// <summary>
    /// Delete a Holiday by ID
    /// </summary>
    public async Task<string> Delete(int id)
    {
        // Mock implementation
        await Task.Delay(10); // Simulate async operation

        var result = new
        {
            success = true,
            message = $"Holiday with ID {id} deleted successfully",
            deletedId = id
        };

        return result.ToJson();
    }

    /// <summary>
    /// Get Holiday by ID
    /// </summary>
    public async Task<string> GetById(int id)
    {
        // Mock implementation
        await Task.Delay(10); // Simulate async operation

        var mockData = new HolidayDto
        {
            Id = id,
            HolidayCode = $"HOL-{id}",
            HolidayName = $"Holiday-{id}",
            HolidayDate = DateTime.UtcNow.AddDays(30),
            IsObserved = true,
            IsFloating = false,
            IsAppliesToAll = true,
            CreatedDate = DateTime.UtcNow.AddDays(-30)
        };

        var result = new
        {
            success = true,
            message = "Holiday retrieved successfully",
            data = mockData
        };

        return result.ToJson();
    }

    /// <summary>
    /// Get all Holidays
    /// </summary>
    public async Task<string> GetAll()
    {
        // Mock implementation
        await Task.Delay(10); // Simulate async operation

        var mockDataList = new List<HolidayDto>
        {
            new HolidayDto
            {
                Id = 1,
                HolidayCode = "HOL-NYD",
                HolidayName = "New Year's Day",
                HolidayDate = new DateTime(DateTime.UtcNow.Year, 1, 1),
                IsObserved = true,
                IsFloating = false,
                IsAppliesToAll = true,
                CreatedDate = DateTime.UtcNow.AddDays(-60)
            },
            new HolidayDto
            {
                Id = 2,
                HolidayCode = "HOL-IND",
                HolidayName = "Independence Day",
                HolidayDate = new DateTime(DateTime.UtcNow.Year, 7, 4),
                IsObserved = true,
                IsFloating = false,
                IsAppliesToAll = true,
                CreatedDate = DateTime.UtcNow.AddDays(-45)
            },
            new HolidayDto
            {
                Id = 3,
                HolidayCode = "HOL-XMAS",
                HolidayName = "Christmas Day",
                HolidayDate = new DateTime(DateTime.UtcNow.Year, 12, 25),
                IsObserved = true,
                IsFloating = false,
                IsAppliesToAll = false,
                CreatedDate = DateTime.UtcNow.AddDays(-30)
            }
        };

        var result = new
        {
            success = true,
            message = "Holidays retrieved successfully",
            data = mockDataList
        };

        return result.ToJson();
    }
}

