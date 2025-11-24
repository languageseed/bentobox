# Wallpaper Browser - Implementation Plan

## Overview

Implement a multi-provider wallpaper browser in the Bentobox GUI with support for **Pexels**, **Unsplash**, and **4K Wallpapers**.

---

## Phase 1: Foundation (Core Architecture)

### 1.1 Provider Abstraction Layer
- [ ] Create `install/wallpaper_providers.py`
- [ ] Implement `WallpaperProvider` base class
- [ ] Implement `PexelsProvider`
- [ ] Implement `UnsplashProvider`
- [ ] Implement `FourKWallpapersProvider` (web scraping)
- [ ] Implement `LocalProvider`
- [ ] Add provider factory function

**Files:**
- `install/wallpaper_providers.py` (new)

**Dependencies:**
```bash
pip3 install --user requests beautifulsoup4 pillow
```

---

## Phase 2: Configuration & State Management

### 2.1 Configuration
- [ ] Add wallpaper config section to `bentobox-config.yaml`
- [ ] Create API key setup wizard in GUI
- [ ] Add config validation (check API keys)
- [ ] Store provider preferences

### 2.2 State Management
- [ ] Create wallpaper cache directory (`~/.cache/bentobox/wallpapers/`)
- [ ] Implement thumbnail caching
- [ ] Track downloaded wallpapers (metadata JSON)
- [ ] Implement cache cleanup (size limits)

**Files:**
- `bentobox-config.yaml` (update)
- `~/.cache/bentobox/wallpapers/` (new directory)
- `~/.cache/bentobox/wallpapers/metadata.json` (new)

---

## Phase 3: GUI Integration

### 3.1 New "Wallpapers" Tab
- [ ] Create wallpaper tab in `install/gui.py`
- [ ] Add provider selector dropdown
- [ ] Add search bar with autocomplete
- [ ] Add category filter (for 4K Wallpapers)
- [ ] Create scrollable grid layout for thumbnails
- [ ] Add pagination controls
- [ ] Add loading spinner/progress indicator

### 3.2 Wallpaper Card Component
- [ ] Display thumbnail image
- [ ] Show title and photographer
- [ ] Add hover effects (preview, download, apply)
- [ ] Show resolution badge (4K, 5K, 8K)
- [ ] Display provider icon

### 3.3 Detail View/Preview
- [ ] Full-size preview modal
- [ ] Download button
- [ ] Apply as wallpaper button
- [ ] Show metadata (photographer, license, resolution)
- [ ] Attribution link (photographer profile)

### 3.4 Actions
- [ ] Download wallpaper to `~/Pictures/Wallpapers/`
- [ ] Apply wallpaper via `gsettings`
- [ ] Add to favorites (local tracking)
- [ ] Share link (copy to clipboard)

**Files:**
- `install/gui.py` (update)
- `install/gui_wallpaper_tab.py` (new, optional refactor)

---

## Phase 4: Provider-Specific Features

### 4.1 Pexels Integration
- [ ] Implement curated collections
- [ ] Add trending wallpapers
- [ ] Implement search with filters (orientation, color)
- [ ] Rate limit handling (200/hr)
- [ ] Attribution compliance

**References:**
- API Docs: https://www.pexels.com/api/documentation/
- Search: https://www.pexels.com/search/4k%20wallpaper/

### 4.2 Unsplash Integration
- [ ] Implement editorial/popular photos
- [ ] Add collections support
- [ ] Implement search with filters
- [ ] Download tracking (trigger download endpoint)
- [ ] Rate limit handling (50/hr)
- [ ] Attribution compliance (Unsplash license)

**References:**
- API Docs: https://unsplash.com/documentation
- Search: https://unsplash.com/s/photos/wallpaper-4k

### 4.3 4K Wallpapers Integration
- [ ] Implement category browsing (30+ categories)
- [ ] Add recent/trending/popular filters
- [ ] Implement search via their search page
- [ ] Respect robots.txt
- [ ] Implement rate limiting (delays between requests)
- [ ] Add error handling for scraping failures
- [ ] Cache category pages (24hr)

**Categories to implement:**
- Abstract, Animals, Anime, Architecture, Cars
- Games, Nature, Space, Sports, Technology
- Black/Dark, Minimal, Sci-Fi
- More: https://4kwallpapers.com/ (sidebar)

**References:**
- Website: https://4kwallpapers.com/
- Categories: https://4kwallpapers.com/nature/, https://4kwallpapers.com/space/, etc.

---

## Phase 5: User Experience Enhancements

### 5.1 Performance
- [ ] Lazy loading for thumbnails
- [ ] Progressive image loading
- [ ] Background download queue
- [ ] Thumbnail pre-caching for next page

### 5.2 Search & Discovery
- [ ] Recent searches history
- [ ] Popular search suggestions
- [ ] Category quick filters
- [ ] Color filter (if supported by provider)
- [ ] Resolution filter (4K, 5K, 8K+)

### 5.3 Personal Library
- [ ] View downloaded wallpapers
- [ ] Favorites/bookmarks
- [ ] Delete wallpapers
- [ ] Auto-wallpaper rotation (slideshow)
- [ ] Wallpaper schedule (time-based)

---

## Phase 6: Testing & Polish

### 6.1 Testing
- [ ] Test API key validation
- [ ] Test rate limit handling
- [ ] Test web scraping robustness (4K Wallpapers)
- [ ] Test offline mode (cached wallpapers)
- [ ] Test large grid performance (100+ items)
- [ ] Test on fresh Ubuntu 24.04 install

### 6.2 Error Handling
- [ ] Invalid API key message
- [ ] Network error retry logic
- [ ] Rate limit exceeded message
- [ ] Scraping failure fallback
- [ ] Download failure handling

### 6.3 Documentation
- [ ] Update README with wallpaper feature
- [ ] Add API key setup instructions
- [ ] Document provider attribution requirements
- [ ] Add troubleshooting guide

---

## Implementation Order

### Sprint 1: Core (1-2 days)
1. Create provider abstraction layer
2. Implement Pexels provider (simplest, has good API)
3. Add basic wallpaper tab to GUI
4. Test search + display grid

### Sprint 2: Multi-Provider (1 day)
1. Implement Unsplash provider
2. Add provider selector to GUI
3. Test switching between providers

### Sprint 3: 4K Wallpapers (1-2 days)
1. Implement web scraping for 4K Wallpapers
2. Add category browsing
3. Test robustness and error handling

### Sprint 4: Features (1 day)
1. Add download functionality
2. Implement "Apply as wallpaper"
3. Add thumbnail caching
4. Add favorites tracking

### Sprint 5: Polish (1 day)
1. Improve UI/UX (loading states, errors)
2. Add configuration wizard for API keys
3. Test on leaf
4. Documentation

---

## Files to Create

```
install/
├── wallpaper_providers.py          # Provider abstraction layer
├── gui_wallpaper_tab.py            # Wallpaper tab component (optional refactor)
└── apply-wallpaper.sh              # Helper script for gsettings

docs/features/
├── WALLPAPER_BROWSER.md            # Feature spec (existing)
├── WALLPAPER_MULTI_PROVIDER.md     # Architecture (existing)
└── WALLPAPER_IMPLEMENTATION_PLAN.md # This file

~/.cache/bentobox/wallpapers/
├── thumbnails/                      # Cached thumbnails
├── downloads/                       # Downloaded wallpapers
└── metadata.json                    # Tracking data
```

---

## API Key Setup (For Users)

### Pexels
1. Visit https://www.pexels.com/api/
2. Click "Get Started"
3. Sign up (free)
4. Copy API key
5. Paste into Bentobox GUI → Configure APIs

### Unsplash
1. Visit https://unsplash.com/developers
2. Click "Register as a developer"
3. Create a new app
4. Copy "Access Key"
5. Paste into Bentobox GUI → Configure APIs

### 4K Wallpapers
- No API key needed ✅

---

## Success Metrics

- ✅ Users can browse 1000+ wallpapers from 3 sources
- ✅ Search works across all providers
- ✅ Download + apply works seamlessly
- ✅ GUI responds in <2 seconds for searches
- ✅ Thumbnails load progressively
- ✅ Works offline with cached wallpapers
- ✅ Proper attribution for all providers

---

## Future Enhancements (Post-MVP)

- [ ] Add Pixabay provider
- [ ] Add Wallhaven provider
- [ ] AI-generated wallpapers (Stable Diffusion)
- [ ] Wallpaper slideshow/rotation
- [ ] Multi-monitor support (different wallpaper per monitor)
- [ ] Wallpaper effects (blur, darken, tint)
- [ ] Community wallpaper sharing
- [ ] Bentobox wallpaper gallery submission

---

## Ready to Implement?

The architecture is designed, providers are specified, and the plan is clear.

**Next step:** Begin Sprint 1 - Core implementation

Would you like me to start building? 🚀

