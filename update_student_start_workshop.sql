-- Add start_workshop_id column to students table
-- This stores the workshop ID where the group begins their session
ALTER TABLE public.students 
ADD COLUMN IF NOT EXISTS start_workshop_id uuid REFERENCES public.workshops(id) ON DELETE SET NULL;
