using System.Data;
using Npgsql;

namespace MedTrueApi.Repositories;

public interface IDbConnectionFactory
{
    IDbConnection CreateConnection();
}

public class NpgsqlConnectionFactory : IDbConnectionFactory
{
    private readonly IConfiguration _configuration;
    private readonly string _connectionString;

    public NpgsqlConnectionFactory(IConfiguration configuration)
    {
        _configuration = configuration;
        
        // Try multiple sources to be absolutely sure
        string? rawConnString = _configuration.GetConnectionString("DefaultConnection");
        string source = "Configuration";

        if (string.IsNullOrEmpty(rawConnString))
        {
            rawConnString = Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection");
            source = "Env:ConnectionStrings__DefaultConnection";
        }

        if (string.IsNullOrEmpty(rawConnString))
        {
            rawConnString = Environment.GetEnvironmentVariable("DATABASE_URL");
            source = "Env:DATABASE_URL";
        }

        if (string.IsNullOrEmpty(rawConnString))
        {
            rawConnString = Environment.GetEnvironmentVariable("DefaultConnection");
            source = "Env:DefaultConnection";
        }

        if (string.IsNullOrEmpty(rawConnString))
        {
             Console.WriteLine("[CRITICAL] Database Initialization Failed: NO CONNECTION STRING FOUND IN ANY SOURCE!");
        }
        else 
        {
             Console.WriteLine($"[DEBUG] Connection String found from source: {source}");
        }

        _connectionString = ConvertUriToConnectionString(rawConnString ?? "");
    }

    public IDbConnection CreateConnection()
    {
        return new NpgsqlConnection(_connectionString);
    }

    private static string ConvertUriToConnectionString(string input)
    {
        if (string.IsNullOrWhiteSpace(input)) return input;

        // Check if it's a URI starting with postgres:// or postgresql://
        if (!input.StartsWith("postgres://", StringComparison.OrdinalIgnoreCase) &&
            !input.StartsWith("postgresql://", StringComparison.OrdinalIgnoreCase))
        {
            return input; // Assume provided string is already valid standard format
        }

        try
        {
            var uri = new Uri(input);
            var userInfo = uri.UserInfo.Split(':');
            var builder = new NpgsqlConnectionStringBuilder
            {
                Host = uri.Host,
                Port = uri.Port > 0 ? uri.Port : 5432,
                Database = uri.AbsolutePath.TrimStart('/'),
                Username = userInfo.Length > 0 ? userInfo[0] : null,
                Password = userInfo.Length > 1 ? userInfo[1] : null
            };

            return builder.ToString();
        }
        catch (Exception)
        {
            // If parsing fails for any reason, return original to let Npgsql handle (and likely fail) with original error
            return input;
        }
    }
}
