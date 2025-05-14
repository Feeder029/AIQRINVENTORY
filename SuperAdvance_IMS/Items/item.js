import { fetchData } from '../Function/getdata.js';

function displayItems() {
    fetchData("displayitems", data => {
        let display = ``;

        if(data.items && data.items.length > 0) {
            data.items.forEach(item => {

                let itemName = item.I_Name.length > 25 ? item.I_Name.substring(0, 25) + '...' : item.I_Name;

                console.log("Data: " + item.I_ImagePath);
                // Process the image path if it exists
                let imagePath = item.I_ImagePath;

                // Fall back to placeholder if no valid image path
                const imageDisplay = imagePath ? 
                    `<img src="${imagePath}" alt="${item.I_Name}" onerror="this.onerror=null; this.src='./assets/placeholder.jpg';">` : 
                    `<img src="../Images/data/Placeholder.png" alt="${item.I_Name}" onerror="this.onerror=null; this.src='./assets/placeholder.jpg';">`;
                

                // Convert the item data to a JSON string to safely pass it to the function
                let itemInfoJSON = JSON.stringify({
                    "Item": item.I_Name,
                    "UnitPrice": item.I_UnitPrice,
                    "SuggestedPrice": item.I_SuggestedPrice,
                    "MaxPriceRange": item.I_MaxPriceRange,
                    "MinPriceRange": item.I_MinPriceRange,
                    "EbaySuggestedPrice": item.I_EbaySuggestedPrice,
                    "EbayFullInfo": item.I_EbayFullInfo,
                    "MCSuggestedPrice": item.I_MCSuggestedPrice,
                    "MCFullInfo": item.I_MCFullInfo,
                    "AmazonSuggestedPrice": item.I_AmazonSuggestedPrice,
                    "AmazonFullInfo": item.I_AmazonFullInfo,
                    "WalmartSuggestedPrice": item.I_WallmartSuggestedPrice,
                    "WalmartInfo": item.I_WallmartInfo,
                    "PriceStatus": item.PriceStatus,
                    "Description": item.I_Description,
                    "Quantity" : item.I_Stock,
                    "Discount" : item.I_Discount,
                    "imagePath" : imagePath,
                    "I_ID" : item.ItemID
                });

                

                display += `
                    <div class="item-container">
                        <div class="item-image">
                            ${imageDisplay}
                        </div>
                        <div class="item-details">
                            <h2>${itemName}</h2>
                            <p>Price: <span>${item.I_UnitPrice}</span></p>
                            <p>Stocks: <span>${item.I_Stock}</span></p>
                        </div>
                        <div class="item-icons ">
                            <details class="warning ${item.PriceStatus}">
                                <summary></summary>
                                <div class="warning-details">
                                    <div class="details">
                                        <h2>WARNING!</h2>
                                        <p>Your price is currently ${item.PriceStatus} based on data.</p>
                                    </div>
                                    <div class="warning-buttons">
                                        <button id="ignore">Ignore</button>
                                        <button id="seemore" onclick='ChangeValues(${itemInfoJSON})' popovertarget="SeeMore">See More</button>
                                    </div>
                                </div>
                            </details>
                            <details class="dropdown">
                                <summary><i class='bx bx-dots-horizontal-rounded'></i></summary>
                                <div class="dropdown-menu">
                                    <div class="dropdown-option"><i class="fa-solid fa-eye"></i> View More</div>
                                    <div class="separator">&nbsp;</div>
                                    <div class="dropdown-option" onclick='EditAddItem(${itemInfoJSON})' popovertarget="AddItem"><i class="fa-solid fa-pen-to-square"></i> Edit</div>
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

            document.getElementById('loading').style.display = 'none';
            document.getElementById('items_display').innerHTML = display;
        } else {
            console.log("No items found");
            display = "<p>No items found in inventory</p>";
        }
    });
}

function ChangeValues(itemData) {

    document.getElementById("itemnameinfo").innerText = itemData.Item + " Price Details";
    document.getElementById("Cprice").innerText = "$"+itemData.UnitPrice;
    document.getElementById("I_SuggestedPrice").innerText = "$"+itemData.SuggestedPrice;
    document.getElementById("PriceStat").innerText = itemData.PriceStatus;
    document.getElementById("I_MinPriceRange").innerText = "$"+itemData.MinPriceRange;
    document.getElementById("I_MaxPriceRange").innerText = "$"+itemData.MaxPriceRange;
    document.getElementById("I_EbaySuggestedPrice").innerText = "$"+itemData.EbaySuggestedPrice;
    document.getElementById("I_MCSuggestedPrice").innerText = "$"+itemData.MCSuggestedPrice;
    document.getElementById("I_AmazonSuggestedPrice").innerText = "$"+itemData.AmazonSuggestedPrice;
    document.getElementById("I_WallmartSuggestedPrice").innerText = "$"+itemData.WalmartSuggestedPrice;
    document.getElementById("I_EbayFullInfo").innerText = itemData.EbayFullInfo;
    document.getElementById("I_MCFullInfo").innerText = itemData.MCFullInfo;
    document.getElementById("I_AmazonFullInfo").innerText = itemData.AmazonFullInfo;
    document.getElementById("I_WallmartInfo").innerText = itemData.WalmartInfo;

}

window.ChangeValues = ChangeValues;

window.SaveItems = SaveItems;
window.Next = Next;


let SP = 0;
let Max = 0;
let Min = 0;
let EbaySP = 0;
let EbayInfo = "";
let MCSPs = 0;
let MCInfo = "";
let AmazonSP = null;
let AmazonInfo = "";
let WalmartSP = 0;
let WalmartInfo = "";

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
                Img: base64String,
                SP: SP,
                Max: Max,
                Min: Min,
                EbaySP: EbaySP,
                EbayInfo: EbayInfo,
                MCSPs: MCSPs,
                MCInfo: MCInfo,
                AmazonSP: AmazonSP,
                AmazonInfo: AmazonInfo,
                WalmartSP: WalmartSP,
                WalmartInfo: WalmartInfo  
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


function EmptyAddItem(){

   // Show all elements with class 'editonly'
  document.querySelectorAll('.editonly').forEach(el => {
   el.style.display = 'none';
  });

  // Hide all elements with class 'addonly'
  document.querySelectorAll('.addonly').forEach(el => {
   el.style.display = 'block'; 
  });

  // Reset form fields for adding a new item
  document.getElementById('Title').textContent = 'ADD ITEM';

  document.getElementById('ProductName').value = '';
  document.getElementById('Description').value = '';
  document.getElementById('Quantity').value = '';
  document.getElementById('Discount').value = '';
  document.getElementById('UnitPriceEdit').value = '';


  
  // Make sure we're showing the first page of the add item form
  popoverupdate("firstaddpage", "block");
  popoverupdate("secondaddpage", "none");

  const fileInput = document.getElementById('Item-Img');
  fileInput.value = '';
}

function EditAddItem(itemData){
  // Store the item data in a data attribute for later use
  const editForm = document.getElementById('AddItem');
  
  // Show the popover for editing
  editForm.showPopover();
  
  // Set up the form for editing

  // Show all elements with class 'editonly'
  document.querySelectorAll('.editonly').forEach(el => {
   el.style.display = 'block';
  });

  // Hide all elements with class 'addonly'
  document.querySelectorAll('.addonly').forEach(el => {
   el.style.display = 'none'; 
  });

  document.getElementById("itemimg").src = itemData.imagePath;

  document.getElementById('Title').textContent = 'EDIT ITEM';
  document.getElementById('id').textContent = itemData.I_ID;
  document.getElementById('UnitLabel').textContent = `Unit Price | Suggested Price: $${itemData.SuggestedPrice} ($${itemData.MaxPriceRange} - $${itemData.MinPriceRange})`;

  // Fill in the form with the item data
  document.getElementById('ProductName').value = itemData.Item;
  document.getElementById('Description').value = itemData.Description;
  document.getElementById('Quantity').value = itemData.Quantity;
  document.getElementById('Discount').value = itemData.Discount;
  
  const unitPriceEdit = document.getElementById('UnitPriceEdit');
  unitPriceEdit.value = itemData.UnitPrice;
  
  // Store the min and max price range as data attributes on the input field
  unitPriceEdit.setAttribute('data-min-price', itemData.MinPriceRange);
  unitPriceEdit.setAttribute('data-max-price', itemData.MaxPriceRange);
  
  // Remove any existing event listeners (using the cloneNode technique)
  const newUnitPriceEdit = unitPriceEdit.cloneNode(true);
  unitPriceEdit.parentNode.replaceChild(newUnitPriceEdit, unitPriceEdit);
  
  // Add the event listener to the new element
  newUnitPriceEdit.addEventListener("input", function() {
    const min = this.getAttribute('data-min-price');
    const max = this.getAttribute('data-max-price');
    pricecomparison(this.value, min, max);
  });

  // Make sure we're showing the first page of the edit form
  popoverupdate("firstaddpage", "block");
  popoverupdate("secondaddpage", "none");

  document.getElementById('pricesuggestion').innerHTML = display;
}

function EditItems(){
    
    const itemData = {
        ID: document.getElementById('id').textContent,
        Name: document.getElementById('ProductName').value,
        Desc: document.getElementById('Description').value,
        Quantity: parseInt(document.getElementById('Quantity').value),
        UnitPrice: parseFloat(document.getElementById('UnitPriceEdit').value),
        Discount: parseFloat(document.getElementById('Discount').value),
    }

    document.getElementById('AddItem').hidePopover();

    fetch("http://localhost:5000/api/updateitems", {
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
        Swal.fire(
            'Error!',
            'Error saving item: ' + error.message,
            'error'
        );
    });
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


            SP = data.suggestedPrice.toFixed(2);
            Min = data.suggestedRanges.midrange.min.toFixed(2);
            Max = data.suggestedRanges.midrange.max.toFixed(2);

            
            // Create the summary section
            let display = `
            <div class="price-analysis-container">
                <div class="price-summary-section">
                    <h2>Price Analysis for ${itemData.itemName}</h2>
                    <div class="price-highlight">
                        <span class="label">Suggested Price:</span>
                        <span class="value" id="SG_Price">$${SP}</span>
                    </div>
                    <div class="price-details">
                        <div class="detail-item">
                            <span class="label">Mid Range Price Range:</span>
                            <span class="value">$${Min} - $${Max}</span>
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

                switch(source.toUpperCase()){
                    case "AMAZON":
                        AmazonSP = sourceData.SuggestedPrice.toFixed(2);
                        AmazonInfo = WebInfo(sourceData.count,sourceData.price_range.min.toFixed(2),sourceData.price_range.max.toFixed(2),sourceData.avg_price.toFixed(2),sourceData.median_price.toFixed(2),sourceData.std_deviation.toFixed(2));
                        console.log("Amazon Added");
                        console.log(AmazonInfo);
                        break;
                    case "EBAY":
                        EbaySP = sourceData.SuggestedPrice.toFixed(2);
                        EbayInfo = WebInfo(sourceData.count,sourceData.price_range.min.toFixed(2),sourceData.price_range.max.toFixed(2),sourceData.avg_price.toFixed(2),sourceData.median_price.toFixed(2),sourceData.std_deviation.toFixed(2));
                        console.log("EBAY Added");
                        console.log(EbayInfo);
                        break;
                    case "MICROCENTER":
                        MCSPs = sourceData.SuggestedPrice.toFixed(2);
                        MCInfo = WebInfo(sourceData.count,sourceData.price_range.min.toFixed(2),sourceData.price_range.max.toFixed(2),sourceData.avg_price.toFixed(2),sourceData.median_price.toFixed(2),sourceData.std_deviation.toFixed(2));
                        console.log("MICROCENTER Added");
                        console.log(MCInfo);
                        break;
                    case "WALMART":
                        WalmartSP = sourceData.SuggestedPrice.toFixed(2);
                        WalmartInfo = WebInfo(sourceData.count,sourceData.price_range.min.toFixed(2),sourceData.price_range.max.toFixed(2),sourceData.avg_price.toFixed(2),sourceData.median_price.toFixed(2),sourceData.std_deviation.toFixed(2));
                        console.log("WALMART Added");
                        console.log(WalmartInfo);
                        break;
                    default:
                        console.log(source.toUpperCase());
                }
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



function WebInfo(C, Min, Max, AVG, MDN, STR) {
    const Info = `Item Count: ${C}, Price Range: $${Min} - $${Max}, Average Price: $${AVG}, Median Price: $${MDN}, Standard Deviation: $${STR}`;
    return Info;
}

function pricecomparison(value, min, max) {
    value = parseFloat(value);
    min = parseFloat(min);
    max = parseFloat(max);

    console.log(`${value} > ${max} = ${value > max} AND ${value} < ${min} = ${value < min}`);

    if (value > max) {
        document.querySelector(".alert").textContent = "This is too high!";
        document.querySelector(".editalert").textContent = "This is too high!";
    } else if (value < min) {
        document.querySelector(".alert").textContent = "This is too low!";
        document.querySelector(".editalert").textContent = "This is too low!";
    } else {
        document.querySelector(".alert").textContent = "";
        document.querySelector(".editalert").textContent = "";
    }
}


window.suggestedprice = suggestedprice;
window.pricecomparison = pricecomparison;
window.EmptyAddItem = EmptyAddItem;
window.EditAddItem = EditAddItem;
window.EditItems = EditItems;

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
    if (addItemButton && modal) {
        addItemButton.addEventListener('click', function() {
            modal.classList.add('show');
        });
    }
    
    // Close modal when X is clicked
    if (closeModal && modal) {
        closeModal.addEventListener('click', function() {
            modal.classList.remove('show');
        });
    }
    
    // Close modal when clicking outside
    if (modal) {
        window.addEventListener('click', function(event) {
            if (event.target === modal) {
                modal.classList.remove('show');
            }
        });
    }
    
    // Clear form
    function clearForm() {
        if (addItemForm) {
            addItemForm.reset();
            if (imagePreview) {
                imagePreview.style.backgroundImage = '';
                imagePreview.classList.remove('has-image');
                imagePreview.innerHTML = '<i class="fa-solid fa-image"></i><span>No image selected</span>';
            }
        }
    }
    
    // Clear button functionality
    if (clearButton) {
        clearButton.addEventListener('click', clearForm);
    }
    
    // Image preview functionality
    if (imagePreview && imageInput) {
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
    }
    
    // Form submission
    if (addItemForm) {
        addItemForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const itemName = document.getElementById('itemName')?.value;
            const unitPrice = document.getElementById('unitPrice')?.value;
            const discount = document.getElementById('discount')?.value;
            const status = document.getElementById('status')?.value;
            const stocks = document.getElementById('stocks')?.value;
            const description = document.getElementById('description')?.value;

            // Close modal after submission
            if (modal) {
                modal.classList.remove('show');
            }
            clearForm();
            
            // Temporary: Show success message
            alert('Item added successfully! (Demo mode)');
        });
    }
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