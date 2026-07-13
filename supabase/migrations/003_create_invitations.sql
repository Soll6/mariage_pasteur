-- Create invitations table
-- This table tracks invitation codes and their usage

CREATE TABLE IF NOT EXISTS public.invitations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  guest_id UUID REFERENCES public.guests(id) ON DELETE CASCADE NOT NULL,
  invitation_code VARCHAR(50) UNIQUE NOT NULL,
  sent_at TIMESTAMP WITH TIME ZONE,
  opened_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_invitations_code ON public.invitations(invitation_code);
CREATE INDEX IF NOT EXISTS idx_invitations_guest_id ON public.invitations(guest_id);

-- Enable Row Level Security
ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Invitations readable by guest" ON public.invitations;
DROP POLICY IF EXISTS "Invitations readable by couple/admin" ON public.invitations;

-- Create RLS Policies

-- Policy 1: Invitations readable by guest (email match)
CREATE POLICY "Invitations readable by guest"
  ON public.invitations FOR SELECT
  USING (
    guest_id IN (
      SELECT id FROM public.guests WHERE email = auth.uid()::text
    )
  );

-- Policy 2: Invitations readable by couple/admin
CREATE POLICY "Invitations readable by couple/admin"
  ON public.invitations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_id = auth.uid() AND role IN ('couple', 'admin')
    )
  );
