import { fetchData } from '../Function/getdata.js';

function displayCustomers() {
    fetchData("displaycustomer", data => {
      let display = `<tr id="table-head">
        <th>ID</th>
        <th>NAME</th>
        <th>EMAIL</th>
        <th id="head-mobile">PHONE</th>
        <th id="head-phone2">PHONE 2</th>
        <th>ADDRESS</th>
        <th id="head-status">STATUS</th>
        <th id="head-action">ACTION</th>
      </tr>`;
  
      if (data.customer && data.customer.length > 0) {
        data.customer.forEach(item => {
          display += `
          <tr id="data">
            <td id="id">${item.CustomerID}</td>
            <td id="name">${item.C_LFullName}</td>
            <td id="email">${item.C_Email}</td>
            <td id="mobile">${item.C_Mobile}</td>
            <td id="phone2">${item.C_Mobile2}</td>
            <td id="address">${item.CA_Street}</td>
            <td id="status"><button>${item.C_status}</button></td>
            <td id="action">
              <div class="action-icon">
                <button><i class="fa-solid fa-pen-to-square"></i></button>
                <button><i class="fa-solid fa-trash"></i></button>
              </div>
            </td>
          </tr>`;
        });
      }
  
      document.getElementById('customer-list').innerHTML = display;
    });
}
  

displayCustomers();