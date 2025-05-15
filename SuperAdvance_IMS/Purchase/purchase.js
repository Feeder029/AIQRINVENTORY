import { fetchData } from '../Function/getdata.js';

function DisplayPurchases() {
    fetchData("displaypurchases",data=>{
        let display = ``;

        if(data.purchases && data.purchases.length > 0) {
            data.purchases.forEach(item => {
                // Process the image path if it exists
        let imagePath = item.I_ImagePath;

        const imageDisplay = imagePath ? imagePath : "../Images/data/Placeholder.png" ;


                
                console.log(imageDisplay)

                
                display += `
<div class="purchase-card">
  <!-- Left side: Image + Item details -->
  <div class="left-section">
    <img src="${imageDisplay}" alt="Item" class="item-image"/>
    <div class="item-info">
      <h2 class="item-name">${item.I_Name}</h2>
      <p class="item-details">${item.P_Quantity} Pieces | ${item.V_LFullName}</p>
    </div>
  </div>
  
  <!-- Right side: dots and date -->
  <div class="right-section">
    <button class="action-dots"><i class='bx bx-dots-horizontal-rounded'></i></button>
    <div class="total-amount">$${item.P_Cost}</div>
    <div class="date">${item.Date}</div>
  </div>
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
        <div class="legacycode" hidden>${item.I_LegacyCode}</div>
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
          option.setAttribute('legacy', vendor.V_LegacyID);
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

  const purchasedate = document.getElementById("purchasedate");
  if (!purchasedate.value) {
    const nowPH = new Date();
    const todayPH = nowPH.toISOString().split('T')[0];
    purchasedate.value = todayPH;
  }

  document.getElementById("amount").addEventListener("input", updateTotalCost);
  document.getElementById("price").addEventListener("input", updateTotalCost);
}

function Purchase(){
  const selectedItemValue = document.getElementById('selected-item').value;
  const vendorValue = document.getElementById("vendor").value;
  const vendorName = document.getElementById("vendor").options[document.getElementById("vendor").selectedIndex].textContent;
  const purchasedate = document.getElementById("purchasedate").value;
  const amount = document.getElementById("amount").value;
  const price = document.getElementById("price").value;
  
  // Get the selected item name from the dropdown
  const selectedItemName = document.querySelector('.dropdown-selected .name').textContent;
  const legacycode = document.querySelector('.dropdown-selected .legacycode').textContent;
  const LegacyVendorID = document.getElementById("vendor").options[document.getElementById("vendor").selectedIndex].getAttribute("legacy");

 
  // Validate form fields
  if (!selectedItemValue || !vendorValue || !purchasedate || !amount || !price) {
    alert("Please fill in all fields");
    return;
  }

  // alert(LegacyVendorID)
  const totalCost = parseFloat(amount) * parseFloat(price);

  const purchaseData = {
    itemId: selectedItemValue,
    itemName: selectedItemName,
    vendorId: vendorValue,
    vendorName: vendorName,
    date: purchasedate,
    quantity: amount,
    unitPrice: price,
    totalCost: totalCost,
    legacycode:legacycode,
    LegacyVendorID: LegacyVendorID
  };
  
  fetch("http://localhost:5000/api/addnewpurchase", {
    method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
        body: JSON.stringify(purchaseData)
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

    DisplayPurchases();

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

                  
  console.log("Submitting purchase:", purchaseData);
  
  const popover = document.getElementById('addpurchase');
  if (popover && typeof popover.hidePopover === 'function') {
    popover.hidePopover();
  }
  
}

function updateTotalCost() {
    const amount = document.getElementById("amount").value || 0;
    const price = document.getElementById("price").value || 0;
    const totalCost = (parseFloat(amount) * parseFloat(price)).toFixed(2);
    document.querySelector('.calculated-cost').textContent = `Total Cost: $${totalCost}`;
}

// Add this to your SetUp function
document.getElementById("amount").addEventListener('input', updateTotalCost);
document.getElementById("price").addEventListener('input', updateTotalCost);

window.Purchase = Purchase;
// Call the function to display items
DisplayPurchases();
DropdownOptions();