using System.Text.Json;

namespace TimeManagement.Application.Extensions;

public static class Extensions
{
    /// <summary>
    /// for nullable structs
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="source"></param>
    /// <returns></returns>
    public static string ToCommaSeparatedString<T>(this IEnumerable<T?> source)
        where T : struct
    {
        if (source == null)
            return string.Empty;

        return string.Join(",", source.Where(x => x.HasValue).Select(x => x.Value));
    }

    /// <summary>
    /// for non-nullable structs
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="source"></param>
    /// <returns></returns>
    public static string ToCommaSeparatedString<T>(this IEnumerable<T> source)
       where T : struct
    {
        if (source == null)
            return string.Empty;

        return string.Join(",", source.Select(x => x));
    }

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

