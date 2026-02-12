namespace MedTrueApi.Models;

public class DeliveryBoy
{
    public long Id { get; set; }
    public long UserId { get; set; }
    public long? DeliveryZoneId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string VehicleType { get; set; } = string.Empty;
    public string VehicleRegistration { get; set; } = string.Empty;
    public string VerificationStatus { get; set; } = "pending";
    public string Status { get; set; } = "active";
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class DeliveryZone
{
    public long Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public decimal CenterLatitude { get; set; }
    public decimal CenterLongitude { get; set; }
    public double RadiusKm { get; set; }
    public string Status { get; set; } = "active";
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class Store
{
    public long Id { get; set; }
    public long SellerId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string State { get; set; } = string.Empty;
    public string Zipcode { get; set; } = string.Empty;
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }
    public string ContactEmail { get; set; } = string.Empty;
    public string ContactNumber { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string VerificationStatus { get; set; } = "not_approved";
    public string Status { get; set; } = "online";
    public string FulfillmentType { get; set; } = "hyperlocal";
    
    // Banking/Tax
    public string TaxName { get; set; } = string.Empty;
    public string TaxNumber { get; set; } = string.Empty;
    public string BankName { get; set; } = string.Empty;
    public string AccountNumber { get; set; } = string.Empty;
    public string IfscCode { get; set; } = string.Empty; // Mapped to code/branch?
    
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
