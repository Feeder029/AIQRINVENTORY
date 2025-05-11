import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_helper.dart';
import 'dart:async';
import 'main.dart';
class DeductQuantityScreen extends StatefulWidget {
  const DeductQuantityScreen({super.key});

  @override
  State<DeductQuantityScreen> createState() => _DeductQuantityScreenState();
}

class _DeductQuantityScreenState extends State<DeductQuantityScreen> {
  String _scannedCode = "";
  final TextEditingController _quantityController = TextEditingController();
  bool _hasScanned = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();
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
      _scannedCode = code;
    });

    // Check if product exists in database
    final product = await _dbHelper.getProductById(code);
    
    setState(() {
      _isLoading = false;
      _hasScanned = true;
      
      if (product != null) {
        _isValidProduct = true;
        _productName = product['name'] as String;
        _currentQuantity = product['quantity'] as int;
      } else {
        _isValidProduct = false;
        _productName = "";
        _currentQuantity = 0;
      }
    });
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
      // Show error for empty quantity
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a quantity")),
      );
      return;
    }

    // Parse quantity
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid quantity")),
      );
      return;
    }

    // Check if we have enough stock
    if (quantity > _currentQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Not enough stock! Current quantity: $_currentQuantity")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Update quantity in database
    final result = await _dbHelper.deductQuantity(_scannedCode, quantity);
    
    setState(() {
      _isLoading = false;
      if (result > 0) {
        _currentQuantity -= quantity;
      }
    });

    if (result > 0) {
      // Show success dialog
      if (!mounted) return;
      showSuccessDialog(
        context, 
        "Successfully deducted $quantity items from $_productName"
      );
      
      // Clear the input
      _quantityController.clear();
    } else {
      // Show error
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update quantity")),
      );
    }
  }

  Widget _cameraBox() {
    // Camera box widget implementation
    return Container(
      width: double.infinity,
      height: 350,
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
        // Remove the custom leading widget to use the default drawer toggle
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
                            "Product ID: $_scannedCode",
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
}