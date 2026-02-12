using MedTrueApi.Models;
using MedTrueApi.Repositories;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;

namespace MedTrueApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BannersController : ControllerBase
{
    private readonly ContentRepository _repository;
    private readonly IWebHostEnvironment _env;

    public BannersController(ContentRepository repository, IWebHostEnvironment env)
    {
        _repository = repository;
        _env = env;
    }

    [HttpGet]
    public async Task<IActionResult> GetBanners([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var (items, total) = await _repository.GetBannersAsync(page, pageSize);
        return Ok(new { Items = items, TotalCount = total, Page = page, PageSize = pageSize });
    }

    [HttpPost]
    public async Task<IActionResult> CreateBanner([FromBody] Banner banner)
    {
        try
        {
            var id = await _repository.CreateBannerAsync(banner);
            banner.Id = id;
            return CreatedAtAction(nameof(GetBanners), new { page = 1 }, banner);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { Message = ex.Message, StackTrace = ex.StackTrace });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateBanner(long id, Banner banner)
    {
        if (id != banner.Id) return BadRequest();
        await _repository.UpdateBannerAsync(banner);
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteBanner(long id)
    {
        await _repository.DeleteBannerAsync(id);
        return NoContent();
    }

    [HttpPost("upload")]
    public async Task<IActionResult> UploadImage(IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest("No file uploaded.");

        var uploadsFolder = Path.Combine(_env.WebRootPath ?? "wwwroot", "uploads", "banners");
        if (!Directory.Exists(uploadsFolder))
            Directory.CreateDirectory(uploadsFolder);

        var uniqueFileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
        var filePath = Path.Combine(uploadsFolder, uniqueFileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        return Ok(new { path = $"/uploads/banners/{uniqueFileName}" });
    }
}
