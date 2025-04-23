import 'package:flutter/material.dart';

void main() {
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
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/products': (context) => const ProductScreen(),
        '/add-quantity': (context) => const AddQuantityScreen(),
        '/deduct-quantity': (context) => const DeductQuantityScreen(),
        '/add-product': (context) => const AddProductScreen(),
      },
    );
  }
}

// IntroScreen, LoginScreen, and SignupScreen remain unchanged...
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.pushReplacementNamed(context, '/login');
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

// Updated ProductScreen with working navigation
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

// Updated AddQuantityScreen with working navigation
class AddQuantityScreen extends StatelessWidget {
  const AddQuantityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _customAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _cameraBox(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton("Scan", Colors.blue, () {}),
              _actionButton("Add quantity", Colors.green, () {}),
            ],
          ),
          const SizedBox(height: 16),
          _quantityField(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
    );
  }
}

// Updated DeductQuantityScreen with working navigation
class DeductQuantityScreen extends StatelessWidget {
  const DeductQuantityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _customAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _cameraBox(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton("Scan", Colors.blue, () {}),
              _actionButton("Deduct", Colors.red, () {}),
            ],
          ),
          const SizedBox(height: 16),
          _quantityField(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
    );
  }
}

// Updated AddProductScreen with working navigation
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

// Helper widgets preserved from the original code
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

Widget _cameraBox() {
  return Center(
    child: Container(
      width: 300,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.camera_alt_outlined, size: 48, color: Colors.black54),
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

Widget _quantityField() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Text("Quantity", style: TextStyle(color: Colors.black54)),
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

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.price,
  });
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
      ),
    );
  }
}