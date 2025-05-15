import requests
from bs4 import BeautifulSoup
import re
import statistics
import time
import random
import pandas as pd
import numpy as np
from fake_useragent import UserAgent
import logging
import json
import hashlib
import http.client
import urllib.parse
from statsmodels.tsa.arima.model import ARIMA
from datetime import datetime, timedelta
from concurrent.futures import ThreadPoolExecutor, as_completed
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import cloudscraper  # For bypassing Cloudflare protection

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class PriceScraper:
    def __init__(self):
        self.ua = UserAgent()
        # Updated list of sources - removed bonanza, craigslist, wish and added walmart
        self.prices = {'ebay': [], 'amazon': [], 'microcenter': [], 'walmart': []}
        self.stats = {}
        self.source_stats = {}
        self.source_suggested_prices = {}
        self.price_history = {}
        self.arima_predictions = {}
        self.selenium_driver = None
        self.cloudscraper = cloudscraper.create_scraper(
            browser={
                'browser': 'chrome',
                'platform': 'windows',
                'mobile': False
            },
            delay=10
        )
        
    def initialize_selenium(self):
        """Initialize Selenium WebDriver for JavaScript rendering"""
        if self.selenium_driver is None:
            try:
                chrome_options = Options()
                chrome_options.add_argument("--headless")
                chrome_options.add_argument("--no-sandbox")
                chrome_options.add_argument("--disable-dev-shm-usage")
                chrome_options.add_argument(f"user-agent={self.ua.random}")
                chrome_options.add_argument("--disable-blink-features=AutomationControlled")
                chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
                chrome_options.add_experimental_option('useAutomationExtension', False)
                
                service = Service(ChromeDriverManager().install())
                self.selenium_driver = webdriver.Chrome(service=service, options=chrome_options)
                
                # Execute CDP commands to prevent detection
                self.selenium_driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", {
                    "source": """
                        Object.defineProperty(navigator, 'webdriver', {
                            get: () => undefined
                        });
                    """
                })
                
                logger.info("Selenium WebDriver initialized successfully")
            except Exception as e:
                logger.error(f"Failed to initialize Selenium WebDriver: {e}")
    
    def close_selenium(self):
        """Close Selenium WebDriver"""
        if self.selenium_driver:
            self.selenium_driver.quit()
            self.selenium_driver = None
    
    def get_headers(self):
        """Generate random headers to avoid detection"""
        return {
            'User-Agent': self.ua.random,
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Referer': 'https://www.google.com/',
            'DNT': '1',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'Cache-Control': 'max-age=0',
            'TE': 'Trailers'
        }
    
    def clean_price(self, price_str):
        """Extract and clean price from string"""
        if not price_str:
            return None
        cleaned = re.sub(r'[^\d.]', '', price_str)
        try:
            return float(cleaned)
        except ValueError:
            return None
    
    def random_delay(self, min_seconds=1, max_seconds=3):
        """Add random delay to avoid detection"""
        delay = random.uniform(min_seconds, max_seconds)
        time.sleep(delay)
        return delay
    
    def scrape_site(self, site, product_name, max_items=20):
        """Generic scraping function that calls the appropriate site-specific method"""
        scrape_methods = {
            'ebay': self._scrape_ebay,
            'amazon': self._scrape_amazon,
            'microcenter': self._scrape_microcenter,
            'walmart': self._scrape_walmart
        }
        
        if site in scrape_methods:
            return scrape_methods[site](product_name, max_items)
        return []
    
    def _scrape_ebay(self, product_name, max_items=20):
        """Scrape prices from eBay using CloudScraper"""
        try:
            search_term = product_name.replace(' ', '+')
            url = f"https://www.ebay.com/sch/i.html?_nkw={search_term}&_sacat=0"
            
            # Use cloudscraper instead of regular requests
            response = self.cloudscraper.get(url, headers=self.get_headers())
            
            if response.status_code != 200:
                logger.error(f"Failed to fetch eBay data: Status code {response.status_code}")
                return
                
            soup = BeautifulSoup(response.text, 'html.parser')
            items = soup.select('li.s-item')[:max_items]
            
            for item in items:
                price_elem = item.select_one('.s-item__price')
                if price_elem:
                    price_text = price_elem.text.strip()
                    if 'to' not in price_text.lower():
                        price = self.clean_price(price_text)
                        if price:
                            self.prices['ebay'].append(price)
            
            logger.info(f"Found {len(self.prices['ebay'])} prices from eBay")
            
        except Exception as e:
            logger.error(f"Error scraping eBay: {e}")
        
        self.random_delay()
    
    def _scrape_amazon(self, product_name, max_items=20):
        """Scrape prices from Amazon using Selenium for better anti-bot bypass"""
        try:
            self.initialize_selenium()
            if not self.selenium_driver:
                logger.error("Selenium WebDriver not available for Amazon scraping")
                return
                
            search_term = product_name.replace(' ', '+')
            url = f"https://www.amazon.com/s?k={search_term}"
            
            self.selenium_driver.get(url)
            
            # Wait for price elements to load
            WebDriverWait(self.selenium_driver, 10).until(
                EC.presence_of_element_located((By.CSS_SELECTOR, ".a-price"))
            )
            
            # Extract prices
            price_elements = self.selenium_driver.find_elements(By.CSS_SELECTOR, '.a-price .a-offscreen')[:max_items]
            
            for price_elem in price_elements:
                price = self.clean_price(price_elem.get_attribute('innerHTML'))
                if price:
                    self.prices['amazon'].append(price)
            
            logger.info(f"Found {len(self.prices['amazon'])} prices from Amazon")
            
        except Exception as e:
            logger.error(f"Error scraping Amazon: {e}")
            
        self.random_delay(3, 6)
    
    def _scrape_microcenter(self, product_name, max_items=20):
        """Scrape prices from Micro Center"""
        try:
            search_term = product_name.replace(' ', '+')
            url = f"https://www.microcenter.com/search/search_results.aspx?N=&cat=&Ntt={search_term}"
            
            response = requests.get(url, headers=self.get_headers(), timeout=15)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            product_items = soup.select('.product_wrapper')[:max_items]
            
            for item in product_items:
                price_elem = item.select_one('.price')
                if price_elem:
                    price = self.clean_price(price_elem.text.strip())
                    if price:
                        self.prices['microcenter'].append(price)
            
            logger.info(f"Found {len(self.prices['microcenter'])} prices from Micro Center")
            
        except Exception as e:
            logger.error(f"Error scraping Micro Center: {e}")
            
        self.random_delay()
    
    def _scrape_walmart(self, product_name, max_items=20):
        """Scrape prices from Walmart using RapidAPI"""
        try:
            logger.info(f"Fetching Walmart prices via API for: {product_name}")
            
            # Encode the search keyword for URL
            encoded_keyword = urllib.parse.quote(product_name)
            
            # Set up the connection
            conn = http.client.HTTPSConnection("realtime-walmart-data.p.rapidapi.com")
            
            # API headers
            headers = {
                'x-rapidapi-key': "ab5b55870bmshc0edfa2e68cff61p1ed139jsn3221542aadd0",
                'x-rapidapi-host': "realtime-walmart-data.p.rapidapi.com"
            }
            
            # Make the request
            conn.request("GET", f"/search?keyword={encoded_keyword}&sort=best_match", headers=headers)
            
            # Get the response
            res = conn.getresponse()
            data = res.read()
            
            # Parse the JSON data
            json_data = json.loads(data.decode("utf-8"))
            
            # Check if the request was successful
            if json_data.get("status") == "success" and "results" in json_data:
                # Extract product prices
                count = 0
                for product in json_data["results"]:
                    if count >= max_items:
                        break
                        
                    if "price" in product:
                        price_text = str(product["price"])
                        price = self.clean_price(price_text)
                        if price:
                            self.prices['walmart'].append(price)
                            count += 1
                
                logger.info(f"Found {len(self.prices['walmart'])} prices from Walmart API")
            else:
                logger.error(f"Walmart API error: {json_data.get('message', 'Unknown error')}")
                
        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON data from Walmart API: {e}")
        except KeyError as e:
            logger.error(f"Missing key in Walmart API data: {e}")
        except Exception as e:
            logger.error(f"Error accessing Walmart API: {e}")
            
        self.random_delay(2, 4)
    
    def _get_product_hash(self, product_name):
        """Generate a consistent hash for the product name"""
        return hashlib.md5(product_name.lower().strip().encode()).hexdigest()
    
    def _check_cache(self, product_name):
        """Check if we have cached results for this product"""
        product_id = self._get_product_hash(product_name)
        try:
            with open(f"SuperAdvance_IMS/Pythonfiles/cacheitems/{product_id}_cache.json", "r") as f:
                return json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            return None
    
    def _load_history(self, product_name):
        """Load historical price data"""
        product_id = self._get_product_hash(product_name)
        try:
            with open(f"SuperAdvance_IMS/Pythonfiles/cacheitems/{product_id}_history.json", "r") as f:
                return json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            # Create synthetic history if none exists
            today = datetime.now()
            return [{"date": (today - timedelta(days=i)).strftime("%Y-%m-%d"), "price": None} 
                   for i in range(30, 0, -1)]
    
    def _save_cache(self, product_name, results):
        """Save the current price data to cache"""
        product_id = self._get_product_hash(product_name)
        try:
            results["timestamp"] = time.time()
            with open(f"SuperAdvance_IMS/Pythonfiles/cacheitems/{product_id}_cache.json", "w") as f:
                json.dump(results, f)
            
            # Update historical data
            self._update_history(product_id, results["summary"]["suggested_price"])
        except Exception as e:
            logger.error(f"Failed to save cache: {e}")
    
    def _update_history(self, product_id, current_price):
        """Update historical price data with current price"""
        try:
            try:
                with open(f"SuperAdvance_IMS/Pythonfiles/cacheitems/{product_id}_history.json", "r") as f:
                    history_data = json.load(f)
            except (FileNotFoundError, json.JSONDecodeError):
                history_data = []
                
            today = datetime.now().strftime("%Y-%m-%d")
            
            # Update or add today's entry
            today_exists = False
            for entry in history_data:
                if entry.get("date") == today:
                    entry["price"] = current_price
                    today_exists = True
                    break
                    
            if not today_exists:
                history_data.append({"date": today, "price": current_price})
                
            # Keep only the most recent 30 entries
            if len(history_data) > 30:
                history_data = sorted(history_data, key=lambda x: x["date"])[-30:]
                
            with open(f"SuperAdvance_IMS/Pythonfiles/cacheitems/{product_id}_history.json", "w") as f:
                json.dump(history_data, f)
                
        except Exception as e:
            logger.error(f"Failed to update historical data: {e}")
    
    def scrape_all(self, product_name):
        """Scrape prices from all sources"""
        logger.info(f"Starting price scraping for: {product_name}")
        
        # Check cache first
        cached_data = self._check_cache(product_name)
        if cached_data and (time.time() - cached_data.get("timestamp", 0)) < 86400:
            logger.info(f"Using cached data for {product_name}")
            return cached_data
        
        # Define sites to scrape - updated list
        sites = ['ebay', 'amazon', 'microcenter', 'walmart']
        
        try:
            # Initialize Selenium for Amazon
            self.initialize_selenium()
            
            # Use ThreadPoolExecutor for parallel scraping
            with ThreadPoolExecutor(max_workers=len(sites)) as executor:
                futures = [executor.submit(self.scrape_site, site, product_name) for site in sites]
                for future in as_completed(futures):
                    future.result()
            
            # Calculate statistics and predictions
            self.calculate_stats()
            self.calculate_source_prices()
            self.perform_arima(product_name)
            
            results = {
                "summary": self.get_suggested_price(),
                "detailed": self.get_detailed_results(),
                "arima": self.arima_predictions
            }
            
            # Save results to cache
            self._save_cache(product_name, results)
            
            # Clean up Selenium
            self.close_selenium()
            
            return results
            
        except Exception as e:
            logger.error(f"Error in scrape_all: {e}")
            self.close_selenium()
            return {"error": str(e)}
    
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
        
        # Calculate overall statistics
        self.stats = {
            'count': len(all_prices),
            'min': min(all_prices),
            'max': max(all_prices),
            'mean': statistics.mean(all_prices),
            'median': statistics.median(all_prices),
            'std_dev': statistics.stdev(all_prices) if len(all_prices) > 1 else 0
        }
            
        # Calculate per-source stats
        for source, prices in self.prices.items():
            if prices:
                self.source_stats[source] = {
                    'count': len(prices),
                    'min': min(prices),
                    'max': max(prices),
                    'mean': statistics.mean(prices),
                    'median': statistics.median(prices),
                    'std_dev': statistics.stdev(prices) if len(prices) > 1 else 0
                }
    
    def calculate_source_prices(self):
        """Calculate suggested price for each source"""
        for source, prices in self.prices.items():
            if not prices:
                continue
                
            # Filter outliers if enough data
            filtered_prices = self.filter_outliers(prices) if len(prices) >= 3 else prices
            if not filtered_prices:
                filtered_prices = prices
                
            # Calculate suggested price
            if len(filtered_prices) == 1:
                suggested_price = filtered_prices[0]
            else:
                # Weighted calculation
                median_price = statistics.median(filtered_prices)
                mean_price = statistics.mean(filtered_prices)
                suggested_price = (median_price * 0.7) + (mean_price * 0.3)
                
            self.source_suggested_prices[source] = round(suggested_price, 2)
    
    def perform_arima(self, product_name):
        """Perform ARIMA analysis for price prediction"""
        try:
            # Load historical data
            historical_data = self._load_history(product_name)
            
            if not self.stats:
                logger.warning("No price statistics available for ARIMA analysis")
                return
                
            current_price = self.stats['median']
            
            # Check if we have real history or need to generate synthetic data
            has_real_history = any(entry["price"] is not None for entry in historical_data)
                
            if not has_real_history:
                # Generate synthetic price history
                base_price = current_price
                for i, entry in enumerate(historical_data):
                    day_factor = i / len(historical_data)
                    seasonal_factor = 0.02 * np.sin(i * (2 * np.pi / 7))
                    random_factor = 0.05 * (random.random() - 0.5)
                    synthetic_price = base_price * (1 + day_factor * 0.03 + seasonal_factor + random_factor)
                    entry["price"] = round(synthetic_price, 2)
            
            # Create time series for ARIMA
            dates = [entry["date"] for entry in historical_data]
            prices = [entry["price"] for entry in historical_data]
            
            # Add current price
            today = datetime.now().strftime("%Y-%m-%d")
            if today not in dates:
                dates.append(today)
                prices.append(current_price)
            
            # Create pandas series
            price_series = pd.Series(prices, index=pd.DatetimeIndex(dates))
            
            # Fit ARIMA model
            model = ARIMA(price_series, order=(1, 1, 0))
            model_fit = model.fit()
            
            # Forecast next 7 days
            forecast_steps = 7
            forecast = model_fit.forecast(steps=forecast_steps)
            
            # Prepare forecast results
            forecast_dates = [(datetime.now() + timedelta(days=i+1)).strftime("%Y-%m-%d") 
                             for i in range(forecast_steps)]
            forecast_values = [round(val, 2) for val in forecast.values]
            
            # Store predictions
            self.arima_predictions = {
                "forecast_dates": forecast_dates,
                "forecast_values": forecast_values,
                "historical_dates": dates,
                "historical_prices": prices
            }
            
            # Calculate price trends
            if len(forecast_values) >= 2:
                price_trend = (forecast_values[-1] - forecast_values[0]) / forecast_values[0] * 100
                
                self.arima_predictions["price_trend"] = {
                    "percentage": round(price_trend, 2),
                    "direction": "up" if price_trend > 0 else "down" if price_trend < 0 else "stable"
                }
                
                # Get recommendation
                if price_trend > 1:
                    recommendation = "Buy now before prices increase further"
                elif price_trend < -1:
                    min_price_index = forecast_values.index(min(forecast_values))
                    best_date = forecast_dates[min_price_index]
                    recommendation = f"Wait until {best_date} for lowest price"
                else:
                    recommendation = "Price is stable, buy when convenient"
                    
                self.arima_predictions["recommendation"] = recommendation
            
        except Exception as e:
            logger.error(f"Error in ARIMA analysis: {e}")
            self.arima_predictions = {"error": f"ARIMA analysis failed: {str(e)}"}
    
    def filter_outliers(self, prices):
        """Filter out price outliers using IQR method"""
        if len(prices) < 4:
            return prices
            
        q1 = statistics.quantiles(prices, n=4)[0]
        q3 = statistics.quantiles(prices, n=4)[2]
        iqr = q3 - q1
        
        lower_bound = q1 - (1.5 * iqr)
        upper_bound = q3 + (1.5 * iqr)
        
        return [price for price in prices if lower_bound <= price <= upper_bound]
    
    def get_price_ranges(self, min_price, max_price, suggested_price):
        """Calculate price range suggestions"""
        budget_max = min_price + (suggested_price - min_price) * 0.7
        premium_min = max_price - (max_price - suggested_price) * 0.7
        
        return {
            "budget": {"min": round(min_price, 2), "max": round(budget_max, 2)},
            "midrange": {"min": round(budget_max, 2), "max": round(premium_min, 2)},
            "premium": {"min": round(premium_min, 2), "max": round(max_price, 2)}
        }
    
    def get_suggested_price(self):
        """Calculate a weighted suggested price"""
        # Flatten all prices
        all_prices = []
        for prices in self.prices.values():
            all_prices.extend(prices)
            
        if not all_prices:
            return {"error": "No prices found to calculate a suggested price"}
            
        # Remove outliers
        filtered_prices = self.filter_outliers(all_prices) or all_prices
            
        # Calculate weighted average
        weights = []
        weighted_prices = []
        
        for source, prices in self.prices.items():
            filtered_source_prices = [p for p in prices if p in filtered_prices]
            if filtered_source_prices:
                # Assign weights based on source - updated for new list
                source_weight = 2.5 if source == 'microcenter' else \
                               2.0 if source in ['ebay', 'amazon'] else \
                               1.8 if source == 'walmart' else 1.0
                    
                for price in filtered_source_prices:
                    weighted_prices.append(price)
                    weights.append(source_weight)
        
        # Calculate final price
        if not weighted_prices:
            suggested_price = statistics.median(all_prices)
        else:
            suggested_price = sum(p * w for p, w in zip(weighted_prices, weights)) / sum(weights)
            
        suggested_price = round(suggested_price, 2)
        
        # Get min and max prices
        min_price = min(filtered_prices)
        max_price = max(filtered_prices)
        
        # Calculate price ranges
        price_ranges = self.get_price_ranges(min_price, max_price, suggested_price)
        
        # ARIMA adjustments
        arima_adjustments = None
        if self.arima_predictions and "forecast_values" in self.arima_predictions:
            forecast_prices = self.arima_predictions["forecast_values"]
            if forecast_prices:
                avg_forecast = sum(forecast_prices) / len(forecast_prices)
                arima_adjusted_price = (suggested_price * 0.7) + (avg_forecast * 0.3)
                
                arima_adjustments = {
                    "arima_adjusted_price": round(arima_adjusted_price, 2),
                    "forecast_range": {
                        "min": min(forecast_prices),
                        "max": max(forecast_prices)
                    },
                    "forecast_avg": round(avg_forecast, 2)
                }
        
        # Create summary
        return {
            "suggested_price": suggested_price,
            "total_prices_found": len(all_prices),
            "prices_after_filtering": len(filtered_prices),
            "price_range": {"min": min_price, "max": max_price},
            "suggested_ranges": price_ranges,
            "source_counts": {source: len(prices) for source, prices in self.prices.items() if prices},
            "source_suggested_prices": self.source_suggested_prices,
            "confidence": self._calculate_confidence(),
            "arima_adjustments": arima_adjustments
        }
    
    def get_detailed_results(self):
        """Get detailed results by source"""
        detailed_results = {}
        
        for source, stats in self.source_stats.items():
            if stats['count'] > 0:
                detailed_results[source] = {
                    "count": stats['count'],
                    "min_price": round(stats['min'], 2),
                    "max_price": round(stats['max'], 2),
                    "avg_price": round(stats['mean'], 2),
                    "median_price": round(stats['median'], 2),
                    "std_deviation": round(stats['std_dev'], 2),
                    "suggested_price": self.source_suggested_prices.get(source, 0),
                    "prices": [round(price, 2) for price in self.prices[source]]
                }
        
        return detailed_results
    
    def _calculate_confidence(self):
        """Calculate confidence level in the suggested price"""
        sources_with_data = sum(1 for prices in self.prices.values() if prices)
        total_prices = sum(len(prices) for prices in self.prices.values())
        
        # Update specialized sources for new list
        specialized_sources = sum(1 for source in ['microcenter', 'walmart'] if self.prices[source])
        
        if total_prices < 5 or sources_with_data < 2:
            return "Low"
        elif total_prices >= 20 and sources_with_data >= 3 and specialized_sources >= 1:
            return "High"
        else:
            return "Medium"

def scrapeprice(product_name):
    """Main function to scrape prices and display results"""
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
    
    return {"summary": summary, "detailed": detailed}

def main():
    product_name = input("Enter the product name to search for: ")
    scrapeprice(product_name)

if __name__ == "__main__":
    main()