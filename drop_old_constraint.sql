-- Force Drop the old strict constraint associated with single-entry-per-group behavior
ALTER TABLE public.notebook_entries 
DROP CONSTRAINT IF EXISTS notebook_entries_student_id_workshop_id_key;

-- Note: We do NOT need to add the new constraint because the error message confirmed it already exists.
-- Just running this DROP command will allow both constraints to stop conflicting (leading to the correct 'multiple entries' behavior).
