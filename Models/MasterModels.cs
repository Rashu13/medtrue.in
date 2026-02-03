namespace MedTrueApi.Models;

public class Company
{
    public int CompanyId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Code { get; set; }
    public string? Address { get; set; }
    public string? ContactNumber { get; set; }
    public bool IsActive { get; set; } = true;

    // Extended Details from Legacy UI
    public int? PreferenceOrderForm { get; set; }
    public int? PreferenceInvoicePrinting { get; set; }
    public int? DumpDays { get; set; }
    public int? ExpiryReceiveUpto { get; set; }
    public decimal? MinimumMargin { get; set; }
    public decimal? SalesTax { get; set; }
    public decimal? SalesCess { get; set; }
    public decimal? PurchaseTax { get; set; }
    public decimal? PurchaseCess { get; set; }
}

public class Salt
{
    public int SaltId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; } // Can serve as 'Note'
    public bool IsActive { get; set; } = true;

    // Extended Details from UI
    public string? Indications { get; set; }
    public string? Dosage { get; set; }
    public string? SideEffects { get; set; }
    public string? SpecialPrecautions { get; set; }
    public string? DrugInteractions { get; set; }
    public bool IsNarcotic { get; set; }
    public bool IsScheduleH { get; set; }
    public bool IsScheduleH1 { get; set; }
    public string? Type { get; set; } // Normal, etc.
    public decimal? MaximumRate { get; set; }
    public bool IsContinued { get; set; } = true;
    public bool IsProhibited { get; set; } = false;
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
    public string HsnSac { get; set; } = string.Empty; // Primary Key
    public string? ShortName { get; set; }
    public decimal? SgstRate { get; set; } = 0;
    public decimal? CgstRate { get; set; } = 0;
    public decimal? IgstRate { get; set; } = 0;
    public string? Type { get; set; } = "Goods"; // Goods or Services
    public string? Uqc { get; set; } // Unit Quantity Code
    public decimal? CessRate { get; set; } = 0;
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
