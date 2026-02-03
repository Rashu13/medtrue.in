namespace MedTrueApi.Models;

public class Product
{
    public long ProductId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? PackingDesc { get; set; }
    public string? Barcode { get; set; }

    // Foreign Keys
    public int? CompanyId { get; set; }
    public int? SaltId { get; set; }
    public int? CategoryId { get; set; }
    public string? HsnCode { get; set; }
    public int? ItemTypeId { get; set; }

    // Units
    public int? UnitPrimaryId { get; set; }
    public int? UnitSecondaryId { get; set; }
    public decimal ConversionFactor { get; set; } = 1;
    public string? UnitPrimaryName { get; set; } // Fetched via JOIN

    // Status
    public string Status { get; set; } = "CONTINUE";
    public bool IsHidden { get; set; }
    public bool IsDecimalAllowed { get; set; }
    public bool HasPhoto { get; set; }

    // Regulatory
    public bool IsNarcotic { get; set; }
    public int? ScheduleHId { get; set; }

    // Inventory
    public string? RackNumber { get; set; }
    public int MinQty { get; set; }
    public int MaxQty { get; set; }
    public int ReorderQty { get; set; }
    public bool AllowNegativeStock { get; set; }
    public int CurrentStock { get; set; } // Added

    // Pricing
    public decimal Mrp { get; set; }
    public decimal PurchaseRate { get; set; }
    public decimal CostRate { get; set; }
    public decimal SalePrice { get; set; } // Added

    // Tax
    public decimal SgstPercent { get; set; }
    public decimal CgstPercent { get; set; }
    public decimal IgstPercent { get; set; }

    // Discount
    public decimal ItemDiscount1 { get; set; }
    public decimal SpecialDiscount { get; set; }
    public decimal MaxDiscountPercent { get; set; }
    public decimal SaleMargin { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public class ProductBatch
{
    public long BatchId { get; set; }
    public long ProductId { get; set; }
    public string BatchNumber { get; set; } = string.Empty;
    public DateOnly ExpiryDate { get; set; }
    public decimal? Mrp { get; set; }
    public decimal? PurchaseRate { get; set; }
    public decimal? QuantityAvailable { get; set; }
    public DateOnly EntryDate { get; set; }
}

public class ProductImage
{
    public int ImgId { get; set; }
    public long ProductId { get; set; }
    public string ImagePath { get; set; } = string.Empty;
    public bool IsPrimary { get; set; }
    public int DisplayOrder { get; set; }
    public DateTime CreatedAt { get; set; }
}
