# Fade - Barber Appointment App

A Flutter mobile app for booking barber appointments. Connects clients with barbers for seamless scheduling.

## Features

- Client & Barber accounts
- Browse nearby barbers
- Book appointments
- Review system
- Barber portfolio & availability management

## Setup

### Prerequisites

- Flutter SDK (3.x+)
- Dart SDK
- Supabase account

### Configuration

1. Copy the environment template:
   ```bash
   cp .env.example .env
   ```

2. Fill in your credentials in `.env`:
   - `SUPABASE_URL` - Your Supabase project URL
   - `SUPABASE_ANON_KEY` - Your Supabase anon/public key
   - `GOOGLE_MAPS_API_KEY` - Google Maps API key
   - `STRIPE_PUBLISHABLE_KEY` - Stripe publishable key (optional)

3. Set up Supabase database - see `SUPABASE_SETUP.md`

### Running the App

```bash
# Install dependencies
flutter pub get

# Run with environment variables
flutter run \
  --dart-define=SUPABASE_URL=your-url \
  --dart-define=SUPABASE_ANON_KEY=your-key \
  --dart-define=GOOGLE_MAPS_API_KEY=your-key
```

Or create a launch configuration in your IDE.

## Project Structure

```
lib/
├── config/       # App configuration & constants
├── models/       # Data models
├── providers/    # Riverpod state management
├── screens/      # UI screens
│   ├── auth/     # Login, register, onboarding
│   ├── barber/   # Barber dashboard & tools
│   └── client/   # Client-facing screens
└── services/     # API & external services
```

## Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Backend**: Supabase (Auth, Database, Storage)
- **Maps**: Google Maps
- **Payments**: Stripe (planned)
