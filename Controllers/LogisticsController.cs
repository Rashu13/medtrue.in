using MedTrueApi.Models;
using MedTrueApi.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace MedTrueApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class LogisticsController : ControllerBase
{
    private readonly LogisticsRepository _repository;

    public LogisticsController(LogisticsRepository repository)
    {
        _repository = repository;
    }

    [HttpPost("ensure-schema")]
    public async Task<IActionResult> EnsureSchema()
    {
        await _repository.EnsureSchemaAsync();
        return Ok("Logistics schema ensured.");
    }

    // ===================== Delivery Zones =====================

    [HttpGet("delivery-zones")]
    public async Task<IActionResult> GetZones([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var (items, total) = await _repository.GetAllZonesPagedAsync(page, pageSize);
        return Ok(new { Items = items, TotalCount = total, Page = page, PageSize = pageSize });
    }

    [HttpPost("delivery-zones")]
    public async Task<IActionResult> CreateZone(DeliveryZone zone)
    {
        var id = await _repository.CreateZoneAsync(zone);
        return Ok(new { Id = id });
    }

    [HttpPut("delivery-zones/{id}")]
    public async Task<IActionResult> UpdateZone(long id, DeliveryZone zone)
    {
        if (id != zone.Id) return BadRequest("ID mismatch");
        await _repository.UpdateZoneAsync(zone);
        return NoContent();
    }

    [HttpDelete("delivery-zones/{id}")]
    public async Task<IActionResult> DeleteZone(long id)
    {
        await _repository.DeleteZoneAsync(id);
        return NoContent();
    }

    // ===================== Delivery Boys =====================

    [HttpGet("delivery-boys")]
    public async Task<IActionResult> GetDeliveryBoys([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var (items, total) = await _repository.GetAllDeliveryBoysPagedAsync(page, pageSize);
        return Ok(new { Items = items, TotalCount = total, Page = page, PageSize = pageSize });
    }

    [HttpPost("delivery-boys")]
    public async Task<IActionResult> RegisterDeliveryBoy(DeliveryBoy boy)
    {
        var id = await _repository.RegisterDeliveryBoyAsync(boy);
        return Ok(new { Id = id });
    }

    [HttpPut("delivery-boys/{id}")]
    public async Task<IActionResult> UpdateDeliveryBoy(long id, DeliveryBoy boy)
    {
        if (id != boy.Id) return BadRequest("ID mismatch");
        await _repository.UpdateDeliveryBoyAsync(boy);
        return NoContent();
    }

    [HttpDelete("delivery-boys/{id}")]
    public async Task<IActionResult> DeleteDeliveryBoy(long id)
    {
        await _repository.DeleteDeliveryBoyAsync(id);
        return NoContent();
    }

    // ===================== Stores =====================

    [HttpGet("stores")]
    public async Task<IActionResult> GetStores([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var (items, total) = await _repository.GetAllStoresPagedAsync(page, pageSize);
        return Ok(new { Items = items, TotalCount = total, Page = page, PageSize = pageSize });
    }

    [HttpPost("stores")]
    public async Task<IActionResult> CreateStore(Store store)
    {
        var id = await _repository.CreateStoreAsync(store);
        return Ok(new { Id = id });
    }

    [HttpPut("stores/{id}")]
    public async Task<IActionResult> UpdateStore(long id, Store store)
    {
        if (id != store.Id) return BadRequest("ID mismatch");
        await _repository.UpdateStoreAsync(store);
        return NoContent();
    }

    [HttpDelete("stores/{id}")]
    public async Task<IActionResult> DeleteStore(long id)
    {
        await _repository.DeleteStoreAsync(id);
        return NoContent();
    }
}
