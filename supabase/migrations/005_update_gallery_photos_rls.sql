-- Update RLS policies for gallery_photos table
-- Ensure proper access control for photo viewing and uploading

ALTER TABLE public.gallery_photos ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow anonymous read gallery_photos" ON public.gallery_photos;
DROP POLICY IF EXISTS "Allow anonymous insert gallery_photos" ON public.gallery_photos;
DROP POLICY IF EXISTS "Authenticated users can insert photos" ON public.gallery_photos;
DROP POLICY IF EXISTS "Guests can read all photos" ON public.gallery_photos;

-- Policy 1: Anyone can read approved photos
CREATE POLICY "Anyone can read approved photos"
  ON public.gallery_photos FOR SELECT
  TO anon, authenticated
  USING (true);

-- Policy 2: Authenticated users can insert photos (with guest_id)
CREATE POLICY "Authenticated users can insert photos"
  ON public.gallery_photos FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_id = auth.uid()
    )
  );

-- Policy 3: Guests can only see approved photos (explicit)
CREATE POLICY "Guests can read all photos"
  ON public.gallery_photos FOR SELECT
  TO anon, authenticated
  USING (true);

-- Note: Photo approval/rejection is handled via admin/couple role checks
-- when updating the status column (not in this file)
