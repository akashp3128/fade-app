# FADE APP - NANO BANANA PRO ROADMAP

## Vision
To create the ultimate, high-performance barber appointment platform ("Fade") with a futuristic "Nano Banana Pro" aesthetic, starting in Chicago. The platform empowers independent barbers and shops while providing clients with a smart, media-rich discovery experience.

---

## 🏗 Phase 1: The Foundation (Data & Schema)
**Goal:** Restructure the database to support independent profiles, shops, and rich media.

### Database Updates (Supabase)
- [ ] **Shops Table:** Create `shops` table for physical locations (Latitude, Longitude, Amenities).
- [ ] **Affiliation:** Update `barber_profiles` to link to a `shop_id` (optional) or be `independent`.
- [ ] **Gallery:** Create `media_posts` table for the "Instagram-style" feed (Images, Videos, Tags).
- [ ] **Client Vault:** Create `client_gallery` table for private "Past Cuts" history.

### Frontend Models (Flutter)
- [ ] Update `BarberProfile` model to include `shopId`, `isIndependent`, `instagramHandle`, `portfolioImages`.
- [ ] Create `Shop` model.
- [ ] Create `FeedPost` model.

---

## 🗺 Phase 2: The Nano Map (Discovery)
**Goal:** A visual-first discovery experience distinguishing between shops and independent barbers.

### Features
- [ ] **Hybrid Markers:**
    - 💈 **Pole Icon:** Represents a Barbershop. Clicking it opens a bottom sheet listing all barbers at that location.
    - 🟡 **Nano Dot:** Represents an independent barber (Garage/Home/Suite).
- [ ] **Smart Filtering:** Filter by "Shop" vs "Independent".
- [ ] **Chicago Launch:** Hardcode initial map region to Chicago downtown.

---

## 📱 Phase 3: The Showcase (Profiles & Feed)
**Goal:** Allow barbers to market themselves via media, not just text.

### Barber Features
- [ ] **Rich Profile:**
    - 5-Photo Minimum Portfolio Carousel.
    - Integrated Instagram Link button.
    - "Book Now" floating action.
- [ ] **The Feed:**
    - A TikTok/IG style scrollable feed of haircuts near you.
    - "Book this Look" button directly on the post.

### Client Features
- [ ] **Style Vault:** Save liked cuts (Pinterest style).
- [ ] **My Mirror:** Private gallery to upload photos of their own cuts for the next barber to see.

---

## 🧠 Phase 4: The Brain (AI & Business)
**Goal:** Smart features and monetization.

### AI Integration
- [ ] **Smart Availability:** "I need a cut on Friday evening." -> AI finds available slots across all local barbers.
- [ ] **Style Match:** (Future) Scan face shape -> Suggest cuts.

### Business Model (SaaS)
- [ ] **Shop Tier:** Manager dashboard, employee management, shop analytics.
- [ ] **Solo Tier:** Personal booking link, portfolio, payment processing.

---

## 🚀 Immediate Next Steps
1.  **Migrate DB:** Add `shops` table and update `barber_profiles`.
2.  **Update UI:** Implement the "Nano Map" logic with distinct markers.
3.  **Build Feed:** Create the media scrolling interface.
