namespace TimeManagement.Application.DTOs.AccrualTypes;

public class UpdateAccrualTypeStatusRequest
{
    public int AccrualTypeId { get; set; }
    public bool IsActive { get; set; }
}


