-- Enable guest self-registration
-- Allows guests to register via social auth or email/password
-- and auto-create them in guests table with pending status
-- Applied: 2026-07-15

-- Create function to auto-register guest after auth signup
CREATE OR REPLACE FUNCTION public.handle_new_guest_registration()
RETURNS TRIGGER AS $$
DECLARE
  guest_full_name TEXT;
  guest_email TEXT;
BEGIN
  -- Get email from auth.users
  guest_email := NEW.email;
  
  -- Get full name from metadata or email prefix
  guest_full_name := COALESCE(
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'name',
    split_part(guest_email, '@', 1)
  );

  -- Create guest record if not exists
  INSERT INTO public.guests (email, full_name, rsvp_status, number_of_guests)
  VALUES (guest_email, guest_full_name, 'pending', 1)
  ON CONFLICT (email) DO NOTHING;

  -- Create user profile with guest role
  INSERT INTO public.user_profiles (user_id, role)
  VALUES (NEW.id, 'guest')
  ON CONFLICT (user_id) DO NOTHING;

  -- Link guest to user profile
  UPDATE public.user_profiles
  SET guest_id = (
    SELECT id FROM public.guests WHERE email = guest_email LIMIT 1
  )
  WHERE user_id = NEW.id AND guest_id IS NULL;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user registration
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_guest_registration();

-- Add RLS policy for guests to read own data (if not exists)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE policyname = 'Guests can register themselves' 
    AND tablename = 'guests'
  ) THEN
    CREATE POLICY "Guests can register themselves"
      ON public.guests FOR INSERT
      WITH CHECK (
        email = auth.uid()::text
        OR EXISTS (
          SELECT 1 FROM public.user_profiles
          WHERE user_id = auth.uid() AND role IN ('couple', 'admin')
        )
      );
  END IF;
END $$;

-- Add policy for guests to update own RSVP status
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE policyname = 'Guests can update own RSVP' 
    AND tablename = 'guests'
  ) THEN
    CREATE POLICY "Guests can update own RSVP"
      ON public.guests FOR UPDATE
      USING (
        email = auth.uid()::text
        OR EXISTS (
          SELECT 1 FROM public.user_profiles
          WHERE user_id = auth.uid() AND role IN ('couple', 'admin')
        )
      )
      WITH CHECK (
        email = auth.uid()::text
        OR EXISTS (
          SELECT 1 FROM public.user_profiles
          WHERE user_id = auth.uid() AND role IN ('couple', 'admin')
        )
      );
  END IF;
END $$;

-- Create function to check if guest is validated (can publish/confirm)
CREATE OR REPLACE FUNCTION public.is_guest_validated(guest_email TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.guests
    WHERE email = guest_email
    AND rsvp_status IN ('confirmed', 'pending')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.is_guest_validated(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_guest_validated(TEXT) TO anon;