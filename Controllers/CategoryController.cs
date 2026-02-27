using MedTrueApi.Models;
using MedTrueApi.Repositories;
using Microsoft.AspNetCore.Mvc;
using System.Text.RegularExpressions;

namespace MedTrueApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CategoryController : ControllerBase
{
    private readonly MasterRepository _repository;
    private readonly IWebHostEnvironment _env;

    public CategoryController(MasterRepository repository, IWebHostEnvironment env)
    {
        _repository = repository;
        _env = env;
    }

    [HttpGet]
    public async Task<IActionResult> GetCategories([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var (items, total) = await _repository.GetPagedAsync<Category>("categories", page, pageSize);
        return Ok(new { Items = items, TotalCount = total, Page = page, PageSize = pageSize });
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Category>> GetCategory(int id)
    {
        var category = await _repository.GetCategoryByIdAsync(id);
        if (category == null)
        {
            return NotFound();
        }
        return Ok(category);
    }

    [HttpPost]
    public async Task<IActionResult> CreateCategory(Category category)
    {
        try
        {
            // Auto-generate UUID if missing
            if (string.IsNullOrWhiteSpace(category.Uuid) || category.Uuid == "string")
                category.Uuid = Guid.NewGuid().ToString();

            // Sync Name and Title for UI compatibility
            if (string.IsNullOrWhiteSpace(category.Name) && !string.IsNullOrWhiteSpace(category.Title))
            {
                category.Name = category.Title;
            }
            else if (string.IsNullOrWhiteSpace(category.Title) && !string.IsNullOrWhiteSpace(category.Name))
            {
                category.Title = category.Name;
            }

            // Auto-generate Slug if missing
            if (string.IsNullOrWhiteSpace(category.Slug))
            {
                var source = !string.IsNullOrWhiteSpace(category.Title) ? category.Title : category.Name;
                if (!string.IsNullOrWhiteSpace(source))
                {
                    var slug = source.ToLower().Replace(" ", "-");
                    category.Slug = Regex.Replace(slug, "[^a-z0-9-]", "");
                }
            }

            var id = await _repository.CreateCategoryAsync(category);
            category.CategoryId = id;

            return CreatedAtAction(nameof(GetCategory), new { id = id }, category);
        }
        catch (Exception ex)
        {
            // Log error
            return StatusCode(500, ex.Message);
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateCategory(int id, Category category)
    {
        if (id != category.CategoryId) return BadRequest("Mismatched Category ID");
        
        try 
        {
            // Sync Name and Title for UI compatibility
            if (string.IsNullOrWhiteSpace(category.Name) && !string.IsNullOrWhiteSpace(category.Title))
            {
                category.Name = category.Title;
            }
            else if (string.IsNullOrWhiteSpace(category.Title) && !string.IsNullOrWhiteSpace(category.Name))
            {
                category.Title = category.Name;
            }

            await _repository.UpdateCategoryAsync(category);
            return NoContent();
        }
        catch (Exception ex)
        {
            return StatusCode(500, ex.Message);
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteCategory(int id)
    {
        var category = await _repository.GetCategoryByIdAsync(id);
        if (category != null && !string.IsNullOrEmpty(category.ImagePath))
        {
            var filePath = Path.Combine(_env.WebRootPath ?? "wwwroot", category.ImagePath.TrimStart('/'));
            if (System.IO.File.Exists(filePath))
            {
                System.IO.File.Delete(filePath);
            }
        }
        await _repository.DeleteCategoryAsync(id);
        return NoContent();
    }
}
