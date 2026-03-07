-- The error proved the "New Constraint" is already there. So that part is good!
-- The problem is likely the "Primary Key" which is acting as a strict duplicate check.
-- Run this to remove the strict Primary Key and replace it with a flexible one.

-- 1. Drop the strict Primary Key
ALTER TABLE public.notebook_entries DROP CONSTRAINT IF EXISTS notebook_entries_pkey;

-- 2. (Optional but good) Create a new Primary Key that supports multiple students
-- This makes the combination of (Student + Workshop + Performer) the unique identifier.
ALTER TABLE public.notebook_entries 
ADD PRIMARY KEY (student_id, workshop_id, performer_name);
