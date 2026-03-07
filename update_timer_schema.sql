-- Add timer configuration and status columns to rooms table
-- Using JSONB allows for flexible structure (phases, colors, loops) without complex relations
ALTER TABLE public.rooms 
ADD COLUMN IF NOT EXISTS timer_config jsonb DEFAULT '{"repeats": 1, "phases": []}'::jsonb,
ADD COLUMN IF NOT EXISTS timer_status jsonb DEFAULT '{"state": "idle", "start_timestamp": null, "paused_timestamp": null, "elapsed_before_pause": 0}'::jsonb;
