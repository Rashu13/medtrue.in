using Dapper;
using MedTrueApi.Models;
using System.Data;

namespace MedTrueApi.Repositories;

public class UserRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public UserRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    private IDbConnection Connection => _connectionFactory.CreateConnection();

    public async Task EnsureSchemaAsync()
    {
        using var conn = Connection;
        
        // Users Table
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,
                mobile VARCHAR(20) NOT NULL UNIQUE,
                referral_code VARCHAR(32),
                friends_code VARCHAR(32),
                reward_points DECIMAL(10,2) DEFAULT 0.00,
                status VARCHAR(20) DEFAULT 'active',
                name VARCHAR(255) NOT NULL,
                email VARCHAR(255) NOT NULL UNIQUE,
                country VARCHAR(255),
                iso_2 VARCHAR(2),
                email_verified_at TIMESTAMP,
                access_panel VARCHAR(20) DEFAULT 'web',
                password VARCHAR(255) NOT NULL,
                remember_token VARCHAR(100),
                deleted_at TIMESTAMP,
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NOW()
            );");

        // Addresses Table
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS addresses (
                id SERIAL PRIMARY KEY,
                user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                address_line1 VARCHAR(255) NOT NULL,
                address_line2 VARCHAR(255),
                city VARCHAR(100) NOT NULL,
                landmark VARCHAR(100),
                state VARCHAR(100) NOT NULL,
                zipcode VARCHAR(20) NOT NULL,
                mobile VARCHAR(20) NOT NULL,
                address_type VARCHAR(20) NOT NULL, -- home, office, other
                country VARCHAR(100) NOT NULL,
                country_code VARCHAR(10) NOT NULL,
                latitude DECIMAL(10,8) NOT NULL,
                longitude DECIMAL(11,8) NOT NULL,
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NOW()
            );");
    }

    // CRUD Methods
    public async Task<long> CreateUserAsync(User user)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO users (
                mobile, referral_code, friends_code, reward_points, status, name, email, 
                country, iso_2, access_panel, password, created_at, updated_at
            ) VALUES (
                @Mobile, @ReferralCode, @FriendsCode, @RewardPoints, @Status, @Name, @Email,
                @Country, @Iso2, @AccessPanel, @Password, NOW(), NOW()
            ) RETURNING id";
        return await conn.ExecuteScalarAsync<long>(sql, user);
    }

    public async Task<User?> GetUserByIdAsync(long id)
    {
        using var conn = Connection;
        return await conn.QueryFirstOrDefaultAsync<User>("SELECT * FROM users WHERE id = @Id", new { Id = id });
    }

    public async Task<User?> GetUserByMobileAsync(string mobile)
    {
        using var conn = Connection;
        return await conn.QueryFirstOrDefaultAsync<User>("SELECT * FROM users WHERE mobile = @Mobile", new { Mobile = mobile });
    }

    public async Task<User?> GetUserByEmailAsync(string email)
    {
        using var conn = Connection;
        return await conn.QueryFirstOrDefaultAsync<User>("SELECT * FROM users WHERE email = @Email", new { Email = email });
    }

    public async Task UpdateUserAsync(User user)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE users SET
                name = @Name, email = @Email, mobile = @Mobile, country = @Country, iso_2 = @Iso2,
                status = @Status, access_panel = @AccessPanel, updated_at = NOW()
            WHERE id = @Id";
        await conn.ExecuteAsync(sql, user);
    }

    // Address Methods
    public async Task<long> AddAddressAsync(Address address)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO addresses (
                user_id, address_line1, address_line2, city, landmark, state, zipcode, mobile,
                address_type, country, country_code, latitude, longitude, created_at, updated_at
            ) VALUES (
                @UserId, @AddressLine1, @AddressLine2, @City, @Landmark, @State, @Zipcode, @Mobile,
                @AddressType, @Country, @CountryCode, @Latitude, @Longitude, NOW(), NOW()
            ) RETURNING id";
        return await conn.ExecuteScalarAsync<long>(sql, address);
    }

    public async Task<IEnumerable<Address>> GetUserAddressesAsync(long userId)
    {
        using var conn = Connection;
        return await conn.QueryAsync<Address>("SELECT * FROM addresses WHERE user_id = @UserId", new { UserId = userId });
    }

    // --- Paginated Users ---
    public async Task<(IEnumerable<User> Items, int Total)> GetAllUsersAsync(int page = 1, int pageSize = 20)
    {
        using var conn = Connection;
        var offset = (page - 1) * pageSize;
        var total = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM users WHERE deleted_at IS NULL");
        var items = await conn.QueryAsync<User>(
            "SELECT * FROM users WHERE deleted_at IS NULL ORDER BY id DESC LIMIT @Limit OFFSET @Offset",
            new { Limit = pageSize, Offset = offset });
        return (items, total);
    }

    // --- Delete User (soft delete) ---
    public async Task DeleteUserAsync(long id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("UPDATE users SET deleted_at = NOW() WHERE id = @Id", new { Id = id });
    }

    // --- Address CRUD ---
    public async Task UpdateAddressAsync(Address address)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE addresses SET
                address_line1 = @AddressLine1, address_line2 = @AddressLine2, city = @City,
                landmark = @Landmark, state = @State, zipcode = @Zipcode, mobile = @Mobile,
                address_type = @AddressType, country = @Country, country_code = @CountryCode,
                latitude = @Latitude, longitude = @Longitude, updated_at = NOW()
            WHERE id = @Id";
        await conn.ExecuteAsync(sql, address);
    }

    public async Task DeleteAddressAsync(long id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM addresses WHERE id = @Id", new { Id = id });
    }
}
