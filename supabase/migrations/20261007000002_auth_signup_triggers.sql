-- =============================================================================
-- Fade: sign-up triggers + protected-column guards
-- -----------------------------------------------------------------------------
-- The database is the SINGLE source of truth for creating profile rows:
--   auth.users INSERT  -> public.profiles row          (handle_new_user)
--   profiles user_type = 'barber' -> barber_profiles row (handle_barber_profile)
-- The app must NOT insert into profiles or barber_profiles itself.
--
-- Sign-up metadata contract (supabase.auth.signUp(..., data: {...})):
--   full_name : text   (fallbacks: name, then email local-part, then 'New User')
--   user_type : 'client' | 'barber'   (alias: role). Anything else -> 'client'.
--               'admin' can never be self-assigned.
--   phone     : text, optional
--   avatar_url: text, optional (fallback: picture, as sent by Google OAuth)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Helper: is the current database role a trusted backend role?
-- (postgres / supabase_admin / service_role, or a SECURITY DEFINER function
-- running as its owner). anon + authenticated are API end users.
-- Must stay SECURITY INVOKER so current_user reflects the caller.
-- -----------------------------------------------------------------------------
create or replace function public.is_backend_role()
returns boolean
language sql
stable
set search_path = ''
as $$
  select current_user not in ('anon', 'authenticated');
$$;

-- -----------------------------------------------------------------------------
-- auth.users -> profiles
-- -----------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_meta      jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  v_user_type text  := lower(coalesce(nullif(trim(v_meta->>'user_type'), ''),
                                      nullif(trim(v_meta->>'role'), ''),
                                      'client'));
  v_full_name text  := coalesce(nullif(trim(v_meta->>'full_name'), ''),
                                nullif(trim(v_meta->>'name'), ''),
                                nullif(split_part(coalesce(new.email, ''), '@', 1), ''),
                                'New User');
begin
  if v_user_type not in ('client', 'barber') then
    v_user_type := 'client';  -- never allow self-assigned 'admin' or junk
  end if;

  insert into public.profiles (id, full_name, email, phone, avatar_url, user_type)
  values (
    new.id,
    v_full_name,
    new.email,
    coalesce(nullif(new.phone, ''), nullif(trim(v_meta->>'phone'), '')),
    coalesce(nullif(v_meta->>'avatar_url', ''), nullif(v_meta->>'picture', '')),
    v_user_type
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Keep profiles.email in sync when the auth email changes (email is not
-- editable through the API; see guard below).
create or replace function public.handle_user_email_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.profiles set email = new.email where id = new.id;
  return new;
end;
$$;

drop trigger if exists on_auth_user_email_changed on auth.users;
create trigger on_auth_user_email_changed
  after update of email on auth.users
  for each row
  when (old.email is distinct from new.email)
  execute function public.handle_user_email_change();

-- -----------------------------------------------------------------------------
-- profiles(user_type = 'barber') -> barber_profiles
-- Fires on sign-up and when a client later switches to barber.
-- -----------------------------------------------------------------------------
create or replace function public.handle_barber_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.user_type = 'barber' then
    insert into public.barber_profiles (user_id)
    values (new.id)
    on conflict (user_id) do nothing;
  end if;
  return new;
end;
$$;

drop trigger if exists on_profile_barber_type on public.profiles;
create trigger on_profile_barber_type
  after insert or update of user_type on public.profiles
  for each row execute function public.handle_barber_profile();

-- -----------------------------------------------------------------------------
-- Guard: columns end users may not change on their own profile
-- -----------------------------------------------------------------------------
create or replace function public.guard_profiles_update()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if public.is_backend_role() then
    return new;
  end if;
  if new.id is distinct from old.id then
    raise exception 'profiles.id is immutable' using errcode = '42501';
  end if;
  if new.email is distinct from old.email then
    raise exception 'email is managed by auth; use supabase.auth.updateUser' using errcode = '42501';
  end if;
  if new.is_fade_pro_member is distinct from old.is_fade_pro_member
     or new.stripe_customer_id is distinct from old.stripe_customer_id then
    raise exception 'billing fields are managed by the backend' using errcode = '42501';
  end if;
  if new.user_type is distinct from old.user_type
     and (new.user_type = 'admin' or old.user_type = 'admin') then
    raise exception 'user_type admin cannot be changed by users' using errcode = '42501';
  end if;
  return new;
end;
$$;

drop trigger if exists guard_profiles_update on public.profiles;
create trigger guard_profiles_update
  before update on public.profiles
  for each row execute function public.guard_profiles_update();

-- -----------------------------------------------------------------------------
-- Guard: barber-editable vs backend-only columns on barber_profiles
-- -----------------------------------------------------------------------------
create or replace function public.guard_barber_profiles_update()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if public.is_backend_role() then
    return new;
  end if;
  if new.user_id is distinct from old.user_id
     or new.rating is distinct from old.rating
     or new.review_count is distinct from old.review_count
     or new.is_verified is distinct from old.is_verified
     or new.stripe_account_id is distinct from old.stripe_account_id
     or new.stripe_connect_id is distinct from old.stripe_connect_id then
    raise exception 'user_id, rating, review_count, is_verified and stripe ids are managed by the backend'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

drop trigger if exists guard_barber_profiles_update on public.barber_profiles;
create trigger guard_barber_profiles_update
  before update on public.barber_profiles
  for each row execute function public.guard_barber_profiles_update();

-- -----------------------------------------------------------------------------
-- Guard: shops business fields (fee %, verification, payouts) are backend-only
-- -----------------------------------------------------------------------------
create or replace function public.guard_shops_write()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if public.is_backend_role() then
    return new;
  end if;
  if tg_op = 'INSERT' then
    new.is_verified          := false;
    new.stripe_connect_id    := null;
    new.platform_fee_percent := 10.00;
  elsif new.is_verified is distinct from old.is_verified
     or new.stripe_connect_id is distinct from old.stripe_connect_id
     or new.platform_fee_percent is distinct from old.platform_fee_percent
     or new.owner_id is distinct from old.owner_id then
    raise exception 'owner_id, is_verified, stripe_connect_id and platform_fee_percent are managed by the backend'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

drop trigger if exists guard_shops_write on public.shops;
create trigger guard_shops_write
  before insert or update on public.shops
  for each row execute function public.guard_shops_write();

-- -----------------------------------------------------------------------------
-- Guard: appointment fields end users may not set/change directly
-- -----------------------------------------------------------------------------
create or replace function public.guard_appointments_write()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_is_client boolean;
begin
  if public.is_backend_role() then
    return new;
  end if;
  if tg_op = 'INSERT' then
    if new.status <> 'pending' or new.payment_status <> 'unpaid'
       or new.stripe_payment_intent_id is not null
       or new.confirmed_at is not null or new.declined_at is not null then
      raise exception 'new appointments must be pending/unpaid' using errcode = '42501';
    end if;
    return new;
  end if;

  if new.client_id is distinct from old.client_id
     or new.barber_id is distinct from old.barber_id
     or new.total_price is distinct from old.total_price
     or new.payment_status is distinct from old.payment_status
     or new.stripe_payment_intent_id is distinct from old.stripe_payment_intent_id then
    raise exception 'client, barber, price and payment fields cannot be changed' using errcode = '42501';
  end if;

  v_is_client := old.client_id = (select auth.uid());
  if v_is_client
     and new.status is distinct from old.status
     and new.status <> 'cancelled'
     and not exists (select 1 from public.barber_profiles bp
                      where bp.id = old.barber_id and bp.user_id = (select auth.uid())) then
    raise exception 'clients can only cancel appointments' using errcode = '42501';
  end if;
  return new;
end;
$$;

drop trigger if exists guard_appointments_write on public.appointments;
create trigger guard_appointments_write
  before insert or update on public.appointments
  for each row execute function public.guard_appointments_write();

-- Trigger functions are not meant to be called directly.
revoke execute on function public.handle_new_user()            from public, anon, authenticated;
revoke execute on function public.handle_user_email_change()   from public, anon, authenticated;
revoke execute on function public.handle_barber_profile()      from public, anon, authenticated;
revoke execute on function public.update_barber_rating()       from public, anon, authenticated;
