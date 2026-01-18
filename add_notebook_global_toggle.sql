-- Add notebook_enabled column to rooms table
ALTER TABLE rooms ADD COLUMN notebook_enabled BOOLEAN DEFAULT TRUE;

-- Update existing rooms to have it enabled by default
UPDATE rooms SET notebook_enabled = TRUE WHERE notebook_enabled IS NULL;
