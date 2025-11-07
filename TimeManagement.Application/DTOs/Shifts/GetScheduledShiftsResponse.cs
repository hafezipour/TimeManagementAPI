using System.ComponentModel.DataAnnotations;
using TimeManagement.Domain.Models;

namespace TimeManagement.Application.DTOs.Shifts;

public class GetScheduledShiftsResponse
{
    public bool Success { get; set; }
    public string Message { get; set; }
    public List<int> UserIds { get; set; }
    public List<CalendarDay> Data { get; set; }
    public List<Column> Columns { get; set; }
}
























