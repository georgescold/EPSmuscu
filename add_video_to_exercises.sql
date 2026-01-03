-- Add video_url column to exercises table
ALTER TABLE exercises 
ADD COLUMN video_url TEXT;

-- (Optional) If we want a separate boolean to track if it's a local upload or youtube, 
-- but usually we can infer from the string content.
