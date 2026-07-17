-- Add display_name column to user_profiles for gallery posts
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS display_name TEXT;

-- Update existing profiles with guest names if available
UPDATE public.user_profiles up
SET display_name = g.first_name || ' ' || g.last_name
FROM public.guests g
WHERE up.guest_id = g.id AND up.display_name IS NULL;

-- Create a view that joins gallery_posts with user_profiles for easy querying
CREATE OR REPLACE VIEW public.gallery_posts_with_profiles AS
SELECT
  gp.*,
  up.display_name,
  up.avatar_url
FROM public.gallery_posts gp
LEFT JOIN public.user_profiles up ON gp.user_id = up.user_id;

-- Grant access to the view
GRANT SELECT ON public.gallery_posts_with_profiles TO anon;
GRANT SELECT ON public.gallery_posts_with_profiles TO authenticated;
