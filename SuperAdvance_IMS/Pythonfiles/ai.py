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

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class PriceScraper:
    def __init__(self):
        self.ua = UserAgent()
        # Add more retailers to the prices dictionary
        self.prices = {
            'ebay': [],
            'amazon': [],
            'bestbuy': [],
            'newegg': [],
            'target': [],
            'walmart': [],
            'costco': [],
            'bhphotovideo': [],
            'adorama': [],
            'microcenter': []
        }
        self.stats = {}
        self.source_stats = {}
        
    def get_random_headers(self):
        """Generate random headers to avoid detection"""
        return {
            'User-Agent': self.ua.random,
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
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
    
    def scrape_amazon(self, product_name, max_items=10):
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
    
    def scrape_bestbuy(self, product_name, max_items=10):
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
                if '$' in price_text:  # Ensure it's a price
                    price = self.clean_price(price_text)
                    if price:
                        self.prices['bestbuy'].append(price)
            
            logger.info(f"Found {len(self.prices['bestbuy'])} prices from Best Buy")
            
        except Exception as e:
            logger.error(f"Error scraping Best Buy: {e}")

    def scrape_newegg(self, product_name, max_items=10):
        """Scrape prices from Newegg"""
        logger.info(f"Scraping Newegg prices for: {product_name}")
        try:
            search_term = product_name.replace(' ', '+')
            url = f"https://www.newegg.com/p/pl?d={search_term}"
            
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Newegg's price elements
            price_elements = soup.select('.price-current strong, .price-current sup')[:max_items]
            
            current_price = None
            for i, elem in enumerate(price_elements):
                if i % 2 == 0:  # Main price
                    current_price = self.clean_price(elem.text)
                else:  # Cents
                    if current_price:
                        cents = self.clean_price(elem.text) / 100
                        self.prices['newegg'].append(current_price + cents)
                        current_price = None
            
            logger.info(f"Found {len(self.prices['newegg'])} prices from Newegg")
            
        except Exception as e:
            logger.error(f"Error scraping Newegg: {e}")

    def scrape_target(self, product_name, max_items=10):
        """Scrape prices from Target"""
        logger.info(f"Scraping Target prices for: {product_name}")
        try:
            search_term = product_name.replace(' ', '+')
            url = f"https://www.target.com/s?searchTerm={search_term}"
            
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Target's price elements
            price_elements = soup.select('[data-test="product-price"]')[:max_items]
            
            for price_elem in price_elements:
                price = self.clean_price(price_elem.text)
                if price:
                    self.prices['target'].append(price)
            
            logger.info(f"Found {len(self.prices['target'])} prices from Target")
            
        except Exception as e:
            logger.error(f"Error scraping Target: {e}")

    def scrape_walmart(self, product_name, max_items=10):
        """Scrape prices from Walmart"""
        logger.info(f"Scraping Walmart prices for: {product_name}")
        try:
            search_term = product_name.replace(' ', '+')
            url = f"https://www.walmart.com/search?q={search_term}"
            
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Walmart price elements
            price_elements = soup.select('span.price-main')[:max_items]
            
            for price_elem in price_elements:
                price_text = price_elem.text.strip()
                price = self.clean_price(price_text)
                if price:
                    self.prices['walmart'].append(price)
            
            logger.info(f"Found {len(self.prices['walmart'])} prices from Walmart")
            
        except Exception as e:
            logger.error(f"Error scraping Walmart: {e}")

    def scrape_costco(self, product_name, max_items=10):
        """Scrape prices from Costco"""
        logger.info(f"Scraping Costco prices for: {product_name}")
        try:
            search_term = product_name.replace(' ', '+')
            url = f"https://www.costco.com/CatalogSearch?keyword={search_term}"
            
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Costco price elements
            price_elements = soup.select('.product-price .price')[:max_items]
            
            for price_elem in price_elements:
                price_text = price_elem.text.strip()
                price = self.clean_price(price_text)
                if price:
                    self.prices['costco'].append(price)
            
            logger.info(f"Found {len(self.prices['costco'])} prices from Costco")
            
        except Exception as e:
            logger.error(f"Error scraping Costco: {e}")

    def scrape_bhphotovideo(self, product_name, max_items=10):
        """Scrape prices from B&H Photo Video"""
        logger.info(f"Scraping B&H Photo Video prices for: {product_name}")
        try:
            search_term = product_name.replace(' ', '+')
            url = f"https://www.bhphotovideo.com/c/search?q={search_term}"
            
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # B&H price elements
            price_elements = soup.select('.price')[:max_items]
            
            for price_elem in price_elements:
                price_text = price_elem.text.strip()
                price = self.clean_price(price_text)
                if price:
                    self.prices['bhphotovideo'].append(price)
            
            logger.info(f"Found {len(self.prices['bhphotovideo'])} prices from B&H Photo Video")
            
        except Exception as e:
            logger.error(f"Error scraping B&H Photo Video: {e}")

    def scrape_adorama(self, product_name, max_items=10):
        """Scrape prices from Adorama"""
        logger.info(f"Scraping Adorama prices for: {product_name}")
        try:
            search_term = product_name.replace(' ', '-')
            url = f"https://www.adorama.com/l/?searchinfo={search_term}"
            
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Adorama price elements
            price_elements = soup.select('.price')[:max_items]
            
            for price_elem in price_elements:
                price_text = price_elem.text.strip()
                price = self.clean_price(price_text)
                if price:
                    self.prices['adorama'].append(price)
            
            logger.info(f"Found {len(self.prices['adorama'])} prices from Adorama")
            
        except Exception as e:
            logger.error(f"Error scraping Adorama: {e}")

    def scrape_microcenter(self, product_name, max_items=10):
        """Scrape prices from Micro Center"""
        logger.info(f"Scraping Micro Center prices for: {product_name}")
        try:
            search_term = product_name.replace(' ', '+')
            url = f"https://www.microcenter.com/search/search_results.aspx?N=&cat=&Ntt={search_term}"
            
            response = requests.get(url, headers=self.get_random_headers(), timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Micro Center price elements
            price_elements = soup.select('.price')[:max_items]
            
            for price_elem in price_elements:
                price_text = price_elem.text.strip()
                price = self.clean_price(price_text)
                if price:
                    self.prices['microcenter'].append(price)
            
            logger.info(f"Found {len(self.prices['microcenter'])} prices from Micro Center")
            
        except Exception as e:
            logger.error(f"Error scraping Micro Center: {e}")

    def scrape_all(self, product_name):
        """Scrape prices from all sources in parallel"""
        logger.info(f"Starting price scraping for: {product_name}")
        
        # Define scraping functions to run
        scrape_functions = [
            (self.scrape_ebay, product_name),
            (self.scrape_amazon, product_name),
            (self.scrape_bestbuy, product_name),
            (self.scrape_newegg, product_name),
            (self.scrape_target, product_name),
            (self.scrape_walmart, product_name),
            (self.scrape_costco, product_name),
            (self.scrape_bhphotovideo, product_name),
            (self.scrape_adorama, product_name),
            (self.scrape_microcenter, product_name)
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
        
        return {
            "summary": self.get_suggested_price(),
            "detailed": self.get_detailed_results()
        }
    
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
            
        # Calculate weighted average with more weight to marketplace sites
        weights = []
        weighted_prices = []
        
        for source, prices in self.prices.items():
            filtered_source_prices = [p for p in prices if p in filtered_prices]
            if filtered_source_prices:
                # Assign weights based on source reliability for market prices
                if source in ['ebay', 'amazon', 'walmart']:
                    source_weight = 2.0  # Higher weight for marketplace sites
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
        
        # Create summary dictionary
        summary = {
            "suggested_price": suggested_price,
            "total_prices_found": len(all_prices),
            "prices_after_filtering": len(filtered_prices),
            "price_range": {
                "min": min(filtered_prices),
                "max": max(filtered_prices)
            },
            "source_counts": {source: len(prices) for source, prices in self.prices.items() if prices},
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
                    "prices": [round(price, 2) for price in self.prices[source]]
                }
        
        return detailed_results
    
    def _calculate_confidence(self):
        """Calculate confidence level in the suggested price"""
        # Count sources with data
        sources_with_data = sum(1 for prices in self.prices.values() if prices)
        
        # Count total prices
        total_prices = sum(len(prices) for prices in self.prices.values())
        
        if total_prices < 3 or sources_with_data < 2:
            return "Low"
        elif total_prices >= 10 and sources_with_data >= 3:
            return "High"
        else:
            return "Medium"
    
    def generate_price_chart(self, product_name, output_file="price_comparison.png"):
        """Generate a visual chart comparing prices across sources"""
        # Collect data for chart
        sources = []
        medians = []
        mins = []
        maxes = []
        
        for source, stats in self.source_stats.items():
            if stats['count'] > 0:
                sources.append(source.capitalize())
                medians.append(stats['median'])
                mins.append(stats['min'])
                maxes.append(stats['max'])
        
        if not sources:
            logger.warning("No data available to generate chart")
            return False
            
        # Create figure and axis
        fig, ax = plt.figure(figsize=(10, 6)), plt.gca()
        
        # Plot median prices as bars
        x = range(len(sources))
        bars = ax.bar(x, medians, color='skyblue', label='Median Price')
        
        # Add error bars for min/max
        error_bars = [
            [m - min_val for m, min_val in zip(medians, mins)],  # lower errors
            [max_val - m for m, max_val in zip(medians, maxes)]   # upper errors
        ]
        ax.errorbar(x, medians, yerr=error_bars, fmt='none', ecolor='black', capsize=5)
        
        # Add price labels on top of bars
        for bar, price in zip(bars, medians):
            height = bar.get_height()
            ax.text(bar.get_x() + bar.get_width()/2., height + 1,
                    f'${price:.2f}', ha='center', va='bottom', rotation=0)
        
        # Add overall suggested price line
        if hasattr(self, 'stats') and 'mean' in self.stats:
            suggested_price = self.get_suggested_price()["suggested_price"]
            ax.axhline(y=suggested_price, color='red', linestyle='-', label=f'Suggested: ${suggested_price:.2f}')
        
        # Customize chart
        ax.set_title(f'Price Comparison for {product_name}')
        ax.set_xlabel('Source')
        ax.set_ylabel('Price ($)')
        ax.set_xticks(x)
        ax.set_xticklabels(sources, rotation=45, ha='right')
        ax.legend()
        plt.tight_layout()
        
        # Save chart
        plt.savefig(output_file)
        logger.info(f"Price comparison chart saved to {output_file}")
        plt.close()
        
        return True
    
    def save_results_to_csv(self, product_name, output_file="price_results.csv"):
        """Save detailed results to CSV file"""
        # Create DataFrame with all prices
        data = []
        
        for source, prices in self.prices.items():
            for price in prices:
                data.append({
                    "Product": product_name,
                    "Source": source,
                    "Price": price
                })
        
        if data:
            df = pd.DataFrame(data)
            df.to_csv(output_file, index=False)
            logger.info(f"Results saved to {output_file}")
            
    def save_detailed_results_to_json(self, product_name, output_file="detailed_results.json"):
        """Save detailed results to JSON file"""
        results = {
            "product": product_name,
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "summary": self.get_suggested_price(),
            "detailed": self.get_detailed_results()
        }
        
        with open(output_file, 'w') as f:
            json.dump(results, f, indent=4)
            
        logger.info(f"Detailed results saved to {output_file}")

def main():
    product_name = input("Enter the product name to search for: ")
    
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
    
    # Display detailed results by source
    print("\n===== DETAILED RESULTS BY SOURCE =====")
    for source, data in detailed.items():
        print(f"\n{source.upper()} (Count: {data['count']})")
        print(f"  Price Range: ${data['min_price']} - ${data['max_price']}")
        print(f"  Average Price: ${data['avg_price']}")
        print(f"  Median Price: ${data['median_price']}")
        print(f"  Standard Deviation: ${data['std_deviation']}")
        print(f"  Individual Prices: {', '.join(['$' + str(p) for p in data['prices']])}")
    
    # Generate price comparison chart
    chart_option = input("\nDo you want to generate a price comparison chart? (y/n): ")
    if chart_option.lower() == 'y':
        scraper.generate_price_chart(product_name)
    
    # Save options
    save_option = input("\nDo you want to save results? (c=CSV, j=JSON, b=Both, n=None): ")
    if save_option.lower() == 'c' or save_option.lower() == 'b':
        scraper.save_results_to_csv(product_name)
    if save_option.lower() == 'j' or save_option.lower() == 'b':
        scraper.save_detailed_results_to_json(product_name)

if __name__ == "__main__":
    main()