export function fetchData(route, handleSuccess, handleError = null) {
    const apiUrl = `http://localhost:5000/api/${route}`;
    console.log(`Fetching from: ${apiUrl}`);
    
    fetch(apiUrl)
      .then(response => response.json())
      .then(data => {
        if (data.status === "success") {
          handleSuccess(data);
          console.log("Request successful");
        } else {
          const errorMessage = data.message || "Unknown error";
          console.log("Access Denied:", errorMessage);
          if (handleError) {
            handleError(errorMessage);
          } else {
            document.getElementById('items_display').innerHTML = "<p>Error loading data</p>";
          }
        }
      })
      .catch(error => {
        console.error("Access Error:", error);
        if (handleError) {
          handleError(error.message);
        } else {
          document.getElementById('items_display').innerHTML = "<p>Error connecting to server</p>";
        }
      });
}