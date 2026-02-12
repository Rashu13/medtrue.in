namespace MedTrueApi.Models;

public class User
{
    public long Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Mobile { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string Status { get; set; } = "active"; // active, inactive
    public string AccessPanel { get; set; } = "web"; // web, admin, seller

    // Optional fields
    public string? ReferralCode { get; set; }
    public string? FriendsCode { get; set; }
    public decimal RewardPoints { get; set; }
    public string? Country { get; set; }
    public string? Iso2 { get; set; }
    public DateTime? EmailVerifiedAt { get; set; }
    public string? RememberToken { get; set; }

    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public DateTime? DeletedAt { get; set; }
}

public class Address
{
    public long Id { get; set; }
    public long UserId { get; set; }
    public string AddressLine1 { get; set; } = string.Empty;
    public string? AddressLine2 { get; set; }
    public string City { get; set; } = string.Empty;
    public string? Landmark { get; set; }
    public string State { get; set; } = string.Empty;
    public string Zipcode { get; set; } = string.Empty;
    public string Mobile { get; set; } = string.Empty;
    public string AddressType { get; set; } = "home"; // home, office, other
    public string Country { get; set; } = string.Empty;
    public string CountryCode { get; set; } = string.Empty;
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
