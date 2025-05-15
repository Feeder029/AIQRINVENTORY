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

function DropdownOptions() {
  fetchData("displayvendors", vendordata => {
    fetchData("displayitems", data =>{ 
      const dropdownContainer = document.querySelector('.dropdown-options');
      const vendorSelect = document.getElementById('vendor');

      if(data.items && data.items.length > 0) {

        data.items.forEach(item => {

        // Process the image path if it exists
        let imagePath = item.I_ImagePath;

        const imageDisplay = imagePath ? imagePath : "../Images/data/Placeholder.png" ;

        const newOption = document.createElement('div');
        newOption.classList.add('dropdown-option');
        newOption.setAttribute('data-value', item.ItemID); // Set your data-value

        // Add inner HTML (image + details)
        newOption.innerHTML = `
        <img src="${imageDisplay}" id="picture_dropdown" alt="${item.I_Name}" />
        <div class="details">
        <div class="name">${item.I_Name}</div>
        <div class="stock">Stock: ${item.I_Stock}</div>
        </div>
       `;
       
       // Append to the dropdown
       dropdownContainer.appendChild(newOption);
      })

      SetUp();
      } else {
      }


      if (vendordata.vendor && vendordata.vendor.length > 0) {

        vendordata.vendor.forEach(vendor =>{
          const option = document.createElement('option');
          option.value = vendor.VendorID;
          option.textContent = vendor.V_LFullName;
          vendorSelect.appendChild(option);
        }

        )
        console.log("Working")

      } else  {
        console.log("Error")
      }




    })
    })
}


function SetUp(){
  const dropdown = document.getElementById('item-dropdown');
  const selected = dropdown.querySelector('.dropdown-selected');
  const options = dropdown.querySelector('.dropdown-options');
  const hiddenInput = document.getElementById('selected-item');

  selected.addEventListener('click', () => {
    options.style.display = options.style.display === 'block' ? 'none' : 'block';
  });

  dropdown.querySelectorAll('.dropdown-option').forEach(option => {
    option.addEventListener('click', () => {
      selected.innerHTML = option.innerHTML;
      hiddenInput.value = option.getAttribute('data-value');
      options.style.display = 'none';
    });
  });

  document.addEventListener('click', (e) => {
    if (!dropdown.contains(e.target)) {
      options.style.display = 'none';
    }
  });
}

function Purchase(){
  const selectedItemValue = document.getElementById('selected-item').value;
  

}

window.Purchase = Purchase;
// Call the function to display items
DisplayPurchases();
DropdownOptions();