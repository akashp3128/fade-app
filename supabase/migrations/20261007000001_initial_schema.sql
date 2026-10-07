-- =============================================================================
-- Fade: initial schema (baseline)
-- -----------------------------------------------------------------------------
-- Consolidates the former loose root scripts into one ordered migration:
--   supabase_setup.sql, supabase_advanced_schema.sql, sprint3_schema.sql
-- Seed / mock data lives in supabase/seed.sql only (never in migrations).
--
-- Fixes vs. the loose scripts:
--   * uses gen_random_uuid() (core Postgres) instead of uuid-ossp
--   * stripe/subscription columns folded into CREATE TABLE (no ALTER chains)
--   * services.category allows 'shave' (the seed data used it; check rejected it)
--   * appointments.status allows 'declined' (used by the booking request flow)
--   * appointments.stripe_payment_intent_id and reviews.photos added
--     (both are read by lib/models but were missing from the schema)
--   * upgrade_mock_data() dropped (invalid UPDATE ... LIMIT; it was seed logic)
--   * generic updated_at trigger
-- Written to be re-runnable (IF NOT EXISTS / OR REPLACE) where reasonable.
-- =============================================================================

create extension if not exists btree_gist with schema extensions;

-- -----------------------------------------------------------------------------
-- Generic updated_at trigger
-- -----------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- profiles (1:1 with auth.users). Rows are created ONLY by the auth trigger.
-- email/phone are private: other users read public.public_profiles instead.
-- -----------------------------------------------------------------------------
create table if not exists public.profiles (
  id                 uuid primary key references auth.users(id) on delete cascade,
  full_name          text not null,
  email              text,
  phone              text,
  avatar_url         text,
  user_type          text not null default 'client'
                       check (user_type in ('client', 'barber', 'admin')),
  is_fade_pro_member boolean not null default false,
  stripe_customer_id text,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- shops
-- -----------------------------------------------------------------------------
create table if not exists public.shops (
  id                   uuid primary key default gen_random_uuid(),
  owner_id             uuid references public.profiles(id) on delete set null,
  name                 text not null,
  address              text,
  latitude             numeric(10,8),
  longitude            numeric(11,8),
  avatar_url           text,
  phone                text,
  website              text,
  stripe_connect_id    text,
  platform_fee_percent numeric(5,2) not null default 10.00,
  is_verified          boolean not null default false,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);
create index if not exists idx_shops_owner on public.shops(owner_id);

-- -----------------------------------------------------------------------------
-- barber_profiles (1:1 with a barber's profile). Created ONLY by trigger.
-- -----------------------------------------------------------------------------
create table if not exists public.barber_profiles (
  id                            uuid primary key default gen_random_uuid(),
  user_id                       uuid not null unique references public.profiles(id) on delete cascade,
  shop_id                       uuid references public.shops(id) on delete set null,
  is_independent                boolean not null default true,
  bio                           text,
  specialties                   text[] not null default '{}',
  years_experience              integer not null default 0,
  hourly_rate                   numeric(10,2),
  rating                        numeric(3,2) not null default 0.00 check (rating >= 0 and rating <= 5),
  review_count                  integer not null default 0,
  latitude                      numeric(10,8),
  longitude                     numeric(11,8),
  address                       text,
  is_available                  boolean not null default true,
  is_verified                   boolean not null default false,
  instagram_handle              text,
  stripe_account_id             text,
  stripe_connect_id             text,
  booking_requires_confirmation boolean not null default true,
  instant_book_enabled          boolean not null default false,
  subscription_price            numeric(10,2) not null default 0.00,
  created_at                    timestamptz not null default now(),
  updated_at                    timestamptz not null default now()
);
create index if not exists idx_barber_profiles_shop on public.barber_profiles(shop_id);

-- -----------------------------------------------------------------------------
-- media_posts (feed; deferred past v1 but kept)
-- -----------------------------------------------------------------------------
create table if not exists public.media_posts (
  id                 uuid primary key default gen_random_uuid(),
  barber_id          uuid not null references public.barber_profiles(id) on delete cascade,
  image_url          text not null,
  video_url          text,
  caption            text,
  tags               text[] not null default '{}',
  is_premium         boolean not null default false,
  pay_per_view_price numeric(10,2) not null default 0.00,
  linked_service_ids uuid[] not null default '{}',
  created_at         timestamptz not null default now()
);
create index if not exists idx_media_posts_barber on public.media_posts(barber_id);

-- -----------------------------------------------------------------------------
-- client_vault (a client's private cut history)
-- -----------------------------------------------------------------------------
create table if not exists public.client_vault (
  id         uuid primary key default gen_random_uuid(),
  client_id  uuid not null references public.profiles(id) on delete cascade,
  barber_id  uuid references public.barber_profiles(id) on delete set null,
  image_url  text not null,
  is_private boolean not null default true,
  created_at timestamptz not null default now()
);
create index if not exists idx_client_vault_client on public.client_vault(client_id);
create index if not exists idx_client_vault_barber on public.client_vault(barber_id);

-- -----------------------------------------------------------------------------
-- saved_styles
-- -----------------------------------------------------------------------------
create table if not exists public.saved_styles (
  id         uuid primary key default gen_random_uuid(),
  client_id  uuid not null references public.profiles(id) on delete cascade,
  post_id    uuid not null references public.media_posts(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (client_id, post_id)
);

-- -----------------------------------------------------------------------------
-- services
-- -----------------------------------------------------------------------------
create table if not exists public.services (
  id               uuid primary key default gen_random_uuid(),
  barber_id        uuid not null references public.barber_profiles(id) on delete cascade,
  name             text not null,
  description      text,
  price            numeric(10,2) not null check (price >= 0),
  duration_minutes integer not null default 30 check (duration_minutes > 0 and duration_minutes <= 720),
  category         text not null default 'haircut'
                     check (category in ('haircut', 'beard', 'shave', 'color', 'treatment', 'combo', 'other')),
  is_active        boolean not null default true,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
create index if not exists idx_services_barber on public.services(barber_id);

-- -----------------------------------------------------------------------------
-- availability (weekly recurring working hours, barber-local time)
-- -----------------------------------------------------------------------------
create table if not exists public.availability (
  id           uuid primary key default gen_random_uuid(),
  barber_id    uuid not null references public.barber_profiles(id) on delete cascade,
  day_of_week  integer not null check (day_of_week between 0 and 6), -- 0=Sunday
  start_time   time not null,
  end_time     time not null,
  is_available boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique (barber_id, day_of_week)
);

-- -----------------------------------------------------------------------------
-- appointments
-- -----------------------------------------------------------------------------
create table if not exists public.appointments (
  id                       uuid primary key default gen_random_uuid(),
  client_id                uuid not null references public.profiles(id) on delete cascade,
  barber_id                uuid not null references public.barber_profiles(id) on delete cascade,
  service_id               uuid references public.services(id) on delete set null,
  scheduled_at             timestamptz not null,
  duration_minutes         integer not null default 30 check (duration_minutes > 0),
  status                   text not null default 'pending'
                             check (status in ('pending', 'confirmed', 'completed', 'cancelled', 'declined', 'no_show')),
  total_price              numeric(10,2),
  notes                    text,
  cancellation_reason      text,
  cancelled_by             uuid references public.profiles(id) on delete set null,
  confirmed_at             timestamptz,
  declined_at              timestamptz,
  declined_reason          text,
  payment_status           text not null default 'unpaid'
                             check (payment_status in ('unpaid', 'authorized', 'captured', 'refunded')),
  stripe_payment_intent_id text,
  created_at               timestamptz not null default now(),
  updated_at               timestamptz not null default now()
);
create index if not exists idx_appointments_client    on public.appointments(client_id);
create index if not exists idx_appointments_barber    on public.appointments(barber_id);
create index if not exists idx_appointments_scheduled on public.appointments(scheduled_at);
create index if not exists idx_appointments_status    on public.appointments(status);

-- -----------------------------------------------------------------------------
-- reviews (+ rating rollup trigger)
-- -----------------------------------------------------------------------------
create table if not exists public.reviews (
  id             uuid primary key default gen_random_uuid(),
  client_id      uuid not null references public.profiles(id) on delete cascade,
  barber_id      uuid not null references public.barber_profiles(id) on delete cascade,
  appointment_id uuid references public.appointments(id) on delete set null,
  rating         integer not null check (rating between 1 and 5),
  comment        text,
  photos         text[] not null default '{}',
  is_visible     boolean not null default true,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  unique (client_id, appointment_id)
);
create index if not exists idx_reviews_barber on public.reviews(barber_id);

create or replace function public.update_barber_rating()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_barber uuid := coalesce(new.barber_id, old.barber_id);
begin
  update public.barber_profiles bp
     set rating       = coalesce((select avg(r.rating)::numeric(3,2) from public.reviews r
                                   where r.barber_id = v_barber and r.is_visible), 0),
         review_count = (select count(*) from public.reviews r
                          where r.barber_id = v_barber and r.is_visible)
   where bp.id = v_barber;
  return coalesce(new, old);
end;
$$;

drop trigger if exists on_review_change on public.reviews;
create trigger on_review_change
  after insert or update or delete on public.reviews
  for each row execute function public.update_barber_rating();

-- -----------------------------------------------------------------------------
-- favorites
-- -----------------------------------------------------------------------------
create table if not exists public.favorites (
  id         uuid primary key default gen_random_uuid(),
  client_id  uuid not null references public.profiles(id) on delete cascade,
  barber_id  uuid not null references public.barber_profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (client_id, barber_id)
);

-- -----------------------------------------------------------------------------
-- portfolio_images
-- -----------------------------------------------------------------------------
create table if not exists public.portfolio_images (
  id            uuid primary key default gen_random_uuid(),
  barber_id     uuid not null references public.barber_profiles(id) on delete cascade,
  image_url     text not null,
  caption       text,
  display_order integer not null default 0,
  is_visible    boolean not null default true,
  created_at    timestamptz not null default now()
);
create index if not exists idx_portfolio_images_barber on public.portfolio_images(barber_id);

-- -----------------------------------------------------------------------------
-- notifications (written by backend / service role only)
-- -----------------------------------------------------------------------------
create table if not exists public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles(id) on delete cascade,
  title      text not null,
  body       text,
  type       text not null default 'general'
               check (type in ('appointment', 'reminder', 'promotion', 'general')),
  data       jsonb not null default '{}',
  is_read    boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists idx_notifications_user on public.notifications(user_id);

-- -----------------------------------------------------------------------------
-- subscriptions (written by Stripe webhook / service role only)
-- -----------------------------------------------------------------------------
create table if not exists public.subscriptions (
  id                     uuid primary key default gen_random_uuid(),
  subscriber_id          uuid not null references public.profiles(id) on delete cascade,
  creator_id             uuid references public.barber_profiles(id) on delete cascade, -- null = platform sub
  type                   text not null check (type in ('platform', 'creator')),
  status                 text not null default 'active',
  current_period_end     timestamptz not null,
  stripe_subscription_id text,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now(),
  unique (subscriber_id, creator_id, type)
);

-- -----------------------------------------------------------------------------
-- Academy (deferred past v1 but kept): courses, lessons, progress, purchases
-- -----------------------------------------------------------------------------
create table if not exists public.courses (
  id               uuid primary key default gen_random_uuid(),
  barber_id        uuid not null references public.barber_profiles(id) on delete cascade,
  title            text not null,
  description      text,
  thumbnail_url    text,
  price            numeric(10,2) not null default 0.00,
  is_premium       boolean not null default true,
  difficulty_level text check (difficulty_level in ('beginner', 'intermediate', 'advanced')),
  duration_minutes integer not null default 0,
  lesson_count     integer not null default 0,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create table if not exists public.course_lessons (
  id               uuid primary key default gen_random_uuid(),
  course_id        uuid not null references public.courses(id) on delete cascade,
  title            text not null,
  video_url        text not null,
  duration_minutes integer,
  order_index      integer not null default 0,
  is_preview       boolean not null default false,
  created_at       timestamptz not null default now()
);

create table if not exists public.user_course_progress (
  user_id      uuid not null references public.profiles(id) on delete cascade,
  course_id    uuid not null references public.courses(id) on delete cascade,
  lesson_id    uuid not null references public.course_lessons(id) on delete cascade,
  completed_at timestamptz not null default now(),
  primary key (user_id, lesson_id)
);

create table if not exists public.purchased_courses (
  user_id      uuid not null references public.profiles(id) on delete cascade,
  course_id    uuid not null references public.courses(id) on delete cascade,
  amount_paid  numeric(10,2) not null,
  purchased_at timestamptz not null default now(),
  primary key (user_id, course_id)
);

-- -----------------------------------------------------------------------------
-- updated_at triggers
-- -----------------------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array['profiles','shops','barber_profiles','services','availability',
                           'appointments','reviews','subscriptions','courses']
  loop
    execute format('drop trigger if exists set_updated_at on public.%I', t);
    execute format('create trigger set_updated_at before update on public.%I
                    for each row execute function public.set_updated_at()', t);
  end loop;
end;
$$;
