-- =============================================================================
-- Fade: Row Level Security on EVERY public table + public_profiles view
-- -----------------------------------------------------------------------------
-- Conventions:
--   * (select auth.uid()) is used for per-statement caching.
--   * Helper functions are SECURITY DEFINER to avoid policy recursion; they
--     only answer questions about the *current* user.
--   * Tables with no write policy are written only by triggers / RPCs /
--     service_role (e.g. profiles insert, notifications, subscriptions).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------
create or replace function public.current_barber_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select bp.id from public.barber_profiles bp where bp.user_id = (select auth.uid());
$$;

-- Does the current user have premium access to this creator's content?
create or replace function public.has_creator_access(p_barber_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    exists (select 1 from public.barber_profiles bp
             where bp.id = p_barber_id and bp.user_id = (select auth.uid()))
    or exists (select 1 from public.profiles p
                where p.id = (select auth.uid()) and p.is_fade_pro_member)
    or exists (select 1 from public.subscriptions s
                where s.subscriber_id = (select auth.uid())
                  and s.status = 'active'
                  and s.current_period_end > now()
                  and (s.type = 'platform' or s.creator_id = p_barber_id));
$$;

create or replace function public.has_course_access(p_course_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.courses c
     where c.id = p_course_id
       and (
         (c.price = 0 and not c.is_premium)
         or public.has_creator_access(c.barber_id)
         or exists (select 1 from public.purchased_courses pc
                     where pc.course_id = c.id and pc.user_id = (select auth.uid()))
       )
  );
$$;

-- -----------------------------------------------------------------------------
-- Enable RLS everywhere (verified list = every table in migration 1)
-- -----------------------------------------------------------------------------
alter table public.profiles             enable row level security;
alter table public.shops                enable row level security;
alter table public.barber_profiles      enable row level security;
alter table public.media_posts          enable row level security;
alter table public.client_vault         enable row level security;
alter table public.saved_styles         enable row level security;
alter table public.services             enable row level security;
alter table public.availability         enable row level security;
alter table public.appointments         enable row level security;
alter table public.reviews              enable row level security;
alter table public.favorites            enable row level security;
alter table public.portfolio_images     enable row level security;
alter table public.notifications        enable row level security;
alter table public.subscriptions        enable row level security;
alter table public.courses              enable row level security;
alter table public.course_lessons       enable row level security;
alter table public.user_course_progress enable row level security;
alter table public.purchased_courses    enable row level security;

-- Drop the permissive policies from the old loose scripts if present.
drop policy if exists "Profiles are viewable by everyone"  on public.profiles;
drop policy if exists "Barbers can insert own profile"     on public.barber_profiles;
drop policy if exists "Media visibility"                   on public.media_posts;

-- -----------------------------------------------------------------------------
-- profiles: full row (incl. email/phone) only for the owner, and for a barber
-- reading clients who have booked with them. Everyone else: public_profiles.
-- No INSERT/DELETE policy: rows come from the auth trigger / auth cascade.
-- -----------------------------------------------------------------------------
drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
  for select to authenticated
  using (id = (select auth.uid()));

drop policy if exists profiles_select_barber_clients on public.profiles;
create policy profiles_select_barber_clients on public.profiles
  for select to authenticated
  using (exists (select 1 from public.appointments a
                  where a.client_id = profiles.id
                    and a.barber_id = (select public.current_barber_id())));

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- Public, safe projection of profiles. Intentionally runs with the view
-- owner's rights (security_invoker = false) so it can bypass the owner-only
-- RLS above, and it exposes ONLY non-sensitive columns (no email/phone,
-- no billing fields). PostgREST can embed it via the profiles FKs, e.g.
--   barber_profiles?select=*,profiles:public_profiles!inner(*)
create or replace view public.public_profiles
  with (security_invoker = false, security_barrier = true)
as
  select p.id, p.full_name, p.avatar_url, p.user_type, p.created_at, p.updated_at
  from public.profiles p;

comment on view public.public_profiles is
  'Safe public fields of profiles (no email/phone). Use for any user other than yourself.';

revoke all on public.public_profiles from public, anon, authenticated;
grant select on public.public_profiles to anon, authenticated, service_role;

-- -----------------------------------------------------------------------------
-- shops: public read; owners manage (business fields guarded by trigger)
-- -----------------------------------------------------------------------------
drop policy if exists shops_select_all on public.shops;
create policy shops_select_all on public.shops
  for select to anon, authenticated using (true);

drop policy if exists shops_insert_owner on public.shops;
create policy shops_insert_owner on public.shops
  for insert to authenticated with check (owner_id = (select auth.uid()));

drop policy if exists shops_update_owner on public.shops;
create policy shops_update_owner on public.shops
  for update to authenticated
  using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));

drop policy if exists shops_delete_owner on public.shops;
create policy shops_delete_owner on public.shops
  for delete to authenticated using (owner_id = (select auth.uid()));

-- -----------------------------------------------------------------------------
-- barber_profiles: public read; owner updates (backend fields guarded).
-- No INSERT policy (trigger creates); no DELETE (cascades from auth.users).
-- -----------------------------------------------------------------------------
drop policy if exists "Barber profiles are viewable by everyone" on public.barber_profiles;
drop policy if exists "Barbers can update own profile" on public.barber_profiles;

drop policy if exists barber_profiles_select_all on public.barber_profiles;
create policy barber_profiles_select_all on public.barber_profiles
  for select to anon, authenticated using (true);

drop policy if exists barber_profiles_update_own on public.barber_profiles;
create policy barber_profiles_update_own on public.barber_profiles
  for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- -----------------------------------------------------------------------------
-- media_posts: non-premium public; premium for creator/subscribers
-- -----------------------------------------------------------------------------
drop policy if exists media_posts_select on public.media_posts;
create policy media_posts_select on public.media_posts
  for select to anon, authenticated
  using (not is_premium or (select public.has_creator_access(barber_id)));

drop policy if exists media_posts_write_own on public.media_posts;
create policy media_posts_write_own on public.media_posts
  for all to authenticated
  using (barber_id = (select public.current_barber_id()))
  with check (barber_id = (select public.current_barber_id()));

-- -----------------------------------------------------------------------------
-- client_vault: owned by the client. The tagged barber may read entries the
-- client has marked non-private. Nobody else.
-- -----------------------------------------------------------------------------
drop policy if exists client_vault_client_all on public.client_vault;
create policy client_vault_client_all on public.client_vault
  for all to authenticated
  using (client_id = (select auth.uid()))
  with check (client_id = (select auth.uid()));

drop policy if exists client_vault_barber_select on public.client_vault;
create policy client_vault_barber_select on public.client_vault
  for select to authenticated
  using (not is_private and barber_id = (select public.current_barber_id()));

-- -----------------------------------------------------------------------------
-- saved_styles: own rows only
-- -----------------------------------------------------------------------------
drop policy if exists saved_styles_own on public.saved_styles;
create policy saved_styles_own on public.saved_styles
  for all to authenticated
  using (client_id = (select auth.uid()))
  with check (client_id = (select auth.uid()));

-- -----------------------------------------------------------------------------
-- services: active services public; barber manages own
-- -----------------------------------------------------------------------------
drop policy if exists "Services are viewable by everyone" on public.services;
drop policy if exists "Barbers can manage own services" on public.services;

drop policy if exists services_select on public.services;
create policy services_select on public.services
  for select to anon, authenticated
  using (is_active or barber_id = (select public.current_barber_id()));

drop policy if exists services_write_own on public.services;
create policy services_write_own on public.services
  for all to authenticated
  using (barber_id = (select public.current_barber_id()))
  with check (barber_id = (select public.current_barber_id()));

-- -----------------------------------------------------------------------------
-- availability (weekly hours): public read; barber manages own
-- -----------------------------------------------------------------------------
drop policy if exists "Availability is viewable by everyone" on public.availability;
drop policy if exists "Barbers can manage own availability" on public.availability;

drop policy if exists availability_select_all on public.availability;
create policy availability_select_all on public.availability
  for select to anon, authenticated using (true);

drop policy if exists availability_write_own on public.availability;
create policy availability_write_own on public.availability
  for all to authenticated
  using (barber_id = (select public.current_barber_id()))
  with check (barber_id = (select public.current_barber_id()));

-- -----------------------------------------------------------------------------
-- appointments: visible to the client and the barber involved.
-- (Writes are tightened further by guard_appointments_write.)
-- -----------------------------------------------------------------------------
drop policy if exists "Users can view own appointments" on public.appointments;
drop policy if exists "Clients can create appointments" on public.appointments;
drop policy if exists "Involved parties can update appointments" on public.appointments;

drop policy if exists appointments_select_party on public.appointments;
create policy appointments_select_party on public.appointments
  for select to authenticated
  using (client_id = (select auth.uid())
         or barber_id = (select public.current_barber_id()));

drop policy if exists appointments_insert_client on public.appointments;
create policy appointments_insert_client on public.appointments
  for insert to authenticated
  with check (client_id = (select auth.uid()));

drop policy if exists appointments_update_party on public.appointments;
create policy appointments_update_party on public.appointments
  for update to authenticated
  using (client_id = (select auth.uid())
         or barber_id = (select public.current_barber_id()))
  with check (client_id = (select auth.uid())
              or barber_id = (select public.current_barber_id()));

-- -----------------------------------------------------------------------------
-- reviews: visible ones public; a client may review only their own
-- completed appointment with that barber.
-- -----------------------------------------------------------------------------
drop policy if exists "Reviews are viewable by everyone" on public.reviews;
drop policy if exists "Clients can create reviews" on public.reviews;
drop policy if exists "Clients can update own reviews" on public.reviews;

drop policy if exists reviews_select on public.reviews;
create policy reviews_select on public.reviews
  for select to anon, authenticated
  using (is_visible or client_id = (select auth.uid()));

drop policy if exists reviews_insert_own on public.reviews;
create policy reviews_insert_own on public.reviews
  for insert to authenticated
  with check (
    client_id = (select auth.uid())
    and exists (select 1 from public.appointments a
                 where a.id = reviews.appointment_id
                   and a.client_id = (select auth.uid())
                   and a.barber_id = reviews.barber_id
                   and a.status = 'completed')
  );

drop policy if exists reviews_update_own on public.reviews;
create policy reviews_update_own on public.reviews
  for update to authenticated
  using (client_id = (select auth.uid()))
  with check (client_id = (select auth.uid()));

drop policy if exists reviews_delete_own on public.reviews;
create policy reviews_delete_own on public.reviews
  for delete to authenticated using (client_id = (select auth.uid()));

-- -----------------------------------------------------------------------------
-- favorites: own rows only
-- -----------------------------------------------------------------------------
drop policy if exists "Users can view own favorites" on public.favorites;
drop policy if exists "Users can manage own favorites" on public.favorites;

drop policy if exists favorites_own on public.favorites;
create policy favorites_own on public.favorites
  for all to authenticated
  using (client_id = (select auth.uid()))
  with check (client_id = (select auth.uid()));

-- -----------------------------------------------------------------------------
-- portfolio_images: visible ones public; barber manages own
-- -----------------------------------------------------------------------------
drop policy if exists "Portfolio images are viewable by everyone" on public.portfolio_images;
drop policy if exists "Barbers can manage own portfolio" on public.portfolio_images;

drop policy if exists portfolio_images_select on public.portfolio_images;
create policy portfolio_images_select on public.portfolio_images
  for select to anon, authenticated
  using (is_visible or barber_id = (select public.current_barber_id()));

drop policy if exists portfolio_images_write_own on public.portfolio_images;
create policy portfolio_images_write_own on public.portfolio_images
  for all to authenticated
  using (barber_id = (select public.current_barber_id()))
  with check (barber_id = (select public.current_barber_id()));

-- -----------------------------------------------------------------------------
-- notifications: recipient reads/marks read/deletes; backend inserts
-- -----------------------------------------------------------------------------
drop policy if exists "Users can view own notifications" on public.notifications;
drop policy if exists "Users can update own notifications" on public.notifications;

drop policy if exists notifications_select_own on public.notifications;
create policy notifications_select_own on public.notifications
  for select to authenticated using (user_id = (select auth.uid()));

drop policy if exists notifications_update_own on public.notifications;
create policy notifications_update_own on public.notifications
  for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

drop policy if exists notifications_delete_own on public.notifications;
create policy notifications_delete_own on public.notifications
  for delete to authenticated using (user_id = (select auth.uid()));

-- -----------------------------------------------------------------------------
-- subscriptions: subscriber reads own; writes via Stripe webhook (service_role)
-- -----------------------------------------------------------------------------
drop policy if exists "Users view own subscriptions" on public.subscriptions;

drop policy if exists subscriptions_select_own on public.subscriptions;
create policy subscriptions_select_own on public.subscriptions
  for select to authenticated using (subscriber_id = (select auth.uid()));

-- -----------------------------------------------------------------------------
-- courses: catalog public; creator manages own
-- -----------------------------------------------------------------------------
drop policy if exists courses_select_all on public.courses;
create policy courses_select_all on public.courses
  for select to anon, authenticated using (true);

drop policy if exists courses_write_own on public.courses;
create policy courses_write_own on public.courses
  for all to authenticated
  using (barber_id = (select public.current_barber_id()))
  with check (barber_id = (select public.current_barber_id()));

-- course_lessons: previews public; full lessons need access
drop policy if exists course_lessons_select on public.course_lessons;
create policy course_lessons_select on public.course_lessons
  for select to anon, authenticated
  using (is_preview or (select public.has_course_access(course_id)));

drop policy if exists course_lessons_write_own on public.course_lessons;
create policy course_lessons_write_own on public.course_lessons
  for all to authenticated
  using (exists (select 1 from public.courses c
                  where c.id = course_lessons.course_id
                    and c.barber_id = (select public.current_barber_id())))
  with check (exists (select 1 from public.courses c
                       where c.id = course_lessons.course_id
                         and c.barber_id = (select public.current_barber_id())));

-- user_course_progress: own rows; only for lessons the user can access
drop policy if exists user_course_progress_select_own on public.user_course_progress;
create policy user_course_progress_select_own on public.user_course_progress
  for select to authenticated using (user_id = (select auth.uid()));

drop policy if exists user_course_progress_insert_own on public.user_course_progress;
create policy user_course_progress_insert_own on public.user_course_progress
  for insert to authenticated
  with check (user_id = (select auth.uid()) and (select public.has_course_access(course_id)));

drop policy if exists user_course_progress_delete_own on public.user_course_progress;
create policy user_course_progress_delete_own on public.user_course_progress
  for delete to authenticated using (user_id = (select auth.uid()));

-- purchased_courses: buyer reads own; writes via payment webhook (service_role)
drop policy if exists purchased_courses_select_own on public.purchased_courses;
create policy purchased_courses_select_own on public.purchased_courses
  for select to authenticated using (user_id = (select auth.uid()));
