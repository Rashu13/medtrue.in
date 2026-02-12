using Dapper;
using MedTrueApi.Models;
using System.Data;

namespace MedTrueApi.Repositories;

public class LogisticsRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public LogisticsRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    private IDbConnection Connection => _connectionFactory.CreateConnection();

    public async Task EnsureSchemaAsync()
    {
        using var conn = Connection;

        // Delivery Zones
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS delivery_zones (
                id SERIAL PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                slug VARCHAR(255) NOT NULL UNIQUE,
                center_latitude DECIMAL(10,8) NOT NULL,
                center_longitude DECIMAL(11,8) NOT NULL,
                radius_km DOUBLE PRECISION NOT NULL,
                status VARCHAR(20) DEFAULT 'active',
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NOW()
            );");

        // Delivery Boys
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS delivery_boys (
                id SERIAL PRIMARY KEY,
                user_id BIGINT NOT NULL,
                delivery_zone_id BIGINT REFERENCES delivery_zones(id),
                full_name VARCHAR(255),
                address TEXT,
                vehicle_type VARCHAR(255),
                vehicle_registration VARCHAR(255),
                verification_status VARCHAR(50) DEFAULT 'pending',
                status VARCHAR(20) DEFAULT 'active',
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NOW()
            );");

        // Stores
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS stores (
                id SERIAL PRIMARY KEY,
                seller_id BIGINT NOT NULL,
                name VARCHAR(255) NOT NULL,
                slug VARCHAR(300) NOT NULL UNIQUE,
                address VARCHAR(255),
                city VARCHAR(100),
                state VARCHAR(100),
                zipcode VARCHAR(20),
                latitude DECIMAL(10,8),
                longitude DECIMAL(11,8),
                contact_email VARCHAR(50),
                contact_number VARCHAR(20),
                verification_status VARCHAR(50) DEFAULT 'not_approved',
                status VARCHAR(20) DEFAULT 'online',
                fulfillment_type VARCHAR(20) DEFAULT 'hyperlocal',
                
                tax_name VARCHAR(250),
                tax_number VARCHAR(250),
                bank_name VARCHAR(250),
                account_number VARCHAR(250),
                ifsc_code VARCHAR(250),
                
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NOW()
            );");
    }

    // Zone Methods
    public async Task<(IEnumerable<DeliveryZone> Items, int Total)> GetAllZonesPagedAsync(int page = 1, int pageSize = 20)
    {
        using var conn = Connection;
        var offset = (page - 1) * pageSize;
        var total = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM delivery_zones");
        var items = await conn.QueryAsync<DeliveryZone>(
            "SELECT * FROM delivery_zones ORDER BY id DESC LIMIT @Limit OFFSET @Offset",
            new { Limit = pageSize, Offset = offset });
        return (items, total);
    }

    public async Task<IEnumerable<DeliveryZone>> GetAllZonesAsync()
    {
        using var conn = Connection;
        return await conn.QueryAsync<DeliveryZone>("SELECT * FROM delivery_zones");
    }

    public async Task<long> CreateZoneAsync(DeliveryZone zone)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO delivery_zones (name, slug, center_latitude, center_longitude, radius_km, status, created_at, updated_at)
            VALUES (@Name, @Slug, @CenterLatitude, @CenterLongitude, @RadiusKm, @Status, NOW(), NOW())
            RETURNING id";
        return await conn.ExecuteScalarAsync<long>(sql, zone);
    }

    public async Task UpdateZoneAsync(DeliveryZone zone)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE delivery_zones SET
                name = @Name, slug = @Slug, center_latitude = @CenterLatitude,
                center_longitude = @CenterLongitude, radius_km = @RadiusKm,
                status = @Status, updated_at = NOW()
            WHERE id = @Id";
        await conn.ExecuteAsync(sql, zone);
    }

    public async Task DeleteZoneAsync(long id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM delivery_zones WHERE id = @Id", new { Id = id });
    }

    // Delivery Boy Methods
    public async Task<(IEnumerable<DeliveryBoy> Items, int Total)> GetAllDeliveryBoysPagedAsync(int page = 1, int pageSize = 20)
    {
        using var conn = Connection;
        var offset = (page - 1) * pageSize;
        var total = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM delivery_boys");
        var items = await conn.QueryAsync<DeliveryBoy>(
            "SELECT * FROM delivery_boys ORDER BY id DESC LIMIT @Limit OFFSET @Offset",
            new { Limit = pageSize, Offset = offset });
        return (items, total);
    }

    public async Task<long> RegisterDeliveryBoyAsync(DeliveryBoy boy)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO delivery_boys (user_id, delivery_zone_id, full_name, address, vehicle_type, vehicle_registration, verification_status, status, created_at, updated_at)
            VALUES (@UserId, @DeliveryZoneId, @FullName, @Address, @VehicleType, @VehicleRegistration, @VerificationStatus, @Status, NOW(), NOW())
            RETURNING id";
        return await conn.ExecuteScalarAsync<long>(sql, boy);
    }

    public async Task UpdateDeliveryBoyAsync(DeliveryBoy boy)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE delivery_boys SET
                full_name = @FullName, address = @Address, vehicle_type = @VehicleType,
                vehicle_registration = @VehicleRegistration, verification_status = @VerificationStatus,
                status = @Status, delivery_zone_id = @DeliveryZoneId, updated_at = NOW()
            WHERE id = @Id";
        await conn.ExecuteAsync(sql, boy);
    }

    public async Task DeleteDeliveryBoyAsync(long id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM delivery_boys WHERE id = @Id", new { Id = id });
    }

    // Store Methods
    public async Task<(IEnumerable<Store> Items, int Total)> GetAllStoresPagedAsync(int page = 1, int pageSize = 20)
    {
        using var conn = Connection;
        var offset = (page - 1) * pageSize;
        var total = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM stores");
        var items = await conn.QueryAsync<Store>(
            "SELECT * FROM stores ORDER BY id DESC LIMIT @Limit OFFSET @Offset",
            new { Limit = pageSize, Offset = offset });
        return (items, total);
    }

    public async Task<long> CreateStoreAsync(Store store)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO stores (
                seller_id, name, slug, address, city, state, zipcode, latitude, longitude,
                contact_email, contact_number, verification_status, status, fulfillment_type,
                tax_name, tax_number, bank_name, account_number, ifsc_code, created_at, updated_at
            ) VALUES (
                @SellerId, @Name, @Slug, @Address, @City, @State, @Zipcode, @Latitude, @Longitude,
                @ContactEmail, @ContactNumber, @VerificationStatus, @Status, @FulfillmentType,
                @TaxName, @TaxNumber, @BankName, @AccountNumber, @IfscCode, NOW(), NOW()
            ) RETURNING id";
        return await conn.ExecuteScalarAsync<long>(sql, store);
    }

    public async Task UpdateStoreAsync(Store store)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE stores SET
                name = @Name, slug = @Slug, address = @Address, city = @City, state = @State,
                zipcode = @Zipcode, latitude = @Latitude, longitude = @Longitude,
                contact_email = @ContactEmail, contact_number = @ContactNumber,
                verification_status = @VerificationStatus, status = @Status,
                fulfillment_type = @FulfillmentType, tax_name = @TaxName, tax_number = @TaxNumber,
                bank_name = @BankName, account_number = @AccountNumber, ifsc_code = @IfscCode,
                updated_at = NOW()
            WHERE id = @Id";
        await conn.ExecuteAsync(sql, store);
    }

    public async Task DeleteStoreAsync(long id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM stores WHERE id = @Id", new { Id = id });
    }
}
