#!/usr/bin/env python3
"""
Wallpaper Provider Abstraction Layer for Bentobox
Supports multiple wallpaper sources with a unified interface
"""

from abc import ABC, abstractmethod
from typing import List, Dict, Optional
from pathlib import Path
import requests
import json
import time
from urllib.parse import quote


class WallpaperProvider(ABC):
    """Abstract base class for wallpaper providers"""
    
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key
        self.name = "Unknown"
        self.requires_api_key = True
        self.rate_limit = 100  # requests per hour
        self.last_request_time = 0
        self.min_request_interval = 3600 / self.rate_limit  # seconds between requests
    
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
        if not self.requires_api_key:
            return True
        
        try:
            result = self.get_curated(per_page=1)
            return 'photos' in result and not result.get('error')
        except:
            return False
    
    def _rate_limit(self):
        """Enforce rate limiting"""
        elapsed = time.time() - self.last_request_time
        if elapsed < self.min_request_interval:
            time.sleep(self.min_request_interval - elapsed)
        self.last_request_time = time.time()


class PexelsProvider(WallpaperProvider):
    """Pexels wallpaper provider - https://www.pexels.com/ (web scraping)"""
    
    def __init__(self):
        super().__init__(None)
        self.name = "Pexels"
        self.base_url = "https://www.pexels.com"
        self.requires_api_key = False
        self.rate_limit = 30  # Be respectful
        self.min_request_interval = 3600 / self.rate_limit
    
    def search(self, query: str, page: int = 1, per_page: int = 15) -> Dict:
        """Search Pexels by scraping search results"""
        self._rate_limit()
        
        # Clean query for URL
        query_slug = quote(query)
        search_url = f"{self.base_url}/search/{query_slug}/"
        
        if page > 1:
            search_url = f"{self.base_url}/search/{query_slug}/?page={page}"
        
        return self._scrape_page(search_url, per_page)
    
    def get_curated(self, page: int = 1, per_page: int = 15) -> Dict:
        """Get popular photos from Pexels"""
        self._rate_limit()
        
        if page == 1:
            url = f"{self.base_url}/search/4k%20wallpaper/"
        else:
            url = f"{self.base_url}/search/4k%20wallpaper/?page={page}"
        
        return self._scrape_page(url, per_page)
    
    def _scrape_page(self, url: str, per_page: int = 15) -> Dict:
        """Scrape Pexels page for wallpapers"""
        try:
            from bs4 import BeautifulSoup
        except ImportError:
            return {
                'photos': [],
                'total_results': 0,
                'per_page': per_page,
                'page': 1,
                'error': 'BeautifulSoup4 not installed. Run: pip3 install beautifulsoup4'
            }
        
        try:
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.5',
                'Referer': 'https://www.pexels.com/',
                'DNT': '1',
                'Connection': 'keep-alive',
                'Upgrade-Insecure-Requests': '1'
            }
            
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            photos = []
            
            # Find all photo articles (updated selectors)
            photo_articles = soup.find_all('article')[:per_page]
            
            for article in photo_articles:
                try:
                    # Find image
                    img = article.find('img')
                    if not img:
                        continue
                    
                    # Get photo link
                    link = article.find('a', href=True)
                    if not link:
                        continue
                    
                    photo_url = link['href']
                    if not photo_url.startswith('http'):
                        photo_url = self.base_url + photo_url
                    
                    # Extract photo ID from URL
                    photo_id = photo_url.split('-')[-1].replace('/', '')
                    
                    # Get image URLs
                    thumbnail = img.get('src') or img.get('data-src', '') or img.get('srcset', '').split()[0] if img.get('srcset') else ''
                    if thumbnail.startswith('//'):
                        thumbnail = 'https:' + thumbnail
                    
                    if not thumbnail:
                        continue
                    
                    # Get title/alt
                    title = img.get('alt', 'Pexels Photo')
                    
                    # Get photographer
                    photographer = 'Pexels'
                    photographer_url = self.base_url
                    
                    photos.append({
                        'id': f"pexels-{photo_id}",
                        'title': title,
                        'photographer': photographer,
                        'photographer_url': photographer_url,
                        'thumbnail_url': thumbnail,
                        'full_url': photo_url,
                        'download_url': photo_url,
                        'width': 3840,
                        'height': 2160,
                        'provider': 'pexels',
                        'license': 'Pexels License',
                        'license_url': 'https://www.pexels.com/license/'
                    })
                
                except Exception as e:
                    continue
            
            return {
                'photos': photos,
                'total_results': len(photos) * 20,
                'per_page': per_page,
                'page': 1
            }
        
        except Exception as e:
            return {
                'photos': [],
                'total_results': 0,
                'per_page': per_page,
                'page': 1,
                'error': f'Scraping failed: {str(e)}'
            }
    
    def download(self, photo: Dict, output_dir: Path) -> Path:
        """Download wallpaper from Pexels detail page"""
        try:
            from bs4 import BeautifulSoup
        except ImportError:
            raise Exception('BeautifulSoup4 not installed')
        
        self._rate_limit()
        
        headers = {
            'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64) Bentobox/2.0 Wallpaper Browser'
        }
        
        try:
            # Visit detail page
            response = requests.get(photo['download_url'], headers=headers, timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Find download button or original image
            download_btn = soup.find('a', string='Free Download')
            if download_btn and download_btn.get('href'):
                # Follow download link
                download_page = download_btn['href']
                if not download_page.startswith('http'):
                    download_page = self.base_url + download_page
                
                # Get actual image
                response2 = requests.get(download_page, headers=headers, timeout=10)
                soup2 = BeautifulSoup(response2.text, 'html.parser')
                img = soup2.find('img', class_='image')
                if img:
                    image_url = img.get('src') or img.get('data-src')
                else:
                    image_url = photo['thumbnail_url']
            else:
                # Fallback to thumbnail
                image_url = photo['thumbnail_url']
            
            if image_url.startswith('//'):
                image_url = 'https:' + image_url
            
            # Download the image
            response = requests.get(image_url, stream=True, timeout=30, headers=headers)
            response.raise_for_status()
            
            photo_id = photo['id'].replace('pexels-', '')
            photographer_slug = photo['photographer'].lower().replace(' ', '-').replace('/', '-')
            filename = f"pexels-{photographer_slug}-{photo_id}.jpg"
            
            filepath = output_dir / filename
            with open(filepath, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            
            return filepath
        
        except Exception as e:
            raise Exception(f'Download failed: {str(e)}')


class UnsplashProvider(WallpaperProvider):
    """Unsplash wallpaper provider - https://unsplash.com/ (web scraping)"""
    
    def __init__(self):
        super().__init__(None)
        self.name = "Unsplash"
        self.base_url = "https://unsplash.com"
        self.requires_api_key = False
        self.rate_limit = 30  # Be respectful
        self.min_request_interval = 3600 / self.rate_limit
    
    def search(self, query: str, page: int = 1, per_page: int = 15) -> Dict:
        """Search Unsplash by scraping search results"""
        self._rate_limit()
        
        query_slug = quote(query)
        search_url = f"{self.base_url}/s/photos/{query_slug}"
        
        if page > 1:
            search_url = f"{self.base_url}/s/photos/{query_slug}?page={page}"
        
        return self._scrape_page(search_url, per_page, page)
    
    def get_curated(self, page: int = 1, per_page: int = 15) -> Dict:
        """Get popular photos from Unsplash"""
        self._rate_limit()
        
        if page == 1:
            url = f"{self.base_url}/s/photos/wallpaper-4k"
        else:
            url = f"{self.base_url}/s/photos/wallpaper-4k?page={page}"
        
        return self._scrape_page(url, per_page, page)
    
    def _scrape_page(self, url: str, per_page: int = 15, page: int = 1) -> Dict:
        """Scrape Unsplash page for wallpapers"""
        try:
            from bs4 import BeautifulSoup
        except ImportError:
            return {
                'photos': [],
                'total_results': 0,
                'per_page': per_page,
                'page': page,
                'error': 'BeautifulSoup4 not installed. Run: pip3 install beautifulsoup4'
            }
        
        try:
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.5'
            }
            
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            photos = []
            
            # Find all photo figures
            photo_figures = soup.find_all('figure')[:per_page]
            
            for figure in photo_figures:
                try:
                    # Find image
                    img = figure.find('img')
                    if not img:
                        continue
                    
                    # Get photo link
                    link = figure.find('a', href=True)
                    if not link:
                        continue
                    
                    photo_url = link['href']
                    if not photo_url.startswith('http'):
                        photo_url = self.base_url + photo_url
                    
                    # Extract photo ID from URL
                    photo_id = photo_url.split('/')[-1].split('-')[-1].split('?')[0]
                    
                    # Get image URLs
                    thumbnail = img.get('src') or img.get('srcset', '').split()[0] if img.get('srcset') else ''
                    if thumbnail.startswith('//'):
                        thumbnail = 'https:' + thumbnail
                    
                    if not thumbnail:
                        continue
                    
                    # Get title/alt
                    title = img.get('alt', 'Unsplash Photo')
                    
                    # Get photographer
                    photographer = 'Unsplash'
                    photographer_url = self.base_url
                    author_link = figure.find('a', href=lambda x: x and '/@' in x)
                    if author_link:
                        photographer = author_link.get_text(strip=True)
                        photographer_url = author_link.get('href', self.base_url)
                        if not photographer_url.startswith('http'):
                            photographer_url = self.base_url + photographer_url
                    
                    photos.append({
                        'id': f"unsplash-{photo_id}",
                        'title': title,
                        'photographer': photographer,
                        'photographer_url': photographer_url,
                        'thumbnail_url': thumbnail,
                        'full_url': photo_url,
                        'download_url': photo_url,
                        'width': 3840,
                        'height': 2160,
                        'provider': 'unsplash',
                        'license': 'Unsplash License',
                        'license_url': 'https://unsplash.com/license'
                    })
                
                except Exception as e:
                    continue
            
            return {
                'photos': photos,
                'total_results': len(photos) * 20,
                'per_page': per_page,
                'page': page
            }
        
        except Exception as e:
            return {
                'photos': [],
                'total_results': 0,
                'per_page': per_page,
                'page': page,
                'error': f'Scraping failed: {str(e)}'
            }
    
    def download(self, photo: Dict, output_dir: Path) -> Path:
        """Download wallpaper from Unsplash detail page"""
        try:
            from bs4 import BeautifulSoup
        except ImportError:
            raise Exception('BeautifulSoup4 not installed')
        
        self._rate_limit()
        
        headers = {
            'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64) Bentobox/2.0 Wallpaper Browser'
        }
        
        try:
            # Visit detail page
            response = requests.get(photo['download_url'], headers=headers, timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Find download button or original image
            download_btn = soup.find('a', href=lambda x: x and '/download' in x)
            if download_btn:
                download_url = download_btn['href']
                if not download_url.startswith('http'):
                    download_url = self.base_url + download_url
                
                # Follow download link
                response = requests.get(download_url, headers=headers, timeout=10, allow_redirects=True)
                image_url = response.url
            else:
                # Fallback: find main image
                main_img = soup.find('img', src=lambda x: x and 'images.unsplash.com' in x)
                if main_img:
                    image_url = main_img['src']
                    # Get higher resolution version
                    image_url = image_url.replace('&w=400', '&w=1920').replace('&h=400', '&h=1080')
                else:
                    image_url = photo['thumbnail_url']
            
            if image_url.startswith('//'):
                image_url = 'https:' + image_url
            
            # Download the image
            response = requests.get(image_url, stream=True, timeout=30, headers=headers)
            response.raise_for_status()
            
            photo_id = photo['id'].replace('unsplash-', '')
            photographer_slug = photo['photographer'].lower().replace(' ', '-').replace('/', '-')
            filename = f"unsplash-{photographer_slug}-{photo_id}.jpg"
            
            filepath = output_dir / filename
            with open(filepath, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            
            return filepath
        
        except Exception as e:
            raise Exception(f'Download failed: {str(e)}')


class FourKWallpapersProvider(WallpaperProvider):
    """4K Wallpapers provider - https://4kwallpapers.com/ (web scraping)"""
    
    def __init__(self):
        super().__init__(None)
        self.name = "4K Wallpapers"
        self.base_url = "https://4kwallpapers.com"
        self.requires_api_key = False
        self.rate_limit = 30  # Be respectful
        self.min_request_interval = 3600 / self.rate_limit
    
    def search(self, query: str, page: int = 1, per_page: int = 15) -> Dict:
        """Search 4K Wallpapers via their search page"""
        self._rate_limit()
        
        # Clean query for URL
        query_slug = quote(query.lower().replace(' ', '-'))
        
        if page == 1:
            search_url = f"{self.base_url}/search/{query_slug}/"
        else:
            search_url = f"{self.base_url}/search/{query_slug}/page/{page}/"
        
        return self._scrape_page(search_url, per_page, page)
    
    def get_curated(self, page: int = 1, per_page: int = 15) -> Dict:
        """Get recent/trending wallpapers"""
        self._rate_limit()
        
        if page == 1:
            url = f"{self.base_url}/"
        else:
            url = f"{self.base_url}/page/{page}/"
        
        return self._scrape_page(url, per_page, page)
    
    def get_category(self, category: str, page: int = 1, per_page: int = 15) -> Dict:
        """Get wallpapers from specific category
        
        Popular categories: nature, space, cars, anime, abstract, minimal, etc.
        """
        self._rate_limit()
        
        category_slug = category.lower().replace(' ', '-')
        
        if page == 1:
            url = f"{self.base_url}/{category_slug}/"
        else:
            url = f"{self.base_url}/{category_slug}/page/{page}/"
        
        return self._scrape_page(url, per_page, page)
    
    def _scrape_page(self, url: str, per_page: int = 15, page: int = 1) -> Dict:
        """Scrape a page for wallpapers"""
        try:
            from bs4 import BeautifulSoup
        except ImportError:
            return {
                'photos': [],
                'total_results': 0,
                'per_page': per_page,
                'page': page,
                'error': 'BeautifulSoup4 not installed. Run: pip3 install beautifulsoup4'
            }
        
        try:
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
            }
            
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            photos = []
            
            # Find all images with 'walls/thumbs' in src
            all_imgs = soup.find_all('img')
            
            for img in all_imgs:
                if len(photos) >= per_page:
                    break
                
                src = img.get('src', '') or img.get('data-src', '')
                
                # Only process wallpaper thumbnails
                if 'walls/thumbs' not in src:
                    continue
                
                # Get parent link
                parent = img.find_parent('a')
                if not parent or not parent.get('href'):
                    continue
                
                photo_url = parent['href']
                if not photo_url.startswith('http'):
                    photo_url = self.base_url + photo_url
                
                # Ensure full URL for thumbnail
                if src.startswith('//'):
                    src = 'https:' + src
                elif src.startswith('/'):
                    src = self.base_url + src
                
                # Extract ID from thumbnail URL
                photo_id = src.split('/')[-1].split('.')[0]
                
                title = img.get('alt', 'Untitled')
                
                photos.append({
                    'id': f"4kwallpapers-{photo_id}",
                    'title': title,
                    'photographer': '4K Wallpapers',
                    'photographer_url': self.base_url,
                    'thumbnail_url': src,
                    'full_url': photo_url,
                    'download_url': photo_url,
                    'width': 3840,
                    'height': 2160,
                    'provider': '4kwallpapers',
                    'license': 'Free for personal use',
                    'license_url': f"{self.base_url}/tos/"
                })
            
            return {
                'photos': photos,
                'total_results': len(photos) * 20,  # Estimate
                'per_page': per_page,
                'page': page
            }
        
        except Exception as e:
            return {
                'photos': [],
                'total_results': 0,
                'per_page': per_page,
                'page': page,
                'error': f'Scraping failed: {str(e)}'
            }
    
    def download(self, photo: Dict, output_dir: Path) -> Path:
        """Download wallpaper from 4K Wallpapers"""
        try:
            from bs4 import BeautifulSoup
        except ImportError:
            raise Exception('BeautifulSoup4 not installed')
        
        self._rate_limit()
        
        # Visit detail page to find download link
        headers = {
            'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64) Bentobox/2.0 Wallpaper Browser'
        }
        
        try:
            response = requests.get(photo['download_url'], headers=headers, timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Find download button or largest image
            download_link = soup.find('a', class_='download') or soup.find('a', string='Download')
            
            if download_link and download_link.get('href'):
                image_url = download_link['href']
            else:
                # Fallback: find main image
                main_img = soup.find('img', class_='main-img') or soup.find('meta', property='og:image')
                if main_img:
                    image_url = main_img.get('content') or main_img.get('src')
                else:
                    # Last resort: use thumbnail
                    image_url = photo['thumbnail_url']
            
            # Ensure full URL
            if image_url.startswith('//'):
                image_url = 'https:' + image_url
            elif image_url.startswith('/'):
                image_url = self.base_url + image_url
            
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
        
        except Exception as e:
            raise Exception(f'Download failed: {str(e)}')


class LocalProvider(WallpaperProvider):
    """Local wallpaper collection provider"""
    
    def __init__(self, wallpaper_dir: Path):
        super().__init__(None)
        self.name = "Local Collection"
        self.wallpaper_dir = Path(wallpaper_dir).expanduser()
        self.requires_api_key = False
        self.rate_limit = float('inf')
    
    def search(self, query: str, page: int = 1, per_page: int = 15) -> Dict:
        """Search local wallpapers by filename"""
        all_wallpapers = self._get_all_wallpapers()
        
        # Simple filename search
        query_lower = query.lower()
        filtered = [w for w in all_wallpapers if query_lower in w['title'].lower()]
        
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
        
        # Support common image formats
        patterns = ['*.jpg', '*.jpeg', '*.png', '*.webp']
        
        for pattern in patterns:
            for filepath in self.wallpaper_dir.glob(pattern):
                wallpapers.append({
                    'id': f"local-{filepath.stem}",
                    'title': filepath.stem.replace('-', ' ').replace('_', ' ').title(),
                    'photographer': 'Local Collection',
                    'photographer_url': '',
                    'thumbnail_url': f"file://{filepath}",
                    'full_url': f"file://{filepath}",
                    'download_url': f"file://{filepath}",
                    'width': 0,  # Would need PIL to get actual dimensions
                    'height': 0,
                    'provider': 'local',
                    'license': 'Personal Use',
                    'license_url': ''
                })
        
        return sorted(wallpapers, key=lambda x: x['title'])
    
    def download(self, photo: Dict, output_dir: Path) -> Path:
        """'Download' (copy) from local collection"""
        import shutil
        
        source = Path(photo['full_url'].replace('file://', ''))
        dest = output_dir / source.name
        
        shutil.copy2(source, dest)
        
        return dest


# Provider registry
PROVIDERS = {
    'unsplash': UnsplashProvider,
    '4kwallpapers': FourKWallpapersProvider,
    'local': LocalProvider
}


def get_provider(name: str, **kwargs) -> WallpaperProvider:
    """Factory function to get a provider instance"""
    if name not in PROVIDERS:
        raise ValueError(f"Unknown provider: {name}. Available: {', '.join(PROVIDERS.keys())}")
    
    provider_class = PROVIDERS[name]
    
    if name == 'local':
        return provider_class(**kwargs)
    else:
        return provider_class()


if __name__ == '__main__':
    # Simple test
    print("Wallpaper Providers Available:")
    for name, provider_class in PROVIDERS.items():
        print(f"  - {name}")

