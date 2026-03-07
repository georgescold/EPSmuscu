-- 1. Add configuration columns to rooms
alter table public.rooms 
add column if not exists notebook_visible_level boolean default true,
add column if not exists notebook_visible_placement boolean default true,
add column if not exists notebook_visible_tempo boolean default true,
add column if not exists notebook_visible_respiration boolean default true;

-- 2. Create notebook entries table
create table if not exists public.notebook_entries (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  student_id uuid references public.students(id) on delete cascade not null,
  room_id uuid references public.rooms(id) on delete cascade not null,
  workshop_id uuid references public.workshops(id) on delete cascade not null,
  coach_name text,
  level_selected text, -- 'Niveau 1', 'Niveau 2', 'Niveau 3'
  placement_errors int default 0, -- 0 means 'Ok', >0 is number of errors
  tempo_errors int default 0,
  respiration_errors int default 0,
  unique(student_id, workshop_id) -- Only one entry per workshop per student
);

-- 3. Enable RLS
alter table public.notebook_entries enable row level security;
create policy "Allow all access to notebook_entries" on public.notebook_entries for all using (true);
