-- =====================================================
-- NEW TABLE: student_workshop_answers
-- Persists muscle quiz answers and points per workshop
-- per student. Enables score recovery on page refresh
-- and prevents duplicate point earning.
-- =====================================================

create table if not exists public.student_workshop_answers (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  student_id uuid references public.students(id) on delete cascade not null,
  workshop_id uuid references public.workshops(id) on delete cascade not null,
  room_id uuid references public.rooms(id) on delete cascade not null,
  answer_principal text,
  answer_secondaire text,
  answer_tertiaire text,
  points_earned integer default 0,
  unique(student_id, workshop_id)
);

-- Enable RLS (permissive for now, matching other tables)
alter table public.student_workshop_answers enable row level security;

create policy "Allow all access to student_workshop_answers"
  on public.student_workshop_answers for all
  using (true)
  with check (true);
