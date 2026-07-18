-- Add guest_number column to guests table for dinner seating
-- Numbers are auto-assigned when a guest is confirmed

ALTER TABLE public.guests ADD COLUMN IF NOT EXISTS guest_number INTEGER UNIQUE;

-- Auto-assign numbers to already confirmed guests based on creation order
UPDATE public.guests
SET guest_number = sub.row_num
FROM (
  SELECT id, ROW_NUMBER() OVER (ORDER BY created_at) AS row_num
  FROM public.guests
  WHERE rsvp_status = 'confirmed'
) AS sub
WHERE public.guests.id = sub.id
  AND public.guests.guest_number IS NULL;

-- Create a sequence to auto-assign numbers to new confirmed guests
CREATE SEQUENCE IF NOT EXISTS guest_number_seq START 1;

-- Set default for future inserts (trigger will handle confirmed guests)
-- This is a safety net; the app handles assignment via updateRSVP
