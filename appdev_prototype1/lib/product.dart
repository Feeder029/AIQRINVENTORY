import 'package:flutter/material.dart';
import 'firebase_helper.dart'; // Import your FirebaseHelper
import 'dart:io';
import 'main.dart';

enum SortOption {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
}

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> with SingleTickerProviderStateMixin {
  final FirebaseHelper _firebaseHelper = FirebaseHelper(); // Use FirebaseHelper
  List<Product> _products = [];
  bool _isLoading = true;
  // Current sort option
  SortOption? _currentSort;

  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    // Initialize animation controller for refresh button
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final productsData = await _firebaseHelper.getProducts();
      setState(() {
        _products = productsData.map((data) => Product.fromMap(data)).toList();
        _isLoading = false;
        _sortProducts(); // sort after loading
      });
    } catch (e) {
      // Handle exceptions
      setState(() {
        _products = [];
        _isLoading = false;
      });
    }
  }

  // Function to sort products based on selected sort option
  void _sortProducts() {
    if (_currentSort == null) return; // no sorting if not selected
    setState(() {
      switch (_currentSort) {
        case SortOption.nameAsc:
          _products.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          break;
        case SortOption.nameDesc:
          _products.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
          break;
        case SortOption.priceAsc:
          _products.sort((a, b) => a.price.compareTo(b.price));
          break;
        case SortOption.priceDesc:
          _products.sort((a, b) => b.price.compareTo(a.price));
          break;
        default:
          break;
      }
    });
  }

  // Function to show sorting options
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.sort_by_alpha),
            title: const Text('Name A-Z'),
            onTap: () {
              _currentSort = SortOption.nameAsc;
              _sortProducts();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sort_by_alpha),
            title: const Text('Name Z-A'),
            onTap: () {
              _currentSort = SortOption.nameDesc;
              _sortProducts();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on),
            title: const Text('Price Low to High'),
            onTap: () {
              _currentSort = SortOption.priceAsc;
              _sortProducts();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.money_off),
            title: const Text('Price High to Low'),
            onTap: () {
              _currentSort = SortOption.priceDesc;
              _sortProducts();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _onRefreshPressed() async {
    // Trigger the animation
    await _refreshController.forward();
    _refreshController.reset();
    // Reload products
    await _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(), // Add the drawer here
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        title: const Text('Products', style: TextStyle(color: Colors.black)),
        actions: [
          // Wrap IconButton with RotationTransition for animation
          GestureDetector(
            onTap: _onRefreshPressed,
            child: RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_refreshController),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(Icons.refresh, color: Colors.black),
              ),
            ),
          ),
          // Add a button to trigger sorting options
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.black),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // (your other UI code remains unchanged)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(child: Text("No products found"))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return _buildProductCard(product);
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2E3E3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display product image if available, otherwise show a placeholder
          Container(
            width: 140,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: product.imageUrl.isNotEmpty
                ? Image.file(
                    File(product.imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if image loading fails
                      return const Icon(Icons.inventory_2, size: 30);
                    },
                  )
                : const Icon(Icons.inventory_2, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            "\$${product.price.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Qty: ${product.quantity}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}