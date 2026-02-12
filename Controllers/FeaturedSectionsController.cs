using MedTrueApi.Models;
using MedTrueApi.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace MedTrueApi.Controllers;

[ApiController]
[Route("api/featured-sections")]
public class FeaturedSectionsController : ControllerBase
{
    private readonly ContentRepository _repository;

    public FeaturedSectionsController(ContentRepository repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<IActionResult> GetFeaturedSections([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var (items, total) = await _repository.GetFeaturedSectionsAsync(page, pageSize);
        return Ok(new { Items = items, TotalCount = total, Page = page, PageSize = pageSize });
    }

    [HttpPost]
    public async Task<IActionResult> CreateFeaturedSection(FeaturedSection section)
    {
        var id = await _repository.CreateFeaturedSectionAsync(section);
        return CreatedAtAction(nameof(GetFeaturedSections), new { page = 1 }, section);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateFeaturedSection(long id, FeaturedSection section)
    {
        if (id != section.Id) return BadRequest();
        await _repository.UpdateFeaturedSectionAsync(section);
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteFeaturedSection(long id)
    {
        await _repository.DeleteFeaturedSectionAsync(id);
        return NoContent();
    }

    /// <summary>
    /// Returns active featured sections with products auto-populated by sectionType.
    /// Used by the Flutter app homepage.
    /// </summary>
    [HttpGet("home")]
    public async Task<IActionResult> GetHomeSections([FromQuery] int productLimit = 10)
    {
        var sections = await _repository.GetActiveFeaturedSectionsAsync();
        var result = new List<object>();

        foreach (var section in sections)
        {
            var products = await _repository.GetProductsBySectionTypeAsync(section.SectionType, productLimit);
            result.Add(new
            {
                section.Id,
                section.Title,
                section.Slug,
                section.ShortDescription,
                section.SectionType,
                section.Style,
                section.BackgroundColor,
                section.TextColor,
                section.SortOrder,
                Products = products
            });
        }

        return Ok(result);
    }
}
