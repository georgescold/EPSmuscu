-- 1. Ensure the performer_name column exists
ALTER TABLE public.notebook_entries 
ADD COLUMN IF NOT EXISTS performer_name text;

-- 2. Drop the old strict unique constraint (1 entry per group per workshop)
-- We try multiple potential names just to be safe
ALTER TABLE public.notebook_entries DROP CONSTRAINT IF EXISTS notebook_entries_student_id_workshop_id_key;
ALTER TABLE public.notebook_entries DROP CONSTRAINT IF EXISTS notebook_entries_pkey; -- In case primary key was defined on (student_id, workshop_id)

-- 3. Re-create the Primary Key (if it doesn't exist, using a serial ID is better, but composite is fine for now)
-- If the table has an 'id' column, we use it. If not, we make a composite PK.
-- Assuming 'id' usually exists in Supabase tables. If not, we stick to Unique.

-- 3b. Add the NEW flexible constraint (1 entry per PERFORMER per workshop)
-- This allows "Group A" / "Workshop 1" / "Student Lucas"  AND "Group A" / "Workshop 1" / "Student Leo"
ALTER TABLE public.notebook_entries 
ADD CONSTRAINT notebook_entries_student_id_workshop_id_performer_name_key 
UNIQUE (student_id, workshop_id, performer_name);

-- 4. Enable RLS or ensure no weird policies are blocking (Optional safety)
ALTER TABLE public.notebook_entries ENABLE ROW LEVEL SECURITY;
-- (Assuming policies exist, otherwise leave as is)
