-- Migration: Add muscle game toggle to rooms
-- This allows teachers to enable/disable the muscle guessing game and scoring

ALTER TABLE public.rooms
ADD COLUMN IF NOT EXISTS muscle_game_enabled boolean DEFAULT true;
