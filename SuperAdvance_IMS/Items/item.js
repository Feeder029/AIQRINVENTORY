// Function to fetch and display items
function displayItems() {
    fetch("http://localhost:5000/api/displayitems")
    .then(response => response.json())
    .then(data => {
        if(data.status === "success"){
            let display = ""
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
                    
                    console.log("Item:", item.I_Name);
                    console.log("Image path:", imagePath || "None");
                });
            } else {
                console.log("No items found");
                display = "<p>No items found in inventory</p>";
            }

            document.getElementById('items_display').innerHTML = display;

        } else {
            console.log("Access Denied:", data.message || "Unknown error");
            document.getElementById('items_display').innerHTML = "<p>Error loading inventory data</p>";
        }
    })
    .catch(error => {
        console.error("Access Error:", error);
        document.getElementById('items_display').innerHTML = "<p>Error connecting to server</p>";
    });    
}

// Call the function to display items
displayItems();