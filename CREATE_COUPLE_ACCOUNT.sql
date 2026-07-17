-- Script to create the couple account manually via Supabase Dashboard SQL Editor
-- Follow these steps:
-- 1. Go to Supabase Dashboard > SQL Editor
-- 2. Create a new query
-- 3. Copy and paste the SQL below
-- 4. Click "Run"

-- Note: This creates a test user. You must set the password via the Auth dashboard manually
-- Or use the Edge Function approach documented in SETUP_ACCOUNTS.md

-- Create couple user account via SQL (if you have direct access)
-- This requires service role, so it might not work directly in the dashboard

-- Instead, use the Supabase Auth Dashboard:
-- 1. Go to Authentication > Users
-- 2. Click "Create new user"
-- 3. Email: aimemaboundou@gmail.com
-- 4. Password: francis2026
-- 5. Check "Auto confirm user"
-- 6. Click "Create user"

-- Then verify and create the profile with this query:
INSERT INTO public.user_profiles (user_id, role, created_at, updated_at)
SELECT 
  id,
  'couple',
  now(),
  now()
FROM auth.users 
WHERE email = 'aimemaboundou@gmail.com'
AND NOT EXISTS (
  SELECT 1 FROM public.user_profiles 
  WHERE user_id = auth.users.id
)
ON CONFLICT (user_id) DO UPDATE 
SET role = 'couple', updated_at = now();

-- Verify the setup:
SELECT 
  u.email,
  up.role,
  u.id as user_id,
  u.email_confirmed_at,
  up.created_at as profile_created
FROM auth.users u
LEFT JOIN public.user_profiles up ON u.id = up.user_id
WHERE u.email IN ('zolasoll7@gmail.com', 'aimemaboundou@gmail.com')
ORDER BY u.email;
