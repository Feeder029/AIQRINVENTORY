import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from statsmodels.tsa.arima.model import ARIMA
from statsmodels.tsa.stattools import adfuller
from statsmodels.graphics.tsaplots import plot_acf, plot_pacf
import warnings
warnings.filterwarnings('ignore')

# Function to create sample historical price data
def generate_price_data(base_price, periods=52, trend=0.05, seasonality=2.0, noise_level=1.0):
    """Generate synthetic price data with trend, seasonality and noise"""
    # Time index
    time_idx = np.arange(periods)
    
    # Trend component
    trend_component = base_price + trend * time_idx
    
    # Seasonality component (using sine wave with annual cycle)
    seasonality_component = seasonality * np.sin(2 * np.pi * time_idx / 52)
    
    # Random noise
    noise = np.random.normal(0, noise_level, periods)
    
    # Combine components
    prices = trend_component + seasonality_component + noise
    
    # Ensure no negative prices
    prices = np.maximum(prices, base_price * 0.7)
    
    # Create time series with weekly frequency
    dates = pd.date_range(start='2024-05-01', periods=periods, freq='W')
    return pd.Series(prices, index=dates)

# Create sample product database
def create_product_database():
    """Create sample product database with your prices and competitor prices"""
    products = [
        {"id": 1, "name": "Premium Coffee Beans (1kg)", "category": "Grocery", "base_price": 24.99},
        {"id": 2, "name": "Wireless Headphones", "category": "Electronics", "base_price": 89.99},
        {"id": 3, "name": "Yoga Mat", "category": "Sports", "base_price": 35.50},
        {"id": 4, "name": "Stainless Steel Water Bottle", "category": "Home", "base_price": 22.95},
        {"id": 5, "name": "Organic Protein Powder", "category": "Health", "base_price": 42.99},
    ]
    
    product_data = {}
    
    for product in products:
        # Set different trend and seasonality parameters based on product category
        if product["category"] == "Electronics":
            trend = -0.1  # Price decreases over time
            seasonality = product["base_price"] * 0.06
            noise = product["base_price"] * 0.03
        elif product["category"] in ["Grocery", "Health"]:
            trend = 0.05  # Price increases over time
            seasonality = product["base_price"] * 0.03
            noise = product["base_price"] * 0.02
        else:
            trend = 0.02
            seasonality = product["base_price"] * 0.04
            noise = product["base_price"] * 0.025
            
        # Generate your shop's price history
        your_prices = generate_price_data(
            product["base_price"], 
            trend=trend,
            seasonality=seasonality,
            noise_level=noise
        )
        
        # Generate competitor price histories with variations
        competitor1_prices = generate_price_data(
            product["base_price"] * 0.97,  # Slightly lower base price
            trend=trend * 0.9,
            seasonality=seasonality * 1.1,
            noise_level=noise * 1.2
        )
        
        competitor2_prices = generate_price_data(
            product["base_price"] * 1.03,  # Slightly higher base price
            trend=trend * 1.1,
            seasonality=seasonality * 0.9,
            noise_level=noise * 0.8
        )
        
        competitor3_prices = generate_price_data(
            product["base_price"] * 0.95,  # Lower base price
            trend=trend * 1.2,
            seasonality=seasonality * 1.3,
            noise_level=noise * 1.5
        )
        
        # Store all price data for this product
        product_data[product["name"]] = {
            "id": product["id"],
            "category": product["category"],
            "your_prices": your_prices,
            "competitor1_prices": competitor1_prices,
            "competitor2_prices": competitor2_prices,
            "competitor3_prices": competitor3_prices,
            "current_prices": {
                "your_price": round(float(your_prices.iloc[-1]), 2),
                "competitor1_price": round(float(competitor1_prices.iloc[-1]), 2),
                "competitor2_price": round(float(competitor2_prices.iloc[-1]), 2),
                "competitor3_price": round(float(competitor3_prices.iloc[-1]), 2)
            }
        }
    
    return product_data

# Check if price data is stationary (required for ARIMA modeling)
def check_stationarity(price_series):
    """Test for stationarity using Augmented Dickey-Fuller test"""
    result = adfuller(price_series)
    
    print(f'ADF Statistic: {result[0]:.4f}')
    print(f'p-value: {result[1]:.4f}')
    print('Critical Values:')
    for key, value in result[4].items():
        print(f'\t{key}: {value:.4f}')
    
    # If p-value is less than 0.05, data is stationary
    is_stationary = result[1] < 0.05
    print(f'Series is {"stationary" if is_stationary else "non-stationary"}')
    
    return is_stationary

# Function to determine optimal order of differencing (d parameter)
def find_optimal_d(series):
    """Find optimal order of differencing for ARIMA model"""
    d = 0
    while d < 2:  # Limit to maximum of second-order differencing
        result = adfuller(series)
        if result[1] < 0.05:  # Check if p-value indicates stationarity
            break
        else:
            # Apply differencing and check again
            series = series.diff().dropna()
            d += 1
    
    return d

# Function to identify optimal p and q parameters using ACF and PACF plots
def plot_acf_pacf(series, lags=40):
    """Plot ACF and PACF to identify potential p and q parameters"""
    plt.figure(figsize=(12, 6))
    
    plt.subplot(211)
    plot_acf(series, ax=plt.gca(), lags=lags)
    plt.title('Autocorrelation Function (ACF)')
    
    plt.subplot(212)
    plot_pacf(series, ax=plt.gca(), lags=lags)
    plt.title('Partial Autocorrelation Function (PACF)')
    
    plt.tight_layout()
    plt.show()

# Function to fit ARIMA model and forecast future prices
def fit_arima_model(price_series, product_name, p=1, d=1, q=1, forecast_periods=8):
    """
    Fit ARIMA model to price data and generate forecasts
    
    Parameters:
    - price_series: Time series of historical prices
    - product_name: Name of the product
    - p: AR order
    - d: Differencing order
    - q: MA order
    - forecast_periods: Number of periods to forecast
    
    Returns:
    - Forecast results
    """
    # Check if we need to determine optimal d
    if d is None:
        d = find_optimal_d(price_series)
        print(f"Optimal order of differencing (d): {d}")
    
    # Fit ARIMA model
    model = ARIMA(price_series, order=(p, d, q))
    results = model.fit()
    
    # Print model summary
    print(f"\nARIMA Model Summary for {product_name}:")
    print(results.summary().tables[1])
    
    # Generate forecast
    forecast = results.forecast(steps=forecast_periods)
    forecast_index = pd.date_range(
        start=price_series.index[-1] + pd.Timedelta('1 week'), 
        periods=forecast_periods, 
        freq='W'
    )
    forecast.index = forecast_index
    
    return results, forecast

# Function to calculate optimal price based on ARIMA forecasts and competitor data
def calculate_optimal_price(your_forecast, competitor_forecasts, current_prices):
    """
    Calculate optimal price based on ARIMA forecasts and competitor prices
    
    Parameters:
    - your_forecast: ARIMA forecast for your prices
    - competitor_forecasts: Dict of competitor ARIMA forecasts
    - current_prices: Dict of current prices for you and competitors
    
    Returns:
    - Optimal price recommendation and justification
    """
    # Get forecasted prices for next week
    your_next_price = your_forecast[0]
    competitor_next_prices = [f[0] for f in competitor_forecasts.values()]
    
    # Calculate market average price (forecasted)
    market_avg_forecast = np.mean([your_next_price] + competitor_next_prices)
    
    # Calculate current market average
    current_market_avg = np.mean([
        current_prices["your_price"],
        current_prices["competitor1_price"],
        current_prices["competitor2_price"],
        current_prices["competitor3_price"]
    ])
    
    # Calculate price trend
    price_trend = market_avg_forecast - current_market_avg
    
    # Calculate price elasticity factor (simplified)
    # Assume higher elasticity for higher-priced items
    if current_prices["your_price"] > 50:
        elasticity_factor = 0.8  # More elastic (price sensitive)
    else:
        elasticity_factor = 0.9  # Less elastic
    
    # Calculate competitive position
    # If your price is significantly higher than competitors, be more aggressive
    your_premium = current_prices["your_price"] / np.mean([
        current_prices["competitor1_price"],
        current_prices["competitor2_price"],
        current_prices["competitor3_price"]
    ])
    
    competitive_factor = 1.0
    if your_premium > 1.1:  # You're more than 10% more expensive
        competitive_factor = 0.95
    elif your_premium < 0.9:  # You're more than 10% cheaper
        competitive_factor = 1.03
    
    # Calculate suggested price
    suggested_price = your_next_price * elasticity_factor * competitive_factor
    
    # Round to two decimal places
    suggested_price = round(suggested_price, 2)
    
    # Generate justification
    if suggested_price < current_prices["your_price"]:
        change_pct = ((current_prices["your_price"] - suggested_price) / 
                      current_prices["your_price"] * 100)
        justification = (
            f"Recommendation: Decrease price by {change_pct:.1f}% to ${suggested_price}. "
            f"Market forecast shows a {'downward' if price_trend < 0 else 'slowing'} trend. "
            f"Your current price is {(your_premium - 1) * 100:.1f}% above competitor average."
        )
    else:
        change_pct = ((suggested_price - current_prices["your_price"]) / 
                     current_prices["your_price"] * 100)
        justification = (
            f"Recommendation: Increase price by {change_pct:.1f}% to ${suggested_price}. "
            f"Market forecast shows an {'upward' if price_trend > 0 else 'accelerating'} trend. "
            f"Your current price is {(1 - your_premium) * 100:.1f}% below competitor average."
        )
    
    return suggested_price, justification

# Function to plot price history and forecast
def plot_price_analysis(product_data, your_forecast, competitor_forecasts):
    """Plot historical prices and forecasts"""
    plt.figure(figsize=(12, 8))
    
    # Plot historical data
    plt.plot(product_data["your_prices"].index, product_data["your_prices"].values, 
             'b-', label='Your Price')
    plt.plot(product_data["competitor1_prices"].index, product_data["competitor1_prices"].values, 
             'g-', alpha=0.6, label='Competitor 1')
    plt.plot(product_data["competitor2_prices"].index, product_data["competitor2_prices"].values, 
             'r-', alpha=0.6, label='Competitor 2')
    plt.plot(product_data["competitor3_prices"].index, product_data["competitor3_prices"].values, 
             'c-', alpha=0.6, label='Competitor 3')
    
    # Plot forecasts
    forecast_start = product_data["your_prices"].index[-1]
    plt.plot(your_forecast.index, your_forecast.values, 'b--', linewidth=2, label='Your Forecast')
    for i, (comp_name, comp_forecast) in enumerate(competitor_forecasts.items()):
        color = ['g', 'r', 'c'][i]
        plt.plot(comp_forecast.index, comp_forecast.values, f'{color}--', alpha=0.6, 
                 label=f'{comp_name} Forecast')
    
    # Add current price markers
    plt.plot(product_data["your_prices"].index[-1], product_data["your_prices"].iloc[-1], 
             'bo', markersize=8)
    plt.plot(product_data["competitor1_prices"].index[-1], product_data["competitor1_prices"].iloc[-1], 
             'go', markersize=6)
    plt.plot(product_data["competitor2_prices"].index[-1], product_data["competitor2_prices"].iloc[-1], 
             'ro', markersize=6)
    plt.plot(product_data["competitor3_prices"].index[-1], product_data["competitor3_prices"].iloc[-1], 
             'co', markersize=6)
    
    # Format plot
    plt.grid(True, alpha=0.3)
    plt.title(f'Price History and ARIMA Forecast Analysis', fontsize=16)
    plt.xlabel('Date', fontsize=12)
    plt.ylabel('Price ($)', fontsize=12)
    plt.legend(loc='best')
    
    # Shade forecast area
    plt.axvspan(forecast_start, your_forecast.index[-1], color='gray', alpha=0.1)
    
    plt.tight_layout()
    plt.show()

# Main function to run the price optimization analysis
def analyze_product_pricing(product_name, arima_order=(1,1,1)):
    """Run complete price optimization analysis for a specific product"""
    print(f"\n{'='*80}")
    print(f"ARIMA PRICE OPTIMIZATION ANALYSIS FOR: {product_name}")
    print(f"{'='*80}\n")
    
    # Get product data
    product_data = product_database.get(product_name)
    if not product_data:
        print(f"Product '{product_name}' not found in database.")
        return
    
    print(f"Category: {product_data['category']}")
    print("\nCURRENT MARKET PRICES:")
    print(f"Your price: ${product_data['current_prices']['your_price']}")
    print(f"Competitor 1: ${product_data['current_prices']['competitor1_price']}")
    print(f"Competitor 2: ${product_data['current_prices']['competitor2_price']}")
    print(f"Competitor 3: ${product_data['current_prices']['competitor3_price']}")
    
    print("\nSTATIONARITY CHECK:")
    is_stationary = check_stationarity(product_data["your_prices"])
    
    # If non-stationary, we'll check if 1st order differencing makes it stationary
    if not is_stationary:
        print("\nChecking stationarity after differencing:")
        differenced = product_data["your_prices"].diff().dropna()
        check_stationarity(differenced)
    
    # Fit ARIMA model for your prices
    p, d, q = arima_order
    your_model, your_forecast = fit_arima_model(
        product_data["your_prices"],
        product_name,
        p=p, d=d, q=q
    )
    
    # Fit ARIMA models for competitor prices
    competitor_models = {}
    competitor_forecasts = {}
    
    for i, comp_name in enumerate(["competitor1", "competitor2", "competitor3"]):
        print(f"\nFitting ARIMA model for {comp_name}:")
        comp_model, comp_forecast = fit_arima_model(
            product_data[f"{comp_name}_prices"],
            f"{comp_name}",
            p=p, d=d, q=q
        )
        competitor_models[comp_name] = comp_model
        competitor_forecasts[comp_name] = comp_forecast
    
    # Calculate optimal price
    suggested_price, justification = calculate_optimal_price(
        your_forecast,
        competitor_forecasts,
        product_data["current_prices"]
    )
    
    print("\n" + "="*80)
    print("PRICE OPTIMIZATION RESULTS:")
    print("="*80)
    print(f"Current price: ${product_data['current_prices']['your_price']}")
    print(f"ARIMA suggested price: ${suggested_price}")
    price_diff = suggested_price - product_data['current_prices']['your_price']
    print(f"Price change: ${price_diff:.2f} ({(price_diff/product_data['current_prices']['your_price'])*100:.1f}%)")
    print("\nJUSTIFICATION:")
    print(justification)
    
    # Plot results
    plot_price_analysis(product_data, your_forecast, competitor_forecasts)
    
    return suggested_price, justification

# Generate the product database
print("Generating product database with historical price data...")
product_database = create_product_database()

# Display available products
print("\nAvailable products for analysis:")
for i, product_name in enumerate(product_database.keys(), 1):
    print(f"{i}. {product_name}")

print("\nRunning analysis on sample product: Wireless Headphones")
analyze_product_pricing("Wireless Headphones")

# Interactive product selection
def interactive_product_analysis():
    """Allow user to select products for analysis"""
    while True:
        print("\n" + "="*80)
        print("ARIMA PRICE OPTIMIZATION TOOL")
        print("="*80)
        print("\nAvailable products:")
        for i, product_name in enumerate(product_database.keys(), 1):
            print(f"{i}. {product_name}")
        
        try:
            choice = input("\nEnter product number to analyze (or 'q' to quit): ")
            if choice.lower() == 'q':
                break
            
            product_idx = int(choice) - 1
            if 0 <= product_idx < len(product_database):
                product_name = list(product_database.keys())[product_idx]
                analyze_product_pricing(product_name)
            else:
                print("Invalid product number. Please try again.")
        except ValueError:
            print("Please enter a valid number or 'q' to quit.")

# Enable this line to run interactive mode
# interactive_product_analysis()

# Example output for specific products
print("\nAnalyzing Organic Protein Powder...")
analyze_product_pricing("Organic Protein Powder")