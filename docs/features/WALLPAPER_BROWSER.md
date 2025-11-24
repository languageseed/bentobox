# Bentobox Wallpaper Browser Feature Specification

## Overview

Add a new "Wallpapers" tab to the Bentobox GUI that allows users to browse, preview, and download wallpapers from Pexels directly within the installer.

---

## Feature Requirements

### 1. New "Wallpapers" Tab in GUI

**Location:** Between "Desktop Customization" and final tab

**Layout:**
```
┌─────────────────────────────────────────────┐
│ Welcome │ Components │ ... │ Wallpapers │   │
├─────────────────────────────────────────────┤
│                                             │
│  🎨 Wallpaper Browser                       │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ Search: [nature mountains dark___] 🔍│   │
│  │ Category: [All ▼] | Curated: ☑       │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌────────┐ ┌────────┐ ┌────────┐          │
│  │ [img1] │ │ [img2] │ │ [img3] │          │
│  │        │ │        │ │        │          │
│  │  ⭐    │ │  ⭐    │ │  ⭐    │          │
│  └────────┘ └────────┘ └────────┘          │
│  by: Photo   by: Photo   by: Photo         │
│                                             │
│  [← Prev] Page 1 of 10 [Next →]            │
│                                             │
│  Selected: 3 wallpapers                     │
│  [📥 Download Selected] [🖼️ Apply Now]      │
└─────────────────────────────────────────────┘
```

### 2. Pexels API Integration

**API:** https://www.pexels.com/api/
- **Free Tier:** 200 requests/hour
- **No auth required** for basic search
- **Requires:** API key (free signup)

**Endpoints:**
```python
# Search photos
GET https://api.pexels.com/v1/search?query={query}&per_page={num}&page={page}

# Curated photos
GET https://api.pexels.com/v1/curated?per_page={num}&page={page}

# Photo by ID
GET https://api.pexels.com/v1/photos/{id}
```

### 3. Features

#### Browse Wallpapers
- ✅ Search by keyword (mountains, nature, dark, abstract, etc.)
- ✅ Curated collections
- ✅ Category filters
- ✅ Pagination

#### Preview & Select
- ✅ Thumbnail grid view
- ✅ Click to preview full-size
- ✅ Multi-select with checkboxes
- ✅ Photographer attribution

#### Download & Apply
- ✅ Download selected wallpapers to `assets/wallpapers/`
- ✅ Add to GNOME wallpaper list
- ✅ Apply immediately (optional)
- ✅ Save metadata (photographer, URL, license)

---

## Implementation Plan

### Phase 1: Basic Structure

1. **Create `install/wallpaper_browser.py`**
   - Pexels API wrapper
   - Search and curated queries
   - Download manager

2. **Update `install/gui.py`**
   - Add "Wallpapers" tab
   - Create thumbnail grid
   - Search interface

3. **Create `assets/wallpapers/` directory**
   - Move existing wallpapers
   - Add downloaded wallpapers here
   - Track metadata

### Phase 2: API Integration

```python
# install/wallpaper_browser.py

import requests
import json
from pathlib import Path
from typing import List, Dict, Optional

class PexelsWallpaperBrowser:
    """Browse and download wallpapers from Pexels"""
    
    API_BASE = "https://api.pexels.com/v1"
    
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.headers = {"Authorization": api_key}
        self.cache_dir = Path.home() / ".cache/bentobox/wallpapers"
        self.cache_dir.mkdir(parents=True, exist_ok=True)
    
    def search(self, query: str, page: int = 1, per_page: int = 15) -> Dict:
        """Search for wallpapers"""
        url = f"{self.API_BASE}/search"
        params = {
            "query": query,
            "per_page": per_page,
            "page": page,
            "orientation": "landscape"  # For wallpapers
        }
        
        response = requests.get(url, headers=self.headers, params=params)
        response.raise_for_status()
        return response.json()
    
    def get_curated(self, page: int = 1, per_page: int = 15) -> Dict:
        """Get curated wallpapers"""
        url = f"{self.API_BASE}/curated"
        params = {
            "per_page": per_page,
            "page": page
        }
        
        response = requests.get(url, headers=self.headers, params=params)
        response.raise_for_status()
        return response.json()
    
    def download_wallpaper(self, photo_url: str, photo_id: int, 
                          photographer: str, output_dir: Path) -> Path:
        """Download a wallpaper"""
        # Download the large version
        response = requests.get(photo_url, stream=True)
        response.raise_for_status()
        
        # Save to output directory
        filename = f"pexels-{photographer.lower().replace(' ', '-')}-{photo_id}.jpg"
        filepath = output_dir / filename
        
        with open(filepath, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        # Save metadata
        metadata = {
            "id": photo_id,
            "photographer": photographer,
            "source": "pexels",
            "url": f"https://www.pexels.com/photo/{photo_id}/",
            "license": "Pexels License (Free to use)"
        }
        
        metadata_file = filepath.with_suffix('.json')
        with open(metadata_file, 'w') as f:
            json.dump(metadata, f, indent=2)
        
        return filepath
    
    def download_thumbnail(self, thumb_url: str, photo_id: int) -> Path:
        """Download thumbnail for preview"""
        response = requests.get(thumb_url)
        response.raise_for_status()
        
        thumb_path = self.cache_dir / f"thumb_{photo_id}.jpg"
        with open(thumb_path, 'wb') as f:
            f.write(response.content)
        
        return thumb_path
```

### Phase 3: GUI Integration

```python
# Add to install/gui.py

def build_wallpaper_tab(self, notebook) -> Gtk.Box:
    """Build wallpaper browser tab"""
    box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
    box.set_margin_top(10)
    box.set_margin_start(10)
    box.set_margin_end(10)
    
    # Header
    header = Gtk.Label()
    header.set_markup("<b>🎨 Browse Wallpapers from Pexels</b>")
    header.set_halign(Gtk.Align.START)
    box.pack_start(header, False, False, 0)
    
    # Search bar
    search_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
    
    self.wallpaper_search_entry = Gtk.Entry()
    self.wallpaper_search_entry.set_placeholder_text("Search: nature, mountains, dark, abstract...")
    self.wallpaper_search_entry.set_width_chars(40)
    search_box.pack_start(self.wallpaper_search_entry, True, True, 0)
    
    search_btn = Gtk.Button(label="🔍 Search")
    search_btn.connect("clicked", self.on_wallpaper_search)
    search_box.pack_start(search_btn, False, False, 0)
    
    curated_btn = Gtk.Button(label="⭐ Curated")
    curated_btn.connect("clicked", self.on_wallpaper_curated)
    search_box.pack_start(curated_btn, False, False, 0)
    
    box.pack_start(search_box, False, False, 0)
    
    # Scrollable thumbnail grid
    scrolled = Gtk.ScrolledWindow()
    scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
    scrolled.set_min_content_height(400)
    
    self.wallpaper_grid = Gtk.FlowBox()
    self.wallpaper_grid.set_valign(Gtk.Align.START)
    self.wallpaper_grid.set_max_children_per_line(4)
    self.wallpaper_grid.set_selection_mode(Gtk.SelectionMode.NONE)
    self.wallpaper_grid.set_row_spacing(10)
    self.wallpaper_grid.set_column_spacing(10)
    
    scrolled.add(self.wallpaper_grid)
    box.pack_start(scrolled, True, True, 0)
    
    # Pagination
    pagination_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
    pagination_box.set_halign(Gtk.Align.CENTER)
    
    self.wallpaper_prev_btn = Gtk.Button(label="← Previous")
    self.wallpaper_prev_btn.connect("clicked", self.on_wallpaper_prev_page)
    self.wallpaper_prev_btn.set_sensitive(False)
    pagination_box.pack_start(self.wallpaper_prev_btn, False, False, 0)
    
    self.wallpaper_page_label = Gtk.Label(label="Page 1")
    pagination_box.pack_start(self.wallpaper_page_label, False, False, 0)
    
    self.wallpaper_next_btn = Gtk.Button(label="Next →")
    self.wallpaper_next_btn.connect("clicked", self.on_wallpaper_next_page)
    pagination_box.pack_start(self.wallpaper_next_btn, False, False, 0)
    
    box.pack_start(pagination_box, False, False, 0)
    
    # Selected count and actions
    action_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
    action_box.set_halign(Gtk.Align.END)
    
    self.wallpaper_selected_label = Gtk.Label(label="Selected: 0 wallpapers")
    action_box.pack_start(self.wallpaper_selected_label, False, False, 0)
    
    download_btn = Gtk.Button(label="📥 Download Selected")
    download_btn.get_style_context().add_class('suggested-action')
    download_btn.connect("clicked", self.on_wallpaper_download)
    action_box.pack_start(download_btn, False, False, 0)
    
    apply_btn = Gtk.Button(label="🖼️ Apply Wallpaper")
    apply_btn.connect("clicked", self.on_wallpaper_apply)
    action_box.pack_start(apply_btn, False, False, 0)
    
    box.pack_start(action_box, False, False, 0)
    
    # Initialize wallpaper browser
    self.init_wallpaper_browser()
    
    return box

def init_wallpaper_browser(self):
    """Initialize Pexels API"""
    # API key from env or config
    api_key = os.environ.get('PEXELS_API_KEY', '')
    
    if not api_key:
        # Show message to get API key
        dialog = Gtk.MessageDialog(
            transient_for=self.window,
            message_type=Gtk.MessageType.INFO,
            buttons=Gtk.ButtonsType.OK,
            text="Pexels API Key Required"
        )
        dialog.format_secondary_text(
            "To browse wallpapers, you need a free Pexels API key.\n\n"
            "1. Visit: https://www.pexels.com/api/\n"
            "2. Sign up for free\n"
            "3. Get your API key\n"
            "4. Set environment variable: PEXELS_API_KEY\n\n"
            "For now, showing local wallpapers only."
        )
        dialog.run()
        dialog.destroy()
        return
    
    from wallpaper_browser import PexelsWallpaperBrowser
    self.wallpaper_browser = PexelsWallpaperBrowser(api_key)
    self.wallpaper_page = 1
    self.wallpaper_query = ""
    self.wallpaper_selected = set()
    
    # Load initial curated wallpapers
    self.load_wallpapers(curated=True)

def load_wallpapers(self, query: str = "", curated: bool = False):
    """Load wallpapers from Pexels"""
    # Show loading
    self.wallpaper_grid.foreach(lambda w: self.wallpaper_grid.remove(w))
    
    loading = Gtk.Label(label="Loading wallpapers...")
    self.wallpaper_grid.add(loading)
    self.wallpaper_grid.show_all()
    
    # Load in background thread
    def worker():
        try:
            if curated:
                result = self.wallpaper_browser.get_curated(
                    page=self.wallpaper_page,
                    per_page=12
                )
            else:
                result = self.wallpaper_browser.search(
                    query=query,
                    page=self.wallpaper_page,
                    per_page=12
                )
            
            GLib.idle_add(self.display_wallpapers, result)
        except Exception as e:
            GLib.idle_add(self.on_wallpaper_error, str(e))
    
    thread = threading.Thread(target=worker)
    thread.daemon = True
    thread.start()

def display_wallpapers(self, result: Dict):
    """Display wallpaper thumbnails"""
    # Clear loading
    self.wallpaper_grid.foreach(lambda w: self.wallpaper_grid.remove(w))
    
    photos = result.get('photos', [])
    
    for photo in photos:
        # Create thumbnail box
        photo_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        
        # Download and display thumbnail
        thumb_url = photo['src']['medium']
        thumb_path = self.wallpaper_browser.download_thumbnail(
            thumb_url,
            photo['id']
        )
        
        # Image
        image = Gtk.Image()
        pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(
            str(thumb_path),
            200, 150,
            True
        )
        image.set_from_pixbuf(pixbuf)
        
        # Wrap in event box for click handling
        event_box = Gtk.EventBox()
        event_box.add(image)
        event_box.connect("button-press-event", self.on_wallpaper_preview, photo)
        photo_box.pack_start(event_box, False, False, 0)
        
        # Checkbox for selection
        checkbox = Gtk.CheckButton(label=f"by {photo['photographer']}")
        checkbox.connect("toggled", self.on_wallpaper_toggle, photo['id'])
        photo_box.pack_start(checkbox, False, False, 0)
        
        self.wallpaper_grid.add(photo_box)
    
    self.wallpaper_grid.show_all()
    
    # Update pagination
    total_results = result.get('total_results', 0)
    per_page = result.get('per_page', 12)
    total_pages = (total_results + per_page - 1) // per_page
    
    self.wallpaper_page_label.set_text(f"Page {self.wallpaper_page} of {total_pages}")
    self.wallpaper_prev_btn.set_sensitive(self.wallpaper_page > 1)
    self.wallpaper_next_btn.set_sensitive(self.wallpaper_page < total_pages)
```

---

## Configuration

### API Key Setup

**Option 1: Environment Variable**
```bash
export PEXELS_API_KEY="your-api-key-here"
```

**Option 2: Config File**
```yaml
# ~/.bentobox-config.yaml
wallpapers:
  pexels_api_key: "your-api-key-here"
  auto_download_curated: true
  default_search: "nature dark"
```

**Option 3: GUI Prompt**
- First time user clicks Wallpapers tab
- Popup with instructions to get API key
- Can paste key directly in GUI
- Saved to config for future use

---

## User Flow

1. **Open Bentobox GUI**
2. **Click "Wallpapers" tab**
3. **First time: Enter API key** (free signup)
4. **Browse curated wallpapers** (shown by default)
5. **Search for specific themes** ("dark mountains", "minimal abstract")
6. **Click thumbnails to preview** full-size
7. **Check boxes to select** multiple wallpapers
8. **Click "Download Selected"** → saves to `assets/wallpapers/`
9. **Click "Apply Wallpaper"** → sets as desktop background
10. **Wallpapers saved permanently** for future use

---

## Benefits

### For Users:
- ✅ Browse thousands of high-quality wallpapers
- ✅ No need to leave installer
- ✅ Proper attribution to photographers
- ✅ Free, legal wallpapers (Pexels License)
- ✅ Builds personal collection

### For Project:
- ✅ Differentiates from Omakub
- ✅ Modern, user-friendly feature
- ✅ Showcases Python/GTK capabilities
- ✅ Community can contribute search presets

---

## Future Enhancements

### Phase 2:
- Multiple wallpaper sources (Unsplash, custom URLs)
- Wallpaper rotation (change every hour/day)
- Color palette extraction
- Match wallpaper to theme colors

### Phase 3:
- AI-generated wallpapers (Stability AI)
- Custom wallpaper editor
- Community wallpaper sharing
- Wallpaper packs/collections

---

## Technical Requirements

### Dependencies:
```python
# Add to requirements
requests>=2.31.0
pillow>=10.0.0  # For image processing
```

### API Rate Limits:
- **Free tier:** 200 requests/hour
- **Caching:** Cache thumbnails locally
- **Efficient:** Load 12 wallpapers per page

### Storage:
```
assets/
└── wallpapers/
    ├── downloaded/                # User downloads
    │   ├── pexels-*.jpg
    │   └── pexels-*.json         # Metadata
    ├── curated/                  # Pre-bundled
    │   └── *.jpg
    └── cache/                    # Thumbnails
        └── thumb_*.jpg
```

---

## Summary

This feature adds a modern, user-friendly wallpaper browser directly into Bentobox, allowing users to:

1. Browse curated and search Pexels wallpapers
2. Preview thumbnails in grid view
3. Download and apply wallpapers
4. Build their personal wallpaper collection

**Implementation time:** ~6-8 hours
**Value:** High - unique feature that enhances UX

Would you like me to implement this feature? 🎨🚀

