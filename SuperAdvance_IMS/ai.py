import requests
from bs4 import BeautifulSoup
import re
import time
import random
from concurrent.futures import ThreadPoolExecutor
from urllib.parse import quote_plus

# Define user agents to rotate and avoid detection
USER_AGENTS = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36'
]

class PriceComparisonScraper:
    def __init__(self):
        self.results = []
    
    def get_random_headers(self):
        """Generate random headers to avoid detection"""
        return {
            'User-Agent': random.choice(USER_AGENTS),
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'Cache-Control': 'max-age=0',
        }
    
    def clean_price(self, price_str):
        """Extract numeric price from string"""
        if not price_str:
            return None
        # Remove currency symbols and non-numeric characters except decimal point
        price_match = re.search(r'[\d,]+\.\d+|\d+', price_str.replace(',', ''))
        if price_match:
            return float(price_match.group().replace(',', ''))
        return None
    
    def clean_title(self, title_str):
        """Clean product title"""
        if not title_str:
            return ""
        # Remove extra whitespace
        return re.sub(r'\s+', ' ', title_str).strip()
    
    def scrape_amazon(self, query):
        """Scrape product prices from Amazon"""
        print(f"Searching Amazon for '{query}'...")
        url = f"https://www.amazon.com/s?k={quote_plus(query)}"
        
        try:
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            if response.status_code != 200:
                print(f"Failed to retrieve data from Amazon. Status code: {response.status_code}")
                return []
            
            soup = BeautifulSoup(response.text, 'html.parser')
            products = []
            
            # Find all product cards
            items = soup.select('.s-result-item[data-component-type="s-search-result"]')
            
            for item in items[:5]:  # Limit to first 5 results
                title_elem = item.select_one('h2 .a-link-normal')
                price_elem = item.select_one('.a-price .a-offscreen')
                
                if title_elem and price_elem:
                    title = self.clean_title(title_elem.get_text())
                    price_str = price_elem.get_text()
                    price = self.clean_price(price_str)
                    
                    if title and price:
                        products.append({
                            'title': title,
                            'price': price,
                            'price_display': price_str,
                            'source': 'Amazon'
                        })
            
            return products
        
        except Exception as e:
            print(f"Error scraping Amazon: {e}")
            return []
    
    def scrape_walmart(self, query):
        """Scrape product prices from Walmart"""
        print(f"Searching Walmart for '{query}'...")
        url = f"https://www.walmart.com/search?q={quote_plus(query)}"
        
        try:
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            if response.status_code != 200:
                print(f"Failed to retrieve data from Walmart. Status code: {response.status_code}")
                return []
            
            soup = BeautifulSoup(response.text, 'html.parser')
            products = []
            
            # Find all product cards
            items = soup.select('div[data-item-id]')
            
            for item in items[:5]:  # Limit to first 5 results
                title_elem = item.select_one('[data-automation-id="product-title"]')
                price_elem = item.select_one('[data-automation-id="product-price"]')
                
                if not title_elem or not price_elem:
                    # Try alternative selectors
                    title_elem = item.select_one('.ellipse-2')
                    price_elem = item.select_one('.price-main')
                
                if title_elem and price_elem:
                    title = self.clean_title(title_elem.get_text())
                    price_str = price_elem.get_text()
                    price = self.clean_price(price_str)
                    
                    if title and price:
                        products.append({
                            'title': title,
                            'price': price,
                            'price_display': price_str,
                            'source': 'Walmart'
                        })
            
            return products
        
        except Exception as e:
            print(f"Error scraping Walmart: {e}")
            return []
    
    def scrape_ebay(self, query):
        """Scrape product prices from eBay"""
        print(f"Searching eBay for '{query}'...")
        url = f"https://www.ebay.com/sch/i.html?_nkw={quote_plus(query)}"
        
        try:
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            if response.status_code != 200:
                print(f"Failed to retrieve data from eBay. Status code: {response.status_code}")
                return []
            
            soup = BeautifulSoup(response.text, 'html.parser')
            products = []
            
            # Find all product cards
            items = soup.select('.s-item__wrapper')
            
            for item in items[:5]:  # Limit to first 5 results
                title_elem = item.select_one('.s-item__title')
                price_elem = item.select_one('.s-item__price')
                
                if title_elem and price_elem:
                    title = self.clean_title(title_elem.get_text())
                    price_str = price_elem.get_text()
                    price = self.clean_price(price_str)
                    
                    # Skip "Shop on eBay" placeholder
                    if "Shop on eBay" in title:
                        continue
                    
                    if title and price:
                        products.append({
                            'title': title,
                            'price': price,
                            'price_display': price_str,
                            'source': 'eBay'
                        })
            
            return products
        
        except Exception as e:
            print(f"Error scraping eBay: {e}")
            return []
    
    def scrape_bestbuy(self, query):
        """Scrape product prices from Best Buy"""
        print(f"Searching Best Buy for '{query}'...")
        url = f"https://www.bestbuy.com/site/searchpage.jsp?st={quote_plus(query)}"
        
        try:
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            if response.status_code != 200:
                print(f"Failed to retrieve data from Best Buy. Status code: {response.status_code}")
                return []
            
            soup = BeautifulSoup(response.text, 'html.parser')
            products = []
            
            # Find all product cards
            items = soup.select('.sku-item')
            
            for item in items[:5]:  # Limit to first 5 results
                title_elem = item.select_one('.sku-title a')
                price_elem = item.select_one('.priceView-customer-price span')
                
                if title_elem and price_elem:
                    title = self.clean_title(title_elem.get_text())
                    price_str = price_elem.get_text()
                    price = self.clean_price(price_str)
                    
                    if title and price:
                        products.append({
                            'title': title,
                            'price': price,
                            'price_display': price_str,
                            'source': 'Best Buy'
                        })
            
            return products
        
        except Exception as e:
            print(f"Error scraping Best Buy: {e}")
            return []
    
    def search_all_sources(self, query):
        """Search for products across all sources concurrently"""
        self.results = []
        sources = [
            self.scrape_amazon,
            self.scrape_walmart,
            self.scrape_ebay,
            self.scrape_bestbuy
        ]
        
        print(f"\nSearching for prices of: {query}\n")
        print("Please wait while we gather data from multiple sources...\n")
        
        # Use ThreadPoolExecutor to scrape sources concurrently
        with ThreadPoolExecutor(max_workers=4) as executor:
            # Submit all scraping tasks
            futures = [executor.submit(source, query) for source in sources]
            
            # Collect results as they complete
            for future in futures:
                self.results.extend(future.result())
                # Add a small delay between requests to avoid rate limiting
                time.sleep(random.uniform(0.5, 1.5))
        
        return self.results
    
    def display_results(self):
        """Display the scraped results in the terminal"""
        if not self.results:
            print("\nNo results found for your search query.")
            return
        
        # Group results by source
        grouped_results = {}
        for item in self.results:
            source = item['source']
            if source not in grouped_results:
                grouped_results[source] = []
            grouped_results[source].append(item)
        
        # Display results by source
        print("\n=== PRICE COMPARISON RESULTS ===\n")
        
        for source, items in grouped_results.items():
            print(f"\n--- {source} ---")
            for i, item in enumerate(items, 1):
                print(f"{i}. {item['title']}")
                print(f"   Price: {item['price_display']}")
                print("")
                
            # Calculate and display price range for this store
            if items:
                prices = [item['price'] for item in items if item['price'] is not None]
                if prices:
                    min_price = min(prices)
                    max_price = max(prices)
                    print(f"Price Range for {source}: ${min_price:.2f} - ${max_price:.2f}")


def main():
    """Main function to run the price comparison tool"""
    scraper = PriceComparisonScraper()
    
    print("===== MARKET PRICE COMPARISON TOOL =====")
    print("This tool searches multiple online marketplaces and compares prices")
    
    while True:
        query = input("\nEnter a product to search for (or type 'exit' to quit): ")
        
        if query.lower() == 'exit':
            print("Goodbye!")
            break
        
        results = scraper.search_all_sources(query)
        scraper.display_results()


if __name__ == "__main__":
    main()