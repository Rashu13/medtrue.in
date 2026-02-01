using Dapper;
using System.Data;

namespace MedTrueApi.Repositories;

public class DatabaseInitializer
{
    private readonly IDbConnectionFactory _connectionFactory;

    public DatabaseInitializer(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task InitializeAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        var schemaSql = await File.ReadAllTextAsync("db/schema.sql");
        await connection.ExecuteAsync(schemaSql);
    }
}
