using MedTrueApi.Models;
using MedTrueApi.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace MedTrueApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly ProductRepository _repository;
    private readonly IWebHostEnvironment _env;

    public ProductsController(ProductRepository repository, IWebHostEnvironment env)
    {
        _repository = repository;
        _env = env;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var products = await _repository.GetAllProductsAsync();
        return Ok(products);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(long id)
    {
        var product = await _repository.GetProductByIdAsync(id);
        if (product == null) return NotFound();
        return Ok(product);
    }

    [HttpPost]
    public async Task<IActionResult> Create(Product product)
    {
        var id = await _repository.CreateProductAsync(product);
        return CreatedAtAction(nameof(GetById), new { id }, product);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(long id, Product product)
    {
        if (id != product.ProductId) return BadRequest("ID mismatch");
        await _repository.UpdateProductAsync(product);
        return NoContent();
    }

    // Image Endpoints
    [HttpGet("{id}/images")]
    public async Task<IActionResult> GetImages(long id)
    {
        var images = await _repository.GetProductImagesAsync(id);
        return Ok(images);
    }
    [HttpPost("{id}/images")]
    public async Task<IActionResult> UploadImage(long id, IFormFile file, [FromForm] int displayOrder = 0, [FromForm] bool isPrimary = false)
    {
        if (file == null || file.Length == 0)
            return BadRequest("No file uploaded.");

        var uploadsFolder = Path.Combine(_env.WebRootPath ?? "wwwroot", "uploads", "products");
        if (!Directory.Exists(uploadsFolder))
            Directory.CreateDirectory(uploadsFolder);

        var uniqueFileName = $"{id}_{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
        var filePath = Path.Combine(uploadsFolder, uniqueFileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        var image = new ProductImage
        {
            ProductId = id,
            ImagePath = $"/uploads/products/{uniqueFileName}",
            IsPrimary = isPrimary,
            DisplayOrder = displayOrder
        };

        var imgId = await _repository.CreateProductImageAsync(image);
        image.ImgId = imgId;

        return Ok(image);
    }



    [HttpDelete("images/{imgId}")]
    public async Task<IActionResult> DeleteImage(int imgId)
    {
        var image = await _repository.GetProductImageByIdAsync(imgId);
        if (image != null && !string.IsNullOrEmpty(image.ImagePath))
        {
            var filePath = Path.Combine(_env.WebRootPath ?? "wwwroot", image.ImagePath.TrimStart('/'));
            if (System.IO.File.Exists(filePath))
            {
                System.IO.File.Delete(filePath);
            }
        }

        await _repository.DeleteProductImageAsync(imgId);
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(long id)
    {
        // Fetch all images for this product to delete them from disk
        var images = await _repository.GetProductImagesAsync(id);
        foreach (var image in images)
        {
            if (!string.IsNullOrEmpty(image.ImagePath))
            {
                var filePath = Path.Combine(_env.WebRootPath ?? "wwwroot", image.ImagePath.TrimStart('/'));
                if (System.IO.File.Exists(filePath))
                {
                    System.IO.File.Delete(filePath);
                }
            }
        }

        await _repository.DeleteProductAsync(id);
        return NoContent();
    }

    [HttpGet("generate-sku")]
    public async Task<IActionResult> GenerateSku()
    {
        var sku = await _repository.GenerateUniqueSkuAsync();
        return Ok(new { sku });
    }

    [HttpPost("migrate-schema")]
    public async Task<IActionResult> MigrateSchema()
    {
        await _repository.EnsureProductSchemaAsync();
        await _repository.EnsureProductImageSchemaAsync();
        return Ok("Schema updated successfully.");
    }
}
