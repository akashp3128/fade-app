-- =====================================================
-- FADE APP - SUPABASE DATABASE SCHEMA
-- =====================================================
-- Run this in your Supabase SQL Editor
-- Order matters due to foreign key dependencies
-- =====================================================

-- Enable UUID extension (usually already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. PROFILES TABLE (extends Supabase auth.users)
-- =====================================================
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    avatar_url TEXT,
    user_type TEXT NOT NULL DEFAULT 'client' CHECK (user_type IN ('client', 'barber', 'admin')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Automatically create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email, user_type)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'New User'),
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'user_type', 'client')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- 2. SHOPS TABLE
-- =====================================================
CREATE TABLE public.shops (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID REFERENCES public.profiles(id),
    name TEXT NOT NULL,
    address TEXT,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    avatar_url TEXT,
    phone TEXT,
    website TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 3. BARBER PROFILES TABLE
-- =====================================================
CREATE TABLE public.barber_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    shop_id UUID REFERENCES public.shops(id) ON DELETE SET NULL,
    is_independent BOOLEAN DEFAULT true,
    bio TEXT,
    specialties TEXT[] DEFAULT '{}',
    years_experience INTEGER DEFAULT 0,
    hourly_rate DECIMAL(10,2),
    rating DECIMAL(3,2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5),
    review_count INTEGER DEFAULT 0,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    address TEXT,
    is_available BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    instagram_handle TEXT,
    stripe_account_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 4. MEDIA POSTS TABLE (Instagram-style feed)
-- =====================================================
CREATE TABLE public.media_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    barber_id UUID NOT NULL REFERENCES public.barber_profiles(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    video_url TEXT,
    caption TEXT,
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 5. CLIENT VAULT TABLE (Private history)
-- =====================================================
CREATE TABLE public.client_vault (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    barber_id UUID REFERENCES public.barber_profiles(id) ON DELETE SET NULL,
    image_url TEXT NOT NULL,
    is_private BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 6. SAVED STYLES TABLE (Pinterest-style)
-- =====================================================
CREATE TABLE public.saved_styles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES public.media_posts(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(client_id, post_id)
);

-- Auto-create barber profile when user_type is 'barber'
CREATE OR REPLACE FUNCTION public.handle_barber_profile()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.user_type = 'barber' THEN
        INSERT INTO public.barber_profiles (user_id)
        VALUES (NEW.id)
        ON CONFLICT (user_id) DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_profile_barber_type
    AFTER INSERT OR UPDATE OF user_type ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_barber_profile();

-- =====================================================
-- 3. SERVICES TABLE
-- =====================================================
CREATE TABLE public.services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    barber_id UUID NOT NULL REFERENCES public.barber_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    duration_minutes INTEGER NOT NULL DEFAULT 30 CHECK (duration_minutes > 0),
    category TEXT DEFAULT 'haircut' CHECK (category IN ('haircut', 'beard', 'color', 'treatment', 'combo', 'other')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 4. AVAILABILITY TABLE
-- =====================================================
CREATE TABLE public.availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    barber_id UUID NOT NULL REFERENCES public.barber_profiles(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6), -- 0=Sunday, 6=Saturday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(barber_id, day_of_week)
);

-- =====================================================
-- 5. APPOINTMENTS TABLE
-- =====================================================
CREATE TABLE public.appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    barber_id UUID NOT NULL REFERENCES public.barber_profiles(id) ON DELETE CASCADE,
    service_id UUID REFERENCES public.services(id) ON DELETE SET NULL,
    scheduled_at TIMESTAMPTZ NOT NULL,
    duration_minutes INTEGER NOT NULL DEFAULT 30,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled', 'no_show')),
    total_price DECIMAL(10,2),
    notes TEXT,
    cancellation_reason TEXT,
    cancelled_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX idx_appointments_client ON public.appointments(client_id);
CREATE INDEX idx_appointments_barber ON public.appointments(barber_id);
CREATE INDEX idx_appointments_scheduled ON public.appointments(scheduled_at);
CREATE INDEX idx_appointments_status ON public.appointments(status);

-- =====================================================
-- 6. REVIEWS TABLE
-- =====================================================
CREATE TABLE public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    barber_id UUID NOT NULL REFERENCES public.barber_profiles(id) ON DELETE CASCADE,
    appointment_id UUID REFERENCES public.appointments(id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    is_visible BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(client_id, appointment_id) -- One review per appointment
);

-- Auto-update barber rating when review is added
CREATE OR REPLACE FUNCTION public.update_barber_rating()
RETURNS TRIGGER AS $$
DECLARE
    avg_rating DECIMAL(3,2);
    total_reviews INTEGER;
BEGIN
    SELECT AVG(rating)::DECIMAL(3,2), COUNT(*)
    INTO avg_rating, total_reviews
    FROM public.reviews
    WHERE barber_id = COALESCE(NEW.barber_id, OLD.barber_id)
    AND is_visible = true;

    UPDATE public.barber_profiles
    SET rating = COALESCE(avg_rating, 0),
        review_count = COALESCE(total_reviews, 0),
        updated_at = NOW()
    WHERE id = COALESCE(NEW.barber_id, OLD.barber_id);

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_review_change
    AFTER INSERT OR UPDATE OR DELETE ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION public.update_barber_rating();

-- =====================================================
-- 7. FAVORITES TABLE
-- =====================================================
CREATE TABLE public.favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    barber_id UUID NOT NULL REFERENCES public.barber_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(client_id, barber_id)
);

-- =====================================================
-- 8. PORTFOLIO IMAGES TABLE
-- =====================================================
CREATE TABLE public.portfolio_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    barber_id UUID NOT NULL REFERENCES public.barber_profiles(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    caption TEXT,
    display_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 9. NOTIFICATIONS TABLE (optional but useful)
-- =====================================================
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT,
    type TEXT DEFAULT 'general' CHECK (type IN ('appointment', 'reminder', 'promotion', 'general')),
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.barber_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- PROFILES: Users can read all profiles, update only their own
CREATE POLICY "Profiles are viewable by everyone" ON public.profiles
    FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- BARBER_PROFILES: Viewable by everyone, editable by owner
CREATE POLICY "Barber profiles are viewable by everyone" ON public.barber_profiles
    FOR SELECT USING (true);

CREATE POLICY "Barbers can update own profile" ON public.barber_profiles
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Barbers can insert own profile" ON public.barber_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- SERVICES: Viewable by everyone, managed by barber owner
CREATE POLICY "Services are viewable by everyone" ON public.services
    FOR SELECT USING (true);

CREATE POLICY "Barbers can manage own services" ON public.services
    FOR ALL USING (
        barber_id IN (SELECT id FROM public.barber_profiles WHERE user_id = auth.uid())
    );

-- AVAILABILITY: Viewable by everyone, managed by barber owner
CREATE POLICY "Availability is viewable by everyone" ON public.availability
    FOR SELECT USING (true);

CREATE POLICY "Barbers can manage own availability" ON public.availability
    FOR ALL USING (
        barber_id IN (SELECT id FROM public.barber_profiles WHERE user_id = auth.uid())
    );

-- APPOINTMENTS: Viewable by client and barber involved
CREATE POLICY "Users can view own appointments" ON public.appointments
    FOR SELECT USING (
        client_id = auth.uid() OR
        barber_id IN (SELECT id FROM public.barber_profiles WHERE user_id = auth.uid())
    );

CREATE POLICY "Clients can create appointments" ON public.appointments
    FOR INSERT WITH CHECK (client_id = auth.uid());

CREATE POLICY "Involved parties can update appointments" ON public.appointments
    FOR UPDATE USING (
        client_id = auth.uid() OR
        barber_id IN (SELECT id FROM public.barber_profiles WHERE user_id = auth.uid())
    );

-- REVIEWS: Viewable by everyone, writable by client who had appointment
CREATE POLICY "Reviews are viewable by everyone" ON public.reviews
    FOR SELECT USING (is_visible = true OR client_id = auth.uid());

CREATE POLICY "Clients can create reviews" ON public.reviews
    FOR INSERT WITH CHECK (client_id = auth.uid());

CREATE POLICY "Clients can update own reviews" ON public.reviews
    FOR UPDATE USING (client_id = auth.uid());

-- FAVORITES: Users can manage their own favorites
CREATE POLICY "Users can view own favorites" ON public.favorites
    FOR SELECT USING (client_id = auth.uid());

CREATE POLICY "Users can manage own favorites" ON public.favorites
    FOR ALL USING (client_id = auth.uid());

-- PORTFOLIO_IMAGES: Viewable by everyone, managed by barber owner
CREATE POLICY "Portfolio images are viewable by everyone" ON public.portfolio_images
    FOR SELECT USING (is_visible = true);

CREATE POLICY "Barbers can manage own portfolio" ON public.portfolio_images
    FOR ALL USING (
        barber_id IN (SELECT id FROM public.barber_profiles WHERE user_id = auth.uid())
    );

-- NOTIFICATIONS: Users can only see their own
CREATE POLICY "Users can view own notifications" ON public.notifications
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications" ON public.notifications
    FOR UPDATE USING (user_id = auth.uid());

-- =====================================================
-- SEED DATA (Optional - for testing)
-- =====================================================

-- Uncomment below to add sample data after creating a test user

/*
-- First, sign up a user through the app or Supabase Auth UI
-- Then update their profile to be a barber:

UPDATE public.profiles
SET user_type = 'barber', full_name = 'Marcus Johnson'
WHERE email = 'your-test-email@example.com';

-- Add barber details (get the barber_profile id first)
UPDATE public.barber_profiles
SET
    shop_name = 'Fresh Cuts Studio',
    bio = 'Master barber with 10+ years experience specializing in fades and beard grooming.',
    specialties = ARRAY['fades', 'beard', 'kids cuts'],
    years_experience = 10,
    address = '123 Main Street',
    city = 'Chicago',
    state = 'IL',
    zip_code = '60601',
    latitude = 41.8781,
    longitude = -87.6298,
    is_available = true,
    instagram_handle = '@freshcutsstudio'
WHERE user_id = (SELECT id FROM public.profiles WHERE email = 'your-test-email@example.com');

-- Add services
INSERT INTO public.services (barber_id, name, description, price, duration_minutes, category) VALUES
((SELECT id FROM public.barber_profiles WHERE shop_name = 'Fresh Cuts Studio'), 'Classic Haircut', 'Traditional scissor cut with styling', 25.00, 30, 'haircut'),
((SELECT id FROM public.barber_profiles WHERE shop_name = 'Fresh Cuts Studio'), 'Fade', 'Skin fade, mid fade, or high fade', 30.00, 45, 'haircut'),
((SELECT id FROM public.barber_profiles WHERE shop_name = 'Fresh Cuts Studio'), 'Beard Trim', 'Shape and line up your beard', 15.00, 20, 'beard'),
((SELECT id FROM public.barber_profiles WHERE shop_name = 'Fresh Cuts Studio'), 'Haircut + Beard', 'Full service haircut and beard trim', 40.00, 60, 'combo');

-- Add availability (Mon-Sat 9am-6pm)
INSERT INTO public.availability (barber_id, day_of_week, start_time, end_time, is_available) VALUES
((SELECT id FROM public.barber_profiles WHERE shop_name = 'Fresh Cuts Studio'), 1, '09:00', '18:00', true),
((SELECT id FROM public.barber_profiles WHERE shop_name = 'Fresh Cuts Studio'), 2, '09:00', '18:00', true),
((SELECT id FROM public.barber_profiles WHERE shop_name = 'Fresh Cuts Studio'), 3, '09:00', '18:00', true),
((SELECT id FROM public.barber_profiles WHERE shop_name = 'Fresh Cuts Studio'), 4, '09:00', '18:00', true),
((SELECT id FROM public.barber_profiles WHERE shop_name = 'Fresh Cuts Studio'), 5, '09:00', '18:00', true),
((SELECT id FROM public.barber_profiles WHERE shop_name = 'Fresh Cuts Studio'), 6, '10:00', '16:00', true);
*/
