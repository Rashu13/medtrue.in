using Dapper;
using MedTrueApi.Models;
using System.Data;

namespace MedTrueApi.Repositories;

public class ProductRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public ProductRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    private IDbConnection Connection => _connectionFactory.CreateConnection();

    public async Task<IEnumerable<Product>> GetAllProductsAsync()
    {
        using var conn = Connection;
        return await conn.QueryAsync<Product>("SELECT * FROM products ORDER BY name");
    }

    public async Task<Product?> GetProductByIdAsync(long id)
    {
        using var conn = Connection;
        return await conn.QueryFirstOrDefaultAsync<Product>("SELECT * FROM products WHERE product_id = @Id", new { Id = id });
    }

    public async Task<long> CreateProductAsync(Product product)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO products (
                name, packing_desc, barcode, company_id, salt_id, category_id, hsn_code, item_type_id,
                unit_primary_id, unit_secondary_id, conversion_factor, status, is_hidden, is_decimal_allowed, has_photo,
                is_narcotic, schedule_h_id, rack_number, min_qty, max_qty, reorder_qty, allow_negative_stock,
                mrp, purchase_rate, cost_rate, sgst_percent, cgst_percent, igst_percent,
                item_discount_1, special_discount, max_discount_percent, sale_margin, created_at, updated_at
            ) VALUES (
                @Name, @PackingDesc, @Barcode, @CompanyId, @SaltId, @CategoryId, @HsnCode, @ItemTypeId,
                @UnitPrimaryId, @UnitSecondaryId, @ConversionFactor, @Status, @IsHidden, @IsDecimalAllowed, @HasPhoto,
                @IsNarcotic, @ScheduleHId, @RackNumber, @MinQty, @MaxQty, @ReorderQty, @AllowNegativeStock,
                @Mrp, @PurchaseRate, @CostRate, @SgstPercent, @CgstPercent, @IgstPercent,
                @ItemDiscount1, @SpecialDiscount, @MaxDiscountPercent, @SaleMargin, NOW(), NOW()
            ) RETURNING product_id";
        return await conn.ExecuteScalarAsync<long>(sql, product);
    }

    public async Task UpdateProductAsync(Product product)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE products SET
                name = @Name, packing_desc = @PackingDesc, barcode = @Barcode, company_id = @CompanyId, 
                salt_id = @SaltId, category_id = @CategoryId, hsn_code = @HsnCode, item_type_id = @ItemTypeId,
                unit_primary_id = @UnitPrimaryId, unit_secondary_id = @UnitSecondaryId, conversion_factor = @ConversionFactor, 
                status = @Status, is_hidden = @IsHidden, is_decimal_allowed = @IsDecimalAllowed, has_photo = @HasPhoto,
                is_narcotic = @IsNarcotic, schedule_h_id = @ScheduleHId, rack_number = @RackNumber, 
                min_qty = @MinQty, max_qty = @MaxQty, reorder_qty = @ReorderQty, allow_negative_stock = @AllowNegativeStock,
                mrp = @Mrp, purchase_rate = @PurchaseRate, cost_rate = @CostRate, 
                sgst_percent = @SgstPercent, cgst_percent = @CgstPercent, igst_percent = @IgstPercent,
                item_discount_1 = @ItemDiscount1, special_discount = @SpecialDiscount, 
                max_discount_percent = @MaxDiscountPercent, sale_margin = @SaleMargin, updated_at = NOW()
            WHERE product_id = @ProductId";
        await conn.ExecuteAsync(sql, product);
    }

    // Images
    public async Task<int> CreateProductImageAsync(ProductImage image)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO product_images (product_id, image_path, is_primary, display_order)
            VALUES (@ProductId, @ImagePath, @IsPrimary, @DisplayOrder)
            RETURNING img_id";
        return await conn.ExecuteScalarAsync<int>(sql, image);
    }

    public async Task<IEnumerable<ProductImage>> GetProductImagesAsync(long productId)
    {
        using var conn = Connection;
        return await conn.QueryAsync<ProductImage>("SELECT * FROM product_images WHERE product_id = @ProductId ORDER BY display_order", new { ProductId = productId });
    }

    public async Task DeleteProductImageAsync(int imgId)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM product_images WHERE img_id = @ImgId", new { ImgId = imgId });
    }
}
