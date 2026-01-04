-- Add start_workshop_id to students table to track their initial choice
ALTER TABLE public.students 
ADD COLUMN IF NOT EXISTS start_workshop_id uuid REFERENCES public.workshops(id) ON DELETE SET NULL;

-- Enable Realtime for students table (so students can see each other's locks)
alter publication supabase_realtime add table public.students;
