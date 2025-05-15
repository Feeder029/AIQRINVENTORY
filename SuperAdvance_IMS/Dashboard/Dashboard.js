        // ARIMA Forecast Chart
        const forecastCtx = document.getElementById('forecastChart').getContext('2d');
        const forecastChart = new Chart(forecastCtx, {
            type: 'line',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'],
                datasets: [{
                    label: 'Actual Sales',
                    data: [65, 72, 78, 84, 95, 102, 110, null],
                    borderColor: '#555',
                    backgroundColor: 'transparent',
                    tension: 0.3,
                    pointBackgroundColor: '#555'
                }, {
                    label: 'Forecasted Sales',
                    data: [null, null, null, null, null, null, 110, 118],
                    borderColor: '#888',
                    backgroundColor: 'transparent',
                    borderDash: [5, 5],
                    tension: 0.3,
                    pointBackgroundColor: '#888'
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'top',
                    },
                },
                scales: {
                    y: {
                        beginAtZero: false,
                        grid: {
                            color: '#eee'
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        }
                    }
                }
            }
        });
        
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