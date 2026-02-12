using Dapper;
using MedTrueApi.Models;
using System.Data;

namespace MedTrueApi.Repositories;

public class ContentRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public ContentRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    private IDbConnection Connection => _connectionFactory.CreateConnection();

    // --- Schema Management ---
    public async Task EnsureSchemaAsync()
    {
        using var conn = Connection;
        
        // Banners Table - Ensure base table exists with user's schema
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS banners (
                banner_id SERIAL PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                image_path TEXT,
                type VARCHAR(50) DEFAULT 'custom',
                scope_type VARCHAR(50) DEFAULT 'global',
                position VARCHAR(50) DEFAULT 'top',
                is_active BOOLEAN DEFAULT true,
                display_order INTEGER DEFAULT 0,
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NULL
            );");

        // Schema Evolution: Add columns if they don't exist (Handling user's partial schema)
        await conn.ExecuteAsync(@"
            DO $$ 
            BEGIN 
                -- Add missing columns if any
                BEGIN ALTER TABLE banners ADD COLUMN slug VARCHAR(255); EXCEPTION WHEN duplicate_column THEN END;
                BEGIN ALTER TABLE banners ADD COLUMN custom_url VARCHAR(255); EXCEPTION WHEN duplicate_column THEN END;
                BEGIN ALTER TABLE banners ADD COLUMN scope_id BIGINT; EXCEPTION WHEN duplicate_column THEN END;
                BEGIN ALTER TABLE banners ADD COLUMN product_id BIGINT; EXCEPTION WHEN duplicate_column THEN END;
                BEGIN ALTER TABLE banners ADD COLUMN category_id BIGINT; EXCEPTION WHEN duplicate_column THEN END;
                BEGIN ALTER TABLE banners ADD COLUMN brand_id BIGINT; EXCEPTION WHEN duplicate_column THEN END;
                BEGIN ALTER TABLE banners ADD COLUMN metadata TEXT; EXCEPTION WHEN duplicate_column THEN END;
                
                -- Ensure image_path exists (user suggested it might be missing in some versions)
                BEGIN ALTER TABLE banners ADD COLUMN image_path TEXT; EXCEPTION WHEN duplicate_column THEN END;

                -- Ensure is_active exists (if migrating from visibility_status)
                BEGIN ALTER TABLE banners ADD COLUMN is_active BOOLEAN DEFAULT true; EXCEPTION WHEN duplicate_column THEN END;
            END $$;");

        // Featured Sections Table
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS featured_sections (
                section_id SERIAL PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                slug VARCHAR(255) DEFAULT NULL,
                scope_type VARCHAR(50) DEFAULT 'global',
                section_type VARCHAR(50) DEFAULT 'custom',
                is_active BOOLEAN DEFAULT true,
                sort_order INTEGER DEFAULT 0,
                
                -- Additional columns for model compatibility
                short_description TEXT,
                scope_id BIGINT,
                style VARCHAR(255) DEFAULT 'default',
                background_type VARCHAR(50),
                background_color VARCHAR(255),
                text_color VARCHAR(255) DEFAULT '#000000',
                
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NULL
            );");

         // Evolution for Featured Sections
         await conn.ExecuteAsync(@"
            DO $$ 
            BEGIN 
                BEGIN ALTER TABLE featured_sections ADD COLUMN slug VARCHAR(255); EXCEPTION WHEN duplicate_column THEN END;
                BEGIN ALTER TABLE featured_sections ADD COLUMN scope_type VARCHAR(50); EXCEPTION WHEN duplicate_column THEN END;
                BEGIN ALTER TABLE featured_sections ADD COLUMN section_type VARCHAR(50); EXCEPTION WHEN duplicate_column THEN END;
                BEGIN ALTER TABLE featured_sections ADD COLUMN is_active BOOLEAN DEFAULT true; EXCEPTION WHEN duplicate_column THEN END;
                BEGIN ALTER TABLE featured_sections ADD COLUMN sort_order INTEGER DEFAULT 0; EXCEPTION WHEN duplicate_column THEN END;
                
                -- Ensure extra model columns exist
                BEGIN ALTER TABLE featured_sections ADD COLUMN short_description TEXT; EXCEPTION WHEN duplicate_column THEN END;
                BEGIN ALTER TABLE featured_sections ADD COLUMN scope_id BIGINT; EXCEPTION WHEN duplicate_column THEN END;
                BEGIN ALTER TABLE featured_sections ADD COLUMN style VARCHAR(255) DEFAULT 'default'; EXCEPTION WHEN duplicate_column THEN END;
                BEGIN ALTER TABLE featured_sections ADD COLUMN background_type VARCHAR(50); EXCEPTION WHEN duplicate_column THEN END;
                BEGIN ALTER TABLE featured_sections ADD COLUMN background_color VARCHAR(255); EXCEPTION WHEN duplicate_column THEN END;
                BEGIN ALTER TABLE featured_sections ADD COLUMN text_color VARCHAR(255) DEFAULT '#000000'; EXCEPTION WHEN duplicate_column THEN END;
            END $$;");

        // Force add updated_at and is_active using standard SQL to avoid PL/pgSQL block issues
        try 
        {
            await conn.ExecuteAsync("ALTER TABLE featured_sections ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NULL;");
            await conn.ExecuteAsync("ALTER TABLE featured_sections ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;");
            Console.WriteLine("Schema evolution for featured_sections executed.");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error updating featured_sections schema: {ex.Message}");
        }
    }

    // --- Banners CRUD ---
    // (Existing Banners CRUD code omitted for brevity as it is unchanged here)

    public async Task<(IEnumerable<Banner> Items, int Total)> GetBannersAsync(int page, int pageSize)
    {
        using var conn = Connection;
        var offset = (page - 1) * pageSize;

        // Map database columns to Model properties
        var sql = @"
            SELECT 
                banner_id as Id,
                title as Title,
                slug as Slug,
                custom_url as CustomUrl,
                image_path as ImagePath,
                type as Type,
                scope_type as ScopeType,
                scope_id as ScopeId,
                product_id as ProductId,
                category_id as CategoryId,
                brand_id as BrandId,
                position as Position,
                is_active as IsActive,
                display_order as DisplayOrder,
                metadata as Metadata,
                created_at as CreatedAt,
                updated_at as UpdatedAt
            FROM banners 
            ORDER BY display_order, created_at DESC 
            LIMIT @PageSize OFFSET @Offset;
            
            SELECT COUNT(*) FROM banners;
        ";

        using var multi = await conn.QueryMultipleAsync(sql, new { PageSize = pageSize, Offset = offset });
        var items = await multi.ReadAsync<Banner>();
        var total = await multi.ReadFirstAsync<int>();

        return (items, total);
    }

    public async Task<long> CreateBannerAsync(Banner banner)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO banners (
                title, slug, custom_url, image_path, type, scope_type, scope_id, 
                product_id, category_id, brand_id, position, is_active, display_order, metadata, created_at, updated_at
            )
            VALUES (
                @Title, @Slug, @CustomUrl, @ImagePath, @Type, @ScopeType, @ScopeId,
                @ProductId, @CategoryId, @BrandId, @Position, @IsActive, @DisplayOrder, @Metadata, NOW(), NOW()
            )
            RETURNING banner_id";
        return await conn.ExecuteScalarAsync<long>(sql, banner);
    }

    public async Task UpdateBannerAsync(Banner banner)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE banners 
            SET title = @Title, slug = @Slug, custom_url = @CustomUrl, image_path = @ImagePath,
                type = @Type, scope_type = @ScopeType, scope_id = @ScopeId,
                product_id = @ProductId, category_id = @CategoryId, brand_id = @BrandId,
                position = @Position, is_active = @IsActive, display_order = @DisplayOrder,
                metadata = @Metadata, updated_at = NOW()
            WHERE banner_id = @Id";
        await conn.ExecuteAsync(sql, banner);
    }

    public async Task DeleteBannerAsync(long id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM banners WHERE banner_id = @Id", new { Id = id });
    }

    // --- Featured Sections CRUD ---

    public async Task<(IEnumerable<FeaturedSection> Items, int Total)> GetFeaturedSectionsAsync(int page, int pageSize)
    {
        using var conn = Connection;
        var offset = (page - 1) * pageSize;

        var sql = @"
            SELECT 
                section_id as Id,
                title as Title,
                slug as Slug,
                short_description as ShortDescription,
                scope_type as ScopeType,
                scope_id as ScopeId,
                section_type as SectionType,
                style as Style,
                background_type as BackgroundType,
                background_color as BackgroundColor,
                text_color as TextColor,
                is_active as IsActive,
                sort_order as SortOrder,
                created_at as CreatedAt,
                updated_at as UpdatedAt
            FROM featured_sections 
            ORDER BY sort_order, created_at DESC 
            LIMIT @PageSize OFFSET @Offset;
            
            SELECT COUNT(*) FROM featured_sections;
        ";

        using var multi = await conn.QueryMultipleAsync(sql, new { PageSize = pageSize, Offset = offset });
        var items = await multi.ReadAsync<FeaturedSection>();
        var total = await multi.ReadFirstAsync<int>();

        return (items, total);
    }

    public async Task<long> CreateFeaturedSectionAsync(FeaturedSection section)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO featured_sections (
                title, slug, short_description, scope_type, scope_id, section_type, style,
                background_type, background_color, text_color, is_active, sort_order, created_at, updated_at
            )
            VALUES (
                @Title, @Slug, @ShortDescription, @ScopeType, @ScopeId, @SectionType, @Style,
                @BackgroundType, @BackgroundColor, @TextColor, @IsActive, @SortOrder, NOW(), NOW()
            )
            RETURNING section_id";
        return await conn.ExecuteScalarAsync<long>(sql, section);
    }

    public async Task UpdateFeaturedSectionAsync(FeaturedSection section)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE featured_sections 
            SET title = @Title, slug = @Slug, short_description = @ShortDescription,
                scope_type = @ScopeType, scope_id = @ScopeId, section_type = @SectionType,
                style = @Style, background_type = @BackgroundType, background_color = @BackgroundColor,
                text_color = @TextColor, is_active = @IsActive, sort_order = @SortOrder, updated_at = NOW()
            WHERE section_id = @Id";
        await conn.ExecuteAsync(sql, section);
    }

    public async Task DeleteFeaturedSectionAsync(long id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM featured_sections WHERE section_id = @Id", new { Id = id });
    }
    public async Task<IEnumerable<dynamic>> GetTableSchemaAsync()
    {
        using var conn = Connection;
        var sql = @"
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'banners';";
        return await conn.QueryAsync(sql);
    }

    // --- Homepage: Featured Sections with Products ---

    public async Task<IEnumerable<FeaturedSection>> GetActiveFeaturedSectionsAsync()
    {
        using var conn = Connection;
        var sql = @"
            SELECT 
                section_id as Id,
                title as Title,
                slug as Slug,
                short_description as ShortDescription,
                scope_type as ScopeType,
                scope_id as ScopeId,
                section_type as SectionType,
                style as Style,
                background_type as BackgroundType,
                background_color as BackgroundColor,
                text_color as TextColor,
                is_active as IsActive,
                sort_order as SortOrder
            FROM featured_sections 
            WHERE is_active = true
            ORDER BY sort_order, created_at DESC";
        return await conn.QueryAsync<FeaturedSection>(sql);
    }

    public async Task<IEnumerable<dynamic>> GetProductsBySectionTypeAsync(string? sectionType, int limit = 10)
    {
        using var conn = Connection;

        var baseSelect = @"
            SELECT p.product_id as ProductId, p.name as Name, p.mrp as Mrp, 
                   p.sale_price as SalePrice, p.current_stock as CurrentStock, 
                   p.status as Status, p.barcode as Barcode,
                   pi.image_path as PrimaryImagePath
            FROM products p
            LEFT JOIN product_images pi ON pi.product_id = p.product_id AND pi.is_primary = true";

        var sql = sectionType?.ToLower() switch
        {
            "newly_added" => $"{baseSelect} ORDER BY p.created_at DESC LIMIT @Limit",
            "best_selling" => $"{baseSelect} ORDER BY p.current_stock ASC LIMIT @Limit",  // Proxy: low stock = high demand
            "discounted" => $"{baseSelect} WHERE p.sale_price < p.mrp AND p.sale_price > 0 ORDER BY (p.mrp - p.sale_price) DESC LIMIT @Limit",
            "top_rated" => $"{baseSelect} ORDER BY p.mrp DESC LIMIT @Limit",  // Placeholder until reviews
            "in_stock" => $"{baseSelect} WHERE p.current_stock > 0 ORDER BY p.name LIMIT @Limit",
            _ => $"{baseSelect} ORDER BY p.created_at DESC LIMIT @Limit"  // Default: newest
        };

        return await conn.QueryAsync(sql, new { Limit = limit });
    }
}
