using Dapper;
using MedTrueApi.Models;
using System.Data;

namespace MedTrueApi.Repositories;

public class OrderRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public OrderRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    private IDbConnection Connection => _connectionFactory.CreateConnection();

    public async Task EnsureSchemaAsync()
    {
        using var conn = Connection;

        // Carts
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS carts (
                id SERIAL PRIMARY KEY,
                uuid VARCHAR(36) NOT NULL UNIQUE,
                user_id BIGINT NOT NULL,
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NOW()
            );");

        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS cart_items (
                id SERIAL PRIMARY KEY,
                cart_id BIGINT NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
                product_id BIGINT NOT NULL,
                product_variant_id BIGINT NOT NULL,
                store_id BIGINT NOT NULL,
                quantity INT NOT NULL,
                save_for_later VARCHAR(1) DEFAULT '0',
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NOW()
            );");

        // Orders
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS orders (
                id SERIAL PRIMARY KEY,
                uuid VARCHAR(36) NOT NULL UNIQUE,
                user_id BIGINT NOT NULL,
                slug VARCHAR(100) NOT NULL,
                email VARCHAR(255),
                status VARCHAR(50) DEFAULT 'pending',
                
                subtotal DECIMAL(12,2) NOT NULL,
                total_payable DECIMAL(12,2) NOT NULL,
                final_total DECIMAL(12,2) NOT NULL,
                delivery_charge DECIMAL(10,2) DEFAULT 0,
                handling_charges DECIMAL(10,2) DEFAULT 0,
                promo_discount DECIMAL(10,2) DEFAULT 0,
                promo_code VARCHAR(50),
                
                delivery_boy_id BIGINT,
                delivery_zone_id BIGINT NOT NULL,
                delivery_time_slot_id BIGINT,
                estimated_delivery_time INT,
                is_rush_order BOOLEAN DEFAULT FALSE,
                fulfillment_type VARCHAR(20) DEFAULT 'hyperlocal',
                
                billing_name VARCHAR(255),
                billing_address_1 TEXT,
                billing_address_2 TEXT,
                billing_city VARCHAR(255),
                billing_state VARCHAR(255),
                billing_zip VARCHAR(20),
                billing_phone VARCHAR(20),
                billing_latitude DECIMAL(10,8),
                billing_longitude DECIMAL(11,8),
                
                shipping_name VARCHAR(255),
                shipping_address_1 TEXT,
                shipping_address_2 TEXT,
                shipping_city VARCHAR(255),
                shipping_state VARCHAR(255),
                shipping_zip VARCHAR(20),
                shipping_phone VARCHAR(20),
                shipping_latitude DECIMAL(10,8),
                shipping_longitude DECIMAL(11,8),
                
                payment_method VARCHAR(50),
                payment_status VARCHAR(50) DEFAULT 'pending',
                
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NOW()
            );");

        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS order_items (
                id SERIAL PRIMARY KEY,
                order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
                product_id BIGINT NOT NULL,
                product_variant_id BIGINT NOT NULL,
                store_id BIGINT NOT NULL,
                title VARCHAR(255) NOT NULL,
                variant_title VARCHAR(255),
                sku VARCHAR(255),
                quantity INT NOT NULL,
                price DECIMAL(10,2) NOT NULL,
                subtotal DECIMAL(10,2) NOT NULL,
                tax_amount DECIMAL(10,2),
                discount DECIMAL(10,2) DEFAULT 0,
                status VARCHAR(50),
                otp VARCHAR(10),
                otp_verified BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NOW()
            );");

        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS prescriptions (
                id SERIAL PRIMARY KEY,
                user_id BIGINT NOT NULL,
                order_id BIGINT,
                image_path TEXT NOT NULL,
                status VARCHAR(20) DEFAULT 'pending',
                note TEXT,
                created_at TIMESTAMP DEFAULT NOW()
            );");
    }

    // Cart Methods
    public async Task<Cart> CreateCartAsync(long userId)
    {
        using var conn = Connection;
        var uuid = Guid.NewGuid().ToString();
        var id = await conn.ExecuteScalarAsync<long>(@"
            INSERT INTO carts (uuid, user_id, created_at, updated_at) 
            VALUES (@Uuid, @UserId, NOW(), NOW()) RETURNING id", 
            new { Uuid = uuid, UserId = userId });
        
        return new Cart { Id = id, Uuid = uuid, UserId = userId };
    }

    public async Task<Cart?> GetCartByUserIdAsync(long userId)
    {
        using var conn = Connection;
        return await conn.QueryFirstOrDefaultAsync<Cart>("SELECT * FROM carts WHERE user_id = @UserId", new { UserId = userId });
    }

    public async Task AddCartItemAsync(CartItem item)
    {
        using var conn = Connection;
        // Check if item already exists in cart, if so update quantity
        var existing = await conn.QueryFirstOrDefaultAsync<CartItem>(
            "SELECT * FROM cart_items WHERE cart_id = @CartId AND product_id = @ProductId AND product_variant_id = @ProductVariantId",
            new { item.CartId, item.ProductId, item.ProductVariantId });

        if (existing != null)
        {
            await conn.ExecuteAsync(
                "UPDATE cart_items SET quantity = quantity + @Quantity, updated_at = NOW() WHERE id = @Id",
                new { item.Quantity, Id = existing.Id });
        }
        else
        {
            var sql = @"
                INSERT INTO cart_items (cart_id, product_id, product_variant_id, store_id, quantity, save_for_later, created_at, updated_at)
                VALUES (@CartId, @ProductId, @ProductVariantId, @StoreId, @Quantity, @SaveForLater, NOW(), NOW())";
            await conn.ExecuteAsync(sql, item);
        }
    }

    public async Task<IEnumerable<dynamic>> GetCartItemsAsync(long userId)
    {
        using var conn = Connection;
        var sql = @"
            SELECT ci.*, p.name as ProductName, p.sale_price as Price,
                   (SELECT image_path FROM product_images WHERE product_id = p.product_id ORDER BY is_primary DESC, display_order LIMIT 1) as ImagePath
            FROM cart_items ci
            JOIN carts c ON ci.cart_id = c.id
            JOIN products p ON ci.product_id = p.product_id
            WHERE c.user_id = @UserId";
        return await conn.QueryAsync(sql, new { UserId = userId });
    }

    public async Task UpdateCartItemQuantityAsync(long cartItemId, int quantity)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("UPDATE cart_items SET quantity = @Quantity, updated_at = NOW() WHERE id = @Id", new { Quantity = quantity, Id = cartItemId });
    }

    public async Task RemoveCartItemAsync(long cartItemId)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM cart_items WHERE id = @Id", new { Id = cartItemId });
    }

    public async Task ClearCartAsync(long userId)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM cart_items WHERE cart_id IN (SELECT id FROM carts WHERE user_id = @UserId)", new { UserId = userId });
    }
    
    // Order Methods
    public async Task<long> CreateOrderAsync(Order order)
    {
        using var conn = Connection;
        // Logic to generate slug/uuid etc
        if (string.IsNullOrEmpty(order.Uuid)) order.Uuid = Guid.NewGuid().ToString();
        if (string.IsNullOrEmpty(order.Slug)) order.Slug = "ORD-" + new Random().Next(100000, 999999);

        var sql = @"
            INSERT INTO orders (
                uuid, user_id, slug, email, status, subtotal, total_payable, final_total, 
                delivery_charge, handling_charges, promo_discount, promo_code,
                delivery_zone_id, delivery_boy_id, fulfillment_type, payment_method, payment_status,
                billing_name, billing_address_1, billing_city, billing_state, billing_zip, billing_phone,
                shipping_name, shipping_address_1, shipping_city, shipping_state, shipping_zip, shipping_phone,
                created_at, updated_at
            ) VALUES (
                @Uuid, @UserId, @Slug, @Email, @Status, @Subtotal, @TotalPayable, @FinalTotal,
                @DeliveryCharge, @HandlingCharges, @PromoDiscount, @PromoCode,
                @DeliveryZoneId, @DeliveryBoyId, @FulfillmentType, @PaymentMethod, @PaymentStatus,
                @BillingName, @BillingAddress1, @BillingCity, @BillingState, @BillingZip, @BillingPhone,
                @ShippingName, @ShippingAddress1, @ShippingCity, @ShippingState, @ShippingZip, @ShippingPhone,
                NOW(), NOW()
            ) RETURNING id";
            
        var orderId = await conn.ExecuteScalarAsync<long>(sql, order);
        return orderId;
    }

    public async Task AddOrderItemAsync(OrderItem item)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO order_items (
                order_id, product_id, product_variant_id, store_id, title, variant_title, sku,
                quantity, price, subtotal, tax_amount, discount, status, created_at, updated_at
            ) VALUES (
                @OrderId, @ProductId, @ProductVariantId, @StoreId, @Title, @VariantTitle, @Sku,
                @Quantity, @Price, @Subtotal, @TaxAmount, @Discount, @Status, NOW(), NOW()
            )";
        await conn.ExecuteAsync(sql, item);
    }

    public async Task<(IEnumerable<Order>, int)> GetAllOrdersAsync(int page, int pageSize)
    {
        using var conn = Connection;
        var offset = (page - 1) * pageSize;
        var sql = @"
            SELECT * FROM orders 
            ORDER BY created_at DESC 
            LIMIT @PageSize OFFSET @Offset";
            
        var countSql = "SELECT COUNT(1) FROM orders";

        var items = await conn.QueryAsync<Order>(sql, new { PageSize = pageSize, Offset = offset });
        var total = await conn.ExecuteScalarAsync<int>(countSql);
        
        return (items, total);
    }

    public async Task<IEnumerable<Order>> GetOrdersByUserIdAsync(long userId)
    {
        using var conn = Connection;
        var sql = "SELECT * FROM orders WHERE user_id = @UserId ORDER BY created_at DESC";
        return await conn.QueryAsync<Order>(sql, new { UserId = userId });
    }

    public async Task<Order?> GetOrderByIdAsync(long id)
    {
        using var conn = Connection;
        return await conn.QueryFirstOrDefaultAsync<Order>("SELECT * FROM orders WHERE id = @Id", new { Id = id });
    }

    public async Task<IEnumerable<OrderItem>> GetOrderItemsAsync(long orderId)
    {
        using var conn = Connection;
        return await conn.QueryAsync<OrderItem>("SELECT * FROM order_items WHERE order_id = @OrderId", new { OrderId = orderId });
    }

    public async Task UpdateOrderStatusAsync(long id, string status)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("UPDATE orders SET status = @Status, updated_at = NOW() WHERE id = @Id",
            new { Id = id, Status = status });
    }

    public async Task DeleteOrderAsync(long id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM order_items WHERE order_id = @Id", new { Id = id });
        await conn.ExecuteAsync("DELETE FROM orders WHERE id = @Id", new { Id = id });
    }

    // Prescription Methods
    public async Task<long> CreatePrescriptionAsync(Prescription prescription)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO prescriptions (user_id, order_id, image_path, status, note, created_at)
            VALUES (@UserId, @OrderId, @ImagePath, @Status, @Note, NOW()) RETURNING id";
        return await conn.ExecuteScalarAsync<long>(sql, prescription);
    }

    public async Task<IEnumerable<Prescription>> GetUserPrescriptionsAsync(long userId)
    {
        using var conn = Connection;
        return await conn.QueryAsync<Prescription>("SELECT * FROM prescriptions WHERE user_id = @UserId ORDER BY created_at DESC", new { UserId = userId });
    }

    public async Task LinkPrescriptionToOrderAsync(long prescriptionId, long orderId)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("UPDATE prescriptions SET order_id = @OrderId WHERE id = @Id", new { OrderId = orderId, Id = prescriptionId });
    }
}
