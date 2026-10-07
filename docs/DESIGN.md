# Fade design system (v1 proposal)

Status: **proposal for Akash's review**, Oct 2026. Owner: Design & Brand workstream.
Scope: brand identity, design tokens (`lib/theme/`), shared components (`lib/widgets/ui/`), brand assets (`assets/brand/`).

v1 is **barbers first**. Fade is a pro tool a barber runs their business on: bookings, hours, payments, payouts, and a link they share with clients. The brand should read as *confident, warm, made for the trade*, not luxury trim or "for the modern man". Clients are anyone who gets a cut.

---

## 1. Brand at a glance

| | Decision |
|---|---|
| Name treatment | **FADE**, all caps, custom geometric wordmark. In running text write "Fade" (never "FADE app", "Fade App" or "fade_app"). |
| Logo idea | **The fading F**: the F's stem breaks into slices that get thinner toward the bottom, like a skin fade blending from skin to a #2 guard. |
| App icon | Ink F on a Fade Gold field. Flat, no gradient, no gloss. |
| Palette | Evolved black & gold: **Ink #0B0B0C**, **Fade Gold #F5B82E**, **Bone #F6F3EC**, and **Brass #7A5600** for gold-family text on light. |
| Type | **Plus Jakarta Sans** (Google Fonts, OFL) for everything, app and site. Tabular figures for money and time. |
| Modes | **Dark is the brand default, and light mode is real and supported.** Both are built from the same semantic tokens. |
| Voice | Talks like a sharp shop owner: direct, warm, a little swagger, never corporate. |

Previews in this repo: `assets/brand/previews/brand-sheet.png` and `assets/brand/previews/overview-board.png`. Full-resolution screen mockups (390×844 @2x, dark + light) and their HTML source live in the team workspace (`/workspace/fade-team/design-previews/`, `/workspace/fade-team/design/mockups/`).

---

## 2. Logo, wordmark and app icon

### Concept
The fade is the signature cut of the modern barbershop and the product's name. The mark shows it literally and simply. The top of the F is solid (the length), and the stem dissolves into three slices of shrinking height (the blend). It's one idea, and it's readable from a billboard down to a 16 px favicon.

The wordmark letters (A, D, E) are hand-built from the same 22-unit stroke on a 100-unit cap height: flat apex A, geometric D, heavy E. Everything is pure vector paths with no font dependency, so it renders identically in Flutter, browsers, Figma and print.

### Files (`assets/brand/`)
| File | Use |
|---|---|
| `svg/fade-wordmark-on-dark.svg` | Primary wordmark on dark: Bone letters with a Gold F |
| `svg/fade-wordmark-on-light.svg` | Wordmark on light: all Ink |
| `svg/fade-wordmark-mono-white.svg`, `-mono-black.svg` | Single-color reproduction (embroidery, stamps, partner logos) |
| `svg/fade-logomark-{gold,ink,white}.svg` | The fading F alone |
| `svg/fade-monogram.svg` | Ink rounded-square badge (social avatar, email header) |
| `svg/fade-lockup-on-{dark,light}.svg` | Badge + wordmark (app headers, partner pages) |
| `svg/fade-app-icon-ios.svg` | iOS icon, 1024 full-bleed square (iOS applies the mask) |
| `svg/fade-app-icon-dark.svg` | Dark/alt icon (iOS 18 dark appearance, social) |
| `svg/fade-app-icon-rounded.svg` | Rounded preview for decks/web only. **Do not** upload it to the stores. |
| `svg/fade-app-icon-android-{foreground,background,monochrome}.svg` | Android adaptive icon layers (108 dp canvas, glyph inside the 66 dp safe zone; monochrome is for Android 13 themed icons) |
| `svg/fade-favicon.svg` | Favicon (simplified to one slice for 16–32 px) |
| `png/fade-app-icon-{1024,512,192,180,48}.png` | Icon exports (RGB, no alpha; store-safe) |
| `png/fade-app-icon-android-*-432.png` | Adaptive layers at xxxhdpi |
| `png/fade-wordmark-on-{dark,light}-{320,640,1280}.png` | Wordmark rasters |
| `png/favicon-16.png`, `png/favicon-32.png`, `png/favicon.ico`, `png/apple-touch-icon-180.png` | Web |
| `generate_brand_svgs.py` | Source of truth for the geometry. Re-run it to regenerate the SVGs. |

In Flutter, use `FadeWordmark`, `FadeLogomark` and `FadeAppBadge` (`lib/widgets/ui/fade_logo.dart`). They're drawn in code from the same geometry, so no asset registration is needed.

### Rules
- **Clear space:** at least the height of the E's middle bar (0.22 × cap height) on every side. Minimum size: wordmark 16 px tall, icon 16 px.
- Colors allowed: Ink, Gold, Bone, White. On photos, use the white mono version on a dark scrim.
- Don't stretch, rotate, outline, add shadows or gradients, re-type the wordmark in a font, or recolor the slices separately.

---

## 3. Color

### Brand palette
| Token | Hex | Role |
|---|---|---|
| Ink | `#0B0B0C` | Brand black, dark-mode canvas, text on gold |
| Fade Gold | `#F5B82E` | Primary action fill, selection, focus, the F |
| Gold pressed | `#E0A31A` | Pressed state of gold fills |
| Brass | `#7A5600` | Gold-family **text/icons on light** |
| Bone | `#F6F3EC` | Light-mode canvas, on-dark wordmark |
| Graphite 900 / 800 / 700 / 600 / 500 | `#141416` `#1C1C1F` `#26262A` `#2E2E33` `#45454C` | Dark surfaces and borders |
| Sand 100 / 200 / 300 | `#EFEBE2` `#E3DED3` `#CFC8BA` | Light surfaces and borders |

**Why evolve from #D4AF37?** The old metallic gold reads as "luxury trim", it looks muddy at small sizes, and it's associated with the gentleman's-club aesthetic we're moving away from. Fade Gold is warmer and cleaner. It's still clearly black and gold, so existing users will recognize it.

### Semantic tokens (`FadeColors` ThemeExtension)
| Token | Dark | Light | Use |
|---|---|---|---|
| `background` | `#0B0B0C` | `#F6F3EC` | Scaffold |
| `surface` | `#141416` | `#FFFFFF` | Cards, sheets |
| `surfaceRaised` | `#1C1C1F` | `#FFFFFF` (+shadow) | Nested/raised cards |
| `surfaceHigh` | `#26262A` | `#EFEBE2` | Tiles, pressed rows, tracks |
| `inputFill` | `#1C1C1F` | `#FFFFFF` | Text fields |
| `border` / `borderStrong` | `#2E2E33` / `#45454C` | `#E3DED3` / `#CFC8BA` | Hairlines / inputs, outlined buttons |
| `textPrimary` | `#F4F2ED` | `#141416` | Headlines, body |
| `textSecondary` | `#A9A7A1` | `#5B5953` | Supporting copy |
| `textTertiary` | `#85837E` | `#6F6C65` | Captions, placeholders |
| `accent` / `onAccent` | `#F5B82E` / `#0B0B0C` | same | Primary fills / content on them |
| `accentSoft` | `#2A2210` | `#FBEFD0` | Selected chip/row, highlight card |
| `accentText` | `#F5B82E` | `#7A5600` | Links, ghost buttons, "See all" |
| `success` | `#3DD68C` | `#1A7F4B` | Paid, confirmed, connected |
| `warning` | `#FF9F43` | `#A64B00` | Pending, in transit, action needed |
| `danger` / `onDanger` | `#FF6B6B` / Ink | `#C8281E` / White | Errors, cancel, delete |
| `info` | `#6CB4FF` | `#1E63C4` | New client, tips |
| `*Soft` variants | tinted | tinted | Tag/badge backgrounds |

### Contrast (WCAG 2.1, measured)
| Pair | Ratio | Result |
|---|---|---|
| textPrimary on background, dark / light | 17.6 : 1 / 16.6 : 1 | AAA |
| textSecondary on background, dark / light | 8.2 : 1 / 6.3 : 1 | AAA / AA |
| textTertiary on background, dark / light | 5.2 : 1 / 4.7 : 1 | AA |
| Ink on Fade Gold (primary button) | 11.0 : 1 | AAA |
| Fade Gold on Ink (accent text, dark) | 11.0 : 1 | AAA |
| Brass on white / Bone (accent text, light) | 6.7 : 1 / 6.0 : 1 | AA |
| **Fade Gold on white** | **1.8 : 1** | **Fail: never use gold as text on light. Use `accentText`.** |
| Danger button: Ink on #FF6B6B / White on #C8281E | 7.1 : 1 / 5.6 : 1 | AA |
| Success text, dark / light | 10.5 : 1 / 5.0 : 1 | AA |

Rules: **one gold-filled element per screen** (the primary action, or "now" in the calendar). Never rely on color alone for status: tags always carry a word.

---

## 4. Typography

**One family: Plus Jakarta Sans** (Google Fonts, SIL OFL, weights 200–800, true tabular figures). It's modern and warm, it's legible on phones, it has enough character for headlines at 800, and it isn't the default Inter look. It replaces the current Poppins + Playfair Display (app) and Inter + Playfair (site).

- Flutter: `google_fonts` (already a dependency) via `FadeType` in `lib/theme/fade_typography.dart`.
- Web: `https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap`

| Style | Size / line | Weight | Tracking | Use |
|---|---|---|---|---|
| `display` | 40 / 44 | 800 | -0.8 | Onboarding hero, big moments |
| `h1` | 32 / 38 | 800 | -0.5 | Screen titles |
| `h2` | 24 / 30 | 700 | -0.3 | Section/sheet titles |
| `h3` | 20 / 26 | 700 | -0.2 | Card titles |
| `title` | 17 / 24 | 600 | 0 | Row titles, app bar |
| `body` | 16 / 24 | 400 | 0 | Default copy |
| `bodySm` | 14 / 20 | 400 | 0 | Supporting copy |
| `label` / `labelSm` | 15 / 20, 13 / 18 | 600 | 0 | Buttons, field labels |
| `caption` | 12 / 16 | 500 | 0.1 | Metadata |
| `overline` | 11 / 16 | 700 | 0.9, UPPERCASE | Group labels |
| `moneyLg` | 36 / 40 | 800, tabular | -0.6 | Earnings hero |
| `numeric` | 15 / 20 | 600, tabular | 0 | Prices, times in rows |

Rules: sentence case everywhere except `overline`. **Always use tabular figures for prices, times and totals.** Support Dynamic Type: don't clamp text scale, and test at 1.3×.

On the landing site, use the same scale and stretch the display size to `clamp(40px, 7vw, 76px)` with weight 800 and tracking -0.02em.

---

## 5. Space, radius, elevation

- **Spacing (4-pt grid):** `FadeSpace.s2 s4 s8 s12 s16 s20 s24 s32 s40 s48 s64`. Page gutter is `FadeSpace.gutter` = 20, and the minimum touch target is 44.
- **Radius:** `sm 8` tags · `md 12` buttons, inputs · `lg 16` cards · `xl 24` sheets, dialogs · `full` pills, avatars.
- **Elevation:** dark mode separates layers with **surface color plus a 1 px border** (shadows disappear on near-black). Light mode uses soft shadows sparingly: `FadeShadows.e1` for raised cards, `e2` for menus and sheets, `e3` for dialogs. `accentGlow` is reserved for a single hero element.

## 6. Iconography

- **Material Symbols Rounded**, outlined at 400 weight. Use filled only for the selected nav tab and status glyphs. This matches Flutter's `Icons.*_rounded` and `*_outlined`.
- Sizes are 20 inside rows and buttons, 24 in nav and app bars, and 28–32 in empty states (inside a 64 px tinted tile).
- Icon-only buttons always get a tooltip, which is also the screen-reader label (`FadeIconButton` requires one).
- No emoji in UI chrome. No clip-art scissors or barber poles. The brand carries the barber cue, so the UI doesn't need to.

## 7. Motion

- Durations: `FadeMotion.fast` 120 ms (press, toggles), `base` 200 ms (most transitions), `slow` 320 ms (sheets, success moments).
- Curves: `standard` = easeOutCubic for entering, `exit` = easeInCubic, `emphasized` for sheets and "Booking confirmed".
- Motion explains change; it never decorates. Don't animate lists on every load, and don't make anything bounce.
- Respect reduced motion (`context.reduceMotion`). Library widgets already do (skeleton pulse stops, chips don't animate).
- Haptics: light impact on primary confirmations (booking saved, payout connected) and selection clicks on chips and time slots.

## 8. Light and dark

**Decision: ship both. Dark is the brand default for marketing, onboarding and the icon. In the app, follow the system setting.**
Why: barbers use Fade standing at the chair in bright shops, often in daylight, glancing at a calendar between cuts, and light mode is easier to read there. Meanwhile dark mode is the brand's signature and is better at night and on OLED. Because every color is a semantic token, supporting both costs almost nothing per screen.

Rollout (Fade App workstream):
1. Point `lib/config/theme.dart` at the compat layer (see §11). The app keeps running in dark mode with the new brand.
2. As screens migrate from `AppColors.*` constants to `context.fadeColors` and `lib/widgets/ui`, switch `MaterialApp` to `theme: FadeTheme.light(), darkTheme: FadeTheme.dark(), themeMode: ThemeMode.system`.
3. Until every screen is migrated, keep `themeMode: ThemeMode.dark`. Legacy screens hard-code dark colors and would look broken in light mode.

## 9. Voice and tone

We talk like a sharp, friendly shop owner who respects the craft. We're **direct** (lead with the verb), **warm** (a little swagger, never cheesy) and **concrete** (times, money, next steps). We say "you" and "your chair" and "your clients". We don't say "users", "leverage", "seamless", "elite", "gentleman" or "for the modern man". Copy is inclusive by default: clients are everyone.

| Context | ✅ Write | ❌ Not |
|---|---|---|
| Headline | **Your chair. Your book. Your money.** | Experience Barbering, Redefined. |
| Headline | **Fill your chair. Skip the DMs.** | The future of grooming is on your phone. |
| Sub-head | Bookings, payments and payouts in one app. Share your link, fill your chair, get paid. | Discover elite barbers seamlessly. |
| Primary button | Get started · Save hours · Continue with Stripe · Copy booking link | Submit · OK · Proceed |
| Destructive | Cancel appointment · Delete service | Are you sure? Yes/No |
| Empty: bookings | **No bookings yet.** Share your booking link and clients can grab a time in seconds. [Copy booking link] | No data. |
| Empty: services | **Add your first service.** Price it, time it, and you're bookable. | You have 0 services. |
| Empty: payouts | **Get paid to your bank.** Connect payouts so clients can pay by card when they book. | Stripe not configured. |
| Error: network | **Couldn't load your calendar.** Check your connection and try again. Your bookings are safe. | Error: SocketException… |
| Error: form | That email doesn't look right. Check for typos. | Invalid input. |
| Error: payment | **Card declined.** Ask your client to try another card. Nothing was charged. | Payment failed (code 402). |
| Success | Booked. Marcus is set for Fri 2:15 PM. | Success! |
| Notification | New booking: Andre, Skin fade, Thu 11:15 AM. | You have a new notification. |

Mechanics: sentence case, US English, 12-hour time ("2:15 PM"), short weekday dates ("Fri, Oct 9"), whole-dollar prices in lists ("$40") and cents for money moved ("$270.00"). No exclamation marks except "You're live!" moments. Never show raw error text, and say what is safe ("nothing was charged").

## 10. Component library (`lib/widgets/ui/`)

Import one file:
```dart
import 'package:fade_app/widgets/ui/ui.dart'; // also re-exports lib/theme/theme.dart
```

| Widget | Notes |
|---|---|
| `FadeButton.primary / .secondary / .ghost / .destructive` | `loading:` shows a spinner and keeps the width, `expand:` is full width, `icon` / `trailingIcon`, sizes `small` 36 / `medium` 44 / `large` 52. Use **one primary per screen**. |
| `FadeIconButton` | 44 pt target, required `tooltip`, optional `filled`. |
| `FadeTextField` | Label above the field, `hint`, `helper`, `errorText`, `optional: true`, `prefixText: '\$ '`, `obscureText` with an automatic show/hide toggle. Works inside `Form` (`validator`). |
| `FadeSearchField` | Pill search with a clear button. |
| `FadeCard` | `tone:` `outlined` (default) / `raised` / `accent` (the one thing that needs attention), optional `onTap`. |
| `FadeListRow` | `leading` or `leadingIcon`, `title`, `subtitle`, `value` (tabular), `trailing`, chevron automatically when tappable, `destructive`, `divider`. |
| `FadeSectionHeader` | Title plus optional action ("See all"), `overline: true` for grouped settings. |
| `FadeTag` | Status pill: `FadeTone.neutral/accent/success/warning/danger/info`, `dot` or `icon`. |
| `FadeChip` | Selectable pill (days, categories, time slots). |
| `FadeAvatar` | Photo with initials fallback, sizes xs–xl, `ring`, `statusColor`. |
| `FadeEmptyState` / `FadeErrorState` / `FadeLoadingState` | Full-screen or `compact` (inside a card). |
| `FadeSkeleton`, `FadeSkeletonRow`, `FadeSkeletonList` | Use these for initial loads of known shapes. They respect reduced motion. |
| `showFadeSheet()` / `FadeSheetBody` | Bottom sheet with drag handle, title, keyboard-safe padding and sticky actions. |
| `FadeWordmark`, `FadeLogomark`, `FadeAppBadge` | Vector brand marks drawn in code. |
| `ui_gallery.dart` → `FadeUiGallery` | Catalogue of everything with a light/dark toggle. It isn't routed; push it from a debug menu. |

Example:
```dart
final c = context.fadeColors;
FadeCard(
  padding: EdgeInsets.zero,
  child: Column(children: [
    FadeListRow(leadingIcon: Icons.content_cut_rounded, title: 'Skin fade', subtitle: '45 min', value: '\$40', onTap: edit, divider: true),
    FadeListRow(leadingIcon: Icons.add_rounded, title: 'Add a service', onTap: add),
  ]),
);
FadeButton.primary(label: 'Save hours', loading: saving, expand: true, onPressed: save);
Text('This week', style: FadeType.overline.copyWith(color: c.textTertiary));
```

Rules for screen authors:
- No hex values and no `Colors.*` in screens. Use `context.fadeColors.*` (or `Theme.of(context).colorScheme`).
- No `GoogleFonts.*` in screens. Use `FadeType.*` or `Theme.of(context).textTheme`.
- No magic numbers for spacing or radius. Use `FadeSpace` and `FadeRadius`.
- If a pattern appears on two screens, it belongs in `lib/widgets/ui`. Open an issue or PR for the Design workstream.

## 11. Migration from the old theme

The old API (`AppColors`, `AppTheme`, `AppSpacing`, `AppRadius` in `lib/config/theme.dart`) keeps working:

- `lib/theme/legacy.dart` re-implements those names on top of the new tokens. Once `lib/config/theme.dart` contains just `export 'package:fade_app/theme/legacy.dart';`, every screen picks up the new brand with **no other code changes**. This was verified: `flutter analyze` shows 0 errors with the swap applied.
- Spacing values are unchanged. Radii get slightly softer (`AppRadius.sm` 4→8, `md` 8→12, `lg` 12→16, `xl` 16→24). Text switches to Plus Jakarta Sans.
- The legacy layer is dark only (see §8).

| Old | New |
|---|---|
| `AppColors.accent` | `context.fadeColors.accent` (fills) / `.accentText` (text) |
| `AppColors.background` / `.surface` | `.background` / `.surface` |
| `AppColors.textPrimary` / `.textSecondary` / `.textLight` | `.textPrimary` / `.textSecondary` / `.textTertiary` |
| `AppColors.border` / `.divider` | `.border` |
| `AppColors.error` / `.success` | `.danger` / `.success` |
| `AppSpacing.md` (16) | `FadeSpace.s16` |
| `AppRadius.md` | `FadeRadius.md` |
| `GoogleFonts.poppins(...)` / `playfairDisplay(...)` | `FadeType.body` / `FadeType.h1` … |
| `ElevatedButton` + custom styling | `FadeButton.primary` |

## 12. Open items

- **Font bundling:** `google_fonts` fetches the font at runtime on first launch. For offline-first and release builds, bundle the Plus Jakarta Sans TTFs and set `GoogleFonts.config.allowRuntimeFetching = false`. That needs a `pubspec.yaml` `assets:` entry (QA & Release owns pubspec).
- **App icon wiring:** iOS `AppIcon.appiconset` and Android `mipmap-*` / adaptive XML need generating from `assets/brand/png` (QA & Release owns `ios/` and `android/`). `flutter_launcher_icons` would be the easy route, but it's a new dev dependency.
- **Booking link domain:** mockups use `fade.app/<name>` as a **placeholder**. The real domain is Akash's decision.
- **Trademark:** "Fade" is a common word, so do a trademark and app-store name search before the brand is final. That's for Akash or counsel.
