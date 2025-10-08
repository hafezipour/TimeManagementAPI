using TimeManagement.Domain.Models;

namespace TimeManagement.Application.Processors;

public abstract class BaseProcessor
{
    public LoggedInUser? CurrentUser { get; set; }
}

