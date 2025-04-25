import { fetchData } from '../Function/getdata.js';
function displayCustomers() {
    fetchData("displayvendors", data => {
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
  
      if (data.vendor && data.vendor.length > 0) {
        data.vendor.forEach(item => {
          display += `
          <tr id="data">
            <td id="id">${item.VendorID}</td>
            <td id="name">${item.V_LFullName}</td>
            <td id="email">${item.V_Email}</td>
            <td id="mobile">${item.V_Mobile}</td>
            <td id="phone2">${item.V_Mobile2}</td>
            <td id="address">${item.VA_Street}</td>
            <td id="status"><button>${item.V_status}</button></td>
            <td id="action">
              <div class="action-icon">
                <button><i class="fa-solid fa-pen-to-square"></i></button>
                <button><i class="fa-solid fa-trash"></i></button>
              </div>
            </td>
          </tr>`;
        });
      }
  
      document.getElementById('vendor-list').innerHTML = display;
    });
}
  

displayCustomers();