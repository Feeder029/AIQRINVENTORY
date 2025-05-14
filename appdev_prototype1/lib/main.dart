import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async';
import 'intro_screen.dart';
import 'loading_screen.dart';
import 'signin_signup.dart';
import 'product.dart';
import 'add_quantity.dart';
import 'deduct_quantity.dart';
import 'add_product.dart';
import 'package:firebase_core/firebase_core.dart';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPT/HCI/APPDEV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Serif',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const IntroScreen(),
        '/loading': (context) => const LoadingScreen(),
        '/login': (context) => const AuthScreen(), // Replace with combined widget
        '/signup': (context) => const AuthScreen(), // Same widget handles both
        '/products': (context) => const ProductScreen(),
        '/add-quantity': (context) => const AddQuantityScreen(),
        '/deduct-quantity': (context) => const DeductQuantityScreen(),
        '/add-product': (context) => const AddProductScreen()
      },
    );
  }
}


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Drawer header with app logo/name
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              color: const Color(0xFF5C71E8),
              width: double.infinity,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AppDev",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Inventory Management",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Drawer items
            const SizedBox(height: 16),
            
            // Account item
            ListTile(
              leading: const Icon(Icons.account_circle, size: 28),
              title: const Text(
                "Account",
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                // Close the drawer first
                Navigator.pop(context);
                // Functionality will be added later
              },
            ),
            
            // Theme item
            ListTile(
              leading: const Icon(Icons.color_lens, size: 28),
              title: const Text(
                "Theme",
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                // Functionality will be added later
              },
            ),
            
            // Divider before logout
            const Divider(),
            
            // Logout item with functionality
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red, size: 28),
              title: const Text(
                "Logout",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                // Close the drawer
                Navigator.pop(context);
                
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close dialog
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close dialog
                            
                            // Clear any local storage or user data here if needed
                            // For example:
                            // SharedPreferences.getInstance().then((prefs) {
                            //   prefs.clear();
                            // });
                            
                            // Navigate to login screen and remove all previous routes
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login', // Replace with your login route
                              (route) => false, // This will remove all previous routes
                            );
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            
            // App version at the bottom
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Version 1.0.0",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class QRScannerView extends StatefulWidget {
  final Function(String) onCodeScanned;
  
  const QRScannerView({super.key, required this.onCodeScanned});

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  MobileScannerController cameraController = MobileScannerController();
  bool _hasScanned = false;
  
  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_hasScanned) return;
              
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes[0].rawValue != null) {
                final String code = barcodes[0].rawValue!;
                setState(() {
                  _hasScanned = true;
                });
                widget.onCodeScanned(code);
                Navigator.pop(context);
              }
            },
          ),
          // Scan area overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          // Bottom instructions
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Position QR code in the center",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Add a success dialog that will show after quantity operations
void showSuccessDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK", style: TextStyle(color: Color(0xFF5C71E8))),
          ),
        ],
      );
    },
  );
}


// New CustomBottomNavBar widget to handle navigation
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navBarItem(
            context, 
            Icons.shopping_bag, 
            currentIndex == 0, 
            () => _navigateTo(context, '/products'),
          ),
          _navBarItem(
            context, 
            Icons.add_circle_outline, 
            currentIndex == 1, 
            () => _navigateTo(context, '/add-quantity'),
          ),
          _navBarItem(
            context, 
            Icons.remove_circle_outline, 
            currentIndex == 2, 
            () => _navigateTo(context, '/deduct-quantity'),
          ),
          _navBarItem(
            context, 
            Icons.add, 
            currentIndex == 3, 
            () => _navigateTo(context, '/add-product'),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  Widget _navBarItem(BuildContext context, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }
}



// Existing model classes and services
class User {
  final int? id;
  final String email;
  final String password;
  final String? name;
  final String? createdAt;

  User({
    this.id,
    required this.email,
    required this.password,
    this.name,
    this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      password: map['password'] as String,
      name: map['name'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'created_at': createdAt,
    };
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String description;
  final String imageUrl;
  final String qrData;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.description = '',
    this.imageUrl = '',
    this.qrData = '',
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] ?? 0).toInt(),
      description: map['description'] ?? '',
      imageUrl: map['image_url'] ?? '',
      qrData: map['qr_data'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'description': description,
      'image_url': imageUrl,
      'qr_data': qrData,
    };
  }
}

class AuthService {
  // Simulate authentication
  Future<bool> signIn(String email, String password) async {
    // In a real app, you would validate credentials against a backend
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> signUp(String email, String password) async {
    // In a real app, you would register a new user on your backend
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<void> signOut() async {
    // Clear user session
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

class ProductService {
  // Simulate fetching products from an API
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample product data
    return List.generate(
      10,
      (index) => Product(
        id: 'product_$index',
        name: 'Product ${index + 1}',
        imageUrl: 'https://via.placeholder.com/150',
        description: 'This is product ${index + 1} description',
        price: (index + 1) * 10.0,
        quantity: (index + 1) * 5, // Added the required quantity parameter
      ),
    );
  }
}