-- =====================================================
-- FADE APP - SPRINT 3: CONTENT & ACADEMY SCHEMA
-- =====================================================

-- 1. COURSES (Long-form Educational Content)
CREATE TABLE public.courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    barber_id UUID NOT NULL REFERENCES public.barber_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    price DECIMAL(10,2) DEFAULT 0.00, -- 0 = Free or Subscription Only
    is_premium BOOLEAN DEFAULT true, -- Requires Platform or Creator Sub
    difficulty_level TEXT CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
    duration_minutes INT DEFAULT 0,
    lesson_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. COURSE LESSONS (Videos inside a course)
CREATE TABLE public.course_lessons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    video_url TEXT NOT NULL,
    duration_minutes INT,
    order_index INT DEFAULT 0, -- For sorting (1, 2, 3...)
    is_preview BOOLEAN DEFAULT false, -- Free preview for non-subscribers
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. USER PROGRESS (Tracking watched lessons)
CREATE TABLE public.user_course_progress (
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES public.course_lessons(id) ON DELETE CASCADE,
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, lesson_id)
);

-- 4. PURCHASED COURSES (Pay-Per-View Access)
CREATE TABLE public.purchased_courses (
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    amount_paid DECIMAL(10,2) NOT NULL,
    purchased_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, course_id)
);

-- 5. UPGRADE EXISTING MEDIA POSTS (For Feed)
-- Ensure media_posts has the right metadata for "Book This Look"
ALTER TABLE public.media_posts
ADD COLUMN IF NOT EXISTS linked_service_ids UUID[]; -- Already added in Sprint 1, ensuring existence

-- =====================================================
-- SEED DATA (Mock Courses)
-- =====================================================

DO $$
DECLARE
    v_leo_id UUID;
    v_course_id UUID;
BEGIN
    -- Get Leo The Blade's ID
    SELECT id INTO v_leo_id FROM public.barber_profiles WHERE instagram_handle = '@leoblade_cuts';

    IF v_leo_id IS NOT NULL THEN
        -- Insert Course
        INSERT INTO public.courses (barber_id, title, description, price, difficulty_level, duration_minutes, lesson_count)
        VALUES (v_leo_id, 'The Perfect Skin Fade', 'Master the art of the blurry fade. Step by step guide using clippers and razor.', 29.99, 'advanced', 45, 3)
        RETURNING id INTO v_course_id;

        -- Insert Lessons
        INSERT INTO public.course_lessons (course_id, title, video_url, duration_minutes, order_index, is_preview)
        VALUES 
        (v_course_id, 'Tools & Preparation', 'https://assets.mixkit.co/videos/preview/mixkit-barber-preparing-tools-12626-large.mp4', 10, 1, true),
        (v_course_id, 'Setting Guidelines', 'https://assets.mixkit.co/videos/preview/mixkit-barber-cutting-hair-with-scissors-and-comb-12624-large.mp4', 15, 2, false),
        (v_course_id, 'Refining the Blur', 'https://assets.mixkit.co/videos/preview/mixkit-barber-shaving-a-client-with-a-razor-12625-large.mp4', 20, 3, false);
    END IF;
END $$;
