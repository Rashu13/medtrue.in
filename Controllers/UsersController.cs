using MedTrueApi.Models;
using MedTrueApi.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace MedTrueApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly UserRepository _repository;

    public UsersController(UserRepository repository)
    {
        _repository = repository;
    }

    [HttpPost("ensure-schema")]
    public async Task<IActionResult> EnsureSchema()
    {
        await _repository.EnsureSchemaAsync();
        return Ok("User schema ensured.");
    }

    // --- Users CRUD ---

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var (items, total) = await _repository.GetAllUsersAsync(page, pageSize);
        return Ok(new { Items = items, TotalCount = total, Page = page, PageSize = pageSize });
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register(User user)
    {
        try
        {
            var id = await _repository.CreateUserAsync(user);
            return Ok(new { Message = "User registered successfully", UserId = id });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetProfile(long id)
    {
        var user = await _repository.GetUserByIdAsync(id);
        if (user == null) return NotFound();
        return Ok(user);
    }
    
    [HttpGet("by-mobile/{mobile}")]
    public async Task<IActionResult> GetByMobile(string mobile)
    {
        var user = await _repository.GetUserByMobileAsync(mobile);
        if (user == null) return NotFound();
        return Ok(user);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(long id, User user)
    {
        if (id != user.Id) return BadRequest("ID mismatch");
        await _repository.UpdateUserAsync(user);
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(long id)
    {
        await _repository.DeleteUserAsync(id);
        return NoContent();
    }

    // --- Address CRUD ---

    [HttpPost("address")]
    public async Task<IActionResult> AddAddress(Address address)
    {
        var id = await _repository.AddAddressAsync(address);
        return Ok(new { Message = "Address added", AddressId = id });
    }

    [HttpGet("{userId}/addresses")]
    public async Task<IActionResult> GetAddresses(long userId)
    {
        var addresses = await _repository.GetUserAddressesAsync(userId);
        return Ok(addresses);
    }

    [HttpPut("address/{id}")]
    public async Task<IActionResult> UpdateAddress(long id, Address address)
    {
        if (id != address.Id) return BadRequest("ID mismatch");
        await _repository.UpdateAddressAsync(address);
        return NoContent();
    }

    [HttpDelete("address/{id}")]
    public async Task<IActionResult> DeleteAddress(long id)
    {
        await _repository.DeleteAddressAsync(id);
        return NoContent();
    }

    [HttpGet("{userId}/reward-points")]
    public async Task<IActionResult> GetRewardPoints(long userId)
    {
        var points = await _repository.GetRewardPointsAsync(userId);
        return Ok(new { RewardPoints = points });
    }

    [HttpPost("{userId}/reward-points/update")]
    public async Task<IActionResult> UpdateRewardPoints(long userId, [FromQuery] decimal points)
    {
        await _repository.UpdateRewardPointsAsync(userId, points);
        return Ok(new { Message = "Reward points updated" });
    }
}
