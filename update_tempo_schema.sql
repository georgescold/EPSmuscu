-- 1. Add tempo to exercises
alter table public.exercises 
add column if not exists tempo text;

-- 2. Add show_tempo to workshops
alter table public.workshops 
add column if not exists show_tempo boolean default false;
