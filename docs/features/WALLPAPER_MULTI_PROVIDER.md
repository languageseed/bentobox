# Multi-Provider Wallpaper Browser - Architecture Design

## Overview

Create a **unified wallpaper browser** that supports multiple providers (Pexels, Unsplash, Pixabay, etc.) with a clean abstraction layer and provider-agnostic UI.

---

## Supported Providers

### Phase 1 - Initial Launch (3 providers)

### 1. **Pexels** - https://www.pexels.com/api/
- **Free tier:** 200 requests/hour
- **API Key:** Free, easy signup at https://www.pexels.com/api/
- **Quality:** High-quality curated 4K photos
- **License:** Free to use, no attribution required
- **Specialty:** Professional photography, curated collections
- **Search:** https://www.pexels.com/search/4k%20wallpaper/

### 2. **Unsplash** - https://unsplash.com/developers
- **Free tier:** 50 requests/hour
- **API Key:** Free signup at https://unsplash.com/developers
- **Quality:** Professional, artistic photography
- **License:** Unsplash License (free for commercial/personal)
- **Specialty:** Artistic, high-resolution wallpapers
- **Search:** https://unsplash.com/s/photos/wallpaper-4k

### 3. **4K Wallpapers** - https://4kwallpapers.com/
- **Free tier:** No API (web scraping fallback)
- **API Key:** Not required (or check if they have RSS/API)
- **Quality:** Curated 4K/5K/8K wallpapers
- **License:** Free for personal use (verify per image)
- **Specialty:** High-res desktop wallpapers, gaming, anime, cars
- **Categories:** Abstract, Animals, Anime, Cars, Space, Technology, etc.

### 4. **Local/Custom**
- **Source:** User's own collection
- **Location:** `assets/wallpapers/custom/`
- **License:** User's own
- **Specialty:** Personal photos

---

### Phase 2 - Future Expansion (Optional)

### 5. **Pixabay** - https://pixabay.com/api/docs/
- **Free tier:** 5,000 requests/hour
- **Specialty:** Illustrations, vectors, photos

### 6. **Wallhaven** - https://wallhaven.cc/help/api
- **Free tier:** Unlimited (no key needed)
- **Specialty:** Desktop-optimized, gaming art

---

## Architecture

### Provider Abstraction Layer

```python
# install/wallpaper_providers.py

from abc import ABC, abstractmethod
from typing import List, Dict, Optional
from pathlib import Path
import requests

class WallpaperProvider(ABC):
    """Abstract base class for wallpaper providers"""
    
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key
        self.name = "Unknown"
        self.requires_api_key = True
        self.rate_limit = 100  # requests per hour
    
    @abstractmethod
    def search(self, query: str, page: int = 1, per_page: int = 15) -> Dict:
        """Search for wallpapers
        
        Returns:
        {
            'photos': [
                {
                    'id': str,
                    'title': str,
                    'photographer': str,
                    'photographer_url': str,
                    'thumbnail_url': str,
                    'full_url': str,
                    'download_url': str,
                    'width': int,
                    'height': int,
                    'provider': str,
                    'license': str,
                    'license_url': str
                },
                ...
            ],
            'total_results': int,
            'per_page': int,
            'page': int
        }
        """
        pass
    
    @abstractmethod
    def get_curated(self, page: int = 1, per_page: int = 15) -> Dict:
        """Get curated wallpapers"""
        pass
    
    @abstractmethod
    def download(self, photo: Dict, output_dir: Path) -> Path:
        """Download a wallpaper"""
        pass
    
    def validate_api_key(self) -> bool:
        """Check if API key is valid"""
        try:
            result = self.get_curated(per_page=1)
            return 'photos' in result
        except:
            return False


class PexelsProvider(WallpaperProvider):
    """Pexels wallpaper provider"""
    
    def __init__(self, api_key: str):
        super().__init__(api_key)
        self.name = "Pexels"
        self.base_url = "https://api.pexels.com/v1"
        self.headers = {"Authorization": api_key}
        self.requires_api_key = True
        self.rate_limit = 200
    
    def search(self, query: str, page: int = 1, per_page: int = 15) -> Dict:
        url = f"{self.base_url}/search"
        params = {
            "query": query,
            "per_page": per_page,
            "page": page,
            "orientation": "landscape"
        }
        
        response = requests.get(url, headers=self.headers, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        # Normalize to standard format
        return self._normalize_response(data)
    
    def get_curated(self, page: int = 1, per_page: int = 15) -> Dict:
        url = f"{self.base_url}/curated"
        params = {"per_page": per_page, "page": page}
        
        response = requests.get(url, headers=self.headers, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        return self._normalize_response(data)
    
    def _normalize_response(self, data: Dict) -> Dict:
        """Normalize Pexels response to standard format"""
        photos = []
        for photo in data.get('photos', []):
            photos.append({
                'id': f"pexels-{photo['id']}",
                'title': photo.get('alt', 'Untitled'),
                'photographer': photo['photographer'],
                'photographer_url': photo['photographer_url'],
                'thumbnail_url': photo['src']['medium'],
                'full_url': photo['src']['original'],
                'download_url': photo['src']['large2x'],
                'width': photo['width'],
                'height': photo['height'],
                'provider': 'pexels',
                'license': 'Pexels License',
                'license_url': 'https://www.pexels.com/license/'
            })
        
        return {
            'photos': photos,
            'total_results': data.get('total_results', len(photos)),
            'per_page': data.get('per_page', 15),
            'page': data.get('page', 1)
        }
    
    def download(self, photo: Dict, output_dir: Path) -> Path:
        """Download wallpaper from Pexels"""
        response = requests.get(photo['download_url'], stream=True, timeout=30)
        response.raise_for_status()
        
        # Extract ID from normalized format
        photo_id = photo['id'].replace('pexels-', '')
        photographer_slug = photo['photographer'].lower().replace(' ', '-')
        filename = f"pexels-{photographer_slug}-{photo_id}.jpg"
        
        filepath = output_dir / filename
        with open(filepath, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        return filepath


class UnsplashProvider(WallpaperProvider):
    """Unsplash wallpaper provider"""
    
    def __init__(self, api_key: str):
        super().__init__(api_key)
        self.name = "Unsplash"
        self.base_url = "https://api.unsplash.com"
        self.headers = {"Authorization": f"Client-ID {api_key}"}
        self.requires_api_key = True
        self.rate_limit = 50
    
    def search(self, query: str, page: int = 1, per_page: int = 15) -> Dict:
        url = f"{self.base_url}/search/photos"
        params = {
            "query": query,
            "per_page": per_page,
            "page": page,
            "orientation": "landscape"
        }
        
        response = requests.get(url, headers=self.headers, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        return self._normalize_response(data)
    
    def get_curated(self, page: int = 1, per_page: int = 15) -> Dict:
        """Get curated photos from Unsplash"""
        url = f"{self.base_url}/photos"
        params = {
            "per_page": per_page,
            "page": page,
            "order_by": "popular"
        }
        
        response = requests.get(url, headers=self.headers, params=params, timeout=10)
        response.raise_for_status()
        
        # Unsplash curated returns array directly
        photos = response.json()
        return self._normalize_response({'results': photos, 'total': 10000})
    
    def _normalize_response(self, data: Dict) -> Dict:
        """Normalize Unsplash response"""
        photos = []
        results = data.get('results', data.get('photos', []))
        
        for photo in results:
            photos.append({
                'id': f"unsplash-{photo['id']}",
                'title': photo.get('description') or photo.get('alt_description', 'Untitled'),
                'photographer': photo['user']['name'],
                'photographer_url': photo['user']['links']['html'],
                'thumbnail_url': photo['urls']['small'],
                'full_url': photo['urls']['full'],
                'download_url': photo['urls']['raw'],
                'width': photo['width'],
                'height': photo['height'],
                'provider': 'unsplash',
                'license': 'Unsplash License',
                'license_url': 'https://unsplash.com/license'
            })
        
        return {
            'photos': photos,
            'total_results': data.get('total', len(photos)),
            'per_page': len(photos),
            'page': data.get('page', 1)
        }
    
    def download(self, photo: Dict, output_dir: Path) -> Path:
        """Download wallpaper from Unsplash"""
        # Trigger download tracking
        photo_id = photo['id'].replace('unsplash-', '')
        download_url = f"{self.base_url}/photos/{photo_id}/download"
        
        # Get actual download URL
        response = requests.get(download_url, headers=self.headers, timeout=10)
        response.raise_for_status()
        actual_url = response.json()['url']
        
        # Download the image
        response = requests.get(actual_url, stream=True, timeout=30)
        response.raise_for_status()
        
        photographer_slug = photo['photographer'].lower().replace(' ', '-')
        filename = f"unsplash-{photographer_slug}-{photo_id}.jpg"
        
        filepath = output_dir / filename
        with open(filepath, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        return filepath


class PixabayProvider(WallpaperProvider):
    """Pixabay wallpaper provider"""
    
    def __init__(self, api_key: str):
        super().__init__(api_key)
        self.name = "Pixabay"
        self.base_url = "https://pixabay.com/api/"
        self.api_key = api_key
        self.requires_api_key = True
        self.rate_limit = 5000
    
    def search(self, query: str, page: int = 1, per_page: int = 15) -> Dict:
        params = {
            "key": self.api_key,
            "q": query,
            "per_page": per_page,
            "page": page,
            "image_type": "photo",
            "orientation": "horizontal"
        }
        
        response = requests.get(self.base_url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        return self._normalize_response(data)
    
    def get_curated(self, page: int = 1, per_page: int = 15) -> Dict:
        """Get popular/editor's choice"""
        params = {
            "key": self.api_key,
            "per_page": per_page,
            "page": page,
            "editors_choice": "true",
            "image_type": "photo",
            "orientation": "horizontal"
        }
        
        response = requests.get(self.base_url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        return self._normalize_response(data)
    
    def _normalize_response(self, data: Dict) -> Dict:
        """Normalize Pixabay response"""
        photos = []
        for photo in data.get('hits', []):
            photos.append({
                'id': f"pixabay-{photo['id']}",
                'title': photo.get('tags', 'Untitled'),
                'photographer': photo['user'],
                'photographer_url': f"https://pixabay.com/users/{photo['user']}-{photo['user_id']}/",
                'thumbnail_url': photo['webformatURL'],
                'full_url': photo['largeImageURL'],
                'download_url': photo['largeImageURL'],
                'width': photo['imageWidth'],
                'height': photo['imageHeight'],
                'provider': 'pixabay',
                'license': 'Pixabay License',
                'license_url': 'https://pixabay.com/service/license/'
            })
        
        return {
            'photos': photos,
            'total_results': data.get('totalHits', len(photos)),
            'per_page': len(photos),
            'page': 1
        }
    
    def download(self, photo: Dict, output_dir: Path) -> Path:
        """Download wallpaper from Pixabay"""
        response = requests.get(photo['download_url'], stream=True, timeout=30)
        response.raise_for_status()
        
        photo_id = photo['id'].replace('pixabay-', '')
        photographer_slug = photo['photographer'].lower().replace(' ', '-')
        filename = f"pixabay-{photographer_slug}-{photo_id}.jpg"
        
        filepath = output_dir / filename
        with open(filepath, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        return filepath


class WallhavenProvider(WallpaperProvider):
    """Wallhaven wallpaper provider"""
    
    def __init__(self, api_key: Optional[str] = None):
        super().__init__(api_key)
        self.name = "Wallhaven"
        self.base_url = "https://wallhaven.cc/api/v1"
        self.requires_api_key = False  # Basic features work without key
        self.rate_limit = 45  # requests per minute
    
    def search(self, query: str, page: int = 1, per_page: int = 15) -> Dict:
        url = f"{self.base_url}/search"
        params = {
            "q": query,
            "page": page,
            "sorting": "relevance",
            "ratios": "16x9,16x10"
        }
        
        if self.api_key:
            params["apikey"] = self.api_key
        
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        return self._normalize_response(data)
    
    def get_curated(self, page: int = 1, per_page: int = 15) -> Dict:
        """Get top rated wallpapers"""
        url = f"{self.base_url}/search"
        params = {
            "page": page,
            "sorting": "toplist",
            "ratios": "16x9,16x10"
        }
        
        if self.api_key:
            params["apikey"] = self.api_key
        
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        return self._normalize_response(data)
    
    def _normalize_response(self, data: Dict) -> Dict:
        """Normalize Wallhaven response"""
        photos = []
        for photo in data.get('data', []):
            photos.append({
                'id': f"wallhaven-{photo['id']}",
                'title': photo.get('category', 'Wallhaven'),
                'photographer': 'Wallhaven Community',
                'photographer_url': f"https://wallhaven.cc/user/{photo.get('uploader', {}).get('username', 'unknown')}",
                'thumbnail_url': photo['thumbs']['large'],
                'full_url': photo['path'],
                'download_url': photo['path'],
                'width': photo['dimension_x'],
                'height': photo['dimension_y'],
                'provider': 'wallhaven',
                'license': 'Various (see source)',
                'license_url': photo['short_url']
            })
        
        return {
            'photos': photos,
            'total_results': data.get('meta', {}).get('total', len(photos)),
            'per_page': data.get('meta', {}).get('per_page', 24),
            'page': data.get('meta', {}).get('current_page', 1)
        }
    
    def download(self, photo: Dict, output_dir: Path) -> Path:
        """Download wallpaper from Wallhaven"""
        response = requests.get(photo['download_url'], stream=True, timeout=30)
        response.raise_for_status()
        
        photo_id = photo['id'].replace('wallhaven-', '')
        filename = f"wallhaven-{photo_id}.jpg"
        
        filepath = output_dir / filename
        with open(filepath, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        return filepath


class FourKWallpapersProvider(WallpaperProvider):
    """4K Wallpapers provider (web scraping based)"""
    
    def __init__(self):
        super().__init__(None)
        self.name = "4K Wallpapers"
        self.base_url = "https://4kwallpapers.com"
        self.requires_api_key = False
        self.rate_limit = 30  # Be respectful
    
    def search(self, query: str, page: int = 1, per_page: int = 15) -> Dict:
        """Search via their search page"""
        # Clean query for URL
        query_slug = query.lower().replace(' ', '-')
        search_url = f"{self.base_url}/search/{query_slug}/"
        
        if page > 1:
            search_url = f"{self.base_url}/search/{query_slug}/page/{page}/"
        
        return self._scrape_page(search_url, per_page)
    
    def get_curated(self, page: int = 1, per_page: int = 15) -> Dict:
        """Get recent/trending wallpapers"""
        if page == 1:
            url = f"{self.base_url}/"
        else:
            url = f"{self.base_url}/page/{page}/"
        
        return self._scrape_page(url, per_page)
    
    def get_category(self, category: str, page: int = 1, per_page: int = 15) -> Dict:
        """Get wallpapers from specific category
        
        Categories: abstract, animals, anime, architecture, bikes, black-dark,
                   cars, celebrations, cute, fantasy, flowers, food, games,
                   gradients, cgi, lifestyle, love, military, minimal, movies,
                   music, nature, people, photography, quotes, sci-fi, space,
                   sports, technology, world
        """
        category_slug = category.lower().replace(' ', '-')
        
        if page == 1:
            url = f"{self.base_url}/{category_slug}/"
        else:
            url = f"{self.base_url}/{category_slug}/page/{page}/"
        
        return self._scrape_page(url, per_page)
    
    def _scrape_page(self, url: str, per_page: int = 15) -> Dict:
        """Scrape a page for wallpapers
        
        Note: This is a placeholder. Actual implementation would use:
        - BeautifulSoup4 for HTML parsing
        - Requests for HTTP
        - Respect robots.txt
        - Cache results
        - Handle errors gracefully
        """
        try:
            from bs4 import BeautifulSoup
            import requests
            
            headers = {
                'User-Agent': 'Bentobox/2.0 (Ubuntu; Wallpaper Browser)'
            }
            
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Parse wallpaper elements
            # (Actual selectors would need to be determined by inspecting the site)
            photos = []
            wallpaper_items = soup.find_all('div', class_='wallpaper-item')[:per_page]
            
            for item in wallpaper_items:
                # Example parsing (adjust based on actual HTML structure)
                link = item.find('a')
                img = item.find('img')
                
                if link and img:
                    photo_id = link.get('href', '').split('/')[-2]
                    title = img.get('alt', 'Untitled')
                    thumbnail = img.get('data-src') or img.get('src')
                    
                    # Get full resolution by visiting detail page
                    detail_url = f"{self.base_url}{link.get('href')}"
                    
                    photos.append({
                        'id': f"4kwallpapers-{photo_id}",
                        'title': title,
                        'photographer': '4K Wallpapers Community',
                        'photographer_url': self.base_url,
                        'thumbnail_url': thumbnail,
                        'full_url': detail_url,  # Would need to scrape detail page
                        'download_url': detail_url,
                        'width': 3840,  # Assume 4K
                        'height': 2160,
                        'provider': '4kwallpapers',
                        'license': 'Free for personal use',
                        'license_url': f"{self.base_url}/tos/"
                    })
            
            return {
                'photos': photos,
                'total_results': len(photos) * 10,  # Estimate
                'per_page': per_page,
                'page': 1
            }
        
        except ImportError:
            # BeautifulSoup not installed, return empty
            return {
                'photos': [],
                'total_results': 0,
                'per_page': per_page,
                'page': 1,
                'error': 'BeautifulSoup4 not installed. Run: pip3 install beautifulsoup4'
            }
        except Exception as e:
            # Scraping failed
            return {
                'photos': [],
                'total_results': 0,
                'per_page': per_page,
                'page': 1,
                'error': str(e)
            }
    
    def download(self, photo: Dict, output_dir: Path) -> Path:
        """Download wallpaper from detail page"""
        import requests
        from bs4 import BeautifulSoup
        
        # Get detail page to find download link
        headers = {
            'User-Agent': 'Bentobox/2.0 (Ubuntu; Wallpaper Browser)'
        }
        
        response = requests.get(photo['download_url'], headers=headers, timeout=10)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Find download link (actual selector would need inspection)
        download_link = soup.find('a', class_='download-button')
        if download_link:
            image_url = download_link.get('href')
        else:
            # Fallback: find largest image
            images = soup.find_all('img')
            image_url = images[0].get('src') if images else photo['thumbnail_url']
        
        # Download the image
        response = requests.get(image_url, stream=True, timeout=30, headers=headers)
        response.raise_for_status()
        
        photo_id = photo['id'].replace('4kwallpapers-', '')
        filename = f"4kwallpapers-{photo_id}.jpg"
        
        filepath = output_dir / filename
        with open(filepath, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        return filepath


class LocalProvider(WallpaperProvider):
    """Local wallpaper collection provider"""
    
    def __init__(self, wallpaper_dir: Path):
        super().__init__(None)
        self.name = "Local Collection"
        self.wallpaper_dir = wallpaper_dir
        self.requires_api_key = False
        self.rate_limit = float('inf')
    
    def search(self, query: str, page: int = 1, per_page: int = 15) -> Dict:
        """Search local wallpapers by filename"""
        all_wallpapers = self._get_all_wallpapers()
        
        # Simple filename search
        filtered = [w for w in all_wallpapers if query.lower() in w['title'].lower()]
        
        # Paginate
        start = (page - 1) * per_page
        end = start + per_page
        page_results = filtered[start:end]
        
        return {
            'photos': page_results,
            'total_results': len(filtered),
            'per_page': per_page,
            'page': page
        }
    
    def get_curated(self, page: int = 1, per_page: int = 15) -> Dict:
        """Get all local wallpapers"""
        all_wallpapers = self._get_all_wallpapers()
        
        start = (page - 1) * per_page
        end = start + per_page
        page_results = all_wallpapers[start:end]
        
        return {
            'photos': page_results,
            'total_results': len(all_wallpapers),
            'per_page': per_page,
            'page': page
        }
    
    def _get_all_wallpapers(self) -> List[Dict]:
        """Get all wallpapers from local directory"""
        wallpapers = []
        
        if not self.wallpaper_dir.exists():
            return wallpapers
        
        for filepath in self.wallpaper_dir.glob("*.{jpg,jpeg,png,webp}"):
            wallpapers.append({
                'id': f"local-{filepath.stem}",
                'title': filepath.stem.replace('-', ' ').replace('_', ' ').title(),
                'photographer': 'Local Collection',
                'photographer_url': '',
                'thumbnail_url': str(filepath),
                'full_url': str(filepath),
                'download_url': str(filepath),
                'width': 0,  # Would need PIL to get actual dimensions
                'height': 0,
                'provider': 'local',
                'license': 'Personal Use',
                'license_url': ''
            })
        
        return wallpapers
    
    def download(self, photo: Dict, output_dir: Path) -> Path:
        """'Download' (copy) from local collection"""
        source = Path(photo['full_url'])
        dest = output_dir / source.name
        
        import shutil
        shutil.copy2(source, dest)
        
        return dest


# Provider registry
PROVIDERS = {
    'pexels': PexelsProvider,
    'unsplash': UnsplashProvider,
    '4kwallpapers': FourKWallpapersProvider,
    'pixabay': PixabayProvider,
    'wallhaven': WallhavenProvider,
    'local': LocalProvider
}


def get_provider(name: str, api_key: Optional[str] = None, **kwargs) -> WallpaperProvider:
    """Factory function to get a provider instance"""
    if name not in PROVIDERS:
        raise ValueError(f"Unknown provider: {name}")
    
    provider_class = PROVIDERS[name]
    
    if name == 'local':
        return provider_class(**kwargs)
    else:
        return provider_class(api_key)
```

---

## GUI Integration

### Provider Selector

```python
# In install/gui.py

def build_wallpaper_tab(self) -> Gtk.Box:
    """Build multi-provider wallpaper browser"""
    box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
    box.set_margin_top(10)
    box.set_margin_start(10)
    box.set_margin_end(10)
    
    # Header with provider selector
    header_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
    
    header = Gtk.Label()
    header.set_markup("<b>🎨 Browse Wallpapers</b>")
    header_box.pack_start(header, False, False, 0)
    
    # Provider dropdown
    provider_label = Gtk.Label(label="Source:")
    header_box.pack_start(provider_label, False, False, 0)
    
    self.provider_combo = Gtk.ComboBoxText()
    self.provider_combo.append("pexels", "📷 Pexels")
    self.provider_combo.append("unsplash", "🖼️ Unsplash")
    self.provider_combo.append("4kwallpapers", "🎨 4K Wallpapers")
    self.provider_combo.append("local", "💾 Local Collection")
    self.provider_combo.set_active(0)
    self.provider_combo.connect("changed", self.on_provider_changed)
    header_box.pack_start(self.provider_combo, False, False, 0)
    
    # API key status indicator
    self.api_status_label = Gtk.Label()
    self.api_status_label.set_markup("<span color='green'>✓ API Ready</span>")
    header_box.pack_start(self.api_status_label, False, False, 0)
    
    # Configure API keys button
    config_btn = Gtk.Button(label="⚙️ Configure APIs")
    config_btn.connect("clicked", self.on_configure_apis)
    header_box.pack_end(config_btn, False, False, 0)
    
    box.pack_start(header_box, False, False, 0)
    
    # ... rest of UI (search, grid, pagination)
```

---

## Configuration

### Multi-Provider API Keys

```yaml
# ~/.bentobox-config.yaml

wallpapers:
  providers:
    pexels:
      api_key: "your-pexels-key-from-pexels.com/api"
      enabled: true
      default: true
    
    unsplash:
      api_key: "your-unsplash-key-from-unsplash.com/developers"
      enabled: true
    
    4kwallpapers:
      enabled: true
      # No API key needed - uses web scraping
    
    local:
      enabled: true
      path: "assets/wallpapers/custom"
  
  settings:
    default_provider: "pexels"
    cache_thumbnails: true
    cache_directory: "~/.cache/bentobox/wallpapers"
    auto_download_curated: false
    default_search: "nature mountains"
    
    # For 4K Wallpapers
    default_category: "nature"  # abstract, animals, anime, cars, space, etc.
```

---

## Benefits of Multi-Provider

### For Users:
- ✅ **More choice** - Access to millions of wallpapers from 3 providers
- ✅ **Different styles** - Professional (Unsplash), curated (Pexels), gaming/anime (4K Wallpapers)
- ✅ **Fallback** - If one provider is down, use another
- ✅ **Rate limit protection** - Spread across providers (200/hr Pexels, 50/hr Unsplash, unlimited 4K)
- ✅ **Personal collection** - Include own photos
- ✅ **Category browsing** - 4K Wallpapers offers 30+ curated categories

### For Project:
- ✅ **Resilient** - Not dependent on single API
- ✅ **Extensible** - Easy to add more providers
- ✅ **Professional** - Clean abstraction layer
- ✅ **Future-proof** - Can add Pixabay, Wallhaven, AI-generated later

---

## Implementation Dependencies

### Required Python Packages

```bash
# Add to install-gui.sh or requirements.txt
pip3 install --user requests beautifulsoup4 pillow pyyaml
```

### Package Usage:
- `requests` - HTTP requests for all providers
- `beautifulsoup4` - HTML parsing for 4K Wallpapers scraping
- `pillow` - Image manipulation (thumbnails, previews)
- `pyyaml` - Config file parsing (already installed)

---

## 4K Wallpapers Integration Notes

Since **4kwallpapers.com** doesn't have a public API, we need to:

### Option A: Web Scraping (Current Design)
- ✅ No API key needed
- ✅ Access to all categories
- ⚠️ Requires BeautifulSoup4
- ⚠️ May break if site structure changes
- ⚠️ Must respect robots.txt
- ⚠️ Rate limiting via delays

### Option B: RSS Feeds (If Available)
```python
# Check if they have RSS feeds for categories
rss_url = "https://4kwallpapers.com/feed/"
# Parse with feedparser library
```

### Option C: Contact for API Access
- Reach out to 4kwallpapers.com
- Request API partnership
- Provide proper attribution

### Recommended Approach:
1. **Start with web scraping** (proof of concept)
2. **Add caching** (24-hour cache of category pages)
3. **Monitor site changes** (automated tests)
4. **Contact site owners** (request official API or partnership)

---

## Summary

This architecture:
1. **Abstract base class** defines standard interface
2. **Provider implementations** normalize different APIs
3. **Factory pattern** for easy provider instantiation
4. **Unified UI** works with any provider
5. **Easy to extend** - just implement base class

**Each provider returns same format** so GUI doesn't need to know the difference!

Would you like me to implement this multi-provider system? 🚀

