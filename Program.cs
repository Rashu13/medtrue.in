
// Configure Dapper to support snake_case column names
Dapper.DefaultTypeMap.MatchNamesWithUnderscores = true;

var builder = WebApplication.CreateBuilder(args);
// builder.WebHost.UseUrls("http://0.0.0.0:5015"); // Removed for container compatibility, use environment variables instead

// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHealthChecks();

// Register Custom Services
builder.Services.AddSingleton<MedTrueApi.Repositories.IDbConnectionFactory, MedTrueApi.Repositories.NpgsqlConnectionFactory>();
builder.Services.AddSingleton<MedTrueApi.Repositories.DatabaseInitializer>();
builder.Services.AddScoped<MedTrueApi.Repositories.MasterRepository>();
builder.Services.AddScoped<MedTrueApi.Repositories.ProductRepository>();
builder.Services.AddScoped<MedTrueApi.Repositories.ContentRepository>();
builder.Services.AddScoped<MedTrueApi.Repositories.UserRepository>();
builder.Services.AddScoped<MedTrueApi.Repositories.OrderRepository>();
builder.Services.AddScoped<MedTrueApi.Repositories.LogisticsRepository>();
builder.Services.AddScoped<MedTrueApi.Repositories.AuxiliaryRepository>();

var app = builder.Build();

// Initialize Database
try 
{
    using (var scope = app.Services.CreateScope())
    {
        var dbFactory = scope.ServiceProvider.GetRequiredService<MedTrueApi.Repositories.IDbConnectionFactory>();
        using var conn = dbFactory.CreateConnection();
        
        // Basic check: See if products table exists. If so, skip heavy migration unless forced.
        bool forceMigration = Environment.GetEnvironmentVariable("FORCE_MIGRATION") == "true";
        bool tableExists = false;
        try {
            await conn.ExecuteScalarAsync<int>("SELECT 1 FROM products LIMIT 1");
            tableExists = true;
        } catch { /* Table doesn't exist */ }

        if (!tableExists || forceMigration)
        {
            Console.WriteLine("[INFO] Database initialization started (Full Migration)...");
            var initializer = scope.ServiceProvider.GetRequiredService<MedTrueApi.Repositories.DatabaseInitializer>();
            await initializer.InitializeAsync();

            // Run individual repo migrations only on fresh install or force
            var masterRepo = scope.ServiceProvider.GetRequiredService<MedTrueApi.Repositories.MasterRepository>();
            await masterRepo.EnsureSchemaAsync();

            var productRepo = scope.ServiceProvider.GetRequiredService<MedTrueApi.Repositories.ProductRepository>();
            await productRepo.EnsureProductSchemaAsync();
            await productRepo.EnsureProductImageSchemaAsync();

            var contentRepo = scope.ServiceProvider.GetRequiredService<MedTrueApi.Repositories.ContentRepository>();
            await contentRepo.EnsureSchemaAsync();

            var userRepo = scope.ServiceProvider.GetRequiredService<MedTrueApi.Repositories.UserRepository>();
            await userRepo.EnsureSchemaAsync();

            var orderRepo = scope.ServiceProvider.GetRequiredService<MedTrueApi.Repositories.OrderRepository>();
            await orderRepo.EnsureSchemaAsync();

            var logisticsRepo = scope.ServiceProvider.GetRequiredService<MedTrueApi.Repositories.LogisticsRepository>();
            await logisticsRepo.EnsureSchemaAsync();

            var auxRepo = scope.ServiceProvider.GetRequiredService<MedTrueApi.Repositories.AuxiliaryRepository>();
            await auxRepo.EnsureSchemaAsync();
            Console.WriteLine("[INFO] Database initialization completed.");
        }
        else 
        {
            Console.WriteLine("[INFO] Database already initialized. Skipping full migration for performance.");
        }
    }
}
catch (Exception ex)
{
    Console.WriteLine($"[CRITICAL] Database Check failed: {ex.Message}");
    // We don't throw here to allow the app to attempt to start if the DB is actually ready
}

// Configure the HTTP request pipeline.
app.UseCors(x => x
    .AllowAnyOrigin()
    .AllowAnyMethod()
    .AllowAnyHeader());

app.UseStaticFiles(); // Default serves from wwwroot

var provider = new Microsoft.AspNetCore.StaticFiles.FileExtensionContentTypeProvider();
provider.Mappings[".avif"] = "image/avif";
app.UseStaticFiles(new StaticFileOptions
{
    ContentTypeProvider = provider
    // RequestPath defaults to empty, serving from root
});

app.MapHealthChecks("/health");
app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

// app.UseHttpsRedirection();

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast =  Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast");

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
