function DisplayPurchases() {
    fetch("http://localhost:5000/api/displaypurchases")
    .then(response => response.json())
    .then(data => {
        if(data.status === "success"){
            let display = ""
            if(data.purchases && data.purchases.length > 0) {
                data.purchases.forEach(item => {
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
                    <tr class="row-data">
                    <div class="data" >
                    <div class="data-left">
                        <img src="../Img/pfp.jpg" alt="">
                        <div class="left">
                            <h1 id="item-name">${item.I_Name}</h1>
                            <p id="item-stock">${item.P_Quantity} Pieces</p>
                         </div>
                         </div>
                          <div class="data-right">
                           <button><i class='bx bx-dots-horizontal-rounded'></i></button>
                           <p id="item-date">69 Days Ago</p>
                          </div>
                         </div>
                        </tr>
                    </div>
                    `;
                    
                });
            } else {
                console.log("No Purchase found");
                display = "<p>No purchase found in inventory</p>";
            }
            document.getElementById('PurchasesList').innerHTML = display;

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
DisplayPurchases();