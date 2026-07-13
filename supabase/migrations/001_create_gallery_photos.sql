-- Add RLS policies for the existing gallery_photos table
ALTER TABLE gallery_photos ENABLE ROW LEVEL SECURITY;

-- Allow anonymous users to read all photos
CREATE POLICY "Allow anonymous read gallery_photos"
  ON gallery_photos
  FOR SELECT
  TO anon
  USING (true);

-- Allow anonymous users to insert photos
CREATE POLICY "Allow anonymous insert gallery_photos"
  ON gallery_photos
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Create the wedding-photos storage bucket (if not exists)
INSERT INTO storage.buckets (id, name, public)
VALUES ('wedding-photos', 'wedding-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Allow anonymous users to read from the bucket
CREATE POLICY "Allow anonymous read wedding-photos"
  ON storage.objects
  FOR SELECT
  TO anon
  USING (bucket_id = 'wedding-photos');

-- Allow anonymous users to upload to the bucket
CREATE POLICY "Allow anonymous upload wedding-photos"
  ON storage.objects
  FOR INSERT
  TO anon
  WITH CHECK (bucket_id = 'wedding-photos');
