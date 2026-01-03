alter table public.workshops 
add column if not exists show_placement boolean default false,
add column if not exists show_respiration boolean default false;
