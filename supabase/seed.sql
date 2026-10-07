-- =============================================================================
-- Fade: LOCAL DEVELOPMENT SEED DATA (mock Chicago barbers)
-- -----------------------------------------------------------------------------
-- Runs on `supabase db reset` / `supabase start` only. NOT applied by
-- `supabase db push`, and must never be run against production.
-- Everything here is fictional demo data (example.com emails, stock photos).
--
-- Mock users are inserted into auth.users with sign-up metadata so the
-- normal triggers create their profiles + barber_profiles (same path as a
-- real sign-up). They have NO password and cannot log in; sign up your own
-- local account to test authenticated flows.
-- Replaces the old seed_chicago_mvp.sql, the seed block of sprint3_schema.sql
-- and the broken upgrade_mock_data() function.
-- =============================================================================

-- 1. Shops ---------------------------------------------------------------------
insert into public.shops (id, name, address, latitude, longitude, avatar_url) values
  ('00000000-0000-4000-a000-000000000101', 'The Gold Coast Fade', '100 E Walton St, Chicago, IL 60611', 41.9002, -87.6255,
   'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?q=80&w=500&auto=format&fit=crop'),
  ('00000000-0000-4000-a000-000000000102', 'Wicker Park Barbers', '1579 N Milwaukee Ave, Chicago, IL 60622', 41.9100, -87.6760,
   'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?q=80&w=500&auto=format&fit=crop')
on conflict (id) do nothing;

-- 2. Mock barber accounts (triggers create profiles + barber_profiles) ---------
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
                        raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
values
  ('00000000-0000-0000-0000-000000000000', '00000000-0000-4000-a000-000000000001', 'authenticated', 'authenticated',
   'leo@example.com', '', now(), '{"provider":"email","providers":["email"]}',
   '{"full_name":"Leo \"The Blade\" Rodriguez","user_type":"barber","avatar_url":"https://images.unsplash.com/photo-1503443207922-dff7d543fd0e?q=80&w=200&auto=format&fit=crop"}',
   now(), now()),
  ('00000000-0000-0000-0000-000000000000', '00000000-0000-4000-a000-000000000002', 'authenticated', 'authenticated',
   'marcus@example.com', '', now(), '{"provider":"email","providers":["email"]}',
   '{"full_name":"Marcus Thompson","user_type":"barber","avatar_url":"https://images.unsplash.com/photo-1531384441138-2736e62e0919?q=80&w=200&auto=format&fit=crop"}',
   now(), now()),
  ('00000000-0000-0000-0000-000000000000', '00000000-0000-4000-a000-000000000003', 'authenticated', 'authenticated',
   'sarah@example.com', '', now(), '{"provider":"email","providers":["email"]}',
   '{"full_name":"Sarah \"Stylist\" Chen","user_type":"barber","avatar_url":"https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop"}',
   now(), now()),
  ('00000000-0000-0000-0000-000000000000', '00000000-0000-4000-a000-000000000004', 'authenticated', 'authenticated',
   'james@example.com', '', now(), '{"provider":"email","providers":["email"]}',
   '{"full_name":"James Dean","user_type":"barber","avatar_url":"https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop"}',
   now(), now())
on conflict (id) do nothing;

-- 3. Barber details ------------------------------------------------------------
update public.barber_profiles set
  is_independent = true,
  bio = 'Cutting out of my private studio in Logan Square. Precision fades and urban styles.',
  specialties = array['Fade', 'Line Up', 'Design'], years_experience = 8,
  rating = 4.9, review_count = 128, latitude = 41.9250, longitude = -87.6870,
  address = '2400 N Western Ave, Chicago, IL', instagram_handle = '@leoblade_cuts',
  booking_requires_confirmation = true, instant_book_enabled = false, subscription_price = 9.99
where user_id = '00000000-0000-4000-a000-000000000001';

update public.barber_profiles set
  is_independent = false, shop_id = '00000000-0000-4000-a000-000000000101',
  bio = 'Senior barber at Gold Coast Fade. Executive grooming and classic scissor cuts.',
  specialties = array['Classic Cut', 'Shave', 'Hot Towel'], years_experience = 12,
  rating = 4.8, review_count = 256, latitude = 41.9002, longitude = -87.6255,
  address = '100 E Walton St, Chicago, IL', instagram_handle = '@marcust_cuts',
  booking_requires_confirmation = false, instant_book_enabled = true
where user_id = '00000000-0000-4000-a000-000000000002';

update public.barber_profiles set
  is_independent = true,
  bio = 'Luxury mobile and penthouse services. Specialist in modern texture and color.',
  specialties = array['Styling', 'Color', 'Texture'], years_experience = 6,
  rating = 5.0, review_count = 45, latitude = 41.8870, longitude = -87.6390,
  address = '333 N Canal St, Chicago, IL', instagram_handle = '@sarahstyled_chi'
where user_id = '00000000-0000-4000-a000-000000000003';

update public.barber_profiles set
  is_independent = false, shop_id = '00000000-0000-4000-a000-000000000102',
  bio = 'Wicker Park local. I love doing creative beard work and modern tapers.',
  specialties = array['Beard Trim', 'Taper', 'Kids Cut'], years_experience = 5,
  rating = 4.7, review_count = 89, latitude = 41.9100, longitude = -87.6760,
  address = '1579 N Milwaukee Ave, Chicago, IL', instagram_handle = '@jdean_barber'
where user_id = '00000000-0000-4000-a000-000000000004';

-- 4. Services, portfolio, feed posts, course ----------------------------------
do $$
declare
  b1 uuid := (select id from public.barber_profiles where user_id = '00000000-0000-4000-a000-000000000001');
  b2 uuid := (select id from public.barber_profiles where user_id = '00000000-0000-4000-a000-000000000002');
  b3 uuid := (select id from public.barber_profiles where user_id = '00000000-0000-4000-a000-000000000003');
  b4 uuid := (select id from public.barber_profiles where user_id = '00000000-0000-4000-a000-000000000004');
  v_course uuid;
begin
  if exists (select 1 from public.services where barber_id = b1) then
    return;  -- already seeded
  end if;

  insert into public.services (barber_id, name, price, duration_minutes, category) values
    (b1, 'Nano Fade', 45.00, 45, 'haircut'),
    (b1, 'Beard Sculpt', 25.00, 30, 'beard'),
    (b2, 'Executive Cut', 60.00, 45, 'haircut'),
    (b2, 'Straight Razor Shave', 50.00, 40, 'shave'),
    (b3, 'Texture Scissor Cut', 75.00, 60, 'haircut'),
    (b4, 'Wicker Taper', 35.00, 30, 'haircut');

  insert into public.portfolio_images (barber_id, image_url, caption) values
    (b1, 'https://images.unsplash.com/photo-1599351431247-f10b21ce9634?q=80&w=400&auto=format&fit=crop', 'Crisp skin fade'),
    (b1, 'https://images.unsplash.com/photo-1621605815841-2ae606382a32?q=80&w=400&auto=format&fit=crop', 'Line up detail'),
    (b2, 'https://images.unsplash.com/photo-1605497788044-5a32c7078486?q=80&w=400&auto=format&fit=crop', 'Classic side part'),
    (b3, 'https://images.unsplash.com/photo-1593702295094-ada74bc4a169?q=80&w=400&auto=format&fit=crop', 'Modern texture work'),
    (b4, 'https://images.unsplash.com/photo-1517832606299-7af9b7209443?q=80&w=400&auto=format&fit=crop', 'Beard trim & shape');

  insert into public.media_posts (barber_id, image_url, caption, tags, is_premium) values
    (b1, 'https://images.unsplash.com/photo-1599351431247-f10b21ce9634?q=80&w=600&auto=format&fit=crop',
     'Master Class: The Perfect Fade (Subscribers Only)', array['chicago', 'fade', 'logan-square'], true),
    (b3, 'https://images.unsplash.com/photo-1593702295094-ada74bc4a169?q=80&w=600&auto=format&fit=crop',
     'Sunset cuts at the penthouse. Luxury redefined. #luxury #hairstylist', array['luxury', 'chi-town'], false),
    (b2, 'https://images.unsplash.com/photo-1621605815841-2ae606382a32?q=80&w=600&auto=format&fit=crop',
     'Keeping it sharp at Gold Coast Fade. #classic #barber', array['gold-coast', 'sharp'], false);

  insert into public.courses (barber_id, title, description, price, difficulty_level, duration_minutes, lesson_count)
  values (b1, 'The Perfect Skin Fade',
          'Master the art of the blurry fade. Step by step guide using clippers and razor.',
          29.99, 'advanced', 45, 3)
  returning id into v_course;

  insert into public.course_lessons (course_id, title, video_url, duration_minutes, order_index, is_preview) values
    (v_course, 'Tools & Preparation', 'https://assets.mixkit.co/videos/preview/mixkit-barber-preparing-tools-12626-large.mp4', 10, 1, true),
    (v_course, 'Setting Guidelines', 'https://assets.mixkit.co/videos/preview/mixkit-barber-cutting-hair-with-scissors-and-comb-12624-large.mp4', 15, 2, false),
    (v_course, 'Refining the Blur', 'https://assets.mixkit.co/videos/preview/mixkit-barber-shaving-a-client-with-a-razor-12625-large.mp4', 20, 3, false);
end;
$$;
