-- =====================================================
-- FADE APP - CHICAGO MVP SEED DATA
-- =====================================================
-- This script adds mock shops, barbers, and content
-- to showcase the "Nano Banana Pro" experience.
-- =====================================================

-- 1. Create Mock Shops
INSERT INTO public.shops (id, name, address, latitude, longitude, avatar_url) VALUES
(uuid_generate_v4(), 'The Gold Coast Fade', '100 E Walton St, Chicago, IL 60611', 41.9002, -87.6255, 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?q=80&w=500&auto=format&fit=crop'),
(uuid_generate_v4(), 'Wicker Park Barbers', '1579 N Milwaukee Ave, Chicago, IL 60622', 41.9100, -87.6760, 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?q=80&w=500&auto=format&fit=crop');

-- 2. Create Mock Profiles (Users)
-- Note: In a real app, these would be in auth.users first. 
-- For MVP showcase, we'll insert into public.profiles directly if RLS allows or via a function.
-- Since we can't easily insert into auth.users via SQL without admin rights, 
-- we will assume some IDs or just provide the logic for the user to understand.

-- HOWEVER, to make the app SHOW data, we need barber_profiles to exist.
-- Let's create some dummy UUIDs for barbers.

DO $$
DECLARE
    shop1_id UUID := (SELECT id FROM public.shops WHERE name = 'The Gold Coast Fade');
    shop2_id UUID := (SELECT id FROM public.shops WHERE name = 'Wicker Park Barbers');
    barber1_id UUID := uuid_generate_v4();
    barber2_id UUID := uuid_generate_v4();
    barber3_id UUID := uuid_generate_v4();
    barber4_id UUID := uuid_generate_v4();
    user1_id UUID := uuid_generate_v4();
    user2_id UUID := uuid_generate_v4();
    user3_id UUID := uuid_generate_v4();
    user4_id UUID := uuid_generate_v4();
BEGIN
    -- Insert Profiles
    INSERT INTO public.profiles (id, full_name, email, user_type, avatar_url) VALUES
    (user1_id, 'Leo "The Blade" Rodriguez', 'leo@example.com', 'barber', 'https://images.unsplash.com/photo-1503443207922-dff7d543fd0e?q=80&w=200&auto=format&fit=crop'),
    (user2_id, 'Marcus Thompson', 'marcus@example.com', 'barber', 'https://images.unsplash.com/photo-1531384441138-2736e62e0919?q=80&w=200&auto=format&fit=crop'),
    (user3_id, 'Sarah "Stylist" Chen', 'sarah@example.com', 'barber', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop'),
    (user4_id, 'James Dean', 'james@example.com', 'barber', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop');

    -- Insert Barber Profiles
    -- Barber 1: Independent (Garage)
    INSERT INTO public.barber_profiles (id, user_id, is_independent, bio, specialties, years_experience, rating, review_count, latitude, longitude, address, instagram_handle) VALUES
    (barber1_id, user1_id, true, 'Cutting out of my private studio in Logan Square. Precision fades and urban styles.', ARRAY['Fade', 'Line Up', 'Design'], 8, 4.9, 128, 41.9250, -87.6870, '2400 N Western Ave, Chicago, IL', '@leoblade_cuts');

    -- Barber 2: At Shop 1
    INSERT INTO public.barber_profiles (id, user_id, is_independent, shop_id, bio, specialties, years_experience, rating, review_count, latitude, longitude, address, instagram_handle) VALUES
    (barber2_id, user2_id, false, shop1_id, 'Senior barber at Gold Coast Fade. Executive grooming and classic scissor cuts.', ARRAY['Classic Cut', 'Shave', 'Hot Towel'], 12, 4.8, 256, 41.9002, -87.6255, '100 E Walton St, Chicago, IL', '@marcust_cuts');

    -- Barber 3: Independent (Penthouse)
    INSERT INTO public.barber_profiles (id, user_id, is_independent, bio, specialties, years_experience, rating, review_count, latitude, longitude, address, instagram_handle) VALUES
    (barber3_id, user3_id, true, 'Luxury mobile and penthouse services. Specialist in modern texture and color.', ARRAY['Styling', 'Color', 'Texture'], 6, 5.0, 45, 41.8870, -87.6390, '333 N Canal St, Chicago, IL', '@sarahstyled_chi');

    -- Barber 4: At Shop 2
    INSERT INTO public.barber_profiles (id, user_id, is_independent, shop_id, bio, specialties, years_experience, rating, review_count, latitude, longitude, address, instagram_handle) VALUES
    (barber4_id, user4_id, false, shop2_id, 'Wicker Park local. I love doing creative beard work and modern tapers.', ARRAY['Beard Trim', 'Taper', 'Kids Cut'], 5, 4.7, 89, 41.9100, -87.6760, '1579 N Milwaukee Ave, Chicago, IL', '@jdean_barber');

    -- 3. Insert Services
    INSERT INTO public.services (barber_id, name, price, duration_minutes, category) VALUES
    (barber1_id, 'Nano Fade', 45.00, 45, 'haircut'),
    (barber1_id, 'Beard Sculpt', 25.00, 30, 'beard'),
    (barber2_id, 'Executive Cut', 60.00, 45, 'haircut'),
    (barber2_id, 'Straight Razor Shave', 50.00, 40, 'shave'),
    (barber3_id, 'Texture Scissor Cut', 75.00, 60, 'haircut'),
    (barber4_id, 'Wicker Taper', 35.00, 30, 'haircut');

    -- 4. Insert Portfolio Images
    INSERT INTO public.portfolio_images (barber_id, image_url, caption) VALUES
    (barber1_id, 'https://images.unsplash.com/photo-1599351431247-f10b21ce9634?q=80&w=400&auto=format&fit=crop', 'Crisp skin fade'),
    (barber1_id, 'https://images.unsplash.com/photo-1621605815841-2ae606382a32?q=80&w=400&auto=format&fit=crop', 'Line up detail'),
    (barber2_id, 'https://images.unsplash.com/photo-1605497788044-5a32c7078486?q=80&w=400&auto=format&fit=crop', 'Classic side part'),
    (barber3_id, 'https://images.unsplash.com/photo-1593702295094-ada74bc4a169?q=80&w=400&auto=format&fit=crop', 'Modern texture work'),
    (barber4_id, 'https://images.unsplash.com/photo-1517832606299-7af9b7209443?q=80&w=400&auto=format&fit=crop', 'Beard trim & shape');

    -- 5. Insert Media Posts (The Feed)
    INSERT INTO public.media_posts (barber_id, image_url, caption, tags) VALUES
    (barber1_id, 'https://images.unsplash.com/photo-1599351431247-f10b21ce9634?q=80&w=600&auto=format&fit=crop', 'Just finished this drop fade in Logan Square. #chicago #fade #nano', ARRAY['chicago', 'fade', 'logan-square']),
    (barber3_id, 'https://images.unsplash.com/photo-1593702295094-ada74bc4a169?q=80&w=600&auto=format&fit=crop', 'Sunset cuts at the penthouse. Luxury redefined. #luxury #hairstylist', ARRAY['luxury', 'chi-town']),
    (barber2_id, 'https://images.unsplash.com/photo-1621605815841-2ae606382a32?q=80&w=600&auto=format&fit=crop', 'Keeping it sharp at Gold Coast Fade. #classic #barber', ARRAY['gold-coast', 'sharp']);

END $$;
