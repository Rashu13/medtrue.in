namespace MedTrueApi.Models;

public class Wallet
{
    public long Id { get; set; }
    public long UserId { get; set; }
    public decimal Balance { get; set; }
    public decimal BlockedBalance { get; set; }
    public string CurrencyCode { get; set; } = "INR";
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class WalletTransaction
{
    public long Id { get; set; }
    public long WalletId { get; set; }
    public long UserId { get; set; }
    public long? OrderId { get; set; }
    public string TransactionType { get; set; } = string.Empty; // deposit, payment, refund
    public string? PaymentMethod { get; set; }
    public decimal Amount { get; set; }
    public string CurrencyCode { get; set; } = "INR";
    public string Status { get; set; } = "pending";
    public string? Description { get; set; }
    public DateTime? CreatedAt { get; set; }
}

public class Wishlist
{
    public long Id { get; set; }
    public long UserId { get; set; }
    public string Title { get; set; } = "My Wishlist";
    public string Slug { get; set; } = "my-wishlist";
    public DateTime? CreatedAt { get; set; }
}

public class WishlistItem
{
    public long Id { get; set; }
    public long WishlistId { get; set; }
    public long ProductId { get; set; }
    public long StoreId { get; set; }
    public DateTime? CreatedAt { get; set; }
}

public class SupportTicket
{
    public long Id { get; set; }
    public long UserId { get; set; }
    public string Subject { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Status { get; set; } = "open";
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class SupportTicketMessage
{
    public long Id { get; set; }
    public long TicketId { get; set; }
    public long UserId { get; set; }
    public string SenderType { get; set; } = "user"; // user, admin
    public string Message { get; set; } = string.Empty;
    public DateTime? CreatedAt { get; set; }
}

public class Review
{
    public long Id { get; set; }
    public long UserId { get; set; }
    public long? ProductId { get; set; }
    public long? OrderId { get; set; }
    public long? StoreId { get; set; }
    public long? DeliveryBoyId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public string Status { get; set; } = "published";
    public DateTime? CreatedAt { get; set; }
}
