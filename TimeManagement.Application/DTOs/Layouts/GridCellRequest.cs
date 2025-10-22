using System.Text.Json.Serialization;

namespace TimeManagement.Application.DTOs.Layouts;

/// <summary>
/// Request model for saving grid cell data
/// </summary>
public class GridCellRequest
{
    /// <summary>
    /// Row number in the grid
    /// </summary>
    [JsonPropertyName("rowNumber")]
    public int RowNumber { get; set; }

    /// <summary>
    /// Column number in the grid
    /// </summary>
    [JsonPropertyName("columnNumber")]
    public int ColumnNumber { get; set; }

    /// <summary>
    /// List of columns assigned to this grid cell
    /// </summary>
    [JsonPropertyName("columns")]
    public List<GridCellColumn> Columns { get; set; } = new();
}

/// <summary>
/// Column data within a grid cell
/// </summary>
public class GridCellColumn
{
    /// <summary>
    /// Column ID
    /// </summary>
    [JsonPropertyName("id")]
    public int Id { get; set; }

    /// <summary>
    /// Column name
    /// </summary>
    [JsonPropertyName("columnName")]
    public string ColumnName { get; set; } = string.Empty;

    /// <summary>
    /// Background color of the column
    /// </summary>
    [JsonPropertyName("backgroundColor")]
    public string BackgroundColor { get; set; } = string.Empty;

    /// <summary>
    /// Display order within the grid cell
    /// </summary>
    [JsonPropertyName("displayOrder")]
    public int DisplayOrder { get; set; }
}

/// <summary>
/// Request model for saving multiple grid cells
/// </summary>
public class SaveGridCellsRequest
{
    /// <summary>
    /// Layout ID
    /// </summary>
    [JsonPropertyName("layoutId")]
    public int LayoutId { get; set; }

    /// <summary>
    /// List of grid cells to save
    /// </summary>
    [JsonPropertyName("gridCells")]
    public List<GridCellRequest> GridCells { get; set; } = new();
}
