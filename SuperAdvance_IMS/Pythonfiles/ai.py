import requests
from bs4 import BeautifulSoup
import re
import statistics
import time
import random
import pandas as pd
from fake_useragent import UserAgent
import logging
import json
from concurrent.futures import ThreadPoolExecutor, as_completed
import matplotlib.pyplot as plt
import hashlib

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class PriceScraper:
    def __init__(self):
        self.ua = UserAgent()
        # Added more electronics retailers to the prices dictionary
        self.prices = {
            'ebay': [],
            'amazon': [],
            'newegg': [],
            'bestbuy': [],
            'pcexpress': [],
            'microcenter': [],
            'bhphotovideo': []
        }
        self.stats = {}
        self.source_stats = {}
        self.source_suggested_prices = {}  # New dictionary to store per-source suggested prices
        self.price_history = {}  # For tracking previous searches
        
    def get_random_headers(self):
        """Generate random headers to avoid detection"""
        return {
            'User-Agent': self.ua.random,
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'Cache-Control': 'max-age=0',
            'Sec-CH-UA': '"Chromium";v="112", "Google Chrome";v="112", "Not:A-Brand";v="99"',
            'Sec-CH-UA-Mobile': '?0',
            'Sec-CH-UA-Platform': '"Windows"',
            'Sec-Fetch-Dest': 'document',
            'Sec-Fetch-Mode': 'navigate',
            'Sec-Fetch-Site': 'none',
            'Sec-Fetch-User': '?1',
            'Referer': 'https://www.google.com/'
        }
    
    def clean_price(self, price_str):
        """Extract and clean price from string"""
        if not price_str:
            return None
        
        # Remove currency symbols, commas and whitespace
        cleaned = re.sub(r'[^\d.]', '', price_str)
        
        try:
            return float(cleaned)
        except ValueError:
            return None
    
    def scrape_ebay(self, product_name, max_items=15):
        """Scrape prices from eBay"""
        logger.info(f"Scraping eBay prices for: {product_name}")
        try:
            # Replace spaces with plus signs for URL
            search_term = product_name.replace(' ', '+')
            url = f"https://www.ebay.com/sch/i.html?_nkw={search_term}&_sacat=0"
            
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Target the search results
            items = soup.select('li.s-item')[:max_items]
            
            for item in items:
                # Get price
                price_elem = item.select_one('.s-item__price')
                
                if price_elem:
                    price_text = price_elem.text.strip()
                    
                    # Skip price ranges
                    if 'to' in price_text.lower():
                        continue
                        
                    price = self.clean_price(price_text)
                    if price:
                        self.prices['ebay'].append(price)
            
            logger.info(f"Found {len(self.prices['ebay'])} prices from eBay")
            
        except Exception as e:
            logger.error(f"Error scraping eBay: {e}")
    
    def scrape_amazon(self, product_name, max_items=15):
        """Scrape prices from Amazon"""
        logger.info(f"Scraping Amazon prices for: {product_name}")
        try:
            search_term = product_name.replace(' ', '+')
            url = f"https://www.amazon.com/s?k={search_term}"
            
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Amazon's price elements
            price_elements = soup.select('.a-price .a-offscreen')[:max_items]
            
            for price_elem in price_elements:
                price = self.clean_price(price_elem.text)
                if price:
                    self.prices['amazon'].append(price)
            
            logger.info(f"Found {len(self.prices['amazon'])} prices from Amazon")
            
        except Exception as e:
            logger.error(f"Error scraping Amazon: {e}")
    
    def scrape_newegg(self, product_name, max_items=15):
        """Scrape prices from Newegg"""
        logger.info(f"Scraping Newegg prices for: {product_name}")
        try:
            search_term = product_name.replace(' ', '+')
            url = f"https://www.newegg.com/p/pl?d={search_term}"
            
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Newegg's price elements
            items = soup.select('.item-cell')[:max_items]
            
            for item in items:
                price_elem = item.select_one('.price-current strong')
                if price_elem:
                    # Newegg splits price into dollars and cents
                    price_text = price_elem.text.strip()
                    cents_elem = item.select_one('.price-current sup')
                    if cents_elem:
                        price_text += cents_elem.text.strip()
                    
                    price = self.clean_price(price_text)
                    if price:
                        self.prices['newegg'].append(price)
            
            logger.info(f"Found {len(self.prices['newegg'])} prices from Newegg")
            
        except Exception as e:
            logger.error(f"Error scraping Newegg: {e}")
    
    def scrape_bestbuy(self, product_name, max_items=15):
        """Scrape prices from Best Buy"""
        logger.info(f"Scraping Best Buy prices for: {product_name}")
        try:
            search_term = product_name.replace(' ', '+')
            url = f"https://www.bestbuy.com/site/searchpage.jsp?st={search_term}"
            
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Best Buy's price elements
            price_elements = soup.select('.priceView-customer-price span')[:max_items]
            
            for price_elem in price_elements:
                price_text = price_elem.text.strip()
                price = self.clean_price(price_text)
                if price:
                    self.prices['bestbuy'].append(price)
            
            logger.info(f"Found {len(self.prices['bestbuy'])} prices from Best Buy")
            
        except Exception as e:
            logger.error(f"Error scraping Best Buy: {e}")
    
    def scrape_pcexpress(self, product_name, max_items=15):
        """Scrape prices from PC Express"""
        logger.info(f"Scraping PC Express prices for: {product_name}")
        try:
            search_term = product_name.replace(' ', '%10')
            url = f"https://pcx.com.ph/search?type=product&options%5Bunavailable_products%5D=hide&options%5Bprefix%5D=last&q={search_term}"
            
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # PC Express price elements
            product_items = soup.select('.product-tile')[:max_items]
            
            for item in product_items:
                price_elem = item.select_one('.price__amount')
                if price_elem:
                    price_text = price_elem.text.strip()
                    price = self.clean_price(price_text)
                    if price:
                        self.prices['pcexpress'].append(price)
            
            logger.info(f"Found {len(self.prices['pcexpress'])} prices from PC Express")
            
        except Exception as e:
            logger.error(f"Error scraping PC Express: {e}")
    
    def scrape_microcenter(self, product_name, max_items=15):
        """Scrape prices from Micro Center"""
        logger.info(f"Scraping Micro Center prices for: {product_name}")
        try:
            search_term = product_name.replace(' ', '+')
            url = f"https://www.microcenter.com/search/search_results.aspx?N=&cat=&Ntt={search_term}"
            
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Micro Center price elements
            product_items = soup.select('.product_wrapper')[:max_items]
            
            for item in product_items:
                price_elem = item.select_one('.price')
                if price_elem:
                    price_text = price_elem.text.strip()
                    price = self.clean_price(price_text)
                    if price:
                        self.prices['microcenter'].append(price)
            
            logger.info(f"Found {len(self.prices['microcenter'])} prices from Micro Center")
            
        except Exception as e:
            logger.error(f"Error scraping Micro Center: {e}")
    
    def scrape_bhphotovideo(self, product_name, max_items=15):
        """Scrape prices from B&H Photo Video"""
        logger.info(f"Scraping B&H Photo Video prices for: {product_name}")
        try:
            search_term = product_name.replace(' ', '+')
            url = f"https://www.bhphotovideo.com/c/search?q={search_term}"
            
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # B&H price elements
            product_items = soup.select('.productItem')[:max_items]
            
            for item in product_items:
                price_elem = item.select_one('.price')
                if price_elem:
                    price_text = price_elem.text.strip()
                    price = self.clean_price(price_text)
                    if price:
                        self.prices['bhphotovideo'].append(price)
            
            logger.info(f"Found {len(self.prices['bhphotovideo'])} prices from B&H Photo Video")
            
        except Exception as e:
            logger.error(f"Error scraping B&H Photo Video: {e}")
    
    def _get_product_hash(self, product_name):
        """Generate a consistent hash for the product name to use as identifier"""
        return hashlib.md5(product_name.lower().strip().encode()).hexdigest()
    
    def _check_price_history(self, product_name):
        """Check if we have cached results for this product"""
        product_id = self._get_product_hash(product_name)
        # Try to load from file if it exists
        try:
            with open(f"{product_id}_cache.json", "r") as f:
                cache_data = json.load(f)
                logger.info(f"Loaded cached data for {product_name}")
                return cache_data
        except (FileNotFoundError, json.JSONDecodeError):
            return None
    
    def _save_price_history(self, product_name, results):
        """Save the current price data to cache"""
        product_id = self._get_product_hash(product_name)
        try:
            # Add timestamp
            results["timestamp"] = time.time()
            with open(f"{product_id}_cache.json", "w") as f:
                json.dump(results, f)
            logger.info(f"Saved results to cache for {product_name}")
        except Exception as e:
            logger.error(f"Failed to save cache: {e}")
    
    def scrape_all(self, product_name):
        """Scrape prices from all sources in parallel"""
        logger.info(f"Starting price scraping for: {product_name}")
        
        # Check cache first - if recent results exist (< 24h), use them
        cached_data = self._check_price_history(product_name)
        if cached_data and (time.time() - cached_data.get("timestamp", 0)) < 86400:
            logger.info(f"Using cached data for {product_name}")
            return cached_data
        
        # Define scraping functions to run
        scrape_functions = [
            (self.scrape_ebay, product_name),
            (self.scrape_amazon, product_name),
            (self.scrape_newegg, product_name),
            (self.scrape_bestbuy, product_name),
            (self.scrape_pcexpress, product_name),
            (self.scrape_microcenter, product_name),
            (self.scrape_bhphotovideo, product_name)
        ]
        
        # Use ThreadPoolExecutor to run scraping functions in parallel
        with ThreadPoolExecutor(max_workers=10) as executor:
            futures = [executor.submit(func, arg) for func, arg in scrape_functions]
            for future in as_completed(futures):
                try:
                    future.result()
                except Exception as e:
                    logger.error(f"Error in thread: {e}")
        
        # Add delay between requests to avoid rate limiting
        time.sleep(random.uniform(1, 3))
        
        # Calculate statistics
        self.calculate_stats()
        
        # Calculate per-source suggested prices
        self.calculate_per_source_suggested_prices()
        
        results = {
            "summary": self.get_suggested_price(),
            "detailed": self.get_detailed_results()
        }
        
        # Save results to cache
        self._save_price_history(product_name, results)
        
        return results
    
    def calculate_stats(self):
        """Calculate statistics for the scraped prices"""
        # Combine all prices
        all_prices = []
        for source, prices in self.prices.items():
            if prices:
                all_prices.extend(prices)
        
        if not all_prices:
            logger.warning("No prices found to calculate statistics")
            return
        
        # Calculate statistics
        self.stats = {
            'count': len(all_prices),
            'min': min(all_prices),
            'max': max(all_prices),
            'mean': statistics.mean(all_prices),
            'median': statistics.median(all_prices)
        }
        
        # Calculate standard deviation if there are enough values
        if len(all_prices) > 1:
            self.stats['std_dev'] = statistics.stdev(all_prices)
        else:
            self.stats['std_dev'] = 0
            
        # Calculate per-source stats
        self.source_stats = {}
        for source, prices in self.prices.items():
            if prices:
                self.source_stats[source] = {
                    'count': len(prices),
                    'min': min(prices),
                    'max': max(prices),
                    'mean': statistics.mean(prices),
                    'median': statistics.median(prices)
                }
                if len(prices) > 1:
                    self.source_stats[source]['std_dev'] = statistics.stdev(prices)
                else:
                    self.source_stats[source]['std_dev'] = 0
    
    def calculate_per_source_suggested_prices(self):
        """Calculate suggested price for each source"""
        for source, prices in self.prices.items():
            if not prices:
                continue
                
            # Use at least 3 prices for filtering outliers
            if len(prices) >= 3:
                filtered_prices = self.filter_outliers(prices)
                if not filtered_prices:  # If all filtered out
                    filtered_prices = prices
            else:
                filtered_prices = prices
                
            # Calculate suggested price
            if len(filtered_prices) == 1:
                # If only one price, use it
                suggested_price = filtered_prices[0]
            else:
                # Weight factors - favor median for consistency, add some average to smooth
                median_weight = 0.7
                mean_weight = 0.3
                
                median_price = statistics.median(filtered_prices)
                mean_price = statistics.mean(filtered_prices)
                
                suggested_price = (median_price * median_weight) + (mean_price * mean_weight)
                
            # Add to source suggested prices dict
            self.source_suggested_prices[source] = round(suggested_price, 2)
    
    def filter_outliers(self, prices):
        """Filter out price outliers using IQR method"""
        if len(prices) < 4:  # Need enough data for quartiles
            return prices
            
        q1 = statistics.quantiles(prices, n=4)[0]
        q3 = statistics.quantiles(prices, n=4)[2]
        iqr = q3 - q1
        
        lower_bound = q1 - (1.5 * iqr)
        upper_bound = q3 + (1.5 * iqr)
        
        return [price for price in prices if lower_bound <= price <= upper_bound]
    
    def get_price_range_suggestion(self, min_price, max_price, suggested_price):
        """Calculate price range suggestions based on market segments"""
        # Determine price ranges for different market segments
        budget_max = min_price + (suggested_price - min_price) * 0.7
        premium_min = max_price - (max_price - suggested_price) * 0.7
        
        return {
            "budget": {
                "min": round(min_price, 2),
                "max": round(budget_max, 2)
            },
            "midrange": {
                "min": round(budget_max, 2),
                "max": round(premium_min, 2)
            },
            "premium": {
                "min": round(premium_min, 2),
                "max": round(max_price, 2)
            }
        }
    
    def get_suggested_price(self):
        """Calculate a weighted suggested price"""
        logger.info("Calculating suggested price...")
        
        # Flatten all prices into a single list
        all_prices = []
        for source, prices in self.prices.items():
            all_prices.extend(prices)
            
        if not all_prices:
            return {"error": "No prices found to calculate a suggested price"}
            
        # Remove outliers
        filtered_prices = self.filter_outliers(all_prices)
        
        if not filtered_prices:
            filtered_prices = all_prices  # Fallback if all filtered out
            
        # Calculate weighted average with more weight to specialized electronics retailers
        weights = []
        weighted_prices = []
        
        for source, prices in self.prices.items():
            filtered_source_prices = [p for p in prices if p in filtered_prices]
            if filtered_source_prices:
                # Assign weights based on source reliability for market prices
                if source in ['newegg', 'bestbuy', 'pcexpress', 'microcenter', 'bhphotovideo']:
                    source_weight = 2.5  # Higher weight for specialized electronics retailers
                elif source in ['ebay', 'amazon']:
                    source_weight = 2.0  # Good weight for marketplace sites
                else:
                    source_weight = 1.0
                    
                for price in filtered_source_prices:
                    weighted_prices.append(price)
                    weights.append(source_weight)
        
        if not weighted_prices:
            # Fallback to median of all prices
            suggested_price = statistics.median(all_prices)
        else:
            # Calculate weighted average
            suggested_price = sum(p * w for p, w in zip(weighted_prices, weights)) / sum(weights)
            
        # Round to 2 decimal places
        suggested_price = round(suggested_price, 2)
        
        # Get min and max prices after filtering outliers
        min_price = min(filtered_prices)
        max_price = max(filtered_prices)
        
        # Calculate price range suggestions
        price_ranges = self.get_price_range_suggestion(min_price, max_price, suggested_price)
        
        # Create summary dictionary
        summary = {
            "suggested_price": suggested_price,
            "total_prices_found": len(all_prices),
            "prices_after_filtering": len(filtered_prices),
            "price_range": {
                "min": min_price,
                "max": max_price
            },
            "suggested_ranges": price_ranges,
            "source_counts": {source: len(prices) for source, prices in self.prices.items() if prices},
            "source_suggested_prices": self.source_suggested_prices,  # Include per-source price suggestions
            "confidence": self._calculate_confidence()
        }
        
        logger.info(f"Suggested price: ${suggested_price}")
        return summary
    
    def get_detailed_results(self):
        """Get detailed results broken down by each source"""
        detailed_results = {}
        
        # Add source-specific statistics to the results
        for source, stats in self.source_stats.items():
            if stats['count'] > 0:
                detailed_results[source] = {
                    "count": stats['count'],
                    "min_price": round(stats['min'], 2),
                    "max_price": round(stats['max'], 2),
                    "avg_price": round(stats['mean'], 2),
                    "median_price": round(stats['median'], 2),
                    "std_deviation": round(stats['std_dev'], 2),
                    "suggested_price": self.source_suggested_prices.get(source, 0),  # Add suggested price for source
                    "prices": [round(price, 2) for price in self.prices[source]]
                }
        
        return detailed_results
    
    def _calculate_confidence(self):
        """Calculate confidence level in the suggested price"""
        # Count sources with data
        sources_with_data = sum(1 for prices in self.prices.values() if prices)
        
        # Count total prices
        total_prices = sum(len(prices) for prices in self.prices.values())
        
        # Enhanced confidence calculation with specialized retailers
        specialized_retailers = ['newegg', 'bestbuy', 'pcexpress', 'microcenter', 'bhphotovideo']
        specialized_sources_with_data = sum(1 for source in specialized_retailers if self.prices[source])
        
        if total_prices < 5 or sources_with_data < 2:
            return "Low"
        elif total_prices >= 15 and sources_with_data >= 4 and specialized_sources_with_data >= 2:
            return "High"
        else:
            return "Medium"   

def main():
    product_name = input("Enter the product name to search for: ")
    results = scrapeprice(product_name)
    
    # Visualize price distribution if matplotlib is available
    try:
        plt.figure(figsize=(10, 6))
        all_prices = []
        for source, data in results["detailed"].items():
            all_prices.extend(data["prices"])
        
        plt.hist(all_prices, bins=15, alpha=0.7)
        plt.axvline(results["summary"]["suggested_price"], color='r', linestyle='dashed', linewidth=2)
        plt.title(f"Price Distribution for {product_name}")
        plt.xlabel("Price ($)")
        plt.ylabel("Frequency")
        plt.grid(True, alpha=0.3)
        plt.savefig(f"{product_name.replace(' ', '_')}_price_distribution.png")
        print(f"\nPrice distribution chart saved as '{product_name.replace(' ', '_')}_price_distribution.png'")
        
        # Create per-source price comparison chart
        if results["summary"].get("source_suggested_prices"):
            plt.figure(figsize=(12, 6))
            sources = list(results["summary"]["source_suggested_prices"].keys())
            prices = list(results["summary"]["source_suggested_prices"].values())
            
            # Sort by price for better visualization
            sorted_data = sorted(zip(sources, prices), key=lambda x: x[1])
            sources = [x[0] for x in sorted_data]
            prices = [x[1] for x in sorted_data]
            
            plt.bar(sources, prices, color='skyblue')
            plt.axhline(results["summary"]["suggested_price"], color='r', linestyle='dashed', linewidth=2, 
                        label=f"Overall Suggested: ${results['summary']['suggested_price']}")
            
            plt.title(f"Suggested Price by Source for {product_name}")
            plt.xlabel("Source")
            plt.ylabel("Suggested Price ($)")
            plt.xticks(rotation=45)
            plt.legend()
            plt.tight_layout()
            plt.savefig(f"{product_name.replace(' ', '_')}_source_price_comparison.png")
            print(f"Source price comparison chart saved as '{product_name.replace(' ', '_')}_source_price_comparison.png'")
    except Exception as e:
        logger.warning(f"Could not generate price visualization: {e}")

def scrapeprice(product_name):
    scraper = PriceScraper()
    results = scraper.scrape_all(product_name)
    
    summary = results["summary"]
    detailed = results["detailed"]
    
    print("\n===== PRICE ANALYSIS RESULTS =====")
    print(f"Product: {product_name}")
    print(f"Suggested Price: ${summary['suggested_price']}")
    print(f"Confidence: {summary['confidence']}")
    print(f"Price Range: ${summary['price_range']['min']} - ${summary['price_range']['max']}")
    print(f"Total Prices Found: {summary['total_prices_found']}")
    
    # Display suggested prices by source
    if "source_suggested_prices" in summary:
        print("\n===== SUGGESTED PRICES BY SOURCE =====")
        for source, price in summary["source_suggested_prices"].items():
            print(f"{source.upper()}: ${price}")
    
    # Display price range suggestions
    if "suggested_ranges" in summary:
        print("\n===== PRICE RANGE SUGGESTIONS =====")
        ranges = summary["suggested_ranges"]
        print(f"Budget Range: ${ranges['budget']['min']} - ${ranges['budget']['max']}")
        print(f"Mid-Range: ${ranges['midrange']['min']} - ${ranges['midrange']['max']}")
        print(f"Premium Range: ${ranges['premium']['min']} - ${ranges['premium']['max']}")
    
    # Display detailed results by source
    print("\n===== DETAILED RESULTS BY SOURCE =====")
    for source, data in detailed.items():
        print(f"\n{source.upper()} (Count: {data['count']})")
        print(f"  Suggested Price: ${data['suggested_price']}")
        print(f"  Price Range: ${data['min_price']} - ${data['max_price']}")
        print(f"  Average Price: ${data['avg_price']}")
        print(f"  Median Price: ${data['median_price']}")
        print(f"  Standard Deviation: ${data['std_deviation']}")
        print(f"  Individual Prices: {', '.join(['$' + str(p) for p in data['prices']])}")
    
    # Return all the results
    return {
        "summary": summary,
        "detailed": detailed
    }

    
if __name__ == "__main__":
    main()