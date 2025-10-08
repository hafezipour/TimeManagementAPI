using System.Text.Json;

namespace TimeManagement.Application.Extensions;

public static class JsonExtensions
{
    private static readonly JsonSerializerOptions DefaultOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented = false
    };

    /// <summary>
    /// Serializes an object to JSON string
    /// </summary>
    public static string ToJson(this object obj, JsonSerializerOptions? options = null)
    {
        return JsonSerializer.Serialize(obj, options ?? DefaultOptions);
    }

    /// <summary>
    /// Deserializes JSON string to specified type
    /// </summary>
    public static T? FromJson<T>(this string json, JsonSerializerOptions? options = null)
    {
        return JsonSerializer.Deserialize<T>(json, options ?? DefaultOptions);
    }
}

