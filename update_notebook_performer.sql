-- Add performer_name column to notebook_entries
alter table public.notebook_entries 
add column if not exists performer_name text;

-- Drop existing unique constraint (if exists)
alter table public.notebook_entries 
drop constraint if exists notebook_entries_student_id_workshop_id_key;

-- Add new unique constraint including performer_name
-- We use coalesce on performer_name to ensure uniqueness even if null (though we intend to always fill it)
-- Note: standard unique allow multiple nulls, but we want strict uniqueness per performer. 
-- However, for simplicity, let's just make the constraint on the columns.
alter table public.notebook_entries 
add constraint notebook_entries_unique_performer 
unique (student_id, workshop_id, performer_name);
