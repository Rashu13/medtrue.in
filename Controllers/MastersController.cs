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
    public async Task<IActionResult> GetCompanies() => Ok(await _repository.GetAllAsync<Company>("companies"));

    [HttpPost("companies")]
    public async Task<IActionResult> CreateCompany(Company company)
    {
        var id = await _repository.CreateCompanyAsync(company);
        return CreatedAtAction(nameof(GetCompanies), new { id }, company);
    }

    [HttpGet("salts")]
    public async Task<IActionResult> GetSalts() => Ok(await _repository.GetAllAsync<Salt>("salts"));

    [HttpPost("salts")]
    public async Task<IActionResult> CreateSalt(Salt salt)
    {
        var id = await _repository.CreateSaltAsync(salt);
        return CreatedAtAction(nameof(GetSalts), new { id }, salt);
    }

    [HttpGet("categories")]
    public async Task<IActionResult> GetCategories() => Ok(await _repository.GetAllAsync<Category>("categories"));

    [HttpPost("categories")]
    public async Task<IActionResult> CreateCategory(Category category)
    {
        var id = await _repository.CreateCategoryAsync(category);
        return CreatedAtAction(nameof(GetCategories), new { id }, category);
    }
    
    [HttpGet("units")]
    public async Task<IActionResult> GetUnits() => Ok(await _repository.GetAllAsync<Unit>("units"));

    [HttpPost("units")]
    public async Task<IActionResult> CreateUnit(Unit unit)
    {
        var id = await _repository.CreateUnitAsync(unit);
        return CreatedAtAction(nameof(GetUnits), new { id }, unit);
    }

    [HttpGet("itemtypes")]
    public async Task<IActionResult> GetItemTypes() => Ok(await _repository.GetAllAsync<ItemType>("item_types"));

    [HttpPost("itemtypes")]
    public async Task<IActionResult> CreateItemType(ItemType itemType)
    {
        var id = await _repository.CreateItemTypeAsync(itemType);
        return CreatedAtAction(nameof(GetItemTypes), new { id }, itemType);
    }
}
