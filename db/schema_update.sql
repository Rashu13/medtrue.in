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