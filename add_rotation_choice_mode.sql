-- 1. Add rotation mode and total_rounds to rooms
ALTER TABLE public.rooms
ADD COLUMN IF NOT EXISTS rotation_mode text DEFAULT 'imposed',
ADD COLUMN IF NOT EXISTS total_rounds integer DEFAULT 0;

-- Add check constraint for rotation_mode values
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.check_constraints
    WHERE constraint_name = 'rooms_rotation_mode_check'
  ) THEN
    ALTER TABLE public.rooms ADD CONSTRAINT rooms_rotation_mode_check
      CHECK (rotation_mode IN ('imposed', 'choice'));
  END IF;
END $$;

-- 2. Create workshop_bookings table
CREATE TABLE IF NOT EXISTS public.workshop_bookings (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id uuid REFERENCES public.rooms(id) ON DELETE CASCADE NOT NULL,
  student_id uuid REFERENCES public.students(id) ON DELETE CASCADE NOT NULL,
  workshop_id uuid REFERENCES public.workshops(id) ON DELETE CASCADE NOT NULL,
  round_number integer NOT NULL CHECK (round_number >= 1),
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Unique constraints
-- One group per workshop per round (prevents double-booking same workshop same round)
ALTER TABLE public.workshop_bookings
  DROP CONSTRAINT IF EXISTS workshop_bookings_room_workshop_round_key;
ALTER TABLE public.workshop_bookings
  ADD CONSTRAINT workshop_bookings_room_workshop_round_key
  UNIQUE (room_id, workshop_id, round_number);

-- One workshop per group per round (prevents a group from booking two workshops for same round)
ALTER TABLE public.workshop_bookings
  DROP CONSTRAINT IF EXISTS workshop_bookings_room_student_round_key;
ALTER TABLE public.workshop_bookings
  ADD CONSTRAINT workshop_bookings_room_student_round_key
  UNIQUE (room_id, student_id, round_number);

-- Prevent same workshop twice for same student across all rounds
DROP INDEX IF EXISTS idx_unique_student_workshop;
CREATE UNIQUE INDEX idx_unique_student_workshop
  ON public.workshop_bookings (room_id, student_id, workshop_id);

-- 4. RLS (matching existing permissive pattern)
ALTER TABLE public.workshop_bookings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all access to workshop_bookings" ON public.workshop_bookings;
CREATE POLICY "Allow all access to workshop_bookings"
  ON public.workshop_bookings FOR ALL USING (true);

-- 5. Enable REPLICA IDENTITY FULL for realtime
ALTER TABLE public.workshop_bookings REPLICA IDENTITY FULL;
