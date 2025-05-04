
import { fetchData } from '../Function/getdata.js';

function DisplayPurchases() {
    fetchData("displaypurchases",data=>{
        let display = ``;

        if(data.purchases && data.purchases.length > 0) {
            data.purchases.forEach(item => {
                // Process the image path if it exists
                let imagePath = item.I_ImagePath;


                console.log(imagePath)
                
                // Fall back to placeholder if no valid image path
                const imageDisplay = imagePath ? 
                    `<img src="${imagePath}" alt="${item.I_Name}" onerror="this.onerror=null; this.src='./assets/placeholder.jpg';">` : 
                    `<div class="placeholder-text">Product Image</div>`;

                
                console.log(imageDisplay)

                
                display += `
                    <tr class="row-data">
                    <div class="data" >
                    <div class="data-left">
                        ${imageDisplay}
                        <div class="left">
                            <h1 id="item-name">${item.I_Name}</h1>
                            <p id="item-stock">${item.P_Quantity} Pieces</p>
                         </div>
                         </div>
                          <div class="data-right">
                           <button><i class='bx bx-dots-horizontal-rounded'></i></button>
                           <p id="item-date">${item.Date}</p>
                          </div>
                         </div>
                        </tr>
                    </div>
                    `;
            });

            document.getElementById('PurchasesList').innerHTML = display;
        } else {
            console.log("No items found");
            display = "<p>No items found in inventory</p>";
        }
    })
}


// Call the function to display items
DisplayPurchases();