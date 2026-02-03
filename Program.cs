
// Configure Dapper to support snake_case column names
Dapper.DefaultTypeMap.MatchNamesWithUnderscores = true;

var builder = WebApplication.CreateBuilder(args);

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

var app = builder.Build();

// Initialize Database
using (var scope = app.Services.CreateScope())
{
    var initializer = scope.ServiceProvider.GetRequiredService<MedTrueApi.Repositories.DatabaseInitializer>();
    await initializer.InitializeAsync();

    // Auto-migrate Salts table
    var masterRepo = scope.ServiceProvider.GetRequiredService<MedTrueApi.Repositories.MasterRepository>();
    await masterRepo.EnsureSaltSchemaAsync();
    await masterRepo.EnsureCompanySchemaAsync();
    await masterRepo.EnsureUnitSchemaAsync(); // Auto-migrate Units
    await masterRepo.EnsureCategorySchemaAsync(); // Auto-migrate Categories (add image_path)
    await masterRepo.EnsureHsnSchemaAsync(); // Auto-migrate HSN Codes

    // Auto-migrate Products table
    // Auto-migrate Products table
    var productRepo = scope.ServiceProvider.GetRequiredService<MedTrueApi.Repositories.ProductRepository>();
    await productRepo.EnsureProductSchemaAsync();
}

// Configure the HTTP request pipeline.
// Configure the HTTP request pipeline.
app.UseCors(x => x
    .AllowAnyOrigin()
    .AllowAnyMethod()
    .AllowAnyHeader());

app.MapHealthChecks("/health");

var provider = new Microsoft.AspNetCore.StaticFiles.FileExtensionContentTypeProvider();
provider.Mappings[".avif"] = "image/avif";
app.UseStaticFiles(new StaticFileOptions
{
    ContentTypeProvider = provider
});
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
