
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

            popoverupdate("secondaddpage","none")
            
            
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
                popoverupdate("firstaddpage","block")
                } else {
                popoverupdate("secondaddpage","block")
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

    popoverupdate("firstaddpage","none")
    popoverupdate("secondaddpage","block")

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
                            <span class="label">Mid Range Price Range:</span>
                            <span class="value">$${data.suggestedRanges.midrange.min.toFixed(2)} - $${data.suggestedRanges.midrange.max.toFixed(2)}</span>
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
                                <h4>${source.toUpperCase()} (${sourceData.count} Items)</h4>
                                <div class="price-value">$${sourceData.SuggestedPrice.toFixed(2)}</div>
                                <div class="price-type">SUGGESTED PRICE</div>
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
                                <button onclick="suggestedprice(${sourceData.SuggestedPrice.toFixed(2)})" class="accept-source-button">Accept This Price</button>
                            </div>
                        </div>
                    </div>`;
            }
            
            display += `
                </div>
                <div class="action-buttons">
                    <button onclick="suggestedprice(${data.suggestedPrice.toFixed(2)})" class="accept-button">Accept Suggested Price</button>
                </div>
            </div>`;

            document.getElementById('pricesuggestion').innerHTML = display;


              document.getElementById("UnitPrice").addEventListener("input", function() {
               pricecomparison(this.value,data.suggestedRanges.midrange.min.toFixed(2),data.suggestedRanges.midrange.max.toFixed(2));
              });

            
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

function pricecomparison(value,min,max){
    
    if(value>max){
        document.querySelector(".alert").textContent = "This is too high!";
    } else if (value<min){
        document.querySelector(".alert").textContent = "This is too low!";
    } else {
       document.querySelector(".alert").textContent = "Fine!";
    }

}
window.suggestedprice = suggestedprice
window.pricecomparison = pricecomparison

function suggestedprice(price){
    document.getElementById("UnitPrice").value = price;
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

function popoverupdate(ID,type){
            document.getElementById(ID).style.display = type;
}
window.popoverupdate = popoverupdate;

// Make sure the function is available globally
window.SaveItems = SaveItems;

// Call the function to display items
displayItems();




// function showCustomPriceInput() {
//     document.getElementById('custom-price-input').style.display = 'block';
// }

// function setCustomPrice() {
//     const customPrice = document.getElementById('customPrice').value;
//     if (customPrice && !isNaN(customPrice) && parseFloat(customPrice) >= 0) {
//         document.getElementById('ItemPrice').value = parseFloat(customPrice).toFixed(2);
//         Swal.fire(
//             'Price Set!',
//             `Your custom price of $${parseFloat(customPrice).toFixed(2)} has been set for the item.`,
//             'success'
//         );
//         document.getElementById('custom-price-input').style.display = 'none';
//     } else {
//         Swal.fire(
//             'Invalid Price',
//             'Please enter a valid price.',
//             'warning'
//         );
//     }
// }





















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