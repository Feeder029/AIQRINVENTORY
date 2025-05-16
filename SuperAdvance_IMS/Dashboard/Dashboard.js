
import { fetchData } from '../Function/getdata.js';

function DisplaySuggestions(){

    let total = 0;
    let under = 0;
    let over = 0;
    let reasonable = 0;

    fetchData("displayitems", data => {

        let display = `<thead>
                            <tr>
                                <th>Product</th>
                                <th>My Shop</th>
                                <th>Suggested</th>
                                <th>eBay</th>
                                <th>Microcenter</th>
                                <th>Amazon</th>
                                <th>Walmart</th>
                            </tr>
                        </thead>
                        <tbody>`;

        if(data.items && data.items.length > 0) {
            data.items.forEach(item => {

                total++;

                switch(item.PriceStatus){
                    case "Fit":
                        reasonable++
                    break
                    case "Underprice":
                        under++
                    break
                    case "Overprice":
                        over++
                    break
                }

                const Wallmart = item.I_WallmartSuggestedPrice ? "$" + item.I_WallmartSuggestedPrice : "N/A";
                const Amazon = item.I_AmazonSuggestedPrice ?  "$" + item.I_AmazonSuggestedPrice : "N/A";
                const MC = item.I_MCSuggestedPrice ?  "$" + item.I_MCSuggestedPrice : "N/A";

                display += `
                            <tr>
                                <td>${item.I_Name}</td>
                                <td class="price-comparison">$${item.I_UnitPrice}</td>
                                <td>$${item.I_SuggestedPrice}</td>
                                <td>$${item.I_EbaySuggestedPrice}</td>
                                <td>${MC}</td>
                                <td>${Amazon}</td>
                                <td>${Wallmart}</td>
                            </tr>`
            })

            display += `
            </tbody>`;
        }

        Data(total,under,over,reasonable)
        document.getElementById('PriceComparison').innerHTML = display

    });

    fetchData("TopFiveItems",data=>{

        let display  = ``
        let i = 1

        if(data.Top && data.Top.length > 0) {

            data.Top.forEach(item => {

                console.log(item)

                display += ` <li>
                        <div class="item-details">
                            <div class="item-icon">${i}</div>
                            <div>
                                <div class="item-name">${item.I_Name}</div>
                                <div class="progress-container">
                                    <div class="progress-bar" style="width: 100%;"></div>
                                </div>
                            </div>
                        </div>
                        <div class="item-sales">${item.Total_Quantity_Sold} sold</div>
                    </li>`
                i++
            })

            document.getElementById('Top5').innerHTML = display
        }
    })

}

DisplaySuggestions();
      
function Data(total,under,over,reasonable){

    document.getElementById('Total').textContent = total
    document.getElementById('Under').textContent = under
    document.getElementById('Over').textContent = over
    document.getElementById('Reasonable').textContent = reasonable

}
      
      
      
      
      
    
      

        
        // Inventory Distribution Chart
        const distributionCtx = document.getElementById('inventoryDistribution').getContext('2d');
           const distributionChart = new Chart(distributionCtx, {
            type: 'doughnut',
            data: {
                labels: ['Peripherals', 'Audio', 'Storage', 'Displays', 'Accessories'],
                datasets: [{
                    data: [35, 25, 15, 10, 15],
                    backgroundColor: [
                        '#333',
                        '#555',
                        '#777',
                        '#999',
                        '#bbb'
                    ],
                    borderWidth: 1,
                    borderColor: '#fff'
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'right',
                    }
                }
            }
        });