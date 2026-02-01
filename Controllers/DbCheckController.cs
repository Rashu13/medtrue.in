using Microsoft.AspNetCore.Mvc;
using Npgsql;

namespace MedTrueApi.Controllers;

[ApiController]
[Route("[controller]")]
public class DbCheckController : ControllerBase
{
    private readonly IConfiguration _configuration;

    public DbCheckController(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    [HttpGet]
    public IActionResult CheckConnection()
    {
        var connString = _configuration.GetConnectionString("DefaultConnection");
        if (string.IsNullOrEmpty(connString))
        {
            return BadRequest("Connection string 'DefaultConnection' not found.");
        }

        try
        {
            var finalConnString = ConvertUriToConnectionString(connString);
            using var conn = new NpgsqlConnection(finalConnString);
            conn.Open();
            return Ok($"Success! Connected to PostgreSQL version: {conn.PostgreSqlVersion}");
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Connection Failed: {ex.Message}");
        }
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
