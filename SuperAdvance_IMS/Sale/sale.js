import { fetchData } from '../Function/getdata.js';

function displaysales() {

    if (!window.currentPage) {
        window.currentPage = 1;
    }

    fetchData("displaysales",data=>{

        if (data.sales && data.sales.length > 0) {
            // Store sales data globally for pagination
            window.salesData = data.sales;
            renderSalesPage(window.currentPage);
        } else {
            console.log("No items found");
            document.getElementById('salesinfo').innerHTML = "<p>No sales records found</p>";
            document.getElementById('page-controls').innerHTML = "";
            
        }

    })
}

function renderSalesPage(page) {
    const itemsPerPage = 6;
    const sales = window.salesData;
    const totalPages = Math.ceil(sales.length / itemsPerPage);
    
    // Validate page number
    if (page < 1) page = 1;
    if (page > totalPages) page = totalPages;
    window.currentPage = page;
    
    // Calculate start and end index for current page
    const startIndex = (page - 1) * itemsPerPage;
    const endIndex = Math.min(startIndex + itemsPerPage, sales.length);
    
    // Generate sales display
    let display = "";
    for (let i = startIndex; i < endIndex; i++) {
        const item = sales[i];
        display += `
        <div class="sale-card">
            <div class="sale-card-header">
                <div class="order-id">#SALES-${item.S_LegacyID}</div>
            </div>
            <div class="sale-card-body">
                <div class="sale-info">
                    <div class="info-group">
                        <div class="info-label">Customer</div>
                        <div class="info-value">${item.C_LFullName}</div>
                    </div>
                    <div class="info-group">
                        <div class="info-label">Date</div>
                        <div class="info-value">${item.SaleDate}</div>
                    </div>
                    <div class="info-group">
                        <div class="info-label">Item</div>
                        <div class="info-value">${item.I_Name}</div>
                    </div>
                    <div class="info-group">
                        <div class="info-label">Amount</div>
                        <div class="info-value">${item.S_Quantity} Pieces</div>
                    </div>
                </div>
                <div class="amount">
                    <div class="price">$${item.TotalPrice}</div>
                    <div class="action-buttons">
                        <button class="adjustbtn"><i class="fas fa-edit edit-icon"></i></button>
                        <button class="adjustbtn"><i class="fas fa-trash delete-icon"></i></button>
                    </div>
                </div>
            </div>
        </div>
        `;
    }
    
    // Generate pagination controls
    let pageButtons = "";
    for (let i = 1; i <= totalPages; i++) {
        pageButtons += `<button class="page-btn ${i === page ? 'active' : ''}" data-page="${i}">${i}</button>`;
    }
    
    const numbering = `
        <button class="page-btn" id="previous" ${page === 1 ? 'disabled' : ''}>Previous</button>
        ${pageButtons}
        <button class="page-btn" id="next" ${page === totalPages ? 'disabled' : ''}>Next</button>
    `;
    
    // Update DOM
    document.getElementById('salesinfo').innerHTML = display;
    document.getElementById('page-controls').innerHTML = numbering;
    
    // Add event listeners for pagination controls
    setupPaginationListeners();
}

function setupPaginationListeners() {
    // Add event listeners for page number buttons
    const pageButtons = document.querySelectorAll('.page-btn[data-page]');
    pageButtons.forEach(button => {
        button.addEventListener('click', function() {
            const page = parseInt(this.getAttribute('data-page'));
            renderSalesPage(page);
        });
    });
    
    // Previous button
    const prevButton = document.getElementById('previous');
    if (prevButton) {
        prevButton.addEventListener('click', function() {
            if (window.currentPage > 1) {
                renderSalesPage(window.currentPage - 1);
            }
        });
    }
    
    // Next button
    const nextButton = document.getElementById('next');
    if (nextButton) {
        nextButton.addEventListener('click', function() {
            const totalPages = Math.ceil(window.salesData.length / 6);
            if (window.currentPage < totalPages) {
                renderSalesPage(window.currentPage + 1);
            }
        });
    }
}

// Store items data globally to access it later
window.itemsData = [];

function DropdownOptions() {
  fetchData("displaycustomer", customerdata => {
    fetchData("displayitems", data =>{ 
      const dropdownContainer = document.querySelector('.dropdown-options');
      const customerSelect = document.getElementById('customer');

      if(data.items && data.items.length > 0) {
        // Store the items data globally
        window.itemsData = data.items;

        data.items.forEach(item => {
        // Process the image path if it exists
        let imagePath = item.I_ImagePath;

        const imageDisplay = imagePath ? imagePath : "../Images/data/Placeholder.png" ;

        const newOption = document.createElement('div');
        newOption.classList.add('dropdown-option');
        newOption.setAttribute('data-value', item.ItemID); // Set your data-value
        newOption.setAttribute('data-price', item.I_UnitPrice); // Add price attribute
        newOption.setAttribute('data-discount', item.I_Discount); // Add discount attribute

        // Add inner HTML (image + details)
        newOption.innerHTML = `
        <img src="${imageDisplay}" id="picture_dropdown" alt="${item.I_Name}" />
        <div class="details">
        <div class="mobilecode" hidden>${item.I_MobileCode}</div>
        <div class="legacycode" hidden>${item.I_LegacyCode}</div>
        <div class="itemname">${item.I_Name}</div>
        <div class="itemstock">Stock: ${item.I_Stock}</div>
        <div class="discountdropdown">Discount: ${item.I_Discount}</div>
        <div class="pricedropdown">Price: ${item.I_UnitPrice}</div>
        </div>
       `;

       
       // Append to the dropdown
       dropdownContainer.appendChild(newOption);
      })

      SetUp();
      } else {
      }


      if (customerdata.customer && customerdata.customer.length > 0) {

        customerdata.customer.forEach(customer =>{
          const option = document.createElement('option');
          option.value = customer.CustomerID;
          option.setAttribute('legacy', customer.C_LegacyID);
          option.textContent = customer.C_LFullName;
          customerSelect.appendChild(option);
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
  const priceInput = document.getElementById('price');
  const discountInput = document.getElementById('discount');

  selected.addEventListener('click', () => {
    options.style.display = options.style.display === 'block' ? 'none' : 'block';
  });

  dropdown.querySelectorAll('.dropdown-option').forEach(option => {
    option.addEventListener('click', () => {
      selected.innerHTML = option.innerHTML;
      const itemId = option.getAttribute('data-value');
      hiddenInput.value = itemId;
      
      // Get price and discount from data attributes
      const price = option.getAttribute('data-price');
      const discount = option.getAttribute('data-discount');
      
      // Set the values in the inputs
      priceInput.value = price;
      discountInput.value = discount;
      
      // Update the total cost calculation
      updateTotalCost();
      
      options.style.display = 'none';
    });
  });

  document.addEventListener('click', (e) => {
    if (!dropdown.contains(e.target)) {
      options.style.display = 'none';
    }
  });

  const Saledate = document.getElementById("Saledate");
  if (!Saledate.value) {
    const nowPH = new Date();
    const todayPH = nowPH.toISOString().split('T')[0];
    Saledate.value = todayPH;
  }

  document.getElementById("amount").addEventListener("input", updateTotalCost);
  document.getElementById("price").addEventListener("input", updateTotalCost);
  document.getElementById("discount").addEventListener("input", updateTotalCost);
}


function updateTotalCost() {
    const amount = document.getElementById("amount").value || 0;
    const price = document.getElementById("price").value || 0;
    const discount = document.getElementById("discount").value || 0;
    const totalCost = ((price * amount) * (1 - (discount / 100))).toFixed(2);
    document.querySelector('.calculated-cost').textContent = `Total Cost: $${totalCost}`;
}

// Call this initially to load the sales data
displaysales();
DropdownOptions();

// Add Purchase function if it doesn't exist elsewhere
function Sale() {

  const itemId = document.getElementById('selected-item').value;
  const customerId = document.getElementById('customer').value;
  const customername = document.getElementById('customer').options[document.getElementById("customer").selectedIndex].textContent;
  const saledate = document.getElementById('Saledate').value;
  const quantity = document.getElementById('amount').value;
  const price = document.getElementById('price').value;
  const discount = document.getElementById('discount').value;
  const totalCost = ((price * quantity) * (1 - (discount / 100))).toFixed(2);
  // Get the selected item name from the dropdown
  const selectedItemName = document.querySelector('.dropdown-selected .itemname').textContent;
  const legacycode = document.querySelector('.dropdown-selected .legacycode').textContent;
  const mobilecode = document.querySelector('.dropdown-selected .mobilecode').textContent;
  const stock = document.querySelector('.dropdown-selected .itemstock').textContent;
  const LegacyCustomerID = document.getElementById("customer").options[document.getElementById("customer").selectedIndex].getAttribute("legacy");



  if (!itemId || !customerId || !saledate || !quantity || !price) {
    alert("Fill up all of the requried textbox!");
    return;
    } else if (parseInt(quantity) > parseInt(stock.replace("Stock: ", ""))) {
    alert('The quantity you entered exceeds the available stock. Please adjust the quantity or check back later for restocks');
    return;
}

   const SaleData = {
    itemId: itemId,
    customerID: customerId,
    date: saledate,
    quantity: quantity,
    unitPrice: price,
    discount: discount,
    totalCost: totalCost,
    ItemName: selectedItemName,
    legacycode: legacycode,
    CustomerName: customername,
    LegacyCustomerID: LegacyCustomerID,
    mobilecode: mobilecode
  };

    fetch("http://localhost:5000/api/addnewsale", {
    method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
        body: JSON.stringify(SaleData)
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

    displaysales();

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

  const popover = document.getElementById('addsale');
  if (popover && typeof popover.hidePopover === 'function') {
    popover.hidePopover();
  }


}

// Make the Purchase function globally available
window.Sale = Sale;