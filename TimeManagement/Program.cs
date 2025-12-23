using TimeManagement.Application.DependencyInjection;
using TimeManagement.Infra.Extensions;

var builder = WebApplication.CreateBuilder(args);

// Add common Time Management services (processors, repositories, application services)
builder.Services.AddHttpContextAccessor();
builder.Services.AddTimeManagementServices(builder.Configuration);

// Add services to the container.
builder.Services.AddGrpc();

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "Time Management API",
        Version = "v1",
        Description = "API for managing time management operations including shifts, schedules, columns, and layouts",
        Contact = new Microsoft.OpenApi.Models.OpenApiContact
        {
            Name = "Time Management Team"
        }
    });
});

// Add common Time Management logging (log4net and custom logger)
builder.Services.AddTimeManagementLogging(builder.Configuration);

var app = builder.Build();

// Configure ApiContext
ApiContext.Configure(app.Services.GetRequiredService<IHttpContextAccessor>());

// Configure custom logger factory
app.Services.ConfigureTimeManagementLoggerFactory();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger(c =>
    {
    });
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Time Management API v1");
        c.RoutePrefix = "swagger";
    });
}

app.UseHttpsRedirection();

app.UseRouting();

// Map gRPC service BEFORE UseAuthorization
// gRPC services handle authentication/authorization internally via ValidateToken
// This prevents UseAuthorization middleware from blocking gRPC requests
app.MapGrpcService<TimeManagement.Application.Services.HttpGrpcService>()
   .AllowAnonymous();

// Apply authorization only to regular HTTP controllers, not gRPC
app.UseAuthorization();

app.MapControllers();

app.Run();
