using MedTrueApi.Models;
using MedTrueApi.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace MedTrueApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuxiliaryController : ControllerBase
{
    private readonly AuxiliaryRepository _repository;

    public AuxiliaryController(AuxiliaryRepository repository)
    {
        _repository = repository;
    }

    [HttpPost("ensure-schema")]
    public async Task<IActionResult> EnsureSchema()
    {
        await _repository.EnsureSchemaAsync();
        return Ok("Auxiliary schema ensured.");
    }

    // --- Wallet ---
    [HttpGet("wallet/{userId}")]
    public async Task<IActionResult> GetWallet(long userId)
    {
        var wallet = await _repository.GetWalletAsync(userId);
        return Ok(wallet);
    }

    [HttpPost("wallet/transactions")]
    public async Task<IActionResult> AddTransaction(WalletTransaction txn)
    {
        await _repository.AddTransactionAsync(txn);
        return Ok("Transaction added");
    }

    // --- Wishlist ---
    [HttpPost("wishlist/add")]
    public async Task<IActionResult> AddToWishlist([FromQuery] long userId, [FromQuery] long productId, [FromQuery] long storeId)
    {
        await _repository.AddToWishlistAsync(userId, productId, storeId);
        return Ok("Added to wishlist");
    }

    [HttpGet("wishlist/{userId}")]
    public async Task<IActionResult> GetWishlist(long userId)
    {
        var items = await _repository.GetWishlistItemsAsync(userId);
        return Ok(items);
    }

    // --- Support ---
    [HttpPost("support/tickets")]
    public async Task<IActionResult> CreateTicket(SupportTicket ticket)
    {
        var id = await _repository.CreateTicketAsync(ticket);
        return Ok(new { TicketId = id });
    }

    // --- Reviews ---
    [HttpPost("reviews")]
    public async Task<IActionResult> AddReview(Review review)
    {
        var id = await _repository.AddReviewAsync(review);
        return Ok(new { ReviewId = id });
    }
}
