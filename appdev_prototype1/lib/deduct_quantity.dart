import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'dart:convert'; // Add this for JSON parsing
// Import your FirebaseHelper
import 'firebase_helper.dart';

class DeductQuantityScreen extends StatefulWidget {
  const DeductQuantityScreen({super.key});
  @override
  State<DeductQuantityScreen> createState() => _DeductQuantityScreenState();
}

class _DeductQuantityScreenState extends State<DeductQuantityScreen> {
  String _productId = ""; // Field to store the extracted product ID
  final TextEditingController _quantityController = TextEditingController();

  bool _hasScanned = false;
  final FirebaseHelper _firebaseHelper = FirebaseHelper(); // Use FirebaseHelper

  String _productName = "";
  int _currentQuantity = 0;
  bool _isLoading = false;
  bool _isValidProduct = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _handleCodeScanned(String code) async {
    setState(() {
      _isLoading = true;
    });

    // Extract the product ID from the QR code content
    String productId;
    try {
      // Try to parse the QR code content as JSON
      if (code.trim().startsWith('{') && code.trim().endsWith('}')) {
        // This is a JSON-formatted QR code from our app
        final Map<String, dynamic> qrData = jsonDecode(code);
        productId = qrData['id'] as String? ?? '';
      } else {
        // This is just a plain product ID
        productId = code;
      }
      
      _productId = productId; // Store the extracted product ID
      
      // Fetch product from FirebaseHelper using the extracted ID
      final product = await _firebaseHelper.getProductById(productId);
      
      setState(() {
        _isLoading = false;
        _hasScanned = true;

        if (product != null) {
          _isValidProduct = true;
          _productName = product['name'] as String? ?? '';
          _currentQuantity = product['quantity'] as int? ?? 0;
        } else {
          _isValidProduct = false;
          _productName = "";
          _currentQuantity = 0;
        }
      });
    } catch (e) {
      // Handle parsing errors
      setState(() {
        _isLoading = false;
        _hasScanned = true;
        _isValidProduct = false;
        _productName = "";
        _currentQuantity = 0;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid QR code format: ${e.toString()}")),
      );
    }
  }

  void _scanQRCode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerView(onCodeScanned: _handleCodeScanned),
      ),
    );
  }

  Future<void> _deductQuantity() async {
    if (_quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a quantity")),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid quantity")),
      );
      return;
    }

    if (quantity > _currentQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Not enough stock! Current quantity: $_currentQuantity")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Deduct quantity via FirebaseHelper
    final result = await _firebaseHelper.deductQuantity(_productId, quantity);

    setState(() {
      _isLoading = false;
      if (result > 0) {
        _currentQuantity -= quantity; // update local state
      }
    });

    if (result > 0) {
      if (!mounted) return;
      showSuccessDialog(
        context,
        "Successfully deducted $quantity items from $_productName"
      );
      _quantityController.clear();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update quantity")),
      );
    }
  }

  Widget _cameraBox() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: _hasScanned
            ? const Icon(Icons.check_circle, color: Colors.green, size: 64)
            : const Icon(Icons.qr_code_scanner, color: Colors.grey, size: 64),
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[400],
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        title: const Text("Deduct Quantity", style: TextStyle(color: Colors.black)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 16),
                _cameraBox(),
                if (_hasScanned) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.qr_code, color: Colors.black54),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Product ID: $_productId",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_isValidProduct) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 32.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Product: $_productName",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 32.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Current Stock: $_currentQuantity",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ] else if (_productName.isEmpty && _hasScanned) ...[
                          const SizedBox(height: 4),
                          const Padding(
                            padding: EdgeInsets.only(left: 32.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Product not found in database",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionButton("Scan", Colors.blue, _scanQRCode),
                    _actionButton(
                      "Deduct",
                      Colors.red,
                      (_hasScanned && _isValidProduct) ? _deductQuantity : null
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      hintText: "Quantity",
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
    );
  }
  
  void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}