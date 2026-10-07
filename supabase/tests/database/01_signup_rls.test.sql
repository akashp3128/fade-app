-- pgTAP: sign-up triggers, RLS privacy, column guards, storage policies.
-- Run with:  supabase test db
begin;
create extension if not exists pgtap with schema extensions;
select plan(32);

-- ---------------------------------------------------------------------------
-- Fixtures: three sign-ups through auth.users (same path as the Auth API)
-- ---------------------------------------------------------------------------
insert into auth.users (id, email, phone, raw_user_meta_data, aud, role) values
  ('11111111-1111-4111-8111-111111111111', 'client.a@test.dev', '+13125550001',
   '{"full_name":"Client A","user_type":"client"}', 'authenticated', 'authenticated'),
  ('22222222-2222-4222-8222-222222222222', 'barber.b@test.dev', null,
   '{"full_name":"Barber B","user_type":"barber","phone":"+13125550002"}', 'authenticated', 'authenticated'),
  ('33333333-3333-4333-8333-333333333333', 'sneaky@test.dev', null,
   '{"name":"Sneaky","role":"admin"}', 'authenticated', 'authenticated');

-- 1-6: trigger creates exactly one profile (+ barber_profiles for barbers)
select is((select count(*)::int from public.profiles where id = '11111111-1111-4111-8111-111111111111'), 1, 'client: one profile');
select is((select count(*)::int from public.barber_profiles where user_id = '11111111-1111-4111-8111-111111111111'), 0, 'client: no barber_profiles');
select is((select count(*)::int from public.profiles where id = '22222222-2222-4222-8222-222222222222'), 1, 'barber: one profile');
select is((select count(*)::int from public.barber_profiles where user_id = '22222222-2222-4222-8222-222222222222'), 1, 'barber: one barber_profiles row');
select is((select user_type from public.profiles where id = '33333333-3333-4333-8333-333333333333'), 'client', 'self-assigned admin is coerced to client');
select is((select full_name || '|' || coalesce(phone,'') from public.profiles where id = '22222222-2222-4222-8222-222222222222'),
          'Barber B|+13125550002', 'full_name + phone read from metadata');

-- 7: trigger is idempotent (re-firing does not raise duplicate key)
select lives_ok($$ insert into public.barber_profiles (user_id) values ('22222222-2222-4222-8222-222222222222') on conflict (user_id) do nothing $$,
                'barber_profiles insert is conflict-safe');

-- ---------------------------------------------------------------------------
-- As Client A
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}', true);

-- 8-9: the OLD app sign-up inserts are now rejected (DB is the only creator)
select throws_ok($$ insert into public.profiles (id, full_name, user_type) values ('11111111-1111-4111-8111-111111111111', 'Client A', 'client') $$,
                 '42501', null, 'app can no longer insert into profiles');
select throws_ok($$ insert into public.barber_profiles (user_id) values ('11111111-1111-4111-8111-111111111111') $$,
                 '42501', null, 'app can no longer insert into barber_profiles');

-- 10-13: profiles privacy
select is((select email from public.profiles where id = '11111111-1111-4111-8111-111111111111'), 'client.a@test.dev', 'owner reads own email');
select is((select count(*)::int from public.profiles where id = '22222222-2222-4222-8222-222222222222'), 0, 'cannot read another user''s profiles row (email/phone)');
select is((select full_name from public.public_profiles where id = '22222222-2222-4222-8222-222222222222'), 'Barber B', 'public_profiles exposes safe fields of others');
select hasnt_column('public', 'public_profiles', 'email', 'public_profiles has no email column');
select hasnt_column('public', 'public_profiles', 'phone', 'public_profiles has no phone column');

-- 15-17: column guards
select throws_ok($$ update public.profiles set user_type = 'admin' where id = '11111111-1111-4111-8111-111111111111' $$,
                 '42501', null, 'cannot self-promote to admin');
select throws_ok($$ update public.profiles set is_fade_pro_member = true where id = '11111111-1111-4111-8111-111111111111' $$,
                 '42501', null, 'cannot grant self pro membership');
select lives_ok($$ update public.profiles set full_name = 'Client A2', phone = '+13125559999' where id = '11111111-1111-4111-8111-111111111111' $$,
                'owner can edit name/phone');

-- 18-19: client_vault (private by default)
select lives_ok($$ insert into public.client_vault (client_id, barber_id, image_url)
                   values ('11111111-1111-4111-8111-111111111111',
                           (select id from public.barber_profiles where user_id = '22222222-2222-4222-8222-222222222222'),
                           'client-vault/11111111-1111-4111-8111-111111111111/cut1.jpg') $$,
                'client can add to own vault');
select throws_ok($$ insert into public.client_vault (client_id, image_url)
                    values ('22222222-2222-4222-8222-222222222222', 'x.jpg') $$,
                 '42501', null, 'cannot write into someone else''s vault');

-- 20-21: storage owner-folder policies
select lives_ok($$ insert into storage.objects (bucket_id, name, owner_id) values
                   ('avatars', '11111111-1111-4111-8111-111111111111/me.jpg', '11111111-1111-4111-8111-111111111111') $$,
                'upload into own avatars folder');
select throws_ok($$ insert into storage.objects (bucket_id, name) values
                    ('avatars', '22222222-2222-4222-8222-222222222222/me.jpg') $$,
                 '42501', null, 'cannot upload into another user''s avatars folder');
-- 22: clients cannot upload portfolio images
select throws_ok($$ insert into storage.objects (bucket_id, name) values
                    ('portfolio', '11111111-1111-4111-8111-111111111111/p.jpg') $$,
                 '42501', null, 'non-barber cannot upload to portfolio');

-- ---------------------------------------------------------------------------
-- As Barber B
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"22222222-2222-4222-8222-222222222222","role":"authenticated"}', true);

-- 23-24: private vault entry hidden from the tagged barber; others' storage hidden
select is((select count(*)::int from public.client_vault), 0, 'barber cannot see client''s private vault entries');
select is((select count(*)::int from storage.objects where bucket_id = 'avatars'), 0, 'cannot list another user''s files');
-- 25-26: barber column guards
select throws_ok($$ update public.barber_profiles set rating = 5 where user_id = '22222222-2222-4222-8222-222222222222' $$,
                 '42501', null, 'barber cannot set own rating');
select lives_ok($$ update public.barber_profiles set bio = 'Fades', instagram_handle = '@b' where user_id = '22222222-2222-4222-8222-222222222222' $$,
                'barber can edit own bio');
-- 27: barber can upload to own portfolio folder
select lives_ok($$ insert into storage.objects (bucket_id, name) values
                   ('portfolio', '22222222-2222-4222-8222-222222222222/p.jpg') $$,
                'barber uploads into own portfolio folder');
-- 28: barber can't read client's private profile without a booking
select is((select count(*)::int from public.profiles where id = '11111111-1111-4111-8111-111111111111'), 0,
          'barber cannot read a non-client''s email/phone');

-- ---------------------------------------------------------------------------
-- As anon
-- ---------------------------------------------------------------------------
reset role;
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select is((select count(*)::int from public.profiles), 0, 'anon reads no profiles rows');
select ok((select count(*) from public.public_profiles) >= 3, 'anon can read public_profiles');
select is((select count(*)::int from public.client_vault), 0, 'anon reads no vault rows');

reset role;
-- 32: every public table has RLS enabled
select is((select count(*)::int from pg_class c join pg_namespace n on n.oid = c.relnamespace
            where n.nspname = 'public' and c.relkind = 'r' and not c.relrowsecurity), 0,
          'RLS enabled on every public table');

select * from finish();
rollback;
