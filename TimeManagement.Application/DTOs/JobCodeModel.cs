namespace TimeManagement.Application.DTOs;

public class JobCodeModel
{
    public int Id { get; set; }
    public string JobCode { get; set; } = string.Empty;
    public string JobDescription { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public DateTime CreatedDate { get; set; }
    public DateTime? ModifiedDate { get; set; }
}

