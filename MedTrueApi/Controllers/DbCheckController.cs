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
            using var conn = new NpgsqlConnection(connString);
            conn.Open();
            return Ok($"Success! Connected to PostgreSQL version: {conn.PostgreSqlVersion}");
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Connection Failed: {ex.Message}");
        }
    }
}
