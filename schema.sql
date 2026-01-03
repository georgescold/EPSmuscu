-- Create tables for Muscu EPS App

-- 1. Exercises Bank
create table public.exercises (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  name text not null,
    image_url text,
  levels text,
  placement text,
  respiration text,
  tempo text,
  show_placement boolean default false,
  show_respiration boolean default false
);

-- 2. Rooms (Salles)
create table public.rooms (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  code text unique not null,
  is_active boolean default true,
  notebook_visible_level boolean default true,
  notebook_visible_placement boolean default true,
  notebook_visible_tempo boolean default true,
  notebook_visible_respiration boolean default true,
  name text
);

-- 3. Workshops (Ateliers)
create table public.workshops (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  room_id uuid references public.rooms(id) on delete cascade not null,
  exercise_id uuid references public.exercises(id),
  workshop_image_url text, -- Specific image for this workshop if different from exercise default
  muscle_primary text not null,
  muscle_secondary text,
  muscle_tertiary text,
  muscle_tertiary text,
  order_index int default 0,
  mission text,
  show_placement boolean default false,
  show_respiration boolean default false,
  show_tempo boolean default false
);

-- 4. Students (Elèves)
create table public.students (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  room_id uuid references public.rooms(id) on delete cascade not null,
  name text not null,
  score int default 0
);

-- Storage buckets (You might need to create these manually in the Storage UI if this fails, but usually SQL can't create buckets directly in standard Supabase setup without extensions, but we can set policies)
-- assuming a bucket named 'images' exists or will be created.

-- Enable RLS (Row Level Security) - Optional for now but good practice. 
-- For simplicity in this V1 with a shared generic password, we might open access or keep it simple.
-- Let's enable RLS but allow public access for now since auth is custom/simple.
alter table public.exercises enable row level security;
alter table public.rooms enable row level security;
alter table public.workshops enable row level security;
alter table public.students enable row level security;

-- Policies (Permissive for V1 to ensure it works easily, can be tightened later)
create policy "Allow all access to exercises" on public.exercises for all using (true);
create policy "Allow all access to rooms" on public.rooms for all using (true);
create policy "Allow all access to workshops" on public.workshops for all using (true);
create policy "Allow all access to students" on public.students for all using (true);

-- 5. Notebook Entries (Carnet d'entrainement)
create table public.notebook_entries (
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
  unique(student_id, workshop_id)
);
alter table public.notebook_entries enable row level security;
create policy "Allow all access to notebook_entries" on public.notebook_entries for all using (true);
