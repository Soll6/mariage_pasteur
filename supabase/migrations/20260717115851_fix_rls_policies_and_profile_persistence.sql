-- Fix #1: Add missing INSERT RLS policy on user_profiles
-- Without this, ensureUserProfile() silently fails and UPDATE affects 0 rows

DROP POLICY IF EXISTS "Users can insert own profile" ON public.user_profiles;

CREATE POLICY "Users can insert own profile"
  ON public.user_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Fix #2: Fix guests RLS policies
-- BUG: email = auth.uid()::text compares a UUID to an email address (never matches)
-- FIX: Use auth.email() instead

-- Drop broken policies
DROP POLICY IF EXISTS "Guests can read own data" ON public.guests;
DROP POLICY IF EXISTS "Guests can register themselves" ON public.guests;
DROP POLICY IF EXISTS "Guests can update own RSVP" ON public.guests;

-- SELECT: guests can read own data by email
CREATE POLICY "Guests can read own data"
  ON public.guests FOR SELECT
  USING (
    email = auth.email()
    OR EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_id = auth.uid() AND role IN ('couple', 'admin')
    )
  );

-- INSERT: guests can self-register by email
CREATE POLICY "Guests can register themselves"
  ON public.guests FOR INSERT
  TO authenticated
  WITH CHECK (
    email = auth.email()
    OR EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_id = auth.uid() AND role IN ('couple', 'admin')
    )
  );

-- UPDATE: guests can update own RSVP by email
CREATE POLICY "Guests can update own RSVP"
  ON public.guests FOR UPDATE
  USING (
    email = auth.email()
    OR EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_id = auth.uid() AND role IN ('couple', 'admin')
    )
  )
  WITH CHECK (
    email = auth.email()
    OR EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_id = auth.uid() AND role IN ('couple', 'admin')
    )
  );

-- Fix #3: Fix invitations RLS policy (same bug: auth.uid()::text vs auth.email())

DROP POLICY IF EXISTS "Invitations readable by guest" ON public.invitations;

CREATE POLICY "Invitations readable by guest"
  ON public.invitations FOR SELECT
  USING (
    guest_id IN (
      SELECT id FROM public.guests WHERE email = auth.email()
    )
  );
