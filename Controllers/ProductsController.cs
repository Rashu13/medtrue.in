using MedTrueApi.Models;
using MedTrueApi.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace MedTrueApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly ProductRepository _repository;

    public ProductsController(ProductRepository repository)
    {
        _repository = repository;
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
}
