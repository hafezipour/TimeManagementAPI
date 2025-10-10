using System.Text.Json;
using TimeManagement.Application.DTOs;
using TimeManagement.Application.Extensions;
using TimeManagement.Infra.Repositories;

namespace TimeManagement.Application.Processors;

public class JobCodeProcessor : BaseProcessor
{
    private readonly JobCodesRepository _jobCodesRepository;

    public JobCodeProcessor(JobCodesRepository jobCodesRepository)
    {
        _jobCodesRepository = jobCodesRepository;
    }

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
            // Handle methods that don't require JSON data
            if (methodName.ToLower() == "getshortlist")
            {
                return await GetJobCodesShortList();
            }

            var dto = jsonData.FromJson<JobCodeModel>();

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
    /// Add a new Job Code
    /// </summary>
    public async Task<string> Add(JobCodeModel jobCodeDto)
    {
        // Mock implementation
       

        // Mock: Generate a new ID
        jobCodeDto.Id = new Random().Next(1000, 9999);
        jobCodeDto.CreatedDate = DateTime.UtcNow;

        // Example: Access CurrentUser from BaseProcessor
        // if (CurrentUser != null)
        // {
        //     Console.WriteLine($"User {CurrentUser.UserName} (ID: {CurrentUser.LoginId}) from Tenant {CurrentUser.TenantID} is adding a job code");
        // }

        var result = new
        {
            success = true,
            message = "Job Code added successfully",
            data = jobCodeDto,
            // Optional: Include user info in response
            // createdBy = CurrentUser?.UserName
        };

        return result.ToJson();
    }

    /// <summary>
    /// Update an existing Job Code
    /// </summary>
    public async Task<string> Update(JobCodeModel jobCodeDto)
    {
        // Mock implementation
        await Task.Delay(10); // Simulate async operation

        jobCodeDto.ModifiedDate = DateTime.UtcNow;

        var result = new
        {
            success = true,
            message = $"Job Code with ID {jobCodeDto.Id} updated successfully",
            data = jobCodeDto
        };

        return result.ToJson();
    }

    /// <summary>
    /// Delete a Job Code by ID
    /// </summary>
    public async Task<string> Delete(int id)
    {
        // Mock implementation
        await Task.Delay(10); // Simulate async operation

        var result = new
        {
            success = true,
            message = $"Job Code with ID {id} deleted successfully",
            deletedId = id
        };

        return result.ToJson();
    }

    /// <summary>
    /// Get Job Code by ID (bonus method)
    /// </summary>
    public async Task<string> GetById(int id)
    {
        // Mock implementation
        await Task.Delay(10); // Simulate async operation

        var mockData = new JobCodeModel
        {
            Id = id,
            JobCode = $"JOB-{id}",
            JobDescription = $"Mock Job Code Description for {id}",
            IsActive = true,
            CreatedDate = DateTime.UtcNow.AddDays(-30)
        };

        var result = new
        {
            success = true,
            message = "Job Code retrieved successfully",
            data = mockData
        };

        return result.ToJson();
    }

    /// <summary>
    /// Get all Job Codes (bonus method)
    /// </summary>
    public async Task<string> GetAll()
    {
        // Mock implementation
        await Task.Delay(10); // Simulate async operation

        var mockDataList = new List<JobCodeModel>
        {
            new JobCodeModel
            {
                Id = 1,
                JobCode = "JOB-001",
                JobDescription = "Development",
                IsActive = true,
                CreatedDate = DateTime.UtcNow.AddDays(-60)
            },
            new JobCodeModel
            {
                Id = 2,
                JobCode = "JOB-002",
                JobDescription = "Testing",
                IsActive = true,
                CreatedDate = DateTime.UtcNow.AddDays(-45)
            }
        };

        var result = new
        {
            success = true,
            message = "Job Codes retrieved successfully",
            data = mockDataList
        };

        return result.ToJson();
    }

    /// <summary>
    /// Get JobCodes Short List for dropdowns/lookups
    /// </summary>
    public async Task<string> GetJobCodesShortList()
    {
        try
        {
            var result = await _jobCodesRepository.GetJobCodesShortList(CurrentUser.TenantID);

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving job codes short list: {ex.Message}" }.ToJson();
        }
    }
}

