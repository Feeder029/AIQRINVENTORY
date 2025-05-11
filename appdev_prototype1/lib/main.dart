import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'database_helper.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'intro_screen.dart';
import 'loading_screen.dart';
import 'signin_signup.dart';
import 'product.dart';
import 'add_quantity.dart';
import 'deduct_quantity.dart';
import 'add_product.dart';

void main() async {
  // Ensure Flutter is initialized before using platform channels
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database and insert sample data
  final dbHelper = DatabaseHelper();
  await dbHelper.insertSampleData();
  
  runApp(const MyApp());
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
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/products': (context) => const ProductScreen(),
        '/add-quantity': (context) => const AddQuantityScreen(),
        '/deduct-quantity': (context) => const DeductQuantityScreen(),
        '/add-product': (context) => const AddProductScreen()
      },
    );
  }
}


// // IntroScreen, LoginScreen, and SignupScreen 
// class IntroScreen extends StatelessWidget {
//   const IntroScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: GestureDetector(
//         onVerticalDragEnd: (details) {
//           if (details.primaryVelocity! < 0) {
//             Navigator.pushReplacementNamed(context, '/loading');
//           }
//         },
//         child: SafeArea(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Container(
//                         padding: const EdgeInsets.all(8.0),
//                         color: Colors.grey[50],
//                         child: const Text(
//                           "Where quality education is a right, not a privilege.",
//                           style: TextStyle(fontSize: 18),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Image.asset(
//                       'asset/PDM_LOGO.png', 
//                       width: 70,
//                       height: 70,
//                       errorBuilder: (context, error, stackTrace) => Container(
//                         width: 70,
//                         height: 70,
//                         color: Colors.grey[300],
//                         child: const Icon(Icons.image),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Center(
//                   child: SizedBox(
//                     width: 200,
//                     height: 200,
//                     child: Image.asset(
//                       'asset/INFOLOGO.jpg',
//                       fit: BoxFit.contain,
//                       errorBuilder: (context, error, stackTrace) => Container(
//                         width: 200,
//                         height: 200,
//                         color: const Color(0xFFE0E0E0),
//                         child: const Center(
//                           child: Icon(Icons.image_not_supported, size: 50),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Column(
//                 children: [
//                   const Icon(Icons.keyboard_arrow_up, color: Colors.grey),
//                   const SizedBox(height: 5),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 20.0),
//                     child: Text(
//                       "Swipe up",
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// Add this class after the IntroScreen class
// class LoadingScreen extends StatefulWidget {
//   const LoadingScreen({super.key});

//   @override
//   State<LoadingScreen> createState() => _LoadingScreenState();
// }

// class _LoadingScreenState extends State<LoadingScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Simulate loading process
// Future.delayed(const Duration(seconds: 2), () {
//   if (mounted) {
//     Navigator.pushReplacementNamed(context, '/login');
//   }
// });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: 200,
//               height: 200,
//               child: Image.asset(
//                 'asset/APPDEV.jpg',
//                 fit: BoxFit.contain,
//                 errorBuilder: (context, error, stackTrace) => Container(
//                   width: 200,
//                   height: 200,
//                   color: const Color(0xFFE0E0E0),
//                   child: const Center(
//                     child: Icon(Icons.image_not_supported, size: 40),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 40),
//             SizedBox(
//               width: 200,
//               child: LinearProgressIndicator(
//                 backgroundColor: Colors.grey[300],
//                 valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF5C71E8)),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               "Loading...",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[800],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   bool _isLoading = false;
//   String? _errorMessage;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     // Validate input
//     if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
//       setState(() {
//         _errorMessage = "Please enter both email and password";
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       // Attempt to login using database
//       final user = await _dbHelper.loginUser(
//         _emailController.text.trim(),
//         _passwordController.text,
//       );

//       setState(() {
//         _isLoading = false;
//       });

//       if (user != null) {
//         // Login successful
//         if (!mounted) return;
//         Navigator.pushReplacementNamed(context, '/products');
//       } else {
//         // Login failed
//         setState(() {
//           _errorMessage = "Invalid email or password";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = "An error occurred: ${e.toString()}";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const SizedBox(height: 40),
//                     const Text(
//                       "AppDev",
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         "Login to your account",
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[800],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     if (_errorMessage != null) ...[
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Colors.red[100],
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           _errorMessage!,
//                           style: const TextStyle(color: Colors.red),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                     ],
//                     TextField(
//                       controller: _emailController,
//                       decoration: const InputDecoration(
//                         hintText: "Email",
//                       ),
//                       keyboardType: TextInputType.emailAddress,
//                     ),
//                     const SizedBox(height: 16),
//                     TextField(
//                       controller: _passwordController,
//                       decoration: const InputDecoration(
//                         hintText: "Password",
//                       ),
//                       obscureText: true,
//                     ),
//                     const SizedBox(height: 24),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: _login,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF5C71E8),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Text(
//                           "Sign in",
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                     // const SizedBox(height: 30),
//                     // const Text("Or sign in with"),
//                     // const SizedBox(height: 16),
//                     // Row(
//                     //   mainAxisAlignment: MainAxisAlignment.center,
//                     //   children: [
//                     //     _socialLoginButton(),
//                     //     const SizedBox(width: 16),
//                     //     _socialLoginButton(),
//                     //     const SizedBox(width: 16),
//                     //     _socialLoginButton(),
//                     //   ],
//                     // ),
//                     const Spacer(),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Don't have account? ",
//                           style: TextStyle(color: Colors.grey[800]),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.pushNamed(context, '/signup');
//                           },
//                           child: const Text(
//                             "Sign up",
//                             style: TextStyle(
//                               color: Color(0xFF5C71E8),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }

//   // Widget _socialLoginButton() {
//   //   return Container(
//   //     width: 60,
//   //     height: 40,
//   //     decoration: BoxDecoration(
//   //       color: Colors.grey[200],
//   //       borderRadius: BorderRadius.circular(8),
//   //     ),
//   //   );
//   // }
// }

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _nameController = TextEditingController();
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   bool _isLoading = false;
//   String? _errorMessage;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   bool _validateInputs() {
//     // Validate email
//     if (_emailController.text.trim().isEmpty) {
//       setState(() {
//         _errorMessage = "Email is required";
//       });
//       return false;
//     }

//     // Simple email validation
//     final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//     if (!emailRegex.hasMatch(_emailController.text.trim())) {
//       setState(() {
//         _errorMessage = "Please enter a valid email address";
//       });
//       return false;
//     }

//     // Validate password
//     if (_passwordController.text.isEmpty) {
//       setState(() {
//         _errorMessage = "Password is required";
//       });
//       return false;
//     }

//     // Check password length
//     if (_passwordController.text.length < 6) {
//       setState(() {
//         _errorMessage = "Password must be at least 6 characters";
//       });
//       return false;
//     }

//     // Check if passwords match
//     if (_passwordController.text != _confirmPasswordController.text) {
//       setState(() {
//         _errorMessage = "Passwords do not match";
//       });
//       return false;
//     }

//     return true;
//   }

//   Future<void> _signUp() async {
//     setState(() {
//       _errorMessage = null;
//     });

//     if (!_validateInputs()) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Register user using database
//       final result = await _dbHelper.registerUser(
//         _emailController.text.trim(),
//         _passwordController.text,
//         name: _nameController.text.trim(),
//       );

//       setState(() {
//         _isLoading = false;
//       });

//       if (result > 0) {
//         // Registration successful
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Account created successfully")),
//         );
//         Navigator.pushReplacementNamed(context, '/products');
//       } else if (result == -1) {
//         // Email already exists
//         setState(() {
//           _errorMessage = "Email already registered. Please login or use another email.";
//         });
//       } else {
//         // Registration failed
//         setState(() {
//           _errorMessage = "Failed to create account. Please try again.";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = "An error occurred: ${e.toString()}";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(24.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       const SizedBox(height: 20),
//                       const Text(
//                         "AppDev",
//                         style: TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           "Create your account",
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       if (_errorMessage != null) ...[
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: Colors.red[100],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             _errorMessage!,
//                             style: const TextStyle(color: Colors.red),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                       ],
//                       TextField(
//                         controller: _nameController,
//                         decoration: const InputDecoration(
//                           hintText: "Full Name (Optional)",
//                         ),
//                         keyboardType: TextInputType.name,
//                       ),
//                       const SizedBox(height: 16),
//                       TextField(
//                         controller: _emailController,
//                         decoration: const InputDecoration(
//                           hintText: "Email",
//                         ),
//                         keyboardType: TextInputType.emailAddress,
//                       ),
//                       const SizedBox(height: 16),
//                       TextField(
//                         controller: _passwordController,
//                         decoration: const InputDecoration(
//                           hintText: "Password",
//                         ),
//                         obscureText: true,
//                       ),
//                       const SizedBox(height: 16),
//                       TextField(
//                         controller: _confirmPasswordController,
//                         decoration: const InputDecoration(
//                           hintText: "Confirm Password",
//                         ),
//                         obscureText: true,
//                       ),
//                       const SizedBox(height: 24),
//                       SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: _signUp,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF5C71E8),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text(
//                             "Sign up",
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                       // const SizedBox(height: 30),
//                       // const Text("Or sign up with"),
//                       // const SizedBox(height: 16),
//                       // Row(
//                       //   mainAxisAlignment: MainAxisAlignment.center,
//                       //   children: [
//                       //     _socialSignupButton(),
//                       //     const SizedBox(width: 16),
//                       //     _socialSignupButton(),
//                       //     const SizedBox(width: 16),
//                       //     _socialSignupButton(),
//                       //   ],
//                       // ),
//                     ],
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }

  // Widget _socialSignupButton() {
  //   return Container(
  //     width: 60,
  //     height: 40,
  //     decoration: BoxDecoration(
  //       color: Colors.grey[200],
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //   );
  // }
// }



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

// Updated ProductScreen with working navigation
// class ProductScreen extends StatefulWidget {
//   const ProductScreen({super.key});

//   @override
//   State<ProductScreen> createState() => _ProductScreenState();
// }

// class _ProductScreenState extends State<ProductScreen> {
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   List<Product> _products = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadProducts();
//   }

//   Future<void> _loadProducts() async {
//     final productsData = await _dbHelper.getProducts();
//     setState(() {
//       _products = productsData.map((data) => Product.fromMap(data)).toList();
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: const AppDrawer(), // Add the drawer here
//       appBar: AppBar(
//         backgroundColor: Colors.grey[300],
//         elevation: 0,
//         title: const Text('Products', style: TextStyle(color: Colors.black)),
//         // The menu icon will now automatically open the drawer
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.black),
//             onPressed: _loadProducts,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             child: Align(
//               alignment: Alignment.centerRight,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text("Sort by"),
//                     const SizedBox(width: 4),
//                     const Icon(Icons.arrow_drop_down, size: 18),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _products.isEmpty
//                     ? const Center(child: Text("No products found"))
//                     : GridView.builder(
//                         padding: const EdgeInsets.all(16),
//                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           mainAxisSpacing: 16,
//                           crossAxisSpacing: 16,
//                           childAspectRatio: 0.75,
//                         ),
//                         itemCount: _products.length,
//                         itemBuilder: (context, index) {
//                           final product = _products[index];
//                           return _buildProductCard(product);
//                         },
//                       ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
//     );
//   }

//   Widget _buildProductCard(Product product) {
//   return Container(
//     decoration: BoxDecoration(
//       color: const Color(0xFFF2E3E3),
//       borderRadius: BorderRadius.circular(8),
//     ),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Display product image if available, otherwise show a placeholder
//         Container(
//           width: 140,
//           height: 100,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey),
//             borderRadius: BorderRadius.circular(4),
//           ),
//           child: product.imageUrl.isNotEmpty
//               ? Image.file(
//                   File(product.imageUrl),
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     // Fallback if image loading fails
//                     return const Icon(Icons.inventory_2, size: 30);
//                   },
//                 )
//               : const Icon(Icons.inventory_2, size: 30),
//         ),
//         const SizedBox(height: 12),
//         Text(
//           product.name,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//         const SizedBox(height: 8),
//         Text(
//           "\$${product.price.toStringAsFixed(2)}",
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             color: Colors.blue,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           "Qty: ${product.quantity}",
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.grey[700],
//           ),
//         ),
//       ],
//     ),
//   );
// }
// }

// Updated AddQuantityScreen with working navigation
// class AddQuantityScreen extends StatefulWidget {
//   const AddQuantityScreen({super.key});

//   @override
//   State<AddQuantityScreen> createState() => _AddQuantityScreenState();
// }

// class _AddQuantityScreenState extends State<AddQuantityScreen> {
//   String _scannedCode = "";
//   final TextEditingController _quantityController = TextEditingController();
//   bool _hasScanned = false;
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   String _productName = "";
//   bool _isLoading = false;
//   bool _isValidProduct = false;

//   @override
//   void dispose() {
//     _quantityController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleCodeScanned(String code) async {
//     setState(() {
//       _isLoading = true;
//       _scannedCode = code;
//     });

//     // Check if product exists in database
//     final product = await _dbHelper.getProductById(code);
    
//     setState(() {
//       _isLoading = false;
//       _hasScanned = true;
      
//       if (product != null) {
//         _isValidProduct = true;
//         _productName = product['name'] as String;
//       } else {
//         _isValidProduct = false;
//         _productName = "";
//       }
//     });
//   }

//   void _scanQRCode() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => QRScannerView(onCodeScanned: _handleCodeScanned),
//       ),
//     );
//   }

//   Future<void> _addQuantity() async {
//     if (_quantityController.text.isEmpty) {
//       // Show error for empty quantity
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a quantity")),
//       );
//       return;
//     }

//     // Parse quantity
//     final quantity = int.tryParse(_quantityController.text);
//     if (quantity == null || quantity <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a valid quantity")),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     // Update quantity in database
//     final result = await _dbHelper.addQuantity(_scannedCode, quantity);
    
//     setState(() {
//       _isLoading = false;
//     });

//     if (result > 0) {
//       // Show success dialog
//       if (!mounted) return;
//       showSuccessDialog(
//         context, 
//         "Successfully added $quantity items to $_productName"
//       );
      
//       // Clear the input
//       _quantityController.clear();
//     } else {
//       // Show error
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to update quantity")),
//       );
//     }
//   }

//   Widget _cameraBox() {
//     // Implement your camera box widget here
//     return Container(
//       width: double.infinity,
//       height: 350,
//       margin: const EdgeInsets.symmetric(horizontal: 32),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Center(
//         child: _hasScanned
//             ? const Icon(Icons.check_circle, color: Colors.green, size: 64)
//             : const Icon(Icons.qr_code_scanner, color: Colors.grey, size: 64),
//       ),
//     );
//   }

//   Widget _actionButton(String text, Color color, VoidCallback? onPressed) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         foregroundColor: Colors.white,
//         disabledBackgroundColor: Colors.grey[400],
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//       child: Text(text),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: const AppDrawer(), 
//       appBar: AppBar(
//         backgroundColor: Colors.grey[300],
//         elevation: 0,
//         title: const Text("Add Quantity", style: TextStyle(color: Colors.black)),
//         // Remove the custom leading widget to use the default drawer toggle
//       ),
//       body: _isLoading 
//         ? const Center(child: CircularProgressIndicator())
//         : Column(
//           children: [
//             const SizedBox(height: 16),
//             _cameraBox(),
//             if (_hasScanned) ...[
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.qr_code, color: Colors.black54),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             "Product ID: $_scannedCode",
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (_isValidProduct) ...[
//                       const SizedBox(height: 4),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 32.0),
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             "Product: $_productName",
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.green,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ] else if (_productName.isEmpty && _hasScanned) ...[
//                       const SizedBox(height: 4),
//                       const Padding(
//                         padding: EdgeInsets.only(left: 32.0),
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             "Product not found in database",
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.red,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _actionButton("Scan", Colors.blue, _scanQRCode),
//                 _actionButton(
//                   "Add quantity", 
//                   Colors.green, 
//                   (_hasScanned && _isValidProduct) ? _addQuantity : null
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               child: TextField(
//                 controller: _quantityController,
//                 decoration: InputDecoration(
//                   hintText: "Quantity",
//                   filled: true,
//                   fillColor: Colors.grey[300],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                 ),
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//               ),
//             ),
//           ],
//         ),
//       bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
//     );
//   }
// }

// Updated DeductQuantityScreen with working navigation
// class DeductQuantityScreen extends StatefulWidget {
//   const DeductQuantityScreen({super.key});

//   @override
//   State<DeductQuantityScreen> createState() => _DeductQuantityScreenState();
// }

// class _DeductQuantityScreenState extends State<DeductQuantityScreen> {
//   String _scannedCode = "";
//   final TextEditingController _quantityController = TextEditingController();
//   bool _hasScanned = false;
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   String _productName = "";
//   int _currentQuantity = 0;
//   bool _isLoading = false;
//   bool _isValidProduct = false;

//   @override
//   void dispose() {
//     _quantityController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleCodeScanned(String code) async {
//     setState(() {
//       _isLoading = true;
//       _scannedCode = code;
//     });

//     // Check if product exists in database
//     final product = await _dbHelper.getProductById(code);
    
//     setState(() {
//       _isLoading = false;
//       _hasScanned = true;
      
//       if (product != null) {
//         _isValidProduct = true;
//         _productName = product['name'] as String;
//         _currentQuantity = product['quantity'] as int;
//       } else {
//         _isValidProduct = false;
//         _productName = "";
//         _currentQuantity = 0;
//       }
//     });
//   }

//   void _scanQRCode() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => QRScannerView(onCodeScanned: _handleCodeScanned),
//       ),
//     );
//   }

//   Future<void> _deductQuantity() async {
//     if (_quantityController.text.isEmpty) {
//       // Show error for empty quantity
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a quantity")),
//       );
//       return;
//     }

//     // Parse quantity
//     final quantity = int.tryParse(_quantityController.text);
//     if (quantity == null || quantity <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a valid quantity")),
//       );
//       return;
//     }

//     // Check if we have enough stock
//     if (quantity > _currentQuantity) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Not enough stock! Current quantity: $_currentQuantity")),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     // Update quantity in database
//     final result = await _dbHelper.deductQuantity(_scannedCode, quantity);
    
//     setState(() {
//       _isLoading = false;
//       if (result > 0) {
//         _currentQuantity -= quantity;
//       }
//     });

//     if (result > 0) {
//       // Show success dialog
//       if (!mounted) return;
//       showSuccessDialog(
//         context, 
//         "Successfully deducted $quantity items from $_productName"
//       );
      
//       // Clear the input
//       _quantityController.clear();
//     } else {
//       // Show error
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to update quantity")),
//       );
//     }
//   }

//   Widget _cameraBox() {
//     // Camera box widget implementation
//     return Container(
//       width: double.infinity,
//       height: 350,
//       margin: const EdgeInsets.symmetric(horizontal: 32),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Center(
//         child: _hasScanned
//             ? const Icon(Icons.check_circle, color: Colors.green, size: 64)
//             : const Icon(Icons.qr_code_scanner, color: Colors.grey, size: 64),
//       ),
//     );
//   }

//   Widget _actionButton(String text, Color color, VoidCallback? onPressed) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         foregroundColor: Colors.white,
//         disabledBackgroundColor: Colors.grey[400],
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//       child: Text(text),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: const AppDrawer(),
//       appBar: AppBar(
//         backgroundColor: Colors.grey[300],
//         elevation: 0,
//         title: const Text("Deduct Quantity", style: TextStyle(color: Colors.black)),
//         // Remove the custom leading widget to use the default drawer toggle
//       ),
//       body: _isLoading 
//         ? const Center(child: CircularProgressIndicator())
//         : Column(
//           children: [
//             const SizedBox(height: 16),
//             _cameraBox(),
//             if (_hasScanned) ...[
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.qr_code, color: Colors.black54),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             "Product ID: $_scannedCode",
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (_isValidProduct) ...[
//                       const SizedBox(height: 4),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 32.0),
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             "Product: $_productName",
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.green,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 32.0),
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             "Current Stock: $_currentQuantity",
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ] else if (_productName.isEmpty && _hasScanned) ...[
//                       const SizedBox(height: 4),
//                       const Padding(
//                         padding: EdgeInsets.only(left: 32.0),
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             "Product not found in database",
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.red,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _actionButton("Scan", Colors.blue, _scanQRCode),
//                 _actionButton(
//                   "Deduct", 
//                   Colors.red, 
//                   (_hasScanned && _isValidProduct) ? _deductQuantity : null
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               child: TextField(
//                 controller: _quantityController,
//                 decoration: InputDecoration(
//                   hintText: "Quantity",
//                   filled: true,
//                   fillColor: Colors.grey[300],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                 ),
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//               ),
//             ),
//           ],
//         ),
//       bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
//     );
//   }
// }

// Keep your existing helper widgets
// Widget _cameraBox() {
//   return Center(
//     child: Container(
//       width: 300,
//       height: 240,
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: const Center(
//         child: Icon(Icons.camera_alt_outlined, size: 48, color: Colors.black54),
//       ),
//     ),
//   );
// }

// Widget _actionButton(String label, Color color, VoidCallback? onPressed) {
//   return SizedBox(
//     width: 140,
//     height: 40,
//     child: ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: onPressed == null ? Colors.grey : color,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//       child: Text(label, style: const TextStyle(color: Colors.white)),
//     ),
//   );
// }

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

// AddProductScreen with working navigationn and database functionality

// class AddProductScreen extends StatefulWidget {
//   const AddProductScreen({super.key});

//   @override
//   State<AddProductScreen> createState() => _AddProductScreenState();
// }

// class _AddProductScreenState extends State<AddProductScreen> {
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   final _formKey = GlobalKey<FormState>();
//   final ImagePicker _imagePicker = ImagePicker();
  
//   // Form controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _quantityController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _idController = TextEditingController();
  
//   bool _isLoading = false;
//   String? _nameError;
//   String? _quantityError;
//   String? _priceError;
//   String? _idError;
  
//   // Add image file variable
//   File? _selectedImage;
//   String? _imagePath;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _quantityController.dispose();
//     _descriptionController.dispose();
//     _priceController.dispose();
//     _idController.dispose();
//     super.dispose();
//   }

//   // Method to pick image from gallery
//   Future<void> _pickImage() async {
//     try {
//       final XFile? pickedImage = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 80,
//       );
      
//       if (pickedImage != null) {
//         setState(() {
//           _selectedImage = File(pickedImage.path);
//           _imagePath = pickedImage.path;
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error picking image: ${e.toString()}")),
//       );
//     }
//   }

//   // Method to take a photo with camera
//   Future<void> _takePhoto() async {
//     try {
//       final XFile? takenImage = await _imagePicker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 80,
//       );
      
//       if (takenImage != null) {
//         setState(() {
//           _selectedImage = File(takenImage.path);
//           _imagePath = takenImage.path;
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error taking photo: ${e.toString()}")),
//       );
//     }
//   }

//   // Show image source dialog
//   void _showImageSourceDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text("Select Image Source"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text("Gallery"),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage();
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text("Camera"),
//               onTap: () {
//                 Navigator.pop(context);
//                 _takePhoto();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Validate all fields before submission
//   bool _validateInputs() {
//     bool isValid = true;
    
//     // Reset errors
//     setState(() {
//       _nameError = null;
//       _quantityError = null;
//       _priceError = null;
//       _idError = null;
//     });
    
//     // Validate name
//     if (_nameController.text.trim().isEmpty) {
//       setState(() {
//         _nameError = "Product name is required";
//       });
//       isValid = false;
//     }
    
//     // Validate quantity
//     if (_quantityController.text.trim().isEmpty) {
//       setState(() {
//         _quantityError = "Quantity is required";
//       });
//       isValid = false;
//     } else {
//       final quantity = int.tryParse(_quantityController.text);
//       if (quantity == null || quantity < 0) {
//         setState(() {
//           _quantityError = "Please enter a valid quantity";
//         });
//         isValid = false;
//       }
//     }
    
//     // Validate price
//     if (_priceController.text.trim().isEmpty) {
//       setState(() {
//         _priceError = "Price is required";
//       });
//       isValid = false;
//     } else {
//       final price = double.tryParse(_priceController.text);
//       if (price == null || price <= 0) {
//         setState(() {
//           _priceError = "Please enter a valid price";
//         });
//         isValid = false;
//       }
//     }
    
//     // Validate product ID
//     if (_idController.text.trim().isEmpty) {
//       setState(() {
//         _idError = "Product ID is required";
//       });
//       isValid = false;
//     }
    
//     return isValid;
//   }

//   // Add product to database
//   Future<void> _addProduct() async {
//     if (!_validateInputs()) return;
    
//     setState(() {
//       _isLoading = true;
//     });
    
//     try {
//       // Check if product ID already exists
//       final existingProduct = await _dbHelper.getProductById(_idController.text);
      
//       if (existingProduct != null) {
//         if (!mounted) return;
//         setState(() {
//           _idError = "Product ID already exists";
//           _isLoading = false;
//         });
//         return;
//       }
      
//       // Create product map
//       final productMap = {
//         'id': _idController.text,
//         'name': _nameController.text,
//         'description': _descriptionController.text,
//         'price': double.parse(_priceController.text),
//         'quantity': int.parse(_quantityController.text),
//         'image_url': _imagePath ?? '', // Use the selected image path
//       };
      
//       // Insert into database
//       final result = await _dbHelper.insertProduct(productMap);
      
//       setState(() {
//         _isLoading = false;
//       });
      
//       if (result > 0) {
//         // Show success dialog
//         if (!mounted) return;
//         showSuccessDialog(
//           context, 
//           "Product ${_nameController.text} successfully added"
//         );
        
//         // Clear form fields
//         _nameController.clear();
//         _quantityController.clear();
//         _descriptionController.clear();
//         _priceController.clear();
//         _idController.clear();
//         setState(() {
//           _selectedImage = null;
//           _imagePath = null;
//         });
//       } else {
//         // Show error
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Failed to add product")),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
      
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: ${e.toString()}")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: const AppDrawer(),
//       appBar: AppBar(
//         backgroundColor: Colors.grey[300],
//         elevation: 0,
//         title: const Text("Add Product", style: TextStyle(color: Colors.black)),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       _buildInputField(
//                         "Product ID", 
//                         _idController,
//                         errorText: _idError,
//                       ),
//                       const SizedBox(height: 12),
//                       _buildInputField(
//                         "Product Name", 
//                         _nameController,
//                         errorText: _nameError,
//                       ),
//                       const SizedBox(height: 12),
//                       _buildInputField(
//                         "Quantity", 
//                         _quantityController,
//                         keyboardType: TextInputType.number,
//                         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                         errorText: _quantityError,
//                       ),
//                       const SizedBox(height: 12),
//                       _buildInputField(
//                         "Price", 
//                         _priceController,
//                         keyboardType: TextInputType.numberWithOptions(decimal: true),
//                         inputFormatters: [
//                           FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
//                         ],
//                         errorText: _priceError,
//                         prefix: "\$",
//                       ),
//                       const SizedBox(height: 12),
//                       _buildInputField(
//                         "Product Description", 
//                         _descriptionController,
//                         maxLines: 3,
//                       ),
//                       const SizedBox(height: 16),
//                       _imagePickerButton(),
//                       const SizedBox(height: 24),
//                       SizedBox(
//                         width: 170,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: _addProduct,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF5C71E8),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text("Add Product", 
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                             )
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//       bottomNavigationBar: CustomBottomNavBar(currentIndex: 3),
//     );
//   }

//   Widget _buildInputField(
//     String hint, 
//     TextEditingController controller, {
//     TextInputType keyboardType = TextInputType.text,
//     List<TextInputFormatter>? inputFormatters,
//     String? errorText,
//     int maxLines = 1,
//     String? prefix,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextField(
//             controller: controller,
//             decoration: InputDecoration(
//               hintText: hint,
//               filled: true,
//               fillColor: Colors.grey[200],
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: errorText != null ? 
//                     const BorderSide(color: Colors.red, width: 1.0) : 
//                     BorderSide.none,
//               ),
//               enabledBorder: errorText != null ? 
//                   OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: const BorderSide(color: Colors.red, width: 1.0),
//                   ) : null,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               prefixText: prefix,
//               suffixIcon: errorText != null 
//                   ? Icon(Icons.error_outline, color: Colors.red[400], size: 22)
//                   : null,
//             ),
//             keyboardType: keyboardType,
//             inputFormatters: inputFormatters,
//             maxLines: maxLines,
//           ),
//           if (errorText != null)
//             Padding(
//               padding: const EdgeInsets.only(left: 12.0, top: 4.0),
//               child: Text(
//                 errorText,
//                 style: const TextStyle(color: Colors.red, fontSize: 12),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _imagePickerButton() {
//     return InkWell(
//       onTap: _showImageSourceDialog,
//       child: Container(
//         width: double.infinity,
//         height: 200,
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey.shade400, width: 1),
//         ),
//         child: _selectedImage != null
//             ? ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.file(
//                   _selectedImage!,
//                   fit: BoxFit.cover,
//                 ),
//               )
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Tap to upload product image",
//                     style: TextStyle(
//                       color: Colors.grey[700],
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }

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
  final String imageUrl;
  final String description;
  final double price;
  final int quantity; 

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.quantity,
  });

  // Add this factory constructor
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      imageUrl: map['image_url'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
    );
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