-- =============================================================================
-- Fade: storage buckets + storage.objects policies
-- -----------------------------------------------------------------------------
-- Path convention for EVERY bucket:  <auth.uid()>/<filename>
--   e.g. avatars/2b7c.../avatar_1696700000.jpg  (bucket = avatars,
--        object name = '2b7c.../avatar_1696700000.jpg')
-- Do NOT prefix the object name with the bucket name.
--
--   avatars       public read (public URL), owner-only write
--   portfolio     public read (public URL), owner-only write, barbers only
--   client-vault  PRIVATE: owner-only read/write; use signed URLs to display
--
-- Public buckets are served through /storage/v1/object/public/... without any
-- SELECT policy, so no broad SELECT policy is created (that would allow anyone
-- to list every file). Owners get SELECT on their own folder (needed for
-- upsert/overwrite and listing their own files).
-- =============================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars',      'avatars',      true,  5242880,  array['image/jpeg','image/png','image/webp']),
  ('portfolio',    'portfolio',    true,  10485760, array['image/jpeg','image/png','image/webp']),
  ('client-vault', 'client-vault', false, 10485760, array['image/jpeg','image/png','image/webp','image/heic'])
on conflict (id) do update
  set public             = excluded.public,
      file_size_limit    = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Remove policies from the old loose script (they allowed public listing).
drop policy if exists "Avatar images are publicly accessible"    on storage.objects;
drop policy if exists "Users can upload their own avatar"        on storage.objects;
drop policy if exists "Users can update their own avatar"        on storage.objects;
drop policy if exists "Users can delete their own avatar"        on storage.objects;
drop policy if exists "Portfolio images are publicly accessible" on storage.objects;
drop policy if exists "Barbers can upload portfolio images"      on storage.objects;
drop policy if exists "Barbers can update portfolio images"      on storage.objects;
drop policy if exists "Barbers can delete own portfolio images"  on storage.objects;

-- -----------------------------------------------------------------------------
-- avatars + client-vault: owner folder only
-- -----------------------------------------------------------------------------
drop policy if exists fade_owner_select on storage.objects;
create policy fade_owner_select on storage.objects
  for select to authenticated
  using (bucket_id in ('avatars', 'portfolio', 'client-vault')
         and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists fade_owner_insert on storage.objects;
create policy fade_owner_insert on storage.objects
  for insert to authenticated
  with check (bucket_id in ('avatars', 'client-vault')
              and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists fade_owner_update on storage.objects;
create policy fade_owner_update on storage.objects
  for update to authenticated
  using (bucket_id in ('avatars', 'client-vault')
         and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id in ('avatars', 'client-vault')
              and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists fade_owner_delete on storage.objects;
create policy fade_owner_delete on storage.objects
  for delete to authenticated
  using (bucket_id in ('avatars', 'portfolio', 'client-vault')
         and (storage.foldername(name))[1] = (select auth.uid())::text);

-- -----------------------------------------------------------------------------
-- portfolio: owner folder, and the uploader must be a barber
-- -----------------------------------------------------------------------------
drop policy if exists fade_portfolio_insert on storage.objects;
create policy fade_portfolio_insert on storage.objects
  for insert to authenticated
  with check (bucket_id = 'portfolio'
              and (storage.foldername(name))[1] = (select auth.uid())::text
              and (select public.current_barber_id()) is not null);

drop policy if exists fade_portfolio_update on storage.objects;
create policy fade_portfolio_update on storage.objects
  for update to authenticated
  using (bucket_id = 'portfolio'
         and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'portfolio'
              and (storage.foldername(name))[1] = (select auth.uid())::text
              and (select public.current_barber_id()) is not null);
