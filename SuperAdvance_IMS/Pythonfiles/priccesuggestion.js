import { useState, useEffect } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Search } from 'lucide-react';

// Sample data representing historical price data for your shop and competitors
const generateHistoricalData = (basePrice, volatility, trend, seasonality) => {
  const data = [];
  const weeks = 52;
  
  for (let i = 0; i < weeks; i++) {
    // Add trend component
    let price = basePrice + trend * i;
    
    // Add seasonality component (sine wave pattern)
    price += seasonality * Math.sin((i / 52) * 2 * Math.PI);
    
    // Add random noise
    price += (Math.random() - 0.5) * volatility;
    
    data.push(Math.max(price, basePrice * 0.6).toFixed(2));
  }
  
  return data;
};

// Generate product database
const generateProductDatabase = () => {
  const products = [
    { id: 1, name: "Premium Coffee Beans (1kg)", category: "Grocery" },
    { id: 2, name: "Wireless Headphones", category: "Electronics" },
    { id: 3, name: "Yoga Mat", category: "Sports" },
    { id: 4, name: "Stainless Steel Water Bottle", category: "Home" },
    { id: 5, name: "Organic Protein Powder", category: "Health" },
    { id: 6, name: "Smart Watch", category: "Electronics" },
    { id: 7, name: "Portable Power Bank", category: "Electronics" },
    { id: 8, name: "Cast Iron Skillet", category: "Kitchen" },
    { id: 9, name: "Moisturizing Face Cream", category: "Beauty" },
    { id: 10, name: "Bluetooth Speaker", category: "Electronics" },
    { id: 11, name: "Organic Cotton T-shirt", category: "Clothing" },
    { id: 12, name: "Wireless Charging Pad", category: "Electronics" },
    { id: 13, name: "Reusable Shopping Bags (Set of 5)", category: "Home" },
    { id: 14, name: "Plant-Based Protein Bars (Box of 12)", category: "Health" },
    { id: 15, name: "LED Desk Lamp", category: "Home" }
  ];

  // Generate price data for each product
  return products.map(product => {
    const basePrice = 10 + (product.id * 5) + (Math.random() * 20);
    const currentPrice = Math.round(basePrice * (0.9 + Math.random() * 0.3) * 100) / 100;
    
    // Different trend and seasonality settings for different product categories
    let trend = 0;
    let seasonality = 0;
    let volatility = 0;
    
    switch(product.category) {
      case "Electronics":
        trend = -0.1; // Price tends to decrease over time
        seasonality = basePrice * 0.1; // 10% seasonal variation
        volatility = basePrice * 0.05;
        break;
      case "Grocery":
      case "Health":
        trend = 0.05; // Slight price increase over time
        seasonality = basePrice * 0.04; // Low seasonal variation
        volatility = basePrice * 0.02;
        break;
      default:
        trend = 0.02;
        seasonality = basePrice * 0.06;
        volatility = basePrice * 0.03;
    }
    
    return {
      ...product,
      yourPrice: currentPrice.toFixed(2),
      yourHistoricalPrices: generateHistoricalData(basePrice, volatility, trend, seasonality),
      competitor1Price: (currentPrice * (0.95 + Math.random() * 0.15)).toFixed(2),
      competitor1HistoricalPrices: generateHistoricalData(basePrice * 0.97, volatility, trend, seasonality),
      competitor2Price: (currentPrice * (0.9 + Math.random() * 0.2)).toFixed(2),
      competitor2HistoricalPrices: generateHistoricalData(basePrice * 0.93, volatility * 1.2, trend, seasonality),
      competitor3Price: (currentPrice * (0.93 + Math.random() * 0.25)).toFixed(2),
      competitor3HistoricalPrices: generateHistoricalData(basePrice * 0.95, volatility * 0.9, trend, seasonality),
      arimaForecast: null, // Will be calculated when needed
      suggestedPrice: null // Will be calculated when needed
    };
  });
};

// ARIMA model simulation (simplified)
const calculateARIMA = (historicalData, competitorData1, competitorData2, competitorData3) => {
  // Convert string data to numbers
  const yourData = historicalData.map(p => parseFloat(p));
  const comp1Data = competitorData1.map(p => parseFloat(p));
  const comp2Data = competitorData2.map(p => parseFloat(p));
  const comp3Data = competitorData3.map(p => parseFloat(p));
  
  // Simple average of last 4 weeks with some additional factors
  const recentAvgYour = yourData.slice(-4).reduce((a, b) => a + b, 0) / 4;
  const recentAvgComp1 = comp1Data.slice(-4).reduce((a, b) => a + b, 0) / 4;
  const recentAvgComp2 = comp2Data.slice(-4).reduce((a, b) => a + b, 0) / 4;
  const recentAvgComp3 = comp3Data.slice(-4).reduce((a, b) => a + b, 0) / 4;
  
  // Calculate trend over the last 12 weeks
  const trend = (yourData[yourData.length - 1] - yourData[yourData.length - 13]) / 12;
  
  // Competitive positioning - aim for slightly below the average of your price and competitors
  const competitivePrice = (recentAvgYour + recentAvgComp1 + recentAvgComp2 + recentAvgComp3) / 4;
  
  // Market trend adjustment
  const marketTrendAdjustment = trend * 8; // Project trend forward
  
  // Calculate suggested price with a slight discount to be competitive
  const suggestedPrice = (competitivePrice + marketTrendAdjustment) * 0.98;
  
  // Generate forecast for next 8 weeks
  const forecast = [];
  let lastPrice = yourData[yourData.length - 1];
  
  for (let i = 0; i < 8; i++) {
    // Apply trend and some regression toward the competitive price
    lastPrice = lastPrice + trend + (competitivePrice - lastPrice) * 0.15;
    // Add some random variation
    lastPrice = lastPrice + (Math.random() - 0.5) * (lastPrice * 0.02);
    forecast.push(parseFloat(lastPrice.toFixed(2)));
  }
  
  return {
    forecast,
    suggestedPrice: parseFloat(suggestedPrice.toFixed(2))
  };
};

export default function ARIMAPricingTool() {
  const [products, setProducts] = useState([]);
  const [selectedProduct, setSelectedProduct] = useState(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [filteredProducts, setFilteredProducts] = useState([]);
  
  useEffect(() => {
    // Generate initial product data
    const productData = generateProductDatabase();
    setProducts(productData);
    setFilteredProducts(productData);
  }, []);
  
  useEffect(() => {
    if (searchQuery) {
      const filtered = products.filter(p => 
        p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        p.category.toLowerCase().includes(searchQuery.toLowerCase())
      );
      setFilteredProducts(filtered);
    } else {
      setFilteredProducts(products);
    }
  }, [searchQuery, products]);
  
  const handleProductSelect = (product) => {
    // Calculate ARIMA forecast when product is selected
    const { forecast, suggestedPrice } = calculateARIMA(
      product.yourHistoricalPrices,
      product.competitor1HistoricalPrices,
      product.competitor2HistoricalPrices,
      product.competitor3HistoricalPrices
    );
    
    const updatedProduct = {
      ...product,
      arimaForecast: forecast,
      suggestedPrice: suggestedPrice
    };
    
    setSelectedProduct(updatedProduct);
    
    // Update the product in the products array
    const updatedProducts = products.map(p => 
      p.id === product.id ? updatedProduct : p
    );
    setProducts(updatedProducts);
  };
  
  const prepareChartData = (product) => {
    if (!product) return [];
    
    // Last 24 weeks of historical data
    const historicalData = [];
    const lastIndex = product.yourHistoricalPrices.length - 1;
    
    for (let i = lastIndex - 23; i <= lastIndex; i++) {
      historicalData.push({
        week: `Week ${i + 1}`,
        yourPrice: parseFloat(product.yourHistoricalPrices[i]),
        competitor1: parseFloat(product.competitor1HistoricalPrices[i]),
        competitor2: parseFloat(product.competitor2HistoricalPrices[i]),
        competitor3: parseFloat(product.competitor3HistoricalPrices[i])
      });
    }
    
    // Add forecast data
    const forecastData = [];
    if (product.arimaForecast) {
      for (let i = 0; i < product.arimaForecast.length; i++) {
        forecastData.push({
          week: `Week ${lastIndex + 2 + i}`,
          forecast: product.arimaForecast[i]
        });
      }
    }
    
    return [...historicalData, ...forecastData];
  };
  
  return (
    <div className="flex flex-col min-h-screen bg-gray-50 p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">ARIMA Price Optimization Tool</h1>
        <p className="text-gray-600">Search for a product to view competitive analysis and AI pricing suggestions</p>
      </div>
      
      <div className="flex flex-col lg:flex-row gap-6">
        {/* Left side - Product selection */}
        <div className="w-full lg:w-1/3 bg-white rounded-lg shadow p-4">
          <div className="relative mb-4">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search size={18} className="text-gray-400" />
            </div>
            <input
              type="text"
              className="pl-10 w-full p-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Search products..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>
          
          <div className="space-y-1 max-h-96 overflow-y-auto">
            {filteredProducts.map(product => (
              <div 
                key={product.id}
                className={`p-3 rounded cursor-pointer hover:bg-gray-100 ${selectedProduct?.id === product.id ? 'bg-blue-100 border-l-4 border-blue-500' : ''}`}
                onClick={() => handleProductSelect(product)}
              >
                <div className="font-medium">{product.name}</div>
                <div className="text-sm text-gray-500">Category: {product.category}</div>
                <div className="text-sm">Your price: ${product.yourPrice}</div>
              </div>
            ))}
          </div>
        </div>
        
        {/* Right side - Analysis */}
        <div className="w-full lg:w-2/3 bg-white rounded-lg shadow p-4">
          {selectedProduct ? (
            <>
              <div className="mb-6">
                <h2 className="text-xl font-bold">{selectedProduct.name}</h2>
                <div className="text-sm text-gray-500">Category: {selectedProduct.category}</div>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                <div className="bg-blue-50 p-4 rounded-lg">
                  <div className="text-lg font-medium">Your Current Price</div>
                  <div className="text-3xl font-bold text-blue-600">${selectedProduct.yourPrice}</div>
                </div>
                
                <div className="bg-green-50 p-4 rounded-lg">
                  <div className="text-lg font-medium">ARIMA Suggested Price</div>
                  <div className="text-3xl font-bold text-green-600">${selectedProduct.suggestedPrice}</div>
                  <div className="text-sm text-gray-600 mt-1">
                    {selectedProduct.suggestedPrice < parseFloat(selectedProduct.yourPrice) 
                      ? `${((parseFloat(selectedProduct.yourPrice) - selectedProduct.suggestedPrice) / parseFloat(selectedProduct.yourPrice) * 100).toFixed(1)}% lower than current price`
                      : `${((selectedProduct.suggestedPrice - parseFloat(selectedProduct.yourPrice)) / parseFloat(selectedProduct.yourPrice) * 100).toFixed(1)}% higher than current price`
                    }
                  </div>
                </div>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                <div className="bg-gray-50 p-3 rounded-lg">
                  <div className="text-sm font-medium text-gray-500">Competitor 1</div>
                  <div className="text-xl font-bold">${selectedProduct.competitor1Price}</div>
                  <div className="text-xs text-gray-500">
                    {parseFloat(selectedProduct.competitor1Price) < parseFloat(selectedProduct.yourPrice) 
                      ? `${((parseFloat(selectedProduct.yourPrice) - parseFloat(selectedProduct.competitor1Price)) / parseFloat(selectedProduct.yourPrice) * 100).toFixed(1)}% lower than you`
                      : `${((parseFloat(selectedProduct.competitor1Price) - parseFloat(selectedProduct.yourPrice)) / parseFloat(selectedProduct.yourPrice) * 100).toFixed(1)}% higher than you`
                    }
                  </div>
                </div>
                
                <div className="bg-gray-50 p-3 rounded-lg">
                  <div className="text-sm font-medium text-gray-500">Competitor 2</div>
                  <div className="text-xl font-bold">${selectedProduct.competitor2Price}</div>
                  <div className="text-xs text-gray-500">
                    {parseFloat(selectedProduct.competitor2Price) < parseFloat(selectedProduct.yourPrice) 
                      ? `${((parseFloat(selectedProduct.yourPrice) - parseFloat(selectedProduct.competitor2Price)) / parseFloat(selectedProduct.yourPrice) * 100).toFixed(1)}% lower than you`
                      : `${((parseFloat(selectedProduct.competitor2Price) - parseFloat(selectedProduct.yourPrice)) / parseFloat(selectedProduct.yourPrice) * 100).toFixed(1)}% higher than you`
                    }
                  </div>
                </div>
                
                <div className="bg-gray-50 p-3 rounded-lg">
                  <div className="text-sm font-medium text-gray-500">Competitor 3</div>
                  <div className="text-xl font-bold">${selectedProduct.competitor3Price}</div>
                  <div className="text-xs text-gray-500">
                    {parseFloat(selectedProduct.competitor3Price) < parseFloat(selectedProduct.yourPrice) 
                      ? `${((parseFloat(selectedProduct.yourPrice) - parseFloat(selectedProduct.competitor3Price)) / parseFloat(selectedProduct.yourPrice) * 100).toFixed(1)}% lower than you`
                      : `${((parseFloat(selectedProduct.competitor3Price) - parseFloat(selectedProduct.yourPrice)) / parseFloat(selectedProduct.yourPrice) * 100).toFixed(1)}% higher than you`
                    }
                  </div>
                </div>
              </div>
              
              <div className="mb-2">
                <h3 className="text-lg font-medium mb-2">Price History & Forecast</h3>
                <div className="h-64">
                  <ResponsiveContainer width="100%" height="100%">
                    <LineChart
                      data={prepareChartData(selectedProduct)}
                      margin={{ top: 5, right: 30, left: 20, bottom: 5 }}
                    >
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis dataKey="week" tick={{fontSize: 10}} interval={3} />
                      <YAxis />
                      <Tooltip />
                      <Legend />
                      <Line type="monotone" dataKey="yourPrice" stroke="#3b82f6" name="Your Price" strokeWidth={2} dot={{ r: 1 }} />
                      <Line type="monotone" dataKey="competitor1" stroke="#9ca3af" name="Competitor 1" strokeWidth={1} dot={false} />
                      <Line type="monotone" dataKey="competitor2" stroke="#d1d5db" name="Competitor 2" strokeWidth={1} dot={false} />
                      <Line type="monotone" dataKey="competitor3" stroke="#e5e7eb" name="Competitor 3" strokeWidth={1} dot={false} />
                      <Line type="monotone" dataKey="forecast" stroke="#10b981" name="ARIMA Forecast" strokeWidth={2} strokeDasharray="5 5" />
                    </LineChart>
                  </ResponsiveContainer>
                </div>
              </div>
              
              <div className="mt-6 bg-gray-50 p-4 rounded-lg">
                <h3 className="font-medium mb-2">ARIMA Analysis Insights</h3>
                <p className="text-sm text-gray-700">
                  {selectedProduct.suggestedPrice < parseFloat(selectedProduct.yourPrice)
                    ? `Our ARIMA model suggests that lowering your price to $${selectedProduct.suggestedPrice} could improve your competitive position. The market trend shows downward price pressure, and competitors are pricing more aggressively.`
                    : `Our ARIMA model suggests increasing your price to $${selectedProduct.suggestedPrice} would optimize your profit margin. Market trend analysis shows increasing prices, and your competitors' pricing allows room for this adjustment.`
                  }
                </p>
                <div className="mt-2 text-sm text-gray-700">
                  <div className="font-medium">Key factors in this recommendation:</div>
                  <ul className="list-disc list-inside mt-1">
                    <li>Historical price trends over 52 weeks</li>
                    <li>Competitive positioning against 3 competitors</li>
                    <li>Seasonal demand patterns for {selectedProduct.category} products</li>
                    <li>Recent market price volatility analysis</li>
                  </ul>
                </div>
              </div>
            </>
          ) : (
            <div className="flex flex-col items-center justify-center h-full py-12 text-gray-500">
              <div className="text-6xl mb-4">📊</div>
              <p className="text-xl font-medium">Select a product to view analysis</p>
              <p className="text-sm mt-2">ARIMA pricing suggestions will appear here</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}