namespace MedTrueApi.Models;

public class Company
{
    public int CompanyId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Code { get; set; }
    public string? Address { get; set; }
    public string? ContactNumber { get; set; }
    public bool IsActive { get; set; } = true;
}

public class Salt
{
    public int SaltId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;
}

public class Category
{
    public int CategoryId { get; set; }
    public string Name { get; set; } = string.Empty;
    public int? ParentId { get; set; }
}

public class Unit
{
    public int UnitId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
}

public class HsnCode
{
    public string Code { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal? GstRate { get; set; }
}

public class ItemType
{
    public int TypeId { get; set; }
    public string Name { get; set; } = string.Empty;
}

public class DrugSchedule
{
    public int ScheduleId { get; set; }
    public string Name { get; set; } = string.Empty;
    public bool RequiresPrescription { get; set; } = true;
    public string? WarningLabel { get; set; }
}
