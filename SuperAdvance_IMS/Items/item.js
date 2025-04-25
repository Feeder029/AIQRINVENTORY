
import { fetchData } from '../Function/getdata.js';

function displayItems() {
    fetchData("displayitems",data=>{
        let display = ``;

        if(data.items && data.items.length > 0) {
            data.items.forEach(item => {
                // Process the image path if it exists
                let imagePath = "";
                
                if(item.I_Image) {
                    // Check if it's a URL or base64 data
                    if(item.I_Image.startsWith('http') || item.I_Image.startsWith('/')) {
                        // It's already a URL - use directly
                        imagePath = item.I_Image;
                    } else {
                        // Try to decode it from bytes if it's not already a URL
                        try {
                            // Convert ASCII representation to actual string if needed
                            if(item.I_Image.includes('http')) {
                                // Extract the URL from the binary data
                                const urlMatch = item.I_Image.match(/(http:\/\/[^\s]+)/);
                                if(urlMatch && urlMatch[1]) {
                                    imagePath = urlMatch[1];
                                }
                            } else {
                                // Use as base64
                                imagePath = `data:image/jpeg;base64,${item.I_Image}`;
                            }
                        } catch(e) {
                            console.error("Error processing image data:", e);
                        }
                    }
                }
                
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



        
        // submitFormData(formData)
        
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