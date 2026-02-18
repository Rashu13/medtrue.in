using Dapper;
using MedTrueApi.Models;
using System.Data;
using ClosedXML.Excel;

namespace MedTrueApi.Repositories;

public class MasterRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public MasterRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    private IDbConnection Connection => _connectionFactory.CreateConnection();

    // --- Schema Management ---
    public async Task EnsureSchemaAsync()
    {
        await EnsureBrandSchemaAsync();
        await EnsureCategorySchemaAsync();
        await EnsureUnitSchemaAsync();
        await EnsureHsnSchemaAsync();
        await EnsureCompanySchemaAsync();
        await EnsureSaltSchemaAsync();
        await EnsurePackingSizeSchemaAsync();
        await EnsureItemTypeSchemaAsync();
        await EnsureDrugScheduleSchemaAsync();
        await EnsureProductBatchSchemaAsync();
    }

    public async Task EnsureBrandSchemaAsync()
    {
        using var conn = Connection;
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS brands (
                id SERIAL PRIMARY KEY,
                uuid VARCHAR(36) NOT NULL,
                title VARCHAR(255) NOT NULL,
                slug VARCHAR(255) NOT NULL,
                description VARCHAR(255),
                status VARCHAR(20) DEFAULT 'active',
                scope_type VARCHAR(50) DEFAULT 'global',
                scope_id BIGINT,
                metadata TEXT,
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NOW()
            );");
    }

    public async Task EnsureCategorySchemaAsync()
    {
        using var conn = Connection;
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS ""categories"" (
                ""category_id"" SERIAL NOT NULL,
                ""name"" VARCHAR(255) NOT NULL,
                ""parent_id"" INTEGER NULL DEFAULT NULL,
                ""image_path"" TEXT NULL DEFAULT NULL,
                ""uuid"" VARCHAR(36) NULL DEFAULT NULL,
                ""slug"" VARCHAR(255) NULL DEFAULT NULL,
                ""title"" VARCHAR(255) NULL DEFAULT NULL,
                ""description"" TEXT NULL DEFAULT NULL,
                ""status"" VARCHAR(20) NULL DEFAULT 'active',
                ""requires_approval"" BOOLEAN NULL DEFAULT false,
                ""sort_order"" INTEGER NULL DEFAULT 0,
                ""commission"" NUMERIC(5,2) NULL DEFAULT 0,
                ""background_type"" VARCHAR(20) NULL DEFAULT NULL,
                ""background_color"" VARCHAR(10) NULL DEFAULT NULL,
                ""font_color"" VARCHAR(255) NULL DEFAULT NULL,
                ""metadata"" TEXT NULL DEFAULT NULL,
                ""created_at"" TIMESTAMP NULL DEFAULT now(),
                ""updated_at"" TIMESTAMP NULL DEFAULT now(),
                PRIMARY KEY (""category_id""),
                UNIQUE (""name"")
            );");
            
        // We assume the schema is correct now or handled by the CREATE TABLE IF NOT EXISTS.
        // If we needed to migrate existing tables to this exact structure, we would need explicit ALTER statements here.
        // For now, adhering to the requested schema creation.
    }

    public async Task EnsureUnitSchemaAsync()
    {
        using var conn = Connection;
        await conn.ExecuteAsync(@"
             CREATE TABLE IF NOT EXISTS units (
                unit_id SERIAL PRIMARY KEY,
                name TEXT NOT NULL,
                description TEXT
            );");
    }

    public async Task EnsureHsnSchemaAsync()
    {
        using var conn = Connection;
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS hsn_codes (
                hsn_sac VARCHAR(20) PRIMARY KEY,
                short_name TEXT,
                sgst_rate DECIMAL(5, 2) DEFAULT 0,
                cgst_rate DECIMAL(5, 2) DEFAULT 0,
                igst_rate DECIMAL(5, 2) DEFAULT 0,
                type TEXT DEFAULT 'Goods',
                uqc TEXT,
                cess_rate DECIMAL(5, 2) DEFAULT 0
            );");
    }

    public async Task EnsureCompanySchemaAsync()
    {
        using var conn = Connection;
         await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS companies (
                company_id SERIAL PRIMARY KEY,
                name TEXT NOT NULL,
                code TEXT,
                address TEXT,
                contact_number TEXT,
                is_active BOOLEAN DEFAULT TRUE,
                preference_order_form INT,
                preference_invoice_printing INT,
                dump_days INT,
                expiry_receive_upto INT,
                minimum_margin DECIMAL(18, 2),
                sales_tax DECIMAL(5, 2),
                sales_cess DECIMAL(5, 2),
                purchase_tax DECIMAL(5, 2),
                purchase_cess DECIMAL(5, 2)
            );");
    }

    public async Task EnsureSaltSchemaAsync()
    {
        using var conn = Connection;
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS salts (
                salt_id SERIAL PRIMARY KEY,
                name TEXT NOT NULL,
                description TEXT,
                is_active BOOLEAN DEFAULT TRUE,
                indications TEXT,
                dosage TEXT,
                side_effects TEXT,
                special_precautions TEXT,
                drug_interactions TEXT,
                is_narcotic BOOLEAN DEFAULT FALSE,
                is_schedule_h BOOLEAN DEFAULT FALSE,
                is_schedule_h1 BOOLEAN DEFAULT FALSE,
                type TEXT,
                maximum_rate DECIMAL(18, 2),
                is_continued BOOLEAN DEFAULT TRUE,
                is_prohibited BOOLEAN DEFAULT FALSE
            );");
    }

    public async Task EnsurePackingSizeSchemaAsync()
    {
        using var conn = Connection;
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS packing_sizes (
                packing_size_id SERIAL PRIMARY KEY,
                name TEXT NOT NULL
            );");
    }

    public async Task EnsureItemTypeSchemaAsync()
    {
        using var conn = Connection;
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS item_types (
                type_id SERIAL PRIMARY KEY,
                name TEXT NOT NULL
            );");
    }


    // --- Generic Pagination ---
    public async Task<(IEnumerable<T> Items, int TotalCount)> GetPagedAsync<T>(string tableName, int page, int pageSize)
    {
        using var conn = Connection;
        var offset = (page - 1) * pageSize;
        var sql = $"SELECT * FROM {tableName} ORDER BY 1 LIMIT @PageSize OFFSET @Offset";
        var countSql = $"SELECT COUNT(1) FROM {tableName}";

        var items = await conn.QueryAsync<T>(sql, new { PageSize = pageSize, Offset = offset });
        var total = await conn.ExecuteScalarAsync<int>(countSql);
        return (items, total);
    }

    // --- Category CRUD ---
    public async Task<long> CreateCategoryAsync(Category category)
    {
        using var conn = Connection;
        
        // Ensure Name is populated (Schema requires it)
        if (string.IsNullOrWhiteSpace(category.Name))
        {
            category.Name = category.Title ?? "Untitled";
        }
        
        var sql = @"
            INSERT INTO categories (
                name, parent_id, image_path, uuid, slug, title, description,
                status, requires_approval, sort_order, commission, background_type,
                background_color, font_color, metadata, created_at, updated_at
            ) VALUES (
                @Name, @ParentId, @ImagePath, @Uuid, @Slug, @Title, @Description,
                @Status, @RequiresApproval, @SortOrder, @Commission, @BackgroundType,
                @BackgroundColor, @FontColor, @Metadata, NOW(), NOW()
            ) RETURNING category_id";
        return await conn.ExecuteScalarAsync<long>(sql, category);
    }

    public async Task UpdateCategoryAsync(Category category)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE categories 
            SET name = @Name, parent_id = @ParentId, image_path = @ImagePath, 
                slug = @Slug, title = @Title, description = @Description,
                status = @Status, requires_approval = @RequiresApproval, sort_order = @SortOrder,
                commission = @Commission, background_type = @BackgroundType,
                background_color = @BackgroundColor, font_color = @FontColor, 
                metadata = @Metadata, updated_at = NOW()
            WHERE category_id = @CategoryId";
        await conn.ExecuteAsync(sql, category);
    }

    public async Task DeleteCategoryAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM categories WHERE category_id = @Id", new { Id = id });
    }

    public async Task<Category?> GetCategoryByIdAsync(int id)
    {
         using var conn = Connection;
         return await conn.QueryFirstOrDefaultAsync<Category>("SELECT * FROM categories WHERE category_id = @Id", new { Id = id });
    }

    public async Task<IEnumerable<Category>> GetAllCategoriesAsync()
    {
         using var conn = Connection;
         return await conn.QueryAsync<Category>("SELECT * FROM categories ORDER BY sort_order");
    }

    // --- Brand CRUD ---
    public async Task<long> CreateBrandAsync(Brand brand)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO brands (uuid, title, slug, description, status, scope_type, scope_id, metadata, created_at, updated_at)
            VALUES (@Uuid, @Title, @Slug, @Description, @Status, @ScopeType, @ScopeId, @Metadata, NOW(), NOW())
            RETURNING id";
        return await conn.ExecuteScalarAsync<long>(sql, brand);
    }

    public async Task<IEnumerable<Brand>> GetAllBrandsAsync()
    {
        using var conn = Connection;
        return await conn.QueryAsync<Brand>("SELECT * FROM brands");
    }

    // --- Company ---
    public async Task<int> CreateCompanyAsync(Company company)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO companies (name, code, address, contact_number, is_active) 
            VALUES (@Name, @Code, @Address, @ContactNumber, @IsActive) 
            RETURNING company_id";
        return await conn.ExecuteScalarAsync<int>(sql, company);
    }

    public async Task UpdateCompanyAsync(Company company)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE companies SET 
                name = @Name, code = @Code, address = @Address, contact_number = @ContactNumber, is_active = @IsActive 
            WHERE company_id = @CompanyId";
        await conn.ExecuteAsync(sql, company);
    }

     public async Task DeleteCompanyAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM companies WHERE company_id = @Id", new { Id = id });
    }

    // --- Salt ---
    public async Task<int> CreateSaltAsync(Salt salt)
    {
         using var conn = Connection;
         var sql = "INSERT INTO salts (name, description, is_active) VALUES (@Name, @Description, @IsActive) RETURNING salt_id";
         return await conn.ExecuteScalarAsync<int>(sql, salt);
    }

    public async Task UpdateSaltAsync(Salt salt)
    {
        using var conn = Connection;
        var sql = "UPDATE salts SET name = @Name, description = @Description, is_active = @IsActive WHERE salt_id = @SaltId";
        await conn.ExecuteAsync(sql, salt);
    }

    public async Task DeleteSaltAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM salts WHERE salt_id = @Id", new { Id = id });
    }

    // --- Unit ---
     public async Task<int> CreateUnitAsync(Unit unit)
    {
        using var conn = Connection;
        var sql = "INSERT INTO units (name, description) VALUES (@Name, @Description) RETURNING unit_id";
        return await conn.ExecuteScalarAsync<int>(sql, unit);
    }

    public async Task UpdateUnitAsync(Unit unit)
    {
        using var conn = Connection;
        var sql = "UPDATE units SET name = @Name, description = @Description WHERE unit_id = @UnitId";
        await conn.ExecuteAsync(sql, unit);
    }

    public async Task DeleteUnitAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM units WHERE unit_id = @Id", new { Id = id });
    }

    // --- HSN Code ---
    public async Task<string> CreateHsnCodeAsync(HsnCode hsn)
    {
        using var conn = Connection;
         var sql = @"
            INSERT INTO hsn_codes (hsn_sac, short_name, sgst_rate, cgst_rate, igst_rate) 
            VALUES (@HsnSac, @ShortName, @SgstRate, @CgstRate, @IgstRate)
            ON CONFLICT (hsn_sac) DO NOTHING
            RETURNING hsn_sac";
         var res = await conn.ExecuteScalarAsync<string>(sql, hsn);
         return res ?? hsn.HsnSac;
    }

    public async Task UpdateHsnCodeAsync(HsnCode hsn)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE hsn_codes SET 
                short_name = @ShortName, sgst_rate = @SgstRate, cgst_rate = @CgstRate, igst_rate = @IgstRate 
            WHERE hsn_sac = @HsnSac";
        await conn.ExecuteAsync(sql, hsn);
    }

    public async Task DeleteHsnCodeAsync(string code)
    {
         using var conn = Connection;
         await conn.ExecuteAsync("DELETE FROM hsn_codes WHERE hsn_sac = @Code", new { Code = code });
    }

    // --- Packing Size ---
    public async Task<int> CreatePackingSizeAsync(PackingSize size)
    {
        using var conn = Connection;
        var sql = "INSERT INTO packing_sizes (name) VALUES (@Name) RETURNING packing_size_id";
        return await conn.ExecuteScalarAsync<int>(sql, size);
    }

    public async Task UpdatePackingSizeAsync(PackingSize size)
    {
        using var conn = Connection;
        var sql = "UPDATE packing_sizes SET name = @Name WHERE packing_size_id = @PackingSizeId";
        await conn.ExecuteAsync(sql, size);
    }

    public async Task DeletePackingSizeAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM packing_sizes WHERE packing_size_id = @Id", new { Id = id });
    }

    // --- Item Type ---
    public async Task<int> CreateItemTypeAsync(ItemType itemType)
    {
        using var conn = Connection;
        var sql = "INSERT INTO item_types (name) VALUES (@Name) RETURNING type_id";
        return await conn.ExecuteScalarAsync<int>(sql, itemType);
    }

    public async Task UpdateItemTypeAsync(ItemType itemType)
    {
        using var conn = Connection;
        var sql = "UPDATE item_types SET name = @Name WHERE type_id = @TypeId";
        await conn.ExecuteAsync(sql, itemType);
    }

    public async Task DeleteItemTypeAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM item_types WHERE type_id = @Id", new { Id = id });
    }

    // --- Drug Schedule ---
    public async Task EnsureDrugScheduleSchemaAsync()
    {
        using var conn = Connection;
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS drug_schedules (
                schedule_id SERIAL PRIMARY KEY,
                name TEXT NOT NULL,
                requires_prescription BOOLEAN DEFAULT TRUE,
                warning_label TEXT
            );");
    }

    public async Task<int> CreateDrugScheduleAsync(DrugSchedule schedule)
    {
        using var conn = Connection;
        var sql = "INSERT INTO drug_schedules (name, requires_prescription, warning_label) VALUES (@Name, @RequiresPrescription, @WarningLabel) RETURNING schedule_id";
        return await conn.ExecuteScalarAsync<int>(sql, schedule);
    }

    public async Task UpdateDrugScheduleAsync(DrugSchedule schedule)
    {
        using var conn = Connection;
        var sql = "UPDATE drug_schedules SET name = @Name, requires_prescription = @RequiresPrescription, warning_label = @WarningLabel WHERE schedule_id = @ScheduleId";
        await conn.ExecuteAsync(sql, schedule);
    }

    public async Task DeleteDrugScheduleAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM drug_schedules WHERE schedule_id = @Id", new { Id = id });
    }

    // --- Product Batch ---
    public async Task EnsureProductBatchSchemaAsync()
    {
        using var conn = Connection;
        await conn.ExecuteAsync(@"
            CREATE TABLE IF NOT EXISTS product_batches (
                batch_id SERIAL PRIMARY KEY,
                product_id BIGINT NOT NULL,
                batch_number VARCHAR(100) NOT NULL,
                expiry_date DATE,
                mrp DECIMAL(10,2),
                purchase_rate DECIMAL(10,2),
                quantity_available DECIMAL(10,2) DEFAULT 0,
                entry_date DATE DEFAULT CURRENT_DATE
            );");
    }

    public async Task<long> CreateProductBatchAsync(ProductBatch batch)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO product_batches (product_id, batch_number, expiry_date, mrp, purchase_rate, quantity_available, entry_date)
            VALUES (@ProductId, @BatchNumber, @ExpiryDate, @Mrp, @PurchaseRate, @QuantityAvailable, @EntryDate)
            RETURNING batch_id";
        return await conn.ExecuteScalarAsync<long>(sql, batch);
    }

    public async Task UpdateProductBatchAsync(ProductBatch batch)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE product_batches SET
                product_id = @ProductId, batch_number = @BatchNumber,
                expiry_date = @ExpiryDate, mrp = @Mrp, purchase_rate = @PurchaseRate,
                quantity_available = @QuantityAvailable, entry_date = @EntryDate
            WHERE batch_id = @BatchId";
        await conn.ExecuteAsync(sql, batch);
    }

    public async Task DeleteProductBatchAsync(long id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM product_batches WHERE batch_id = @Id", new { Id = id });
    }

    // --- Import ---
    public async Task<int> ImportMasterDataAsync(string type, Stream stream)
    {
        int count = 0;
        using var workbook = new XLWorkbook(stream);
        var worksheet = workbook.Worksheet(1);
        var rows = worksheet.RangeUsed().RowsUsed().Skip(1); // Skip header

        switch (type.ToLower())
        {
            case "companies":
                foreach (var row in rows)
                {
                    try {
                        var company = new Company
                        {
                            Name = row.Cell(1).GetValue<string>(),
                            Code = row.Cell(2).GetValue<string>(),
                            ContactNumber = row.Cell(3).GetValue<string>(),
                            Address = row.Cell(4).GetValue<string>(),
                            PreferenceOrderForm = row.Cell(5).GetValue<int>()
                        };
                        await CreateCompanyAsync(company);
                        count++;
                    } catch {}
                }
                break;
            case "salts":
                foreach (var row in rows)
                {
                    try {
                        var salt = new Salt
                        {
                            Name = row.Cell(1).GetValue<string>(),
                            Dosage = row.Cell(2).GetValue<string>(),
                            Type = row.Cell(3).GetValue<string>(),
                        };
                        await CreateSaltAsync(salt);
                        count++;
                    } catch {}
                }
                break;
             case "units":
                foreach (var row in rows)
                {
                    try {
                        var unit = new Unit
                        {
                            Name = row.Cell(1).GetValue<string>(),
                            Description = row.Cell(2).GetValue<string>(),
                        };
                        await CreateUnitAsync(unit);
                        count++;
                    } catch {}
                }
                break;
            // Add other cases as needed
        }
        return count;
    }
}
