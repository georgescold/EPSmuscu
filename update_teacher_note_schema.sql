-- Add teacher_note column to students table
ALTER TABLE public.students 
ADD COLUMN IF NOT EXISTS teacher_note text;
