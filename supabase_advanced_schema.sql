-- =====================================================
-- FADE APP - ADVANCED SAAS SCHEMA (SPRINT 1)
-- =====================================================
-- This extends the previous schema to support:
-- 1. Dual Roles (Client + Barber)
-- 2. Hybrid Payments (Stripe Connect)
-- 3. Platform & Creator Subscriptions
-- 4. Advanced Booking Settings
-- =====================================================

-- =====================================================
-- 1. USER ROLES & PERMISSIONS
-- =====================================================
-- We keep 'profiles' as the base user record.
-- 'barber_profiles' existence implies "Barber" role.
-- 'shops' existence with 'owner_id' implies "Shop Owner" role.

ALTER TABLE public.profiles 
ADD COLUMN is_fade_pro_member BOOLEAN DEFAULT false,
ADD COLUMN stripe_customer_id TEXT; -- For paying users

-- =====================================================
-- 2. PAYMENT & BUSINESS SETTINGS
-- =====================================================

-- Update SHOPS for Business Logic
ALTER TABLE public.shops
ADD COLUMN stripe_connect_id TEXT, -- Shop receives money here
ADD COLUMN platform_fee_percent DECIMAL(5,2) DEFAULT 10.00, -- We take 10%
ADD COLUMN is_verified BOOLEAN DEFAULT false;

-- Update BARBER PROFILES for Hybrid Logic
ALTER TABLE public.barber_profiles
ADD COLUMN booking_requires_confirmation BOOLEAN DEFAULT true, -- Default to "Request"
ADD COLUMN instant_book_enabled BOOLEAN DEFAULT false,
ADD COLUMN stripe_connect_id TEXT, -- Independent barbers receive money here
ADD COLUMN subscription_price DECIMAL(10,2) DEFAULT 0.00; -- Cost to subscribe to this creator

-- =====================================================
-- 3. CONTENT MONETIZATION
-- =====================================================

ALTER TABLE public.media_posts
ADD COLUMN is_premium BOOLEAN DEFAULT false, -- Requires sub (Platform or Creator)
ADD COLUMN pay_per_view_price DECIMAL(10,2) DEFAULT 0.00, -- Optional one-time cost
ADD COLUMN linked_service_ids UUID[] DEFAULT '{}'; -- "Get This Look" links to services

-- =====================================================
-- 4. SUBSCRIPTIONS TABLE
-- =====================================================
CREATE TABLE public.subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subscriber_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    creator_id UUID REFERENCES public.barber_profiles(id) ON DELETE CASCADE, -- Null if Platform Sub
    type TEXT NOT NULL CHECK (type IN ('platform', 'creator')),
    status TEXT NOT NULL DEFAULT 'active',
    current_period_end TIMESTAMPTZ NOT NULL,
    stripe_subscription_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(subscriber_id, creator_id, type) -- Prevent duplicate active subs
);

-- =====================================================
-- 5. BOOKING REQUESTS (Enhancing Appointments)
-- =====================================================
-- Add columns to handle the confirmation flow
ALTER TABLE public.appointments
ADD COLUMN confirmed_at TIMESTAMPTZ,
ADD COLUMN declined_at TIMESTAMPTZ,
ADD COLUMN declined_reason TEXT,
ADD COLUMN payment_status TEXT DEFAULT 'unpaid' CHECK (payment_status IN ('unpaid', 'authorized', 'captured', 'refunded'));

-- =====================================================
-- 6. RLS POLICIES (Update)
-- =====================================================

-- Subscriptions: Users see their own
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users view own subscriptions" ON public.subscriptions
    FOR SELECT USING (subscriber_id = auth.uid());

-- Media: Premium check logic (Simplified for SQL, handled in App usually)
-- Public posts are visible. Premium posts visible if:
-- 1. User is the creator
-- 2. User has 'is_fade_pro_member' = true (Platform bypass)
-- 3. User has active subscription to creator
-- (This complex logic is often better handled in an Edge Function or App Logic, 
-- but we enforce basic visibility here).

CREATE POLICY "Media visibility" ON public.media_posts
    FOR SELECT USING (
        is_premium = false OR 
        barber_id IN (SELECT id FROM public.barber_profiles WHERE user_id = auth.uid())
    );

-- =====================================================
-- 7. SEED UPDATE (Add Settings to Mock Data)
-- =====================================================
-- This is a helper function to update our existing seed data to be "SaaS Ready"

CREATE OR REPLACE FUNCTION public.upgrade_mock_data()
RETURNS void AS $$
BEGIN
    -- Make Leo The Blade require confirmation
    UPDATE public.barber_profiles
    SET booking_requires_confirmation = true, 
        instant_book_enabled = false,
        subscription_price = 9.99
    WHERE instagram_handle = '@leoblade_cuts';

    -- Make Marcus (Shop) Instant Book
    UPDATE public.barber_profiles
    SET booking_requires_confirmation = false, 
        instant_book_enabled = true
    WHERE instagram_handle = '@marcust_cuts';
    
    -- Make one post Premium
    UPDATE public.media_posts
    SET is_premium = true,
        caption = 'Master Class: The Perfect Fade (Subscribers Only)'
    WHERE barber_id = (SELECT id FROM public.barber_profiles WHERE instagram_handle = '@leoblade_cuts')
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
