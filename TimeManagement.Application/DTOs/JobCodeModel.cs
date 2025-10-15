namespace TimeManagement.Application.DTOs;

/// <summary>
/// Job Code Data Transfer Object - matches database table structure
/// </summary>
public class JobCodeModel
{
    public int Id { get; set; }

    /// <summary>
    /// Job Title (e.g., "Registered Nurse", "Office Manager")
    /// Maps to: DB.JobTitle -> SP.jobTitle
    /// </summary>
    public string JobTitle { get; set; } = string.Empty;

    /// <summary>
    /// Job Code (e.g., "RN-001", "OM-001")
    /// Maps to: DB.JobCode -> SP.code
    /// </summary>
    public string Code { get; set; } = string.Empty;

    /// <summary>
    /// Job Description
    /// Maps to: DB.Description -> SP.description
    /// </summary>
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// Job Category (e.g., "Healthcare", "Administrative")
    /// Maps to: DB.Category -> SP.category
    /// </summary>
    public string Category { get; set; } = string.Empty;

    /// <summary>
    /// Maps to: DB.IsExempt -> SP.isExempt
    /// </summary>
    public bool IsExempt { get; set; }

    /// <summary>
    /// Pay rate per hour
    /// Maps to: DB.PayRate -> SP.payRate
    /// </summary>
    public decimal PayRate { get; set; }

    /// <summary>
    /// Default hours per week for this position
    /// Maps to: DB.DefaultHoursPerWeek -> SP.defaultHoursPerWeek
    /// </summary>
    public decimal DefaultHoursPerWeek { get; set; }

    /// <summary>
    /// Pay multiplier for overtime/special rates
    /// Maps to: DB.PayMultiplier -> SP.payMultiplier
    /// </summary>
    public decimal? PayMultiplier { get; set; }

    /// <summary>
    /// Status (active/inactive) - also mapped as IsActive
    /// Maps to: DB.IsActive -> SP.status
    /// </summary>
    public bool Status { get; set; }

    /// <summary>
    /// Is this job code active?
    /// Maps to: DB.IsActive → SP.isActive
    /// </summary>
    public bool IsActive { get; set; }

    /// <summary>
    /// Tenant ID for multi-tenant support
    /// Maps to: DB.TenantId → SP.tenantId
    /// </summary>
    public int TenantId { get; set; }

    /// <summary>
    /// Created date
    /// Maps to: DB.DateCreated → SP.createdDate
    /// </summary>
    public DateTime CreatedDate { get; set; }

    /// <summary>
    /// Modified date
    /// Maps to: DB.DateUpdated → SP.modifiedDate
    /// </summary>
    public DateTime? ModifiedDate { get; set; }

    /// <summary>
    /// User who created this record
    /// Maps to: DB.CreatedBy → SP.createdBy
    /// </summary>
    public int CreatedBy { get; set; }

    /// <summary>
    /// User who last modified this record
    /// Maps to: DB.UpdatedBy → SP.modifiedBy
    /// </summary>
    public int? ModifiedBy { get; set; }
}

