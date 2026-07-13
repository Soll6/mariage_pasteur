-- Update RLS policies for photo_likes table

ALTER TABLE public.photo_likes ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can read photo_likes" ON public.photo_likes;
DROP POLICY IF EXISTS "Authenticated users can insert likes" ON public.photo_likes;
DROP POLICY IF EXISTS "Users can delete own likes" ON public.photo_likes;

-- Policy 1: Anyone can read likes
CREATE POLICY "Anyone can read photo_likes"
  ON public.photo_likes FOR SELECT
  TO anon, authenticated
  USING (true);

-- Policy 2: Authenticated users can insert likes
CREATE POLICY "Authenticated users can insert likes"
  ON public.photo_likes FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_id = auth.uid()
    )
  );

-- Policy 3: Users can delete their own likes
CREATE POLICY "Users can delete own likes"
  ON public.photo_likes FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_id = auth.uid()
    )
  );
