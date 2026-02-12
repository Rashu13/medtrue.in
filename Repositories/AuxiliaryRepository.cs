using Dapper;
using MedTrueApi.Models;
using System.Data;

namespace MedTrueApi.Repositories;

public class AuxiliaryRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public AuxiliaryRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    private IDbConnection Connection => _connectionFactory.CreateConnection();

    public async Task EnsureSchemaAsync()
    {
        using var conn = Connection;

        // Wallets
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS wallets (
                id SERIAL PRIMARY KEY,
                user_id BIGINT NOT NULL UNIQUE,
                balance DECIMAL(15,2) DEFAULT 0,
                blocked_balance DECIMAL(15,2) DEFAULT 0,
                currency_code VARCHAR(10) DEFAULT 'INR',
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NOW()
            );");

        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS wallet_transactions (
                id SERIAL PRIMARY KEY,
                wallet_id BIGINT NOT NULL REFERENCES wallets(id),
                user_id BIGINT NOT NULL,
                order_id BIGINT,
                transaction_type VARCHAR(50) NOT NULL,
                payment_method VARCHAR(50),
                amount DECIMAL(15,2) NOT NULL,
                currency_code VARCHAR(10) DEFAULT 'INR',
                status VARCHAR(50) DEFAULT 'pending',
                description TEXT,
                created_at TIMESTAMP DEFAULT NOW()
            );");

        // Wishlists
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS wishlists (
                id SERIAL PRIMARY KEY,
                user_id BIGINT NOT NULL,
                title VARCHAR(255) DEFAULT 'My Wishlist',
                slug VARCHAR(255),
                created_at TIMESTAMP DEFAULT NOW()
            );");

        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS wishlist_items (
                id SERIAL PRIMARY KEY,
                wishlist_id BIGINT NOT NULL REFERENCES wishlists(id) ON DELETE CASCADE,
                product_id BIGINT NOT NULL,
                store_id BIGINT NOT NULL,
                created_at TIMESTAMP DEFAULT NOW()
            );");

        // Support Tickets
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS support_tickets (
                id SERIAL PRIMARY KEY,
                user_id BIGINT NOT NULL,
                subject VARCHAR(255) NOT NULL,
                description TEXT,
                status VARCHAR(50) DEFAULT 'open',
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NOW()
            );");

        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS support_ticket_messages (
                id SERIAL PRIMARY KEY,
                ticket_id BIGINT NOT NULL REFERENCES support_tickets(id) ON DELETE CASCADE,
                user_id BIGINT NOT NULL,
                sender_type VARCHAR(50) DEFAULT 'user',
                message TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT NOW()
            );");

        // Reviews
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS reviews (
                id SERIAL PRIMARY KEY,
                user_id BIGINT NOT NULL,
                product_id BIGINT,
                order_id BIGINT,
                store_id BIGINT,
                delivery_boy_id BIGINT,
                rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
                comment TEXT,
                status VARCHAR(50) DEFAULT 'published',
                created_at TIMESTAMP DEFAULT NOW()
            );");
    }

    // --- Wallet ---
    public async Task<Wallet> GetWalletAsync(long userId)
    {
        using var conn = Connection;
        var wallet = await conn.QueryFirstOrDefaultAsync<Wallet>("SELECT * FROM wallets WHERE user_id = @UserId", new { UserId = userId });
        if (wallet == null)
        {
            var id = await conn.ExecuteScalarAsync<long>(
                "INSERT INTO wallets (user_id, balance, created_at, updated_at) VALUES (@UserId, 0, NOW(), NOW()) RETURNING id", 
                new { UserId = userId });
            return new Wallet { Id = id, UserId = userId, Balance = 0 };
        }
        return wallet;
    }

    public async Task AddTransactionAsync(WalletTransaction txn)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO wallet_transactions (
                wallet_id, user_id, order_id, transaction_type, payment_method, amount, 
                currency_code, status, description, created_at
            ) VALUES (
                @WalletId, @UserId, @OrderId, @TransactionType, @PaymentMethod, @Amount,
                @CurrencyCode, @Status, @Description, NOW()
            )";
        await conn.ExecuteAsync(sql, txn);
        
        // Update balance if completed
        if (txn.Status == "completed")
        {
            var updateSql = txn.TransactionType == "deposit" 
                ? "UPDATE wallets SET balance = balance + @Amount WHERE id = @WalletId"
                : "UPDATE wallets SET balance = balance - @Amount WHERE id = @WalletId"; // deduction
                
            // Check logic for refunds etc later
            if(txn.TransactionType == "refund") updateSql = "UPDATE wallets SET balance = balance + @Amount WHERE id = @WalletId";
            
            await conn.ExecuteAsync(updateSql, new { Amount = txn.Amount, WalletId = txn.WalletId });
        }
    }

    // --- Wishlist ---
    public async Task AddToWishlistAsync(long userId, long productId, long storeId)
    {
        using var conn = Connection;
        // Get or Create default wishlist
        var wishlistId = await conn.ExecuteScalarAsync<long?>("SELECT id FROM wishlists WHERE user_id = @UserId", new { UserId = userId });
        if (wishlistId == null)
        {
             wishlistId = await conn.ExecuteScalarAsync<long>("INSERT INTO wishlists (user_id, created_at) VALUES (@UserId, NOW()) RETURNING id", new { UserId = userId });
        }

        var sql = @"
            INSERT INTO wishlist_items (wishlist_id, product_id, store_id, created_at)
            VALUES (@WishlistId, @ProductId, @StoreId, NOW())";
        await conn.ExecuteAsync(sql, new { WishlistId = wishlistId, ProductId = productId, StoreId = storeId });
    }

    public async Task<IEnumerable<WishlistItem>> GetWishlistItemsAsync(long userId)
    {
        using var conn = Connection;
        var wishlistId = await conn.ExecuteScalarAsync<long?>("SELECT id FROM wishlists WHERE user_id = @UserId", new { UserId = userId });
        if (wishlistId == null) return Enumerable.Empty<WishlistItem>();

        return await conn.QueryAsync<WishlistItem>("SELECT * FROM wishlist_items WHERE wishlist_id = @Id", new { Id = wishlistId });
    }

    // --- Support ---
    public async Task<long> CreateTicketAsync(SupportTicket ticket)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO support_tickets (user_id, subject, description, status, created_at, updated_at)
            VALUES (@UserId, @Subject, @Description, @Status, NOW(), NOW())
            RETURNING id";
        return await conn.ExecuteScalarAsync<long>(sql, ticket);
    }

    // --- Reviews ---
    public async Task<long> AddReviewAsync(Review review)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO reviews (
                user_id, product_id, order_id, store_id, delivery_boy_id, rating, comment, status, created_at
            ) VALUES (
                @UserId, @ProductId, @OrderId, @StoreId, @DeliveryBoyId, @Rating, @Comment, @Status, NOW()
            ) RETURNING id";
        return await conn.ExecuteScalarAsync<long>(sql, review);
    }
}
