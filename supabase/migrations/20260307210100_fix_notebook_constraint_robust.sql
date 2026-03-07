-- =====================================================
-- ROBUST FIX: Drop ALL existing unique constraints on
-- notebook_entries, then add the correct one with
-- series_number included.
-- =====================================================

DO $$
DECLARE
  r RECORD;
BEGIN
  -- Drop all unique constraints on notebook_entries
  FOR r IN
    SELECT conname
    FROM pg_constraint
    WHERE conrelid = 'public.notebook_entries'::regclass
      AND contype = 'u'
  LOOP
    EXECUTE format('ALTER TABLE public.notebook_entries DROP CONSTRAINT %I', r.conname);
    RAISE NOTICE 'Dropped constraint: %', r.conname;
  END LOOP;
END $$;

-- Add the correct constraint with series_number
ALTER TABLE public.notebook_entries
  ADD CONSTRAINT notebook_entries_unique_per_series
  UNIQUE (student_id, workshop_id, series_number, performer_name);
