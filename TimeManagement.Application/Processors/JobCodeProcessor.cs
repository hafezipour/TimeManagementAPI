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
    /// <param name="methodName">Method to execute (GetAll, GetShortList, Add, Update, Delete)</param>
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

            if (methodName.ToLower() == "getall")
            {
                return await GetJobCodes();
            }

            if (methodName.ToLower() == "getbyid")
            {
                var idDto = jsonData.FromJson<JobCodeModel>();
                if (idDto?.Id > 0)
                {
                    var result =  await GetById(idDto.Id);
                    return result;
                }
                return new { success = false, message = "Invalid ID" }.ToJson();
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
            throw ex;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }

    /// <summary>
    /// Add a new Job Code
    /// </summary>
    public async Task<string> Add(JobCodeModel jobCodeDto)
    {
        try
        {
            // Set tenant and user info from current user
            jobCodeDto.TenantId = CurrentUser.TenantID;
            jobCodeDto.CreatedBy = CurrentUser.LoginId;
        jobCodeDto.CreatedDate = DateTime.UtcNow;

            // Call repository to add job code
            var result = await _jobCodesRepository.AddJobCode(
                jobCodeDto.JobTitle,
                jobCodeDto.Code,
                jobCodeDto.Description,
                jobCodeDto.Category,
                jobCodeDto.IsExempt,
                jobCodeDto.PayRate,
                jobCodeDto.DefaultHoursPerWeek,
                jobCodeDto.IsActive,
                jobCodeDto.TenantId,
                jobCodeDto.CreatedBy
            );

            return result;
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error adding job code: {ex.Message}" }.ToJson();
    }
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
    /// Get Job Code by ID
    /// </summary>
    public async Task<string> GetById(int id)
    {
        try
        {
            return await _jobCodesRepository.GetJobCodeById(id, CurrentUser.TenantID);
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving job code: {ex.Message}" }.ToJson();
        }
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
                Code = "JOB-001",
                JobTitle = "Developer",
                Description = "Development",
                IsActive = true,
                CreatedDate = DateTime.UtcNow.AddDays(-60)
            },
            new JobCodeModel
            {
                Id = 2,
                Code = "JOB-002",
                JobTitle = "Tester",
                Description = "Testing",
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

    /// <summary>
    /// Get all JobCodes
    /// </summary>
    public async Task<string> GetJobCodes()
    {
        try
        {
            return await _jobCodesRepository.GetJobCodes(CurrentUser.TenantID);
        }
        catch (Exception ex)
        {
            return new { success = false, message = $"Error retrieving job codes: {ex.Message}" }.ToJson();
        }
    }
}

