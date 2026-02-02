using MedTrueApi.Models;
using MedTrueApi.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace MedTrueApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MastersController : ControllerBase
{
    private readonly MasterRepository _repository;

    public MastersController(MasterRepository repository)
    {
        _repository = repository;
    }

    [HttpGet("companies")]
    public async Task<IActionResult> GetCompanies([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var (items, total) = await _repository.GetPagedAsync<Company>("companies", page, pageSize);
        return Ok(new { Items = items, TotalCount = total, Page = page, PageSize = pageSize });
    }

    [HttpPost("companies")]
    public async Task<IActionResult> CreateCompany(Company company)
    {
        var id = await _repository.CreateCompanyAsync(company);
        return CreatedAtAction(nameof(GetCompanies), new { id }, company);
    }

    [HttpPut("companies/{id}")]
    public async Task<IActionResult> UpdateCompany(int id, Company company)
    {
        if (id != company.CompanyId) return BadRequest();
        await _repository.UpdateCompanyAsync(company);
        return NoContent();
    }

    [HttpGet("salts")]
    public async Task<IActionResult> GetSalts([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var (items, total) = await _repository.GetPagedAsync<Salt>("salts", page, pageSize);
        return Ok(new { Items = items, TotalCount = total, Page = page, PageSize = pageSize });
    }

    [HttpPost("salts")]
    public async Task<IActionResult> CreateSalt(Salt salt)
    {
        var id = await _repository.CreateSaltAsync(salt);
        return CreatedAtAction(nameof(GetSalts), new { id }, salt);
    }

    [HttpPut("salts/{id}")]
    public async Task<IActionResult> UpdateSalt(int id, Salt salt)
    {
        if (id != salt.SaltId) return BadRequest();
        await _repository.UpdateSaltAsync(salt);
        return NoContent();
    }

    [HttpGet("categories")]
    public async Task<IActionResult> GetCategories([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var (items, total) = await _repository.GetPagedAsync<Category>("categories", page, pageSize);
        return Ok(new { Items = items, TotalCount = total, Page = page, PageSize = pageSize });
    }

    [HttpPost("categories")]
    public async Task<IActionResult> CreateCategory(Category category)
    {
        var id = await _repository.CreateCategoryAsync(category);
        return CreatedAtAction(nameof(GetCategories), new { id }, category);
    }

    [HttpPut("categories/{id}")]
    public async Task<IActionResult> UpdateCategory(int id, Category category)
    {
        if (id != category.CategoryId) return BadRequest();
        await _repository.UpdateCategoryAsync(category);
        return NoContent();
    }
    
    [HttpGet("units")]
    public async Task<IActionResult> GetUnits([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var (items, total) = await _repository.GetPagedAsync<Unit>("units", page, pageSize);
        return Ok(new { Items = items, TotalCount = total, Page = page, PageSize = pageSize });
    }

    [HttpPost("units")]
    public async Task<IActionResult> CreateUnit(Unit unit)
    {
        var id = await _repository.CreateUnitAsync(unit);
        return CreatedAtAction(nameof(GetUnits), new { id }, unit);
    }

    [HttpPut("units/{id}")]
    public async Task<IActionResult> UpdateUnit(int id, Unit unit)
    {
        if (id != unit.UnitId) return BadRequest();
        await _repository.UpdateUnitAsync(unit);
        return NoContent();
    }

    [HttpGet("itemtypes")]
    public async Task<IActionResult> GetItemTypes([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var (items, total) = await _repository.GetPagedAsync<ItemType>("item_types", page, pageSize);
        return Ok(new { Items = items, TotalCount = total, Page = page, PageSize = pageSize });
    }

    [HttpPost("itemtypes")]
    public async Task<IActionResult> CreateItemType(ItemType itemType)
    {
        var id = await _repository.CreateItemTypeAsync(itemType);
        return CreatedAtAction(nameof(GetItemTypes), new { id }, itemType);
    }

    [HttpPut("itemtypes/{id}")]
    public async Task<IActionResult> UpdateItemType(int id, ItemType itemType)
    {
        if (id != itemType.TypeId) return BadRequest();
        await _repository.UpdateItemTypeAsync(itemType);
        return NoContent();
    }

    // Delete Endpoints
    [HttpDelete("companies/{id}")]
    public async Task<IActionResult> DeleteCompany(int id)
    {
        await _repository.DeleteCompanyAsync(id);
        return NoContent();
    }

    [HttpDelete("salts/{id}")]
    public async Task<IActionResult> DeleteSalt(int id)
    {
        await _repository.DeleteSaltAsync(id);
        return NoContent();
    }

    [HttpDelete("categories/{id}")]
    public async Task<IActionResult> DeleteCategory(int id)
    {
        await _repository.DeleteCategoryAsync(id);
        return NoContent();
    }

    [HttpDelete("units/{id}")]
    public async Task<IActionResult> DeleteUnit(int id)
    {
        await _repository.DeleteUnitAsync(id);
        return NoContent();
    }

    [HttpDelete("itemtypes/{id}")]
    public async Task<IActionResult> DeleteItemType(int id)
    {
        await _repository.DeleteItemTypeAsync(id);
        return NoContent();
    }
}
