# Supabase Setup Guide for Fade App

## Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in/sign up
2. Click **"New Project"**
3. Fill in the details:
   - **Project name**: `fade-app` (or your preference)
   - **Database Password**: Generate a strong password (save this!)
   - **Region**: Choose closest to your users
4. Click **"Create new project"** and wait 2-3 minutes

## Step 2: Get Your Credentials

Once the project is ready:

1. Go to **Settings** (gear icon) > **API**
2. Copy these values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon public key** (starts with `eyJ...`)

## Step 3: Run the Database Schema

1. In Supabase, go to **SQL Editor** (left sidebar)
2. Click **"New query"**
3. Copy the entire contents of `supabase_setup.sql` and paste it
4. Click **"Run"** (or press Cmd/Ctrl + Enter)
5. You should see "Success. No rows returned" for each statement

## Step 4: Set Up Storage Buckets

1. Go to **Storage** (left sidebar)
2. Click **"New bucket"** and create two buckets:

### Bucket 1: `avatars`
- Name: `avatars`
- Public: **Yes** (toggle on)
- File size limit: 5MB
- Allowed MIME types: `image/jpeg, image/png, image/webp`

### Bucket 2: `portfolio`
- Name: `portfolio`
- Public: **Yes** (toggle on)
- File size limit: 10MB
- Allowed MIME types: `image/jpeg, image/png, image/webp`

### Storage Policies (run in SQL Editor):

```sql
-- Avatar bucket policies
CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[2]
);

CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[2]
);

CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[2]
);

-- Portfolio bucket policies
CREATE POLICY "Portfolio images are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'portfolio');

CREATE POLICY "Barbers can upload portfolio images"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'portfolio' AND
    EXISTS (
        SELECT 1 FROM public.barber_profiles
        WHERE user_id = auth.uid()
        AND id::text = (storage.foldername(name))[2]
    )
);

CREATE POLICY "Barbers can delete own portfolio images"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'portfolio' AND
    EXISTS (
        SELECT 1 FROM public.barber_profiles
        WHERE user_id = auth.uid()
        AND id::text = (storage.foldername(name))[2]
    )
);
```

## Step 5: Enable Authentication Providers (Optional)

### Email/Password (enabled by default)
No additional setup needed.

### Google OAuth:
1. Go to **Authentication** > **Providers** > **Google**
2. Toggle **Enable**
3. Follow instructions to get Google Client ID/Secret from Google Cloud Console
4. Add your app's redirect URL

### Apple OAuth:
1. Go to **Authentication** > **Providers** > **Apple**
2. Toggle **Enable**
3. Follow Apple Developer setup instructions

## Step 6: Update Your App

Open `lib/config/constants.dart` and update:

```dart
class AppConstants {
  // Supabase - YOUR ACTUAL VALUES
  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'eyJ...YOUR_ANON_KEY...';

  // ... rest of the file
}
```

## Step 7: Test the Setup

Run the app and try:
1. **Sign up** with email/password
2. Check Supabase **Authentication** > **Users** - your user should appear
3. Check **Table Editor** > **profiles** - profile should be auto-created
4. If signing up as barber, check **barber_profiles** table too

## Troubleshooting

### "relation does not exist" error
- Make sure you ran the SQL schema in the correct order
- Check the SQL Editor for any errors

### Authentication not working
- Verify your Supabase URL and anon key are correct
- Check that Email auth is enabled in Authentication > Providers

### Storage uploads failing
- Verify bucket names match exactly: `avatars` and `portfolio`
- Check storage policies are applied
- Ensure buckets are set to public

## Database Schema Overview

```
profiles              <- User accounts (linked to auth.users)
    ↓
barber_profiles       <- Extended info for barbers
    ↓
    ├── services      <- Services offered by barber
    ├── availability  <- Weekly schedule
    ├── portfolio_images
    └── reviews       <- From clients

appointments          <- Bookings between clients & barbers
favorites            <- Client's saved barbers
notifications        <- Push notification queue
```

## Next Steps

After setup is complete:
1. Create a test barber account
2. Add services and availability
3. Create a test client account
4. Book an appointment
5. Leave a review

The app is now ready for development and testing!
