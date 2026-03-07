-- =====================================================
-- FIX: notebook_entries unique constraint must include
-- series_number to support multiple series per workshop.
-- Without this, upsert with onConflict fails when
-- series > 1, causing silent data loss.
-- =====================================================

-- Drop the old constraint (without series_number)
alter table public.notebook_entries
  drop constraint if exists notebook_entries_student_id_workshop_id_performer_name_key;

-- Add the correct constraint (with series_number)
alter table public.notebook_entries
  add constraint notebook_entries_unique_per_series
  unique (student_id, workshop_id, series_number, performer_name);
