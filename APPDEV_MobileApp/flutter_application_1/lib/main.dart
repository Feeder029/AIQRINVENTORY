import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MyApp());
}

// Routes in MyApp class remain the same
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
        '/loading': (context) => const MinimalistLoadingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/products': (context) => const ProductScreen(),
        '/add-quantity': (context) => const AddQuantityScreen(),
        '/deduct-quantity': (context) => const DeductQuantityScreen(),
        '/add-product': (context) => const AddProductScreen(),
        '/scanner': (context) => const QRScannerScreen(), // Add new route for scanner
      },
    );
  }
}

// IntroScreen implementation remains the same
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.pushReplacementNamed(context, '/loading');
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.grey[200],
                        child: const Text(
                          "Where quality education is a right, not a privilege.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Image.asset(
                      'assets/logo_badge.png', 
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image),
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
                      child: Center(
                        child: Text(
                          "LOGO",
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.keyboard_arrow_up, color: Colors.grey),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "Swipe up",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Loading Screen code remains the same
class MinimalistLoadingScreen extends StatefulWidget {
  const MinimalistLoadingScreen({super.key});

  @override
  State<MinimalistLoadingScreen> createState() => _MinimalistLoadingScreenState();
}

class _MinimalistLoadingScreenState extends State<MinimalistLoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    
    // Animation controller for loading indicator
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    // Navigate to login screen after a short delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple Logo Container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF5C71E8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "A",
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // App Name
            const Text(
              "AppDev",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            // Modern, minimalist loading indicator
            _buildModernLoadingIndicator(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModernLoadingIndicator() {
    return SizedBox(
      width: 80,
      height: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          3,
          (index) => _buildDotWithAnimation(index * 0.2),
        ),
      ),
    );
  }
  
  Widget _buildDotWithAnimation(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Create a delayed animation for each dot
        final double animation = (((_controller.value + delay) % 1.0) < 0.5)
            ? ((_controller.value + delay) % 0.5) * 2 // 0 to 1 in first half
            : 1 - (((_controller.value + delay) % 0.5) * 2); // 1 to 0 in second half
            
        return Transform.scale(
          scale: 0.5 + (animation * 0.5), // Scale between 0.5 and 1.0
          child: Opacity(
            opacity: 0.3 + (animation * 0.7), // Opacity between 0.3 and 1.0
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF5C71E8),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Login and Signup screens remain the same
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                "AppDev",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Login to your account",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: "Email",
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  hintText: "Password",
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/products');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C71E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Sign in",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text("Or sign in with"),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialLoginButton(),
                  const SizedBox(width: 16),
                  _socialLoginButton(),
                  const SizedBox(width: 16),
                  _socialLoginButton(),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have account? ",
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        color: Color(0xFF5C71E8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButton() {
    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "AppDev",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Create your account",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: "Email",
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  hintText: "Password",
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  hintText: "Confirm Password",
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/products');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C71E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text("Or sign up with"),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialSignupButton(),
                  const SizedBox(width: 16),
                  _socialSignupButton(),
                  const SizedBox(width: 16),
                  _socialSignupButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialSignupButton() {
    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// New QR Scanner Screen
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;
  String? _scannedCode;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(
                      Icons.flash_off,
                      color: Colors.black,
                    );
                  case TorchState.on:
                    return const Icon(
                      Icons.flash_on,
                      color: Colors.black,
                    );
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(
                      Icons.camera_front,
                      color: Colors.black,
                    );
                  case CameraFacing.back:
                    return const Icon(
                      Icons.camera_rear,
                      color: Colors.black,
                    );
                }
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isScanning
                ? MobileScanner(
                    controller: controller,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final Barcode barcode = barcodes.first;
                        // Stop scanning temporarily to avoid multiple scans
                        setState(() {
                          _isScanning = false;
                          _scannedCode = barcode.rawValue;
                        });
                        
                        // Show success dialog
                        _showScanResultDialog(context, barcode.rawValue ?? 'Unknown code');
                      }
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'QR Code Scanned Successfully!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Value: $_scannedCode',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isScanning = true;
                              _scannedCode = null;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C71E8),
                          ),
                          child: const Text('Scan Again'),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showScanResultDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Detected'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scanned successfully:'),
            const SizedBox(height: 8),
            Text(
              code,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
              });
            },
            child: const Text('Scan Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, code); // Return the scanned code to previous screen
            },
            child: const Text('Use This Code'),
          ),
        ],
      ),
    );
  }
}

// Updated AddQuantityScreen with working scan button
class AddQuantityScreen extends StatefulWidget {
  const AddQuantityScreen({super.key});

  @override
  State<AddQuantityScreen> createState() => _AddQuantityScreenState();
}

class _AddQuantityScreenState extends State<AddQuantityScreen> {
  final TextEditingController _quantityController = TextEditingController();
  String? _scannedProductId;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _customAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _cameraBox(_scannedProductId),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton("Scan", Colors.blue, () => _startScanning(context)),
              _actionButton("Add quantity", Colors.green, () => _addQuantity()),
            ],
          ),
          const SizedBox(height: 16),
          _quantityField(_quantityController),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
    );
  }

  void _startScanning(BuildContext context) async {
    // Navigate to scanner and wait for result
    final result = await Navigator.pushNamed(context, '/scanner');
    
    if (result != null && result is String) {
      setState(() {
        _scannedProductId = result;
      });
      
      // Show snackbar with success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product ID scanned: $result'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _addQuantity() {
    if (_scannedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please scan a product first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Here you would normally update your database with the new quantity
    // For this example, we'll just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${_quantityController.text} units to product $_scannedProductId'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Clear fields
    setState(() {
      _scannedProductId = null;
      _quantityController.clear();
    });
  }
}

// Updated DeductQuantityScreen with working scan button
class DeductQuantityScreen extends StatefulWidget {
  const DeductQuantityScreen({super.key});

  @override
  State<DeductQuantityScreen> createState() => _DeductQuantityScreenState();
}

class _DeductQuantityScreenState extends State<DeductQuantityScreen> {
  final TextEditingController _quantityController = TextEditingController();
  String? _scannedProductId;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _customAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _cameraBox(_scannedProductId),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton("Scan", Colors.blue, () => _startScanning(context)),
              _actionButton("Deduct", Colors.red, () => _deductQuantity()),
            ],
          ),
          const SizedBox(height: 16),
          _quantityField(_quantityController),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
    );
  }

  void _startScanning(BuildContext context) async {
    // Navigate to scanner and wait for result
    final result = await Navigator.pushNamed(context, '/scanner');
    
    if (result != null && result is String) {
      setState(() {
        _scannedProductId = result;
      });
      
      // Show snackbar with success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product ID scanned: $result'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _deductQuantity() {
    if (_scannedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please scan a product first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Here you would normally update your database with the new quantity
    // For this example, we'll just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deducted ${_quantityController.text} units from product $_scannedProductId'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Clear fields
    setState(() {
      _scannedProductId = null;
      _quantityController.clear();
    });
  }
}

// The rest of the code remains the same
class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _customAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _inputField("Product Name"),
            const SizedBox(height: 12),
            _inputField("Quantity"),
            const SizedBox(height: 12),
            _inputField("Product Description"),
            const SizedBox(height: 12),
            _inputField("Price", hasError: true),
            const SizedBox(height: 12),
            _imagePickerBox(),
            const SizedBox(height: 24),
            SizedBox(
              width: 120,
              height: 40,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Add", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 3),
    );
  }
}

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Sort by"),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _buildProductCard();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildProductCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2E3E3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: const Icon(Icons.image, size: 30),
          ),
          const SizedBox(height: 12),
          const Text(
            "Product Information",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Bottom Nav Bar
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
            Icons.search, 
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

// Modified helper widgets with state handling
PreferredSizeWidget _customAppBar() {
  return AppBar(
    backgroundColor: Colors.grey[300],
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.menu, color: Colors.black),
      onPressed: () {},
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.person_outline, color: Colors.black),
        onPressed: () {},
      ),
    ],
  );
}

Widget _cameraBox(String? scannedProductId) {
  return Center(
    child: Container(
      width: 300,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 48, color: Colors.black54),
            if (scannedProductId != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Product ID:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scannedProductId,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Widget _actionButton(String label, Color color, VoidCallback onPressed) {
  return SizedBox(
    width: 140,
    height: 40,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    ),
  );
}

Widget _quantityField(TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[300],
        hintText: "Quantity",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    ),
  );
}

Widget _inputField(String hint, {bool hasError = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Stack(
      children: [
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(hint, style: const TextStyle(color: Colors.black54)),
        ),
        if (hasError)
          Positioned(
            right: 12,
            top: 12,
            child: Icon(Icons.error_outline, color: Colors.red[400], size: 22),
          ),
      ],
    ),
  );
}

Widget _imagePickerBox() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 36, color: Colors.black54),
    ),
  );
}

// Existing model classes and services
class User {
  final String email;
  final String password;

  User({required this.email, required this.password});
}

class Product {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final double price;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.price,
    this.quantity = 0,
  });
  
  void addQuantity(int amount) {
    quantity += amount;
  }
  
  bool deductQuantity(int amount) {
    if (quantity >= amount) {
      quantity -= amount;
      return true;
    }
    return false;
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
  // Sample product data
  static final List<Product> _products = List.generate(
    10,
    (index) => Product(
      id: 'product_$index',
      name: 'Product ${index + 1}',
      imageUrl: 'https://via.placeholder.com/150',
      description: 'This is product ${index + 1} description',
      price: (index + 1) * 10.0,
      quantity: index * 5,
    ),
  );
  
  // Simulate fetching products from an API
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(seconds: 1));
    return _products;
  }
  
  // Find product by ID (from QR code)
  Future<Product?> findProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Update product quantity
  Future<bool> updateProductQuantity(String id, int amount, bool isAddition) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final product = _products.firstWhere((product) => product.id == id);
      
      if (isAddition) {
        product.addQuantity(amount);
        return true;
      } else {
        return product.deductQuantity(amount);
      }
    } catch (e) {
      return false;
    }
  }
  
  // Add new product
  Future<bool> addProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _products.add(product);
    return true;
  }
}