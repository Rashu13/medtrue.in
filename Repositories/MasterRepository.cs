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

    // Schema Migration Helper (Temporary/Auto-fix)
    public async Task EnsureSaltSchemaAsync()
    {
        using var conn = Connection;
        var sql = @"
            DO $$ 
            BEGIN 
                -- Add columns if they don't exist
                BEGIN
                    ALTER TABLE salts ADD COLUMN indications TEXT;
                    ALTER TABLE salts ADD COLUMN dosage TEXT;
                    ALTER TABLE salts ADD COLUMN side_effects TEXT;
                    ALTER TABLE salts ADD COLUMN special_precautions TEXT;
                    ALTER TABLE salts ADD COLUMN drug_interactions TEXT;
                    ALTER TABLE salts ADD COLUMN is_narcotic BOOLEAN DEFAULT FALSE;
                    ALTER TABLE salts ADD COLUMN is_schedule_h BOOLEAN DEFAULT FALSE;
                    ALTER TABLE salts ADD COLUMN is_schedule_h1 BOOLEAN DEFAULT FALSE;
                    ALTER TABLE salts ADD COLUMN type TEXT;
                    ALTER TABLE salts ADD COLUMN maximum_rate DECIMAL(18, 2);
                    ALTER TABLE salts ADD COLUMN is_continued BOOLEAN DEFAULT TRUE;
                    ALTER TABLE salts ADD COLUMN is_prohibited BOOLEAN DEFAULT FALSE;
                EXCEPTION
                    WHEN duplicate_column THEN RAISE NOTICE 'column already exists';
                END;
            END $$;";
        await conn.ExecuteAsync(sql);
    }

    public async Task EnsureCompanySchemaAsync()
    {
        using var conn = Connection;
        var sql = @"
            DO $$ 
            BEGIN 
                -- Add columns if they don't exist
                BEGIN
                    ALTER TABLE companies ADD COLUMN preference_order_form INT;
                    ALTER TABLE companies ADD COLUMN preference_invoice_printing INT;
                    ALTER TABLE companies ADD COLUMN dump_days INT;
                    ALTER TABLE companies ADD COLUMN expiry_receive_upto INT;
                    ALTER TABLE companies ADD COLUMN minimum_margin DECIMAL(18, 2);
                    ALTER TABLE companies ADD COLUMN sales_tax DECIMAL(5, 2);
                    ALTER TABLE companies ADD COLUMN sales_cess DECIMAL(5, 2);
                    ALTER TABLE companies ADD COLUMN purchase_tax DECIMAL(5, 2);
                    ALTER TABLE companies ADD COLUMN purchase_cess DECIMAL(5, 2);
                EXCEPTION
                    WHEN duplicate_column THEN RAISE NOTICE 'column already exists';
                END;
            END $$;";
        await conn.ExecuteAsync(sql);
    }

    public async Task EnsureUnitSchemaAsync()
    {
        using var conn = Connection;
        var sql = @"
            CREATE TABLE IF NOT EXISTS units (
                unit_id SERIAL PRIMARY KEY,
                name TEXT NOT NULL,
                description TEXT
            );";
        await conn.ExecuteAsync(sql);
    }

    public async Task EnsureCategorySchemaAsync()
    {
        using var conn = Connection;
        // Add image_path column if it doesn't exist
        var sql = @"
            DO $$ BEGIN
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'categories' AND column_name = 'image_path') THEN
                    ALTER TABLE categories ADD COLUMN image_path TEXT;
                END IF;
            END $$;";
        await conn.ExecuteAsync(sql);
    }

    public async Task EnsureHsnSchemaAsync()
    {
        using var conn = Connection;
        // Drop old table if exists with old schema and recreate with new schema
        var sql = @"
            DROP TABLE IF EXISTS hsn_codes CASCADE;
            CREATE TABLE hsn_codes (
                hsn_sac VARCHAR(20) PRIMARY KEY,
                short_name TEXT,
                sgst_rate DECIMAL(5, 2) DEFAULT 0,
                cgst_rate DECIMAL(5, 2) DEFAULT 0,
                igst_rate DECIMAL(5, 2) DEFAULT 0,
                type TEXT DEFAULT 'Goods',
                uqc TEXT,
                cess_rate DECIMAL(5, 2) DEFAULT 0
            );";
        await conn.ExecuteAsync(sql);
    }

    // Generic Get All
    public async Task<IEnumerable<T>> GetAllAsync<T>(string tableName)
    {
        using var conn = Connection;
        return await conn.QueryAsync<T>($"SELECT * FROM {tableName}");
    }

    // Generic Get Paged
    public async Task<(IEnumerable<T> Items, int TotalCount)> GetPagedAsync<T>(string tableName, int page, int pageSize)
    {
        using var conn = Connection;
        var offset = (page - 1) * pageSize;
        var sql = $@"
            SELECT * FROM {tableName} ORDER BY 1 LIMIT @PageSize OFFSET @Offset;
            SELECT COUNT(*) FROM {tableName};";
        
        using var multi = await conn.QueryMultipleAsync(sql, new { PageSize = pageSize, Offset = offset });
        var items = await multi.ReadAsync<T>();
        var totalCount = await multi.ReadFirstAsync<int>();
        
        return (items, totalCount);
    }

    // Companies
    public async Task<int> CreateCompanyAsync(Company company)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO companies (
                name, code, address, contact_number, is_active,
                preference_order_form, preference_invoice_printing, dump_days, expiry_receive_upto,
                minimum_margin, sales_tax, sales_cess, purchase_tax, purchase_cess
            ) 
            VALUES (
                @Name, @Code, @Address, @ContactNumber, @IsActive,
                @PreferenceOrderForm, @PreferenceInvoicePrinting, @DumpDays, @ExpiryReceiveUpto,
                @MinimumMargin, @SalesTax, @SalesCess, @PurchaseTax, @PurchaseCess
            ) 
            RETURNING company_id";
        return await conn.ExecuteScalarAsync<int>(sql, company);
    }

    public async Task UpdateCompanyAsync(Company company)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE companies 
            SET 
                name = @Name, 
                code = @Code, 
                address = @Address, 
                contact_number = @ContactNumber, 
                is_active = @IsActive,
                preference_order_form = @PreferenceOrderForm,
                preference_invoice_printing = @PreferenceInvoicePrinting,
                dump_days = @DumpDays,
                expiry_receive_upto = @ExpiryReceiveUpto,
                minimum_margin = @MinimumMargin,
                sales_tax = @SalesTax,
                sales_cess = @SalesCess,
                purchase_tax = @PurchaseTax,
                purchase_cess = @PurchaseCess
            WHERE company_id = @CompanyId";
        await conn.ExecuteAsync(sql, company);
    }

    // Salts
    public async Task<int> CreateSaltAsync(Salt salt)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO salts (
                name, description, is_active, 
                indications, dosage, side_effects, special_precautions, drug_interactions,
                is_narcotic, is_schedule_h, is_schedule_h1, type, maximum_rate, is_continued, is_prohibited
            ) 
            VALUES (
                @Name, @Description, @IsActive,
                @Indications, @Dosage, @SideEffects, @SpecialPrecautions, @DrugInteractions,
                @IsNarcotic, @IsScheduleH, @IsScheduleH1, @Type, @MaximumRate, @IsContinued, @IsProhibited
            ) 
            RETURNING salt_id";
        return await conn.ExecuteScalarAsync<int>(sql, salt);
    }

    public async Task UpdateSaltAsync(Salt salt)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE salts 
            SET 
                name = @Name, 
                description = @Description, 
                is_active = @IsActive,
                indications = @Indications,
                dosage = @Dosage,
                side_effects = @SideEffects,
                special_precautions = @SpecialPrecautions,
                drug_interactions = @DrugInteractions,
                is_narcotic = @IsNarcotic,
                is_schedule_h = @IsScheduleH,
                is_schedule_h1 = @IsScheduleH1,
                type = @Type,
                maximum_rate = @MaximumRate,
                is_continued = @IsContinued,
                is_prohibited = @IsProhibited
            WHERE salt_id = @SaltId";
        await conn.ExecuteAsync(sql, salt);
    }

    // Categories
    public async Task<int> CreateCategoryAsync(Category category)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO categories (name, parent_id, image_path) 
            VALUES (@Name, @ParentId, @ImagePath) 
            RETURNING category_id";
        return await conn.ExecuteScalarAsync<int>(sql, category);
    }

    public async Task UpdateCategoryAsync(Category category)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE categories 
            SET name = @Name, parent_id = @ParentId, image_path = @ImagePath 
            WHERE category_id = @CategoryId";
        await conn.ExecuteAsync(sql, category);
    }
    
    // Units
    public async Task<int> CreateUnitAsync(Unit unit)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO units (name, description) 
            VALUES (@Name, @Description) 
            RETURNING unit_id";
        return await conn.ExecuteScalarAsync<int>(sql, unit);
    }

    public async Task UpdateUnitAsync(Unit unit)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE units 
            SET name = @Name, description = @Description 
            WHERE unit_id = @UnitId";
        await conn.ExecuteAsync(sql, unit);
    }

    // Packing Sizes
    public async Task EnsurePackingSizeSchemaAsync()
    {
        using var conn = Connection;
        var sql = @"
            CREATE TABLE IF NOT EXISTS packing_sizes (
                packing_size_id SERIAL PRIMARY KEY,
                name TEXT NOT NULL
            );";
        await conn.ExecuteAsync(sql);
    }

    public async Task<int> CreatePackingSizeAsync(PackingSize size)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO packing_sizes (name) 
            VALUES (@Name) 
            RETURNING packing_size_id";
        return await conn.ExecuteScalarAsync<int>(sql, size);
    }

    public async Task UpdatePackingSizeAsync(PackingSize size)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE packing_sizes 
            SET name = @Name 
            WHERE packing_size_id = @PackingSizeId";
        await conn.ExecuteAsync(sql, size);
    }

    public async Task DeletePackingSizeAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM packing_sizes WHERE packing_size_id = @Id", new { Id = id });
    }

    // Item Types
    public async Task<int> CreateItemTypeAsync(ItemType itemType)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO item_types (name) 
            VALUES (@Name) 
            RETURNING type_id";
        return await conn.ExecuteScalarAsync<int>(sql, itemType);
    }

    public async Task UpdateItemTypeAsync(ItemType itemType)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE item_types 
            SET name = @Name 
            WHERE type_id = @TypeId";
        await conn.ExecuteAsync(sql, itemType);
    }

    // Delete Methods
    public async Task DeleteCompanyAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM companies WHERE company_id = @Id", new { Id = id });
    }

    public async Task DeleteSaltAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM salts WHERE salt_id = @Id", new { Id = id });
    }

    public async Task DeleteCategoryAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM categories WHERE category_id = @Id", new { Id = id });
    }

    public async Task DeleteUnitAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM units WHERE unit_id = @Id", new { Id = id });
    }

    public async Task DeleteItemTypeAsync(int id)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM item_types WHERE type_id = @Id", new { Id = id });
    }

    // HSN Codes
    public async Task<string> CreateHsnCodeAsync(HsnCode hsn)
    {
        using var conn = Connection;
        var sql = @"
            INSERT INTO hsn_codes (hsn_sac, short_name, sgst_rate, cgst_rate, igst_rate, type, uqc, cess_rate) 
            VALUES (@HsnSac, @ShortName, @SgstRate, @CgstRate, @IgstRate, @Type, @Uqc, @CessRate)
            ON CONFLICT (hsn_sac) DO NOTHING
            RETURNING hsn_sac";
        var result = await conn.ExecuteScalarAsync<string>(sql, hsn);
        return result ?? hsn.HsnSac;
    }

    public async Task UpdateHsnCodeAsync(HsnCode hsn)
    {
        using var conn = Connection;
        var sql = @"
            UPDATE hsn_codes 
            SET short_name = @ShortName, sgst_rate = @SgstRate, cgst_rate = @CgstRate, 
                igst_rate = @IgstRate, type = @Type, uqc = @Uqc, cess_rate = @CessRate
            WHERE hsn_sac = @HsnSac";
        await conn.ExecuteAsync(sql, hsn);
    }

    public async Task DeleteHsnCodeAsync(string code)
    {
        using var conn = Connection;
        await conn.ExecuteAsync("DELETE FROM hsn_codes WHERE hsn_sac = @Code", new { Code = code });
    }

    // Import / Upload Logic
    public async Task<int> ImportMasterDataAsync(string type, Stream fileStream)
    {
        using var workbook = new XLWorkbook(fileStream);
        var worksheet = workbook.Worksheet(1);
        var rangeUsed = worksheet.RangeUsed();
        if (rangeUsed == null) return 0;
        var rows = rangeUsed.RowsUsed().Skip(1); // Skip header

        int count = 0;
        foreach (var row in rows)
        {
            try 
            {
                switch (type.ToLower())
                {
                    case "companies":
                        var company = new Company
                        {
                            Name = row.Cell(1).GetValue<string>(),
                            Code = row.Cell(2).GetValue<string>(),
                            ContactNumber = row.Cell(3).GetValue<string>(),
                            Address = row.Cell(4).GetValue<string>(),
                            // Initialize defaults for new fields if not present in basic upload
                            IsActive = true,
                             // Optional: Advanced fields if columns exist (assuming fixed order for simplicity for now, or use named lookup later)
                             // For "Sabke liye" quick implementation, we prioritize getting the basic data in, users can edit details.
                        };
                         // Try to read advanced fields if they exist (cols 5+)
                        if(!row.Cell(5).IsEmpty()) company.PreferenceOrderForm = row.Cell(5).GetValue<int>();
                        if(!row.Cell(6).IsEmpty()) company.PreferenceInvoicePrinting = row.Cell(6).GetValue<int>();
                        if(!row.Cell(7).IsEmpty()) company.DumpDays = row.Cell(7).GetValue<int>();
                        if(!row.Cell(8).IsEmpty()) company.ExpiryReceiveUpto = row.Cell(8).GetValue<int>();
                        if(!row.Cell(9).IsEmpty()) company.MinimumMargin = row.Cell(9).GetValue<decimal>();
                        if(!row.Cell(10).IsEmpty()) company.SalesTax = row.Cell(10).GetValue<decimal>();
                        if(!row.Cell(11).IsEmpty()) company.SalesCess = row.Cell(11).GetValue<decimal>();
                        if(!row.Cell(12).IsEmpty()) company.PurchaseTax = row.Cell(12).GetValue<decimal>();
                        if(!row.Cell(13).IsEmpty()) company.PurchaseCess = row.Cell(13).GetValue<decimal>();

                        await CreateCompanyAsync(company);
                        break;

                    case "salts":
                        var salt = new Salt
                        {
                            Name = row.Cell(1).GetValue<string>(),
                            Dosage = row.Cell(2).GetValue<string>(),
                            Type = row.Cell(3).GetValue<string>(),
                            Indications = row.Cell(4).GetValue<string>(),
                            SideEffects = row.Cell(5).GetValue<string>(),
                            SpecialPrecautions = row.Cell(6).GetValue<string>(),
                            DrugInteractions = row.Cell(7).GetValue<string>(),
                            Description = row.Cell(8).GetValue<string>(),
                            IsActive = true
                        };
                         // Boolean flags (cols 9+) - parsing "Y"/"N" or true/false
                        if(!row.Cell(9).IsEmpty()) salt.IsNarcotic = ParseBool(row.Cell(9).Value.ToString());
                        if(!row.Cell(10).IsEmpty()) salt.IsScheduleH = ParseBool(row.Cell(10).Value.ToString());
                        if(!row.Cell(11).IsEmpty()) salt.IsScheduleH1 = ParseBool(row.Cell(11).Value.ToString());
                        if(!row.Cell(12).IsEmpty()) salt.IsContinued = ParseBool(row.Cell(12).Value.ToString());
                        if(!row.Cell(13).IsEmpty()) salt.IsProhibited = ParseBool(row.Cell(13).Value.ToString());

                        await CreateSaltAsync(salt);
                        break;

                    case "categories":
                        var category = new Category
                        {
                            Name = row.Cell(1).GetValue<string>()
                            // ParentId support pending
                        };
                        await CreateCategoryAsync(category);
                        break;

                    case "units":
                        var unit = new Unit
                        {
                            Name = row.Cell(1).GetValue<string>(),
                            Description = row.Cell(2).GetValue<string>()
                        };
                        await CreateUnitAsync(unit);
                        break;

                    case "itemtypes":
                        var itemType = new ItemType
                        {
                            Name = row.Cell(1).GetValue<string>()
                        };
                        await CreateItemTypeAsync(itemType);
                        break;
                }
                count++;
            }
            catch (Exception ex)
            {
                // Verify if its just an empty row at end
                if (string.IsNullOrWhiteSpace(row.Cell(1).GetString())) continue;
                // Log error or continue? For now continue.
                Console.WriteLine($"Error importing row {row.RowNumber()}: {ex.Message}");
            }
        }
        return count;
    }

    private bool ParseBool(string val)
    {
        if (string.IsNullOrWhiteSpace(val)) return false;
        val = val.Trim().ToLower();
        return val == "1" || val == "true" || val == "yes" || val == "y";
    }
}

