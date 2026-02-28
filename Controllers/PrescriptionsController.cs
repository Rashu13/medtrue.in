using MedTrueApi.Models;
using MedTrueApi.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace MedTrueApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PrescriptionsController : ControllerBase
{
    private readonly OrderRepository _repository;
    private readonly string _uploadPath;

    public PrescriptionsController(OrderRepository repository, IWebHostEnvironment env)
    {
        _repository = repository;
        _uploadPath = Path.Combine(env.WebRootPath, "uploads", "prescriptions");
        if (!Directory.Exists(_uploadPath)) Directory.CreateDirectory(_uploadPath);
    }

    [HttpPost("upload")]
    public async Task<IActionResult> UploadPrescription([FromForm] IFormFile file, [FromForm] long userId)
    {
        if (file == null || file.Length == 0) return BadRequest("No file uploaded");

        var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
        var filePath = Path.Combine(_uploadPath, fileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        var prescription = new Prescription
        {
            UserId = userId,
            ImagePath = $"/uploads/prescriptions/{fileName}",
            Status = "pending",
            CreatedAt = DateTime.UtcNow
        };

        var id = await _repository.CreatePrescriptionAsync(prescription);
        return Ok(new { Message = "Prescription uploaded successfully", PrescriptionId = id, ImagePath = prescription.ImagePath });
    }

    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetUserPrescriptions(long userId)
    {
        var items = await _repository.GetUserPrescriptionsAsync(userId);
        return Ok(items);
    }

    [HttpPut("{id}/link-order/{orderId}")]
    public async Task<IActionResult> LinkToOrder(long id, long orderId)
    {
        await _repository.LinkPrescriptionToOrderAsync(id, orderId);
        return Ok(new { Message = "Prescription linked to order" });
    }
}
