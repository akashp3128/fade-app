-- =====================================================
-- FADE APP - STORAGE BUCKET POLICIES
-- =====================================================
-- Run this AFTER creating the 'avatars' and 'portfolio' buckets
-- in the Supabase Storage dashboard
-- =====================================================

-- AVATAR BUCKET POLICIES
-- =====================================================

-- Anyone can view avatar images
CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

-- Users can upload to their own folder (avatars/USER_ID/filename)
CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can update their own avatar
CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can delete their own avatar
CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- PORTFOLIO BUCKET POLICIES
-- =====================================================

-- Anyone can view portfolio images
CREATE POLICY "Portfolio images are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'portfolio');

-- Barbers can upload to their portfolio folder (portfolio/BARBER_ID/filename)
CREATE POLICY "Barbers can upload portfolio images"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'portfolio' AND
    EXISTS (
        SELECT 1 FROM public.barber_profiles
        WHERE user_id = auth.uid()
        AND id::text = (storage.foldername(name))[1]
    )
);

-- Barbers can update their portfolio images
CREATE POLICY "Barbers can update portfolio images"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'portfolio' AND
    EXISTS (
        SELECT 1 FROM public.barber_profiles
        WHERE user_id = auth.uid()
        AND id::text = (storage.foldername(name))[1]
    )
);

-- Barbers can delete their own portfolio images
CREATE POLICY "Barbers can delete own portfolio images"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'portfolio' AND
    EXISTS (
        SELECT 1 FROM public.barber_profiles
        WHERE user_id = auth.uid()
        AND id::text = (storage.foldername(name))[1]
    )
);
