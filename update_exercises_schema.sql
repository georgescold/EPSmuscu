alter table public.exercises 
add column if not exists levels text,
add column if not exists placement text,
add column if not exists respiration text,
add column if not exists show_placement boolean default false,
add column if not exists show_respiration boolean default false;
