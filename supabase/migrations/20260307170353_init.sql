-- =====================================================
-- BASELINE MIGRATION: Full schema as currently deployed
-- This migration represents the complete current state
-- of the database on Supabase.
-- =====================================================

-- 1. Exercises Bank
create table if not exists public.exercises (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  name text not null,
  image_url text,
  levels text,
  placement text,
  respiration text,
  tempo text,
  show_placement boolean default false,
  show_respiration boolean default false,
  video_url text
);

-- 2. Rooms (Salles)
create table if not exists public.rooms (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  code text unique not null,
  is_active boolean default true,
  notebook_visible_level boolean default true,
  notebook_visible_placement boolean default true,
  notebook_visible_tempo boolean default true,
  notebook_visible_respiration boolean default true,
  notebook_visible_feeling boolean default true,
  notebook_visible_series boolean default false,
  notebook_series_count integer default 4,
  notebook_visible_charges boolean default false,
  notebook_visible_reps boolean default false,
  notebook_enabled boolean default true,
  name text,
  timer_config jsonb default '{"repeats": 1, "phases": []}'::jsonb,
  timer_status jsonb default '{"state": "idle", "start_timestamp": null, "paused_timestamp": null, "elapsed_before_pause": 0}'::jsonb
);

-- 3. Workshops (Ateliers)
create table if not exists public.workshops (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  room_id uuid references public.rooms(id) on delete cascade not null,
  exercise_id uuid references public.exercises(id),
  workshop_image_url text,
  muscle_primary text not null,
  muscle_secondary text,
  muscle_tertiary text,
  order_index int default 0,
  mission text,
  show_placement boolean default false,
  show_respiration boolean default false,
  show_tempo boolean default false
);

-- 4. Students (Eleves)
create table if not exists public.students (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  room_id uuid references public.rooms(id) on delete cascade not null,
  name text not null,
  score int default 0,
  start_workshop_id uuid references public.workshops(id) on delete set null,
  teacher_note text
);

-- 5. Notebook Entries (Carnet d'entrainement)
create table if not exists public.notebook_entries (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  student_id uuid references public.students(id) on delete cascade not null,
  room_id uuid references public.rooms(id) on delete cascade not null,
  workshop_id uuid references public.workshops(id) on delete cascade not null,
  coach_name text,
  level_selected text,
  placement_errors int default 0,
  tempo_errors int default 0,
  respiration_errors int default 0,
  performer_name text,
  series_number integer default 1,
  charge text,
  repetitions text,
  feeling int
);

-- Constraints
alter table public.notebook_entries
add constraint notebook_entries_student_id_workshop_id_performer_name_key
unique (student_id, workshop_id, performer_name);

-- Enable RLS
alter table public.exercises enable row level security;
alter table public.rooms enable row level security;
alter table public.workshops enable row level security;
alter table public.students enable row level security;
alter table public.notebook_entries enable row level security;

-- RLS Policies
create policy "Allow all access to exercises" on public.exercises for all using (true);
create policy "Enable read access for all users" on public.rooms for select using (true);
create policy "Enable update for all users" on public.rooms for update using (true) with check (true);
create policy "Allow all access to workshops" on public.workshops for all using (true);
create policy "Allow all access to students" on public.students for all using (true);
create policy "Allow all access to notebook_entries" on public.notebook_entries for all using (true);

-- Realtime
alter table students replica identity full;
alter publication supabase_realtime add table public.students;
