using MedTrueApi.Models;
using MedTrueApi.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace MedTrueApi.Controllers;

[ApiController]
[Route("api/masters")]
public class MastersController : ControllerBase
{
    private readonly MasterRepository _repository;
    private readonly IWebHostEnvironment _env;

    public MastersController(MasterRepository repository, IWebHostEnvironment env)
    {
        _repository = repository;
        _env = env;
    }

    [HttpPost("upload-image")]
    public async Task<IActionResult> UploadMasterImage([FromForm] IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest("No file uploaded.");

        var uploadsFolder = Path.Combine(_env.WebRootPath ?? "wwwroot", "uploads", "masters");
        if (!Directory.Exists(uploadsFolder))
            Directory.CreateDirectory(uploadsFolder);

        var uniqueFileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
        var filePath = Path.Combine(uploadsFolder, uniqueFileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        return Ok(new { path = $"/uploads/masters/{uniqueFileName}" });
    }

    [HttpPost("migrate-salts")]
    public async Task<IActionResult> MigrateSalts()
    {
        await _repository.EnsureSaltSchemaAsync();
        return Ok("Salt schema updated successfully.");
    }

    [HttpPost("migrate-companies")]
    public async Task<IActionResult> MigrateCompanies()
    {
        await _repository.EnsureCompanySchemaAsync();
        return Ok("Company schema updated successfully.");
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
        return CreatedAtAction(nameof(GetCompanies), new { page = 1 }, company);
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
        return CreatedAtAction(nameof(GetSalts), new { page = 1 }, salt);
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
        return CreatedAtAction(nameof(GetCategories), new { page = 1 }, category);
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
        return CreatedAtAction(nameof(GetUnits), new { page = 1 }, unit);
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
        return CreatedAtAction(nameof(GetItemTypes), new { page = 1 }, itemType);
    }

    [HttpPut("itemtypes/{id}")]
    public async Task<IActionResult> UpdateItemType(int id, ItemType itemType)
    {
        if (id != itemType.TypeId) return BadRequest();
        await _repository.UpdateItemTypeAsync(itemType);
        return NoContent();
    }

    // HSN Codes
    [HttpGet("hsncodes")]
    public async Task<IActionResult> GetHsnCodes([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var (items, total) = await _repository.GetPagedAsync<HsnCode>("hsn_codes", page, pageSize);
        return Ok(new { Items = items, TotalCount = total, Page = page, PageSize = pageSize });
    }

    [HttpPost("hsncodes")]
    public async Task<IActionResult> CreateHsnCode(HsnCode hsn)
    {
        var code = await _repository.CreateHsnCodeAsync(hsn);
        return CreatedAtAction(nameof(GetHsnCodes), new { page = 1 }, hsn);
    }

    [HttpPut("hsncodes/{code}")]
    public async Task<IActionResult> UpdateHsnCode(string code, HsnCode hsn)
    {
        if (code != hsn.HsnSac) return BadRequest();
        await _repository.UpdateHsnCodeAsync(hsn);
        return NoContent();
    }

    [HttpDelete("hsncodes/{code}")]
    public async Task<IActionResult> DeleteHsnCode(string code)
    {
        await _repository.DeleteHsnCodeAsync(code);
        return NoContent();
    }

    // Packing Sizes
    [HttpGet("packingsizes")]
    public async Task<IActionResult> GetPackingSizes([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var (items, total) = await _repository.GetPagedAsync<PackingSize>("packing_sizes", page, pageSize);
        return Ok(new { Items = items, TotalCount = total, Page = page, PageSize = pageSize });
    }

    [HttpPost("packingsizes")]
    public async Task<IActionResult> CreatePackingSize(PackingSize size)
    {
        var id = await _repository.CreatePackingSizeAsync(size);
        return CreatedAtAction(nameof(GetPackingSizes), new { page = 1 }, size);
    }

    [HttpPut("packingsizes/{id}")]
    public async Task<IActionResult> UpdatePackingSize(int id, PackingSize size)
    {
        if (id != size.PackingSizeId) return BadRequest();
        await _repository.UpdatePackingSizeAsync(size);
        return NoContent();
    }

    [HttpDelete("packingsizes/{id}")]
    public async Task<IActionResult> DeletePackingSize(int id)
    {
        await _repository.DeletePackingSizeAsync(id);
        return NoContent();
    }

    [HttpPost("upload/{masterType}")]
    public async Task<IActionResult> UploadMasterData(string masterType, [FromForm] IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest("File is empty or not provided.");

        try
        {
            using var stream = file.OpenReadStream();
            var count = await _repository.ImportMasterDataAsync(masterType, stream);
            return Ok(new { Message = $"Successfully imported {count} records for {masterType}.", Count = count });
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Internal server error: {ex.Message}");
        }
    }

    [HttpGet("template/{masterType}")]
    public IActionResult DownloadTemplate(string masterType)
    {
        using var workbook = new ClosedXML.Excel.XLWorkbook();
        var worksheet = workbook.Worksheets.Add(masterType);
        
        switch (masterType.ToLower())
        {
            case "companies":
                worksheet.Cell(1, 1).Value = "Name";
                worksheet.Cell(1, 2).Value = "Code";
                worksheet.Cell(1, 3).Value = "Contact Number";
                worksheet.Cell(1, 4).Value = "Address";
                worksheet.Cell(1, 5).Value = "Order Form (0/1)";
                worksheet.Cell(1, 6).Value = "Inv Printing (0/1)";
                worksheet.Cell(1, 7).Value = "Dump Days";
                worksheet.Cell(1, 8).Value = "Expiry Receive Upto";
                worksheet.Cell(1, 9).Value = "Minimum Margin";
                worksheet.Cell(1, 10).Value = "Sales Tax %";
                worksheet.Cell(1, 11).Value = "Sales Cess %";
                worksheet.Cell(1, 12).Value = "Purchase Tax %";
                worksheet.Cell(1, 13).Value = "Purchase Cess %";
                // Add sample row
                worksheet.Cell(2, 1).Value = "Demo Pharma";
                worksheet.Cell(2, 2).Value = "DPH01";
                worksheet.Cell(2, 3).Value = "9876543210";
                worksheet.Cell(2, 4).Value = "123 Main St";
                worksheet.Cell(2, 5).Value = 1;
                break;

            case "salts":
                worksheet.Cell(1, 1).Value = "Name";
                worksheet.Cell(1, 2).Value = "Dosage";
                worksheet.Cell(1, 3).Value = "Type";
                worksheet.Cell(1, 4).Value = "Indications";
                worksheet.Cell(1, 5).Value = "Side Effects";
                worksheet.Cell(1, 6).Value = "Special Precautions";
                worksheet.Cell(1, 7).Value = "Drug Interactions";
                worksheet.Cell(1, 8).Value = "Note/Description";
                worksheet.Cell(1, 9).Value = "Narcotic (Y/N)";
                worksheet.Cell(1, 10).Value = "Sch H (Y/N)";
                worksheet.Cell(1, 11).Value = "Sch H1 (Y/N)";
                worksheet.Cell(1, 12).Value = "Continued (Y/N)";
                worksheet.Cell(1, 13).Value = "Prohibited (Y/N)";
                break;

            case "categories":
                worksheet.Cell(1, 1).Value = "Name";
                break;

            case "units":
                worksheet.Cell(1, 1).Value = "Name";
                worksheet.Cell(1, 2).Value = "Description";
                break;

            case "itemtypes":
                worksheet.Cell(1, 1).Value = "Name";
                break;

            default:
                return BadRequest("Invalid type.");
        }

        using var stream = new MemoryStream();
        workbook.SaveAs(stream);
        var content = stream.ToArray();
        return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", $"{masterType}_template.xlsx");
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
