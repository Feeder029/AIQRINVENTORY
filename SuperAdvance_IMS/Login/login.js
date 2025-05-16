import { fetchData } from '../Function/getdata.js';


function GetUser() {
    // Show loading state
    Swal.fire({
        title: 'Logging in...',
        text: 'Please wait while we verify your credentials',
        allowOutsideClick: false,
        showConfirmButton: false,
        willOpen: () => {
            Swal.showLoading();
        }
    });

    const user = document.getElementById("user").value.trim();
    const pass = document.getElementById("password").value;

    // Basic validation before sending request
    if (!user || !pass) {
        return Swal.fire({
            icon: 'error',
            title: 'Missing Information',
            text: 'Please enter both username and password',
            confirmButtonColor: '#3085d6'
        });
    }

    fetchData("getuser", data => {
        if (data.user && data.user.length > 0) {
            // Find matching user
            const foundUser = data.user.find(item => 
                item.username === user && item.password === pass
            );
            
            if (foundUser) {
                // Success case
                Swal.fire({
                    icon: 'success',
                    title: 'Login Successful!',
                    text: 'Welcome back, ' + user,
                    timer: 1500,
                    showConfirmButton: false
                }).then(() => {
                    // Save login state if needed
                    sessionStorage.setItem('loggedInUser', user);
                    // Redirect
                    window.location.href = "../index.html";
                });
            } else {
                // Invalid credentials
                Swal.fire({
                    icon: 'error',
                    title: 'Access Denied',
                    text: 'Invalid username or password',
                    confirmButtonColor: '#3085d6'
                });
            }
        } else {
            // No user data returned
            Swal.fire({
                icon: 'warning',
                title: 'System Error',
                text: 'Unable to verify credentials. Please try again later.',
                confirmButtonColor: '#3085d6'
            });
            console.log("No user data available");
        }
    }).catch(error => {
        // Handle network or other errors
        Swal.fire({
            icon: 'error',
            title: 'Connection Error',
            text: 'Unable to connect to the server. Please check your connection.',
            confirmButtonColor: '#3085d6'
        });
        console.error("Login error:", error);
    });
}

window.GetUser = GetUser;

function showTab(tabName) {
            // Hide all form containers
            const formContainers = document.querySelectorAll('.form-container');
            formContainers.forEach(container => {
                container.classList.remove('active');
            });
            
            // Show the selected form container
            document.getElementById(tabName + '-form').classList.add('active');
            
            // Update tab styles
            const tabs = document.querySelectorAll('.tab');
            tabs.forEach(tab => {
                tab.classList.remove('active');
            });
            
            // Find the clicked tab and make it active
            const clickedTab = Array.from(tabs).find(tab => tab.textContent.toLowerCase() === tabName);
            if (clickedTab) {
                clickedTab.classList.add('active');
            }
}

window.showTab = showTab;


