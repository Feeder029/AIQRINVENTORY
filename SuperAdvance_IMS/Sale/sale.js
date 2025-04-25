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
                        <div class="info-value">${item.S_Date}</div>
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

// Call this initially to load the sales data
displaysales();