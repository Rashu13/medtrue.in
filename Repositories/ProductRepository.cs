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

    public async Task EnsureProductSchemaAsync()
    {
        using var conn = Connection;
        await conn.ExecuteAsync("ALTER TABLE products ADD COLUMN IF NOT EXISTS sale_price DECIMAL(18,2) DEFAULT 0;");
        await conn.ExecuteAsync("ALTER TABLE products ADD COLUMN IF NOT EXISTS current_stock INT DEFAULT 0;");
        await conn.ExecuteAsync("ALTER TABLE products ADD COLUMN IF NOT EXISTS min_qty INT DEFAULT 0;");
        await conn.ExecuteAsync("ALTER TABLE products ADD COLUMN IF NOT EXISTS max_qty INT DEFAULT 0;");
        await conn.ExecuteAsync("ALTER TABLE products ADD COLUMN IF NOT EXISTS packing_size_id INT;");
    }

    public async Task<IEnumerable<Product>> GetAllProductsAsync()
    {
        using var conn = Connection;
        var sql = @"
            SELECT p.*, u.name as UnitPrimaryName 
            FROM products p
            LEFT JOIN units u ON p.unit_primary_id = u.unit_id
            ORDER BY p.name";
        return await conn.QueryAsync<Product>(sql);
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
                unit_primary_id, unit_secondary_id, packing_size_id, conversion_factor, status, is_hidden, is_decimal_allowed, has_photo,
                is_narcotic, schedule_h_id, rack_number, min_qty, max_qty, reorder_qty, allow_negative_stock,
                mrp, purchase_rate, cost_rate, sale_price, current_stock, sgst_percent, cgst_percent, igst_percent,
                item_discount_1, special_discount, max_discount_percent, sale_margin, created_at, updated_at
            ) VALUES (
                @Name, @PackingDesc, @Barcode, @CompanyId, @SaltId, @CategoryId, @HsnCode, @ItemTypeId,
                @UnitPrimaryId, @UnitSecondaryId, @PackingSizeId, @ConversionFactor, @Status, @IsHidden, @IsDecimalAllowed, @HasPhoto,
                @IsNarcotic, @ScheduleHId, @RackNumber, @MinQty, @MaxQty, @ReorderQty, @AllowNegativeStock,
                @Mrp, @PurchaseRate, @CostRate, @SalePrice, @CurrentStock, @SgstPercent, @CgstPercent, @IgstPercent,
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
                unit_primary_id = @UnitPrimaryId, unit_secondary_id = @UnitSecondaryId, packing_size_id = @PackingSizeId,
                conversion_factor = @ConversionFactor, 
                status = @Status, is_hidden = @IsHidden, is_decimal_allowed = @IsDecimalAllowed, has_photo = @HasPhoto,
                is_narcotic = @IsNarcotic, schedule_h_id = @ScheduleHId, rack_number = @RackNumber, 
                min_qty = @MinQty, max_qty = @MaxQty, reorder_qty = @ReorderQty, allow_negative_stock = @AllowNegativeStock,
                mrp = @Mrp, purchase_rate = @PurchaseRate, cost_rate = @CostRate, sale_price = @SalePrice, current_stock = @CurrentStock,
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

    public async Task DeleteProductAsync(long id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM products WHERE product_id = @Id", new { Id = id });
    }

    public async Task<string> GenerateUniqueSkuAsync()
    {
        using var conn = Connection;
        var rnd = new Random();
        string sku;
        bool exists;
        do
        {
            sku = rnd.Next(10000000, 99999999).ToString();
            var count = await conn.ExecuteScalarAsync<int>("SELECT COUNT(1) FROM products WHERE barcode = @Sku", new { Sku = sku });
            exists = count > 0;
        } while (exists);
        return sku;
    }
}
