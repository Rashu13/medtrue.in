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
        var rawConnString = _configuration.GetConnectionString("DefaultConnection") ?? "";
        _connectionString = ConvertUriToConnectionString(rawConnString);
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
