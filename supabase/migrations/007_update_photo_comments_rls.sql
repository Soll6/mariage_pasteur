-- Update RLS policies for photo_comments table

ALTER TABLE public.photo_comments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can read photo_comments" ON public.photo_comments;
DROP POLICY IF EXISTS "Authenticated users can insert comments" ON public.photo_comments;
DROP POLICY IF EXISTS "Users can delete own comments" ON public.photo_comments;

-- Policy 1: Anyone can read comments
CREATE POLICY "Anyone can read photo_comments"
  ON public.photo_comments FOR SELECT
  TO anon, authenticated
  USING (true);

-- Policy 2: Authenticated users can insert comments
CREATE POLICY "Authenticated users can insert comments"
  ON public.photo_comments FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_id = auth.uid()
    )
  );

-- Policy 3: Users can delete their own comments
CREATE POLICY "Users can delete own comments"
  ON public.photo_comments FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_id = auth.uid()
    )
  );
