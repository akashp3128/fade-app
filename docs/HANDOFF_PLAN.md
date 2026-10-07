# Fade: Build Plan & Handoff (for ChatGPT / any coding agent)

Owner: Akash (GitHub `akashp3128`). Written Oct 7, 2026.
Repos:
- App: https://github.com/akashp3128/fade-app (Flutter/Dart, Supabase, Riverpod, GoRouter, flutter_stripe, Google Maps)
- Site: https://github.com/akashp3128/fade-landing (Astro 5 + Tailwind v4, live at https://akashp3128.github.io/fade-landing/)

## 1. What Fade is
A two-sided barber-booking marketplace launching in Chicago. **v1 is barbers-first**: give independent barbers a great booking + payments tool (profile, services and prices, hours, availability, bookings, Stripe Connect payouts, a shareable booking link). Client discovery (map, search, reviews) opens after barbers are on board.

**Out of scope for v1 (do not build yet):** Academy/courses, premium content subscriptions, TikTok-style feed, AI booking or style matching, shop/team management.

## 2. Working rules
1. Never push to `main`. One focused branch per change, open a PR with a clear summary and test notes. Akash merges.
2. Never commit secrets. Use `--dart-define`, `.env` files that are gitignored, or Supabase/GitHub secrets, and list required vars in the PR.
3. Don't invent testimonials, stats, pricing, or company/legal claims. Use clearly marked placeholders.
4. No cloud accounts exist yet (no Supabase project, Stripe, Apple Developer, Play Console, or domain). Build and test locally (Supabase CLI local stack, Stripe test mode).
5. Run `flutter analyze` and `flutter test` before every PR.

## 3. Current state
### Landing site: DONE (v1)
PR #1 merged, deployed via GitHub Actions to Pages. Barbers-first home, For Clients, placeholder pricing, barber waitlist, DRAFT privacy/terms, 404, SEO/OG, sitemap. Remaining:
- Waitlist is off (`PUBLIC_WAITLIST_MODE=none`). To enable: create Supabase project, run `supabase/waitlist.sql`, set repo Variables `PUBLIC_WAITLIST_MODE=supabase`, `PUBLIC_SUPABASE_URL`, `PUBLIC_SUPABASE_PUBLISHABLE_KEY` (or use Formspree with `PUBLIC_WAITLIST_ENDPOINT`).
- Analytics hook (Plausible/Umami) off until an env var is set.
- Swap placeholder brand tokens at top of `src/styles/global.css` for the final brand (see Design).
- Real pricing, legal review of Privacy/Terms, custom domain later.

### App (fade-app): PROTOTYPE, most logic is fake
Audit findings (fix all of these):
- `lib/providers/auth_provider.dart` is in "SIMULATION MODE": every login becomes a hardcoded barber `akash@fade.app`.
- Appointments are an in-memory list; client id is the literal `'current_user'`. Reviews are a no-op. DB function `book_appointment` exists but is never called.
- Providers silently fall back to mock barbers/shops on error or empty results. Remove all of this.
- Stripe Connect screen is mocked (`acct_test_simulated_123`). Courses and feed are mocked (deferred anyway).
- Profile save, photo change, hours edit, earnings chart are TODOs.
- **Sign-up bug:** DB triggers already create `profiles` and `barber_profiles`; the app inserts them again, which causes duplicate-key errors.
- Google OAuth redirect `com.fadeapp.fade://login-callback` is not registered on iOS/Android; bundle ids mismatch (`com.fadeapp.fade_app` vs `com.fadeapp.fadeApp`).
- iOS `Info.plist` lacks location/camera/photo usage strings. Android manifest has `YOUR_GOOGLE_MAPS_API_KEY` placeholder. Release builds use the debug key. App display names are `fade_app` / "Fade App".
- SQL is 5 loose scripts, no migrations. `upgrade_mock_data()` uses invalid `UPDATE ... LIMIT`.
- Route `/barber/profile` is defined twice.
- **Security:** RLS is OFF on `shops`, `media_posts`, `client_vault`, `saved_styles`, `courses`, `course_lessons`, `user_course_progress`, `purchased_courses`. `profiles` (email, phone) is publicly readable. Google Places key ships in the client. Storage buckets are public. (No secrets leaked in git history.)
- No CI; only a placeholder test.

### Work in progress at handoff
Five assistant "bots" started on the lanes below on Oct 7. Before starting a lane, check for open PRs and branches (`gh pr list -R akashp3128/fade-app`, `git branch -r`) and build on them rather than duplicating. Design previews (brand sheet, component gallery, screens) were being produced; if a Design PR exists, adopt it.

## 4. Workstreams and file ownership
Keep to these boundaries to avoid merge conflicts.

### A. Backend and security (`supabase/**`, `docs/BACKEND_API.md`) - P0, do first
1. Convert SQL into ordered migrations in `supabase/migrations/` (Supabase CLI layout); seed data in `supabase/seed.sql`; fix/remove `upgrade_mock_data`.
2. Enable RLS with policies on every table. Expose only safe public profile fields (view or separate table); email/phone private. Make `client_vault` and private buckets private.
3. Make DB triggers the single source of `profiles`/`barber_profiles` creation.
4. Booking core: working hours + time-off tables, `get_available_slots(barber_id, date, service_id)` RPC, `book_appointment` with a no-double-booking exclusion constraint, cancel and reschedule RPCs, reviews only for completed appointments.
5. Edge functions: Google Places proxy (key server-side), Stripe Connect Express onboarding link, PaymentIntent creation with platform fee, Stripe webhook handler.
6. Document every RPC/function in `docs/BACKEND_API.md`.

### B. App core (`lib/**` except `lib/theme/**`, `lib/widgets/ui/**`) - P0
1. Real Supabase auth (email, Google, Apple), password reset, role-based routing (barber vs client).
2. Stop inserting profile rows on sign-up.
3. Remove every mock fallback; real loading/empty/error states.
4. Barber onboarding: profile, photo upload, services and prices, weekly hours.
5. Bookings via the RPCs: barber calendar, accept/cancel/reschedule, shareable booking link (deep link).
6. Stripe Connect onboarding hand-off and real earnings view.
7. Fix duplicate `/barber/profile` route; in-app account deletion (Apple requirement).

### C. Design and brand (`lib/theme/**`, `lib/widgets/ui/**`, `assets/brand/**`, `docs/DESIGN.md`) - P1
1. Brand identity: logo/wordmark, app icon, palette (black and gold evolved), single type system shared by app and site (currently Poppins vs Inter), barber-pro voice.
2. Design tokens and a component library (buttons, inputs, cards, list rows, empty/error/loading states, light mode or deliberate dark-only).
3. Polished barber flows: onboarding, services/hours, booking calendar, payouts.
4. Share tokens with the landing site.

### D. Landing and growth (fade-landing repo) - P1
See section 3. Next: adopt brand tokens, connect waitlist, analytics, real pricing, "For Barbers" content as features ship, custom domain.

### E. QA, CI and release (`.github/**`, `android/**`, `ios/**`, `test/**`, `integration_test/**`) - P1
1. GitHub Actions: `flutter analyze`, `flutter test`, Android + web builds on PRs.
2. Unify identity: display name "Fade", bundle/app id `com.fadeapp.fade` on both platforms, register `com.fadeapp.fade://login-callback`, iOS usage strings, Maps key via build config, release signing from env.
3. Real tests: auth, booking, availability (unit + integration).
4. Crash reporting (Sentry or Crashlytics) and analytics (PostHog/Firebase).
5. `docs/RELEASE.md` launch checklist: Fastlane/Codemagic to TestFlight and Play internal testing, store listing, privacy labels, review test account.

## 5. Suggested order
1. A1-A3 (migrations, RLS, trigger fix) and E1-E2 (CI, app identity) in parallel.
2. B1-B3 (real auth, no mocks) once A3 lands.
3. A4 then B4-B5 (booking core end to end).
4. C1-C2 in parallel throughout; apply to app and site.
5. A5 + B6 (Stripe Connect payouts).
6. E3-E5, then TestFlight/Play internal beta with a few Chicago barbers.

## 6. What Akash needs to set up before launch
Supabase project (staging + production), Stripe account (Connect enabled), Apple Developer Program, Google Play Console, Google Maps/Places API keys, a domain, legal review of Privacy/Terms/barber agreement, a business entity before using "Inc." anywhere, and final pricing.

## 7. Definition of done for v1
A barber can sign up, set up profile, services, hours and payouts, share a booking link, and receive real paid bookings that persist, with cancel/reschedule. Clients can book and pay through that link. All tables have RLS, CI is green, the app is on TestFlight and Play internal testing, and the landing waitlist collects real sign-ups.
