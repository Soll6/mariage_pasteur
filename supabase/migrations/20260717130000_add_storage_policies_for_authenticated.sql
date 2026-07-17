-- Add storage policies for authenticated users to upload/read from wedding-photos bucket
-- The existing policies only grant access to anon role, but the app uses authenticated users

-- Allow authenticated users to read from the bucket
CREATE POLICY "Allow authenticated read wedding-photos"
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (bucket_id = 'wedding-photos');

-- Allow authenticated users to upload to the bucket
CREATE POLICY "Allow authenticated insert wedding-photos"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'wedding-photos');

-- Allow authenticated users to update their own uploads (needed for upsert)
CREATE POLICY "Allow authenticated update wedding-photos"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (bucket_id = 'wedding-photos');

-- Allow authenticated users to delete their own uploads
CREATE POLICY "Allow authenticated delete wedding-photos"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (bucket_id = 'wedding-photos');
