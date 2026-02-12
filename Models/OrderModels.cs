namespace MedTrueApi.Models;

public class Cart
{
    public long Id { get; set; }
    public string Uuid { get; set; } = string.Empty;
    public long UserId { get; set; }
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class CartItem
{
    public long Id { get; set; }
    public long CartId { get; set; }
    public long ProductId { get; set; }
    public long ProductVariantId { get; set; }
    public long StoreId { get; set; }
    public int Quantity { get; set; }
    public string SaveForLater { get; set; } = "0"; // "0" or "1"
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class Order
{
    public long Id { get; set; }
    public string Uuid { get; set; } = string.Empty;
    public long UserId { get; set; }
    public string Slug { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Status { get; set; } = "pending";
    
    // Financials
    public decimal Subtotal { get; set; }
    public decimal TotalPayable { get; set; }
    public decimal FinalTotal { get; set; }
    public decimal DeliveryCharge { get; set; }
    public decimal HandlingCharges { get; set; }
    public decimal PromoDiscount { get; set; }
    public string? PromoCode { get; set; }
    
    // Delivery Info
    public long? DeliveryBoyId { get; set; }
    public long DeliveryZoneId { get; set; }
    public long? DeliveryTimeSlotId { get; set; } // Optional if not using slots
    public int? EstimatedDeliveryTime { get; set; }
    public bool IsRushOrder { get; set; }
    public string FulfillmentType { get; set; } = "hyperlocal";

    // Billing Address
    public string BillingName { get; set; } = string.Empty;
    public string BillingAddress1 { get; set; } = string.Empty;
    public string? BillingAddress2 { get; set; }
    public string BillingCity { get; set; } = string.Empty;
    public string BillingState { get; set; } = string.Empty;
    public string BillingZip { get; set; } = string.Empty;
    public string BillingPhone { get; set; } = string.Empty;
    public decimal BillingLatitude { get; set; }
    public decimal BillingLongitude { get; set; }

    // Shipping Address
    public string ShippingName { get; set; } = string.Empty;
    public string ShippingAddress1 { get; set; } = string.Empty;
    public string? ShippingAddress2 { get; set; }
    public string ShippingCity { get; set; } = string.Empty;
    public string ShippingState { get; set; } = string.Empty;
    public string ShippingZip { get; set; } = string.Empty;
    public string ShippingPhone { get; set; } = string.Empty;
    public decimal ShippingLatitude { get; set; }
    public decimal ShippingLongitude { get; set; }

    // Payment
    public string PaymentMethod { get; set; } = string.Empty;
    public string PaymentStatus { get; set; } = "pending";
    
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class OrderItem
{
    public long Id { get; set; }
    public long OrderId { get; set; }
    public long ProductId { get; set; }
    public long ProductVariantId { get; set; }
    public long StoreId { get; set; }
    
    public string Title { get; set; } = string.Empty;
    public string VariantTitle { get; set; } = string.Empty;
    public string Sku { get; set; } = string.Empty;
    
    public int Quantity { get; set; }
    public decimal Price { get; set; }
    public decimal Subtotal { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal Discount { get; set; }
    
    public string Status { get; set; } = string.Empty;
    public string? Otp { get; set; }
    public bool OtpVerified { get; set; }

    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
