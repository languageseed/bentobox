# Headless Browser for Wallpaper Scraping

## What is a Headless Browser?

A **headless browser** is a real web browser (Chrome, Firefox) that runs without a visible GUI. It:
- Executes JavaScript (unlike `requests`)
- Renders pages like a real browser
- Can bypass most bot detection
- Handles cookies, sessions, etc.

## Options

### 1. Playwright (RECOMMENDED)
**Modern, fast, official browser automation**

```bash
# Install
pip3 install playwright
playwright install chromium
```

**Pros:**
- ✅ Modern API (async support)
- ✅ Fast (~3-5 seconds per page)
- ✅ Good documentation
- ✅ Handles JavaScript
- ✅ Can take screenshots
- ✅ Works with Chromium, Firefox, WebKit

**Cons:**
- ❌ ~200 MB Chromium download
- ❌ Higher memory usage (100-200 MB per instance)
- ❌ Slower than pure HTTP requests

### 2. Selenium
**Older, widely used**

```bash
# Install
pip3 install selenium
sudo apt install chromium-browser chromium-chromedriver
```

**Pros:**
- ✅ More mature
- ✅ Lots of examples online
- ✅ Works with many browsers

**Cons:**
- ❌ Slower than Playwright
- ❌ More complex setup
- ❌ Older API design
- ❌ Requires ChromeDriver management

### 3. Puppeteer (Node.js)
**Not recommended for Python project**

---

## Implementation for Bentobox

### Architecture Option A: Hybrid (RECOMMENDED)

```python
class PexelsProvider(WallpaperProvider):
    def __init__(self, use_headless=False):
        self.use_headless = use_headless
    
    def search(self, query, page=1, per_page=15):
        if self.use_headless:
            return self._search_headless(query, page, per_page)
        else:
            return self._search_requests(query, page, per_page)
    
    def _search_headless(self, query, page, per_page):
        """Use Playwright for scraping"""
        # ... headless browser code
    
    def _search_requests(self, query, page, per_page):
        """Fall back to requests (may get blocked)"""
        # ... current code
```

### Architecture Option B: Playwright Only

Replace all `requests.get()` calls with Playwright for Pexels.

**Trade-offs:**
- Slower (5 seconds vs 1 second)
- More reliable (no 403 errors)
- Heavier (200 MB install, 100 MB RAM)

---

## Performance Comparison

| Method | Speed | Memory | Reliability | Setup |
|--------|-------|--------|-------------|-------|
| **requests** | ⚡ 0.5-1s | 💚 10 MB | ⚠️ Often blocked | ✅ Easy |
| **Playwright** | 🐢 3-5s | 🟡 150 MB | ✅ Reliable | 🟡 Medium |
| **Selenium** | 🐌 5-10s | 🔴 200 MB | ✅ Reliable | 🔴 Complex |

---

## Installation Impact

### Current Dependencies (Bentobox)
```bash
sudo apt install python3-yaml python3-requests python3-bs4 python3-pil
# Total: ~5 MB
```

### With Playwright
```bash
sudo apt install python3-playwright
playwright install chromium
# Additional: ~200 MB
```

---

## Code Example

### Current (requests + BeautifulSoup)
```python
response = requests.get(url, headers=headers)
soup = BeautifulSoup(response.text, 'html.parser')
images = soup.find_all('img')
```

### With Playwright
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto(url)
    
    # JavaScript execution!
    wallpapers = page.evaluate("""
        () => {
            return Array.from(document.querySelectorAll('article'))
                .map(article => ({
                    title: article.querySelector('img')?.alt,
                    url: article.querySelector('a')?.href
                }));
        }
    """)
    
    browser.close()
```

---

## Real-World Performance

### Scenario: User browses 3 pages of wallpapers

**With requests (current):**
- Time: 3 seconds total
- Memory: 50 MB
- ❌ May get blocked

**With Playwright:**
- Time: 15 seconds total
- Memory: 250 MB
- ✅ Reliable

**User experience:**
- 12 seconds slower
- But actually works!

---

## Recommendation for Bentobox

### Option 1: Make Playwright Optional ⭐

```yaml
# bentobox-config.yaml
wallpapers:
  providers:
    pexels:
      enabled: true
      use_headless: false  # Fast but may be blocked
      # Set to true if you get 403 errors
```

**Benefits:**
- Default: Fast (requests)
- Fallback: Reliable (Playwright)
- User choice

### Option 2: Just Use 4K Wallpapers

It works great without any of this complexity!

---

## Legal Consideration

⚠️ **Remember:** Pexels prohibits wallpaper apps in their ToS.

Even with headless browser:
- ❌ Still against their terms
- ❌ Could result in IP ban
- ❌ Ethically questionable

**Better approach:**
- Use 4K Wallpapers (no restrictions)
- Use Unsplash (check their ToS)
- Skip Pexels entirely

---

## Testing

Run the test script:
```bash
cd /Users/ben/Documents/bentobox
python3 test-headless-browser.py
```

This will:
1. Launch Chromium headless
2. Visit Pexels
3. Scrape 5 wallpapers
4. Take a screenshot
5. Show results

---

## My Recommendation

Given:
- Pexels ToS prohibits wallpaper apps
- 4K Wallpapers works perfectly
- Unsplash works with current approach
- Playwright adds 200 MB + complexity

**I recommend: Remove Pexels, keep it simple.**

But if you want to see headless browser working, let's test it!

