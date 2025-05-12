
import { fetchData } from '../Function/getdata.js';

function displayItems() {
    fetchData("displayitems",data=>{
        let display = ``;

        if(data.items && data.items.length > 0) {
            data.items.forEach(item => {

                console.log("Data: " +item.I_ImagePath)
                // Process the image path if it exists
                let imagePath = item.I_ImagePath;
                

                
                // Fall back to placeholder if no valid image path
                const imageDisplay = imagePath ? 
                    `<img src="${imagePath}" alt="${item.I_Name}" onerror="this.onerror=null; this.src='./assets/placeholder.jpg';">` : 
                    `<div class="placeholder-text">Product Image</div>`;
                
                display += `
                    <div class="item-container">
                        <div class="item-image">
                            ${imageDisplay}
                        </div>
                        <div class="item-details">
                            <h2>${item.I_Name}</h2>
                            <p>Price: <span>${item.I_UnitPrice}</span></p>
                            <p>Stocks: <span>${item.I_Stock}</span></p>
                        </div>
                        <div class="item-icons">
                            <details class="warning">
                                <summary><i class="fa-solid fa-triangle-exclamation"></i></summary>
                                <div class="warning-details">
                                    <div class="details">
                                        <h2>WARNING!</h2>
                                        <p>Your price is currently underprice based on data.</p>
                                    </div>
                                    <div class="warning-buttons">
                                        <button id="ignore">Ignore</button>
                                        <button id="seemore">See More</button>
                                    </div>
                                </div>
                            </details>
                            <details class="dropdown">
                                <summary><i class='bx bx-dots-horizontal-rounded'></i></summary>
                                <div class="dropdown-menu">
                                    <div class="dropdown-option"><i class="fa-solid fa-eye"></i> View More</div>
                                    <div class="separator">&nbsp;</div>
                                    <div class="dropdown-option"><i class="fa-solid fa-pen-to-square"></i> Edit</div>
                                    <div class="separator">&nbsp;</div>
                                    <div class="dropdown-option"><i class="fa-solid fa-trash"></i> Delete</div>
                                    <div class="separator">&nbsp;</div>
                                    <div class="dropdown-option"><i class="fa-solid fa-square-plus"></i> Add Quantity</div>
                                </div>
                            </details>
                        </div>
                    </div>
                `;
            });

            document.getElementById('items_display').innerHTML = display;
        } else {
            console.log("No items found");
            display = "<p>No items found in inventory</p>";
        }
    })
}

window.SaveItems = SaveItems;
window.Next = Next;

function SaveItems() {
    // Get file input element
    const fileInput = document.getElementById('Item-Img');
    
    // Check if a file was selected
    if (fileInput.files && fileInput.files[0]) {
        const file = fileInput.files[0];
        const reader = new FileReader();
        
        reader.onload = function(event) {
            // The base64 string represents the LONGBLOB data
            const base64String = event.target.result;
            
            // Create the item data object with the base64 image data
            const itemData = {
                Name: document.getElementById('ProductName').value,
                Desc: document.getElementById('Description').value,
                Quantity: parseInt(document.getElementById('Quantity').value),
                UnitPrice: parseFloat(document.getElementById('UnitPrice').value),
                Discount: parseFloat(document.getElementById('Discount').value),
                Img: base64String // This will be the LONGBLOB data as a base64 string
            };
            
            // Ask for confirmation before submitting
            Swal.fire({
                title: 'Are you sure?',
                text: `You are about to save the item "${itemData.Name}"`,
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Yes, save it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    // User confirmed, proceed with saving
                    fetch("http://localhost:5000/api/insertitems", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json"
                        },
                        body: JSON.stringify(itemData)
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.status === "success") {
                            // Success message using SweetAlert
                            Swal.fire(
                                'Saved!',
                                'Item has been saved successfully.',
                                'success'
                            );
                            // Optionally refresh the items display
                            displayItems();
                        } else {
                            // Error message using SweetAlert
                            Swal.fire(
                                'Error!',
                                'Failed to save item: ' + data.message,
                                'error'
                            );
                        }
                    })
                    .catch(error => {
                        console.error("Access Error:", error);
                        // Error message using SweetAlert
                        Swal.fire(
                            'Error!',
                            'Error saving item: ' + error.message,
                            'error'
                        );
                    });
                }
            });
        };
        
        // Read the file as a Data URL (base64)
        reader.readAsDataURL(file);
    } else {
        // No file selected - using SweetAlert
        Swal.fire(
            'Warning',
            'Please select an image file',
            'warning'
        );
    }
}

// Frontend JavaScript Fix
function Next() {
    document.getElementById("firstaddpage").style.display = "none";
    document.getElementById("secondaddpage").style.display = "block";

    // Create the item data object with proper property names
    const itemData = {
        itemName: document.getElementById('ProductName').value, // Match this with backend parameter name
        itemDesc: document.getElementById('Description').value
    };    

    fetch("http://localhost:5000/api/getrecommendedprice", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(itemData)
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        if (data.success) { 
            console.log("Price data received:", data);
            
            // Create the summary section
            let display = `
            <div class="price-analysis-container">
                <div class="price-summary-section">
                    <h2>Price Analysis for ${itemData.itemName}</h2>
                    <div class="price-highlight">
                        <span class="label">Suggested Price:</span>
                        <span class="value">$${data.suggestedPrice.toFixed(2)}</span>
                    </div>
                    <div class="price-details">
                        <div class="detail-item">
                            <span class="label">Price Range:</span>
                            <span class="value">$${data.priceRange.min.toFixed(2)} - $${data.priceRange.max.toFixed(2)}</span>
                        </div>
                        <div class="detail-item">
                            <span class="label">Confidence:</span>
                            <span class="value">${data.confidence}</span>
                        </div>
                        <div class="detail-item">
                            <span class="label">Total Prices Found:</span>
                            <span class="value">${data.totalPricesFound}</span>
                        </div>
                    </div>
                </div>
                
                <div class="detailed-results-section">
                    <h3>Detailed Results by Source</h3>`;
            
            // Add detailed results for each source with dropdown functionality
            for (const [source, sourceData] of Object.entries(data.detailedResults)) {
                const sourceId = `source-${source.replace(/[^a-z0-9]/gi, '')}`;
                display += `
                    <div class="source-dropdown">
                        <div class="source-header" onclick="toggleSourceDetails('${sourceId}')">
                            <div class="source-logo">
                                <div class="logo-container">
                                    <span class="logo-text">${formatLogoText(source)}</span>
                                </div>
                            </div>
                            <div class="source-summary">
                                <h4>${source.toUpperCase()}</h4>
                                <div class="price-value">$${sourceData.median_price.toFixed(2)}</div>
                                <div class="price-type">MEDIAN PRICE</div>
                            </div>
                            <div class="dropdown-arrow">
                                <i class="arrow-down" id="${sourceId}-arrow"></i>
                            </div>
                        </div>
                        <div class="source-details" id="${sourceId}" style="display: none;">
                            <div class="details-grid">
                                <div class="detail-card">
                                    <div class="detail-title">Price Range</div>
                                    <div class="detail-value">$${sourceData.price_range.min.toFixed(2)} - $${sourceData.price_range.max.toFixed(2)}</div>
                                </div>
                                <div class="detail-card">
                                    <div class="detail-title">Average Price</div>
                                    <div class="detail-value">$${sourceData.avg_price.toFixed(2)}</div>
                                </div>
                                <div class="detail-card">
                                    <div class="detail-title">Median Price</div>
                                    <div class="detail-value">$${sourceData.median_price.toFixed(2)}</div>
                                </div>
                                <div class="detail-card">
                                    <div class="detail-title">Standard Deviation</div>
                                    <div class="detail-value">$${sourceData.std_deviation.toFixed(2)}</div>
                                </div>
                            </div>
                            <div class="individual-prices">
                                <div class="prices-title">Individual Prices (${sourceData.count})</div>
                                <div class="price-chips">
                                    ${sourceData.prices.map(price => `<span class="price-chip">$${price.toFixed(2)}</span>`).join('')}
                                </div>
                            </div>
                            <div class="source-actions">
                                <button onclick="acceptSourcePrice('${source}', ${sourceData.median_price})" class="accept-source-button">Accept This Price</button>
                            </div>
                        </div>
                    </div>`;
            }
            
            display += `
                </div>
                <div class="action-buttons">
                    <button onclick="acceptSuggestedPrice(${data.suggestedPrice})" class="accept-button">Accept Suggested Price</button>
                </div>
            </div>`;

            // Add CSS styles for the dropdown functionality
            const styleElement = document.createElement('style');
            styleElement.textContent = `
                /* General Styles */
                .price-analysis-container {
                    font-family: Arial, sans-serif;
                    max-width: 800px;
                    margin: 0 auto;
                }
                
                /* Source Dropdown Styles */
                .source-dropdown {
                    margin-bottom: 15px;
                    border-radius: 8px;
                    overflow: hidden;
                    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
                }
                
                .source-header {
                    background-color: #3a3b3f;
                    color: white;
                    display: flex;
                    align-items: center;
                    padding: 15px;
                    cursor: pointer;
                    transition: background-color 0.2s;
                }
                
                .source-header:hover {
                    background-color: #4a4b50;
                }
                
                .source-logo {
                    margin-right: 15px;
                    flex-shrink: 0;
                }
                
                .logo-container {
                    background-color: white;
                    width: 70px;
                    height: 70px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    text-align: center;
                }
                
                .logo-text {
                    color: black;
                    font-weight: bold;
                    font-size: 12px;
                    line-height: 1.2;
                }
                
                .source-summary {
                    flex-grow: 1;
                }
                
                .source-summary h4 {
                    margin: 0 0 5px 0;
                    font-size: 18px;
                    font-weight: lighter;
                    color: #c0c0c0;
                }
                
                .price-value {
                    font-size: 32px;
                    font-weight: bold;
                    color: #4d8eff;
                }
                
                .price-type {
                    font-size: 14px;
                    color: #c0c0c0;
                }
                
                .dropdown-arrow {
                    margin-left: 15px;
                }
                
                .arrow-down {
                    border: solid white;
                    border-width: 0 3px 3px 0;
                    display: inline-block;
                    padding: 5px;
                    transform: rotate(45deg);
                    transition: transform 0.3s;
                }
                
                .arrow-up {
                    transform: rotate(-135deg);
                }
                
                /* Details Section */
                .source-details {
                    background-color: #f5f5f5;
                    padding: 20px;
                    border-top: 1px solid #ddd;
                }
                
                .details-grid {
                    display: grid;
                    grid-template-columns: repeat(2, 1fr);
                    gap: 15px;
                    margin-bottom: 20px;
                }
                
                .detail-card {
                    background-color: white;
                    padding: 12px;
                    border-radius: 5px;
                    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
                }
                
                .detail-title {
                    color: #666;
                    font-size: 14px;
                    margin-bottom: 5px;
                }
                
                .detail-value {
                    font-weight: bold;
                    font-size: 16px;
                }
                
                .individual-prices {
                    background-color: white;
                    padding: 15px;
                    border-radius: 5px;
                    margin-bottom: 15px;
                    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
                }
                
                .prices-title {
                    color: #666;
                    margin-bottom: 10px;
                }
                
                .price-chips {
                    display: flex;
                    flex-wrap: wrap;
                    gap: 8px;
                }
                
                .price-chip {
                    background-color: #e6f0ff;
                    color: #0055cc;
                    padding: 5px 10px;
                    border-radius: 15px;
                    font-size: 14px;
                }
                
                .source-actions {
                    margin-top: 15px;
                }
                
                .accept-source-button {
                    background-color: #2563eb;
                    color: white;
                    border: none;
                    padding: 10px 15px;
                    border-radius: 5px;
                    cursor: pointer;
                    width: 100%;
                    font-size: 16px;
                    transition: background-color 0.2s;
                }
                
                .accept-source-button:hover {
                    background-color: #1d4ed8;
                }
                
                /* Summary Styles */
                .price-summary-section {
                    margin-bottom: 25px;
                }
                
                .price-highlight {
                    background-color: #e6f0ff;
                    padding: 15px;
                    border-radius: 8px;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin: 15px 0;
                }
                
                .price-highlight .label {
                    font-weight: bold;
                    color: #444;
                }
                
                .price-highlight .value {
                    font-size: 24px;
                    font-weight: bold;
                    color: #0055cc;
                }
                
                .price-details {
                    display: grid;
                    grid-template-columns: repeat(3, 1fr);
                    gap: 15px;
                }
                
                .detail-item {
                    background-color: white;
                    padding: 12px;
                    border-radius: 5px;
                    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
                }
                
                .detail-item .label {
                    color: #666;
                    display: block;
                    margin-bottom: 5px;
                }
                
                .detail-item .value {
                    font-weight: bold;
                }
                
                .action-buttons {
                    margin-top: 20px;
                    text-align: center;
                }
                
                .accept-button {
                    background-color: #16a34a;
                    color: white;
                    border: none;
                    padding: 12px 20px;
                    border-radius: 5px;
                    cursor: pointer;
                    font-size: 16px;
                    transition: background-color 0.2s;
                }
                
                .accept-button:hover {
                    background-color: #15803d;
                }
                
                /* Mobile Responsiveness */
                @media (max-width: 600px) {
                    .price-details {
                        grid-template-columns: 1fr;
                    }
                    
                    .details-grid {
                        grid-template-columns: 1fr;
                    }
                    
                    .source-header {
                        flex-wrap: wrap;
                    }
                    
                    .source-logo {
                        margin-bottom: 10px;
                    }
                }
            `;
            document.head.appendChild(styleElement);

            document.getElementById('pricesuggestion').innerHTML = display;
            
            // Add the toggle function to the global scope
            window.toggleSourceDetails = function(sourceId) {
                const detailsElement = document.getElementById(sourceId);
                const arrowElement = document.getElementById(`${sourceId}-arrow`);
                
                if (detailsElement.style.display === 'none') {
                    detailsElement.style.display = 'block';
                    arrowElement.classList.add('arrow-up');
                } else {
                    detailsElement.style.display = 'none';
                    arrowElement.classList.remove('arrow-up');
                }
            };
            
            // Add the accept source price function
            window.acceptSourcePrice = function(source, price) {
                console.log(`Accepting price from ${source}: $${price}`);
                acceptSuggestedPrice(price);
            };
            
        } else {
            // Error message using SweetAlert
            Swal.fire(
                'Error!',
                'Failed to get price: ' + data.message,
                'error'
            );
        }
    })
    .catch(error => {
        console.error("Access Error:", error);
        // Error message using SweetAlert
        Swal.fire(
            'Error!',
            'Error getting price: ' + error.message,
            'error'
        );
    });
}

// Helper function to format source name for logo display
function formatLogoText(source) {
    const name = source.toUpperCase();
    if (name.length <= 5) {
        return name;
    }
    
    // Try to split at a logical point
    const midPoint = Math.ceil(name.length / 2);
    const firstHalf = name.substring(0, midPoint);
    const secondHalf = name.substring(midPoint);
    
    return `${firstHalf}<br>${secondHalf}`;
}

// Helper functions for the price actions
function acceptSuggestedPrice(price) {
    document.getElementById('ItemPrice').value = price.toFixed(2);
    // Add any additional logic needed when accepting the suggested price
    Swal.fire(
        'Price Set!',
        `The suggested price of $${price.toFixed(2)} has been set for your item.`,
        'success'
    );
}

function showCustomPriceInput() {
    document.getElementById('custom-price-input').style.display = 'block';
}

function setCustomPrice() {
    const customPrice = document.getElementById('customPrice').value;
    if (customPrice && !isNaN(customPrice) && parseFloat(customPrice) >= 0) {
        document.getElementById('ItemPrice').value = parseFloat(customPrice).toFixed(2);
        Swal.fire(
            'Price Set!',
            `Your custom price of $${parseFloat(customPrice).toFixed(2)} has been set for the item.`,
            'success'
        );
        document.getElementById('custom-price-input').style.display = 'none';
    } else {
        Swal.fire(
            'Invalid Price',
            'Please enter a valid price.',
            'warning'
        );
    }
}
// Make sure the function is available globally
window.SaveItems = SaveItems;

// Call the function to display items
displayItems();


























// Modal functionality
document.addEventListener('DOMContentLoaded', function() {
    // Get modal elements
    const addItemButton = document.querySelector('.btn-primary');
    const modal = document.getElementById('addItemModal');
    const closeModal = document.querySelector('.close-modal');
    const clearButton = document.querySelector('.btn-clear');
    const addItemForm = document.getElementById('addItemForm');
    const imageInput = document.getElementById('itemImage');
    const imagePreview = document.getElementById('imagePreview');
    
    // Open modal when Add Item button is clicked
    addItemButton.addEventListener('click', function() {
        modal.classList.add('show');
    });
    
    // Close modal when X is clicked
    closeModal.addEventListener('click', function() {
        modal.classList.remove('show');
    });
    
    // Close modal when clicking outside
    window.addEventListener('click', function(event) {
        if (event.target === modal) {
            modal.classList.remove('show');
        }
    });
    
    // Clear form
    function clearForm() {
        addItemForm.reset();
        imagePreview.style.backgroundImage = '';
        imagePreview.classList.remove('has-image');
        imagePreview.innerHTML = '<i class="fa-solid fa-image"></i><span>No image selected</span>';
    }
    
    // Clear button functionality
    clearButton.addEventListener('click', clearForm);
    
    // Image preview functionality
    imagePreview.addEventListener('click', function() {
        imageInput.click();
    });
    
    imageInput.addEventListener('change', function() {
        const file = this.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                imagePreview.style.backgroundImage = `url('${e.target.result}')`;
                imagePreview.classList.add('has-image');
                imagePreview.innerHTML = '';
            };
            reader.readAsDataURL(file);
        }
    });
    
// Form submission
 addItemForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        const itemName = document.getElementById('itemName').value;
        const unitPrice = document.getElementById('unitPrice').value;
        const discount = document.getElementById('discount').value;
        const status = document.getElementById('status').value;
        const stocks = document.getElementById('stocks').value;
        const description = document.getElementById('description').value;

        // Close modal after submission
        modal.classList.remove('show');
        clearForm();
        
        // Temporary: Show success message
        alert('Item added successfully! (Demo mode)');
    });
});


function submitFormData(formData) {
    fetch('/api/getsales', {
      method: 'POST',
      body: formData  
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.json();
    })
    .then(data => {
      console.log('Success:', data);
      // Handle successful response
      if (data.success) {
        alert(data.message); // Or update UI in a more elegant way
      }
    })
    .catch(error => {
      console.error('Error:', error);
      // Handle errors
      alert('Failed to add item: ' + error.message);
    });
  }