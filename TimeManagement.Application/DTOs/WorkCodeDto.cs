namespace TimeManagement.Application.DTOs;

public class WorkCodeDto
{
    public int Id { get; set; }
    public string WorkCode { get; set; } = string.Empty;
    public string WorkDescription { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public DateTime CreatedDate { get; set; }
    public DateTime? ModifiedDate { get; set; }
}

