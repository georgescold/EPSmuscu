-- Add configuration column to rooms table
ALTER TABLE public.rooms 
ADD COLUMN IF NOT EXISTS notebook_visible_feeling boolean DEFAULT true;

-- Add feeling data column to notebook_entries table
ALTER TABLE public.notebook_entries 
ADD COLUMN IF NOT EXISTS feeling int;
