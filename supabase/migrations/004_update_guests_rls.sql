-- Update RLS policies for guests table
-- Ensure proper access control for guests, couple, and admin roles

ALTER TABLE public.guests ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Guests can read own data" ON public.guests;
DROP POLICY IF EXISTS "Couple can manage all guests" ON public.guests;
DROP POLICY IF EXISTS "Admins can manage all guests" ON public.guests;

-- Policy 1: Guests can read own data
CREATE POLICY "Guests can read own data"
  ON public.guests FOR SELECT
  USING (
    email = auth.uid()::text
    OR EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_id = auth.uid() AND role IN ('couple', 'admin')
    )
  );

-- Policy 2: Couple can manage all guests
CREATE POLICY "Couple can manage all guests"
  ON public.guests FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_id = auth.uid() AND role IN ('couple', 'admin')
    )
  );

-- Policy 3: Admins can manage all guests (explicit)
CREATE POLICY "Admins can manage all guests"
  ON public.guests FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );
