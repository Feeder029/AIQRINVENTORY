function displaysales(){
    fetch("http://localhost:5000/api/displaysales")
    .then(response => response.json())
    .then(data=>{
        if(data.status === "success"){
            let display="";
            if(data.sales && data.sales.length>0){
                data.sales.forEach(item => {
                    console.log("Working");

                    display+= `
                    <div class="sale-card">
                    <div class="sale-card-header">
                        <div class="order-id">#ORD-${item.S_LegacyID}</div>
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
                    `
                });
            } else {
                console.log("No items found");
            }

            document.getElementById('salesinfo').innerHTML = display;
        } else {
            console.log("Access Denied:", data.message || "Unknown error");
            document.getElementById('items_display').innerHTML = "<p>Error loading inventory data</p>";
        }
    }
    ).catch(error => {
        console.error("Access Error:", error);
        document.getElementById('items_display').innerHTML = "<p>Error connecting to server</p>";
    });
}


displaysales();