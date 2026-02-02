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

    public async Task UpdateCompanyAsync(Company company)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE companies 
            SET name = @Name, code = @Code, address = @Address, contact_number = @ContactNumber, is_active = @IsActive 
            WHERE company_id = @CompanyId";
        await conn.ExecuteAsync(sql, company);
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

    public async Task UpdateSaltAsync(Salt salt)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE salts 
            SET name = @Name, description = @Description, is_active = @IsActive 
            WHERE salt_id = @SaltId";
        await conn.ExecuteAsync(sql, salt);
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

    public async Task UpdateCategoryAsync(Category category)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE categories 
            SET name = @Name, parent_id = @ParentId 
            WHERE category_id = @CategoryId";
        await conn.ExecuteAsync(sql, category);
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

    public async Task UpdateUnitAsync(Unit unit)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE units 
            SET name = @Name, description = @Description 
            WHERE unit_id = @UnitId";
        await conn.ExecuteAsync(sql, unit);
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

    public async Task UpdateItemTypeAsync(ItemType itemType)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE item_types 
            SET name = @Name 
            WHERE type_id = @TypeId";
        await conn.ExecuteAsync(sql, itemType);
    }

    // Delete Methods
    public async Task DeleteCompanyAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM companies WHERE company_id = @Id", new { Id = id });
    }

    public async Task DeleteSaltAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM salts WHERE salt_id = @Id", new { Id = id });
    }

    public async Task DeleteCategoryAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM categories WHERE category_id = @Id", new { Id = id });
    }

    public async Task DeleteUnitAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM units WHERE unit_id = @Id", new { Id = id });
    }

    public async Task DeleteItemTypeAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM item_types WHERE type_id = @Id", new { Id = id });
    }
}
