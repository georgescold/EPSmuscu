-- Fix RLS permissions for rooms table
-- Ensures that anonymous users (students) can read the timer status

ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Allow all access to rooms" ON public.rooms;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.rooms;

-- Create a permissive policy for SELECT
CREATE POLICY "Enable read access for all users"
ON public.rooms
FOR SELECT
USING (true);

-- Also allow update for everyone for now (or at least authenticated if we had auth)
-- Since we rely on a shared password or simple access, we keep it permissive for V1
CREATE POLICY "Enable update for all users"
ON public.rooms
FOR UPDATE
USING (true)
WITH CHECK (true);
