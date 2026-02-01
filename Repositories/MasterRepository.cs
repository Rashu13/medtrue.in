using Dapper;
using MedTrueApi.Models;
using System.Data;

namespace MedTrueApi.Repositories;

public class MasterRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public MasterRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    private IDbConnection Connection => _connectionFactory.CreateConnection();

    // Generic Get All
    public async Task<IEnumerable<T>> GetAllAsync<T>(string tableName)
    {
        using var conn = Connection;
        return await conn.QueryAsync<T>($"SELECT * FROM {tableName}");
    }

    // Companies
    public async Task<int> CreateCompanyAsync(Company company)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO companies (name, code, address, contact_number, is_active) 
            VALUES (@Name, @Code, @Address, @ContactNumber, @IsActive) 
            RETURNING company_id";
        return await conn.ExecuteScalarAsync<int>(sql, company);
    }

    // Salts
    public async Task<int> CreateSaltAsync(Salt salt)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO salts (name, description, is_active) 
            VALUES (@Name, @Description, @IsActive) 
            RETURNING salt_id";
        return await conn.ExecuteScalarAsync<int>(sql, salt);
    }

    // Categories
    public async Task<int> CreateCategoryAsync(Category category)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO categories (name, parent_id) 
            VALUES (@Name, @ParentId) 
            RETURNING category_id";
        return await conn.ExecuteScalarAsync<int>(sql, category);
    }
    
    // Units
    public async Task<int> CreateUnitAsync(Unit unit)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO units (name, description) 
            VALUES (@Name, @Description) 
            RETURNING unit_id";
        return await conn.ExecuteScalarAsync<int>(sql, unit);
    }

    // Item Types
    public async Task<int> CreateItemTypeAsync(ItemType itemType)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO item_types (name) 
            VALUES (@Name) 
            RETURNING type_id";
        return await conn.ExecuteScalarAsync<int>(sql, itemType);
    }
}
