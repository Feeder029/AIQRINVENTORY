import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'firebase_helper.dart'; // Adjust the import as needed
import 'package:qr_flutter/qr_flutter.dart'; // Add this package for QR generation
// import 'package:firebase_storage/firebase_storage.dart'; // Uncomment if image upload

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final FirebaseHelper _firebaseHelper = FirebaseHelper(); // Initialize FirebaseHelper
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  bool _isLoading = false;
  String? _nameError;
  String? _quantityError;
  String? _priceError;
  String? _idError;

  // Image file
  File? _selectedImage;
  String? _imagePath;
  
  // QR code data
  bool _generateQrCode = false;
  String _qrData = '';

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
          _imagePath = pickedImage.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: ${e.toString()}")),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? takenImage = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (takenImage != null) {
        setState(() {
          _selectedImage = File(takenImage.path);
          _imagePath = takenImage.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error taking photo: ${e.toString()}")),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Select Image Source"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateQrData() {
    // Create a JSON-like string from current product data
    setState(() {
      _qrData = '{' +
          '"id":"${_idController.text}",' +
          '"name":"${_nameController.text}",' +
          '"price":"${_priceController.text}",' +
          '"quantity":"${_quantityController.text}"' +
          '}';
    });
  }

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      _nameError = null;
      _quantityError = null;
      _priceError = null;
      _idError = null;
    });

    if (_idController.text.trim().isEmpty) {
      setState(() { _idError = "Product ID is required"; });
      isValid = false;
    }

    if (_nameController.text.trim().isEmpty) {
      setState(() { _nameError = "Product name is required"; });
      isValid = false;
    }

    if (_quantityController.text.trim().isEmpty) {
      setState(() { _quantityError = "Quantity is required"; });
      isValid = false;
    } else {
      final qty = int.tryParse(_quantityController.text);
      if (qty == null || qty < 0) {
        setState(() { _quantityError = "Please enter a valid quantity"; });
        isValid = false;
      }
    }

    if (_priceController.text.trim().isEmpty) {
      setState(() { _priceError = "Price is required"; });
      isValid = false;
    } else {
      final price = double.tryParse(_priceController.text);
      if (price == null || price <= 0) {
        setState(() { _priceError = "Please enter a valid price"; });
        isValid = false;
      }
    }

    return isValid;
  }

  Future<void> _addProduct() async {
    if (!_validateInputs()) return;

    setState(() { _isLoading = true; });

    try {
      // Check if Product ID Exists
      final existingProduct = await _firebaseHelper.getProductById(_idController.text);
      if (existingProduct != null) {
        if (!mounted) return;
        setState(() { _idError = "Product ID already exists"; _isLoading = false; });
        return;
      }

      // Generate final QR data if not already done
      if (!_generateQrCode) {
        _updateQrData();
      }

      String imageUrl = '';

      // Optional: Upload image to Firebase Storage (recommended)
      /*
      if (_selectedImage != null) {
        // Remember to add firebase_storage package in pubspec.yaml
        final storageRef = FirebaseStorage.instance.ref().child('product_images/${DateTime.now().millisecondsSinceEpoch}');
        final uploadTask = storageRef.putFile(_selectedImage!);
        final snapshot = await uploadTask.whenComplete(() => {});
        imageUrl = await snapshot.ref.getDownloadURL();
      }
      */

      // For now, store local path or empty string
      imageUrl = _imagePath ?? '';

      // Prepare product data
      final productMap = {
        'id': _idController.text,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'quantity': int.parse(_quantityController.text),
        'image_url': imageUrl,
        'qr_data': _qrData, // Save QR data to Firebase
      };

      // Save to Firestore
      final result = await _firebaseHelper.insertProduct(productMap);

      setState(() { _isLoading = false; });

      if (result > 0) {
        if (!mounted) return;
        showSuccessDialog(context, "Product ${_nameController.text} successfully added");
        _nameController.clear();
        _quantityController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _idController.clear();
        setState(() {
          _selectedImage = null;
          _imagePath = null;
          _generateQrCode = false;
          _qrData = '';
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add product")));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // replace with your drawer if needed
      // drawer: const AppDrawer(), 
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        title: const Text("Add Product", style: TextStyle(color: Colors.black)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInputField("Product ID", _idController, errorText: _idError),
                      const SizedBox(height: 12),
                      _buildInputField("Product Name", _nameController, errorText: _nameError),
                      const SizedBox(height: 12),
                      _buildInputField("Quantity", _quantityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        errorText: _quantityError,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField("Price", _priceController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                        errorText: _priceError,
                        prefix: "\$",
                      ),
                      const SizedBox(height: 12),
                      _buildInputField("Product Description", _descriptionController, maxLines: 3),
                      const SizedBox(height: 16),
                      _imagePickerButton(),
                      const SizedBox(height: 24),
                      _buildQrCodeSection(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 170,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _addProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C71E8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Add Product", style: TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildQrCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _generateQrCode,
              onChanged: (value) {
                setState(() {
                  _generateQrCode = value ?? false;
                  if (_generateQrCode) {
                    _updateQrData();
                  }
                });
              },
            ),
            const Text("Generate QR Code", style: TextStyle(fontSize: 16)),
            const Spacer(),
            if (_generateQrCode)
              TextButton.icon(
                onPressed: _updateQrData,
                icon: const Icon(Icons.refresh),
                label: const Text("Update QR"),
              ),
          ],
        ),
        if (_generateQrCode) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: SizedBox(
                    height: 200,
                    width: 200,
                    child: QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _qrData,
                    style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputField(
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
    int maxLines = 1,
    String? prefix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: errorText != null
                    ? const BorderSide(color: Colors.red, width: 1.0)
                    : BorderSide.none,
              ),
              enabledBorder: errorText != null
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 1.0),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixText: prefix,
              suffixIcon: errorText != null
                  ? Icon(Icons.error_outline, color: Colors.red[400], size: 22)
                  : null,
            ),
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            onChanged: (_) {
              if (_generateQrCode) {
                _updateQrData();
              }
            },
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 4.0),
              child: Text(errorText, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _imagePickerButton() {
    return InkWell(
      onTap: _showImageSourceDialog,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    "Tap to upload product image",
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
      ),
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