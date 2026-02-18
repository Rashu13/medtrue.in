-- Comprehensive ERP Product Schema based on Legacy UI
-- Generated for PostgreSQL
-- ==========================================
-- 1. MASTER TABLES (Dropdowns & References)
-- ==========================================
-- Companies / Manufacturers (e.g., BAYER PHARMACEUTICALS)
CREATE TABLE IF NOT EXISTS companies (
    company_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    code VARCHAR(50),
    -- Optional short code
    address TEXT,
    contact_number VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE
);
-- Salts / Generic Compositions (e.g., Paracetamol, Metformin)
CREATE TABLE IF NOT EXISTS salts (
    salt_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE
);
-- Categories (e.g., Pharma, Surgical, FMCG)
CREATE TABLE IF NOT EXISTS categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    parent_id INT REFERENCES categories(category_id)
);
-- Units (e.g., TAB, STRIP, BOTTLE, BOX)
CREATE TABLE IF NOT EXISTS units (
    unit_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    -- e.g., "TAB", "STRIP"
    description VARCHAR(100)
);
-- HSN Codes (Taxation)
CREATE TABLE IF NOT EXISTS hsn_codes (
    hsn_code VARCHAR(20) PRIMARY KEY,
    -- e.g., "3004"
    description TEXT,
    gst_rate DECIMAL(5, 2) -- Standard rate associated with this HSN
);
-- Item Types (e.g., NORMAL, COLD CHAIN)
CREATE TABLE IF NOT EXISTS item_types (
    type_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE -- e.g., "NORMAL", "FRIDGE"
);
-- Drug Schedules (Regulatory)
CREATE TABLE IF NOT EXISTS drug_schedules (
    schedule_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    -- e.g., "H", "H1", "X", "NARCOTIC"
    requires_prescription BOOLEAN DEFAULT TRUE,
    warning_label TEXT
);
-- ==========================================
-- 2. MAIN PRODUCT TABLE
-- ==========================================
CREATE TABLE IF NOT EXISTS products (
    product_id BIGSERIAL PRIMARY KEY,
    -- Basic Identity
    name VARCHAR(255) NOT NULL,
    packing_desc VARCHAR(100),
    -- "10 TAB", "150ml" (UI field: PACKING)
    barcode VARCHAR(100),
    -- Relationships (Foreign Keys to Masters)
    company_id INT REFERENCES companies(company_id),
    salt_id INT REFERENCES salts(salt_id),
    category_id INT REFERENCES categories(category_id),
    hsn_code VARCHAR(20) REFERENCES hsn_codes(hsn_code),
    item_type_id INT REFERENCES item_types(type_id),
    -- Units & Conversion
    unit_primary_id INT REFERENCES units(unit_id),
    -- "UNIT 1st" (e.g., TAB)
    unit_secondary_id INT REFERENCES units(unit_id),
    -- "UNIT 2nd" (e.g., STRIP)
    conversion_factor DECIMAL(10, 3) DEFAULT 1,
    -- "CONV.STRI" (How many Primary in Secondary? e.g., 10 Tabs per Strip)
    -- Status Flags
    status VARCHAR(20) DEFAULT 'CONTINUE',
    -- UI: STATUS
    is_hidden BOOLEAN DEFAULT FALSE,
    -- UI: HIDE
    is_decimal_allowed BOOLEAN DEFAULT FALSE,
    -- UI: DECIMAL
    has_photo BOOLEAN DEFAULT FALSE,
    -- Regulatory Flags
    is_narcotic BOOLEAN DEFAULT FALSE,
    schedule_h_id INT REFERENCES drug_schedules(schedule_id),
    -- UI: SCHEDULE H/H1
    -- Inventory Settings
    rack_number VARCHAR(50),
    min_qty INT DEFAULT 0,
    max_qty INT DEFAULT 0,
    reorder_qty INT DEFAULT 0,
    allow_negative_stock BOOLEAN DEFAULT FALSE,
    -- UI: NEGATIVE
    -- Pricing & Taxation (Base Values)
    mrp DECIMAL(12, 2) DEFAULT 0.00,
    purchase_rate DECIMAL(12, 2) DEFAULT 0.00,
    -- UI: P.RATE
    cost_rate DECIMAL(12, 2) DEFAULT 0.00,
    -- UI: COST/
    -- Tax Configuration (Can be overridden or derived from HSN, but UI allows specific entry)
    sgst_percent DECIMAL(5, 2) DEFAULT 0.00,
    cgst_percent DECIMAL(5, 2) DEFAULT 0.00,
    igst_percent DECIMAL(5, 2) DEFAULT 0.00,
    -- Discounts & Margins
    item_discount_1 DECIMAL(5, 2) DEFAULT 0.00,
    special_discount DECIMAL(5, 2) DEFAULT 0.00,
    max_discount_percent DECIMAL(5, 2) DEFAULT 0.00,
    sale_margin DECIMAL(10, 3) DEFAULT 0.000,
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- ==========================================
-- 3. ADDITIONAL TABLES (Deduced relationships)
-- ==========================================
-- Batch/Stock Table (Since UI shows Batch-specific details probably elsewhere, but good to have)
CREATE TABLE IF NOT EXISTS product_batches (
    batch_id BIGSERIAL PRIMARY KEY,
    product_id BIGINT REFERENCES products(product_id),
    batch_number VARCHAR(50) NOT NULL,
    expiry_date DATE NOT NULL,
    mrp DECIMAL(12, 2),
    purchase_rate DECIMAL(12, 2),
    quantity_available DECIMAL(10, 2),
    entry_date DATE DEFAULT CURRENT_DATE
);
-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_products_company ON products(company_id);
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode);
-- ==========================================
-- 4. IMAGE TABLE
-- ==========================================
CREATE TABLE IF NOT EXISTS product_images (
    img_id SERIAL PRIMARY KEY,
    product_id BIGINT REFERENCES products(product_id) ON DELETE CASCADE,
    image_path VARCHAR(500) NOT NULL,
    -- e.g., "/uploads/products/123_abc.jpg"
    is_primary BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Update categories table to match MasterRepository expectations
DO $$ BEGIN -- Add UUID
IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'categories'
        AND column_name = 'uuid'
) THEN
ALTER TABLE categories
ADD COLUMN uuid VARCHAR(36);
END IF;
-- Add Slug
IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'categories'
        AND column_name = 'slug'
) THEN
ALTER TABLE categories
ADD COLUMN slug VARCHAR(255);
END IF;
-- Add Title (if missing, though schema has 'name', MasterRepo uses 'title')
IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'categories'
        AND column_name = 'title'
) THEN
ALTER TABLE categories
ADD COLUMN title VARCHAR(255);
-- Backfill title from name
UPDATE categories
SET title = name
WHERE title IS NULL;
END IF;
-- Add Description
IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'categories'
        AND column_name = 'description'
) THEN
ALTER TABLE categories
ADD COLUMN description TEXT;
END IF;
-- Add Status
IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'categories'
        AND column_name = 'status'
) THEN
ALTER TABLE categories
ADD COLUMN status VARCHAR(20) DEFAULT 'active';
END IF;
-- Add ImagePath
IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'categories'
        AND column_name = 'image_path'
) THEN
ALTER TABLE categories
ADD COLUMN image_path TEXT;
END IF;
-- Add other columns (parent_id is already there usually, but check)
-- requires_approval
IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'categories'
        AND column_name = 'requires_approval'
) THEN
ALTER TABLE categories
ADD COLUMN requires_approval BOOLEAN DEFAULT FALSE;
END IF;
-- sort_order
IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'categories'
        AND column_name = 'sort_order'
) THEN
ALTER TABLE categories
ADD COLUMN sort_order INT DEFAULT 0;
END IF;
-- commission
IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'categories'
        AND column_name = 'commission'
) THEN
ALTER TABLE categories
ADD COLUMN commission DECIMAL(5, 2) DEFAULT 0;
END IF;
-- background_type
IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'categories'
        AND column_name = 'background_type'
) THEN
ALTER TABLE categories
ADD COLUMN background_type VARCHAR(20);
END IF;
-- background_color
IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'categories'
        AND column_name = 'background_color'
) THEN
ALTER TABLE categories
ADD COLUMN background_color VARCHAR(10);
END IF;
-- font_color
IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'categories'
        AND column_name = 'font_color'
) THEN
ALTER TABLE categories
ADD COLUMN font_color VARCHAR(255);
END IF;
-- metadata
IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'categories'
        AND column_name = 'metadata'
) THEN
ALTER TABLE categories
ADD COLUMN metadata TEXT;
END IF;
-- created_at
IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'categories'
        AND column_name = 'created_at'
) THEN
ALTER TABLE categories
ADD COLUMN created_at TIMESTAMP DEFAULT NOW();
END IF;
-- updated_at
IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'categories'
        AND column_name = 'updated_at'
) THEN
ALTER TABLE categories
ADD COLUMN updated_at TIMESTAMP DEFAULT NOW();
END IF;
END $$;