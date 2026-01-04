-- 1. Add performer_name column if it's missing (it holds "Lo1", "Lo2", etc.)
ALTER TABLE public.notebook_entries 
ADD COLUMN IF NOT EXISTS performer_name text;

-- 2. Drop the old strict constraint (which allowed only 1 entry per group per workshop)
ALTER TABLE public.notebook_entries 
DROP CONSTRAINT IF EXISTS notebook_entries_student_id_workshop_id_key;

-- 3. Add the new flexible constraint (allows 1 entry per PERFOMER per workshop in the same group)
ALTER TABLE public.notebook_entries 
ADD CONSTRAINT notebook_entries_student_id_workshop_id_performer_name_key 
UNIQUE (student_id, workshop_id, performer_name);
