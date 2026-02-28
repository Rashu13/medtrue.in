using MedTrueApi.Models;
using MedTrueApi.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace MedTrueApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly OrderRepository _repository;

    public OrdersController(OrderRepository repository)
    {
        _repository = repository;
    }

    [HttpPost("ensure-schema")]
    public async Task<IActionResult> EnsureSchema()
    {
        await _repository.EnsureSchemaAsync();
        return Ok("Order schema ensured.");
    }

    // --- Cart Endpoints ---

    [HttpPost("cart")]
    public async Task<IActionResult> CreateCart([FromQuery] long userId)
    {
        var cart = await _repository.CreateCartAsync(userId);
        return Ok(cart);
    }

    [HttpGet("cart/{userId}")]
    public async Task<IActionResult> GetCart(long userId)
    {
        var cart = await _repository.GetCartByUserIdAsync(userId);
        if (cart == null) return NotFound(new { Message = "Cart not found" });
        return Ok(cart);
    }

    [HttpPost("cart/items")]
    public async Task<IActionResult> AddToCart(CartItem item)
    {
        await _repository.AddCartItemAsync(item);
        return Ok(new { Message = "Item added to cart" });
    }

    [HttpGet("cart/{userId}/items")]
    public async Task<IActionResult> GetCartItems(long userId)
    {
        var items = await _repository.GetCartItemsAsync(userId);
        return Ok(items);
    }

    [HttpPut("cart/items/{id}")]
    public async Task<IActionResult> UpdateCartItem(long id, [FromQuery] int quantity)
    {
        await _repository.UpdateCartItemQuantityAsync(id, quantity);
        return Ok(new { Message = "Cart item updated" });
    }

    [HttpDelete("cart/items/{id}")]
    public async Task<IActionResult> RemoveCartItem(long id)
    {
        await _repository.RemoveCartItemAsync(id);
        return Ok(new { Message = "Cart item removed" });
    }

    [HttpDelete("cart/{userId}/clear")]
    public async Task<IActionResult> ClearCart(long userId)
    {
        await _repository.ClearCartAsync(userId);
        return Ok(new { Message = "Cart cleared" });
    }

    // --- Order Endpoints ---

    [HttpGet]
    public async Task<IActionResult> GetOrders([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var (items, total) = await _repository.GetAllOrdersAsync(page, pageSize);
        return Ok(new { Items = items, TotalCount = total, Page = page, PageSize = pageSize });
    }

    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetUserOrders(long userId)
    {
        var orders = await _repository.GetOrdersByUserIdAsync(userId);
        return Ok(orders);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetOrderById(long id)
    {
        var order = await _repository.GetOrderByIdAsync(id);
        if (order == null) return NotFound();
        var items = await _repository.GetOrderItemsAsync(id);
        return Ok(new { Order = order, Items = items });
    }

    [HttpPost("place-order")]
    public async Task<IActionResult> PlaceOrder(Order order)
    {
        try
        {
            var orderId = await _repository.CreateOrderAsync(order);
            return Ok(new { Message = "Order placed successfully", OrderId = orderId, OrderUuid = order.Uuid });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }
    
    [HttpPost("order-items")]
    public async Task<IActionResult> AddOrderItems(List<OrderItem> items)
    {
        foreach(var item in items)
        {
             await _repository.AddOrderItemAsync(item);
        }
        return Ok(new { Message = "Order items added" });
    }

    [HttpPut("{id}/status")]
    public async Task<IActionResult> UpdateOrderStatus(long id, [FromBody] OrderStatusUpdate update)
    {
        await _repository.UpdateOrderStatusAsync(id, update.Status);
        return Ok(new { Message = "Order status updated" });
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteOrder(long id)
    {
        await _repository.DeleteOrderAsync(id);
        return NoContent();
    }
}

public class OrderStatusUpdate
{
    public string Status { get; set; } = string.Empty;
}
