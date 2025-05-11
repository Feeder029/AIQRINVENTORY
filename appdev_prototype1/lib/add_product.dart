import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_helper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'main.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
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
  
  // Add image file variable
  File? _selectedImage;
  String? _imagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _idController.dispose();
    super.dispose();
  }

  // Method to pick image from gallery
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

  // Method to take a photo with camera
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

  // Show image source dialog
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

  // Validate all fields before submission
  bool _validateInputs() {
    bool isValid = true;
    
    // Reset errors
    setState(() {
      _nameError = null;
      _quantityError = null;
      _priceError = null;
      _idError = null;
    });
    
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = "Product name is required";
      });
      isValid = false;
    }
    
    // Validate quantity
    if (_quantityController.text.trim().isEmpty) {
      setState(() {
        _quantityError = "Quantity is required";
      });
      isValid = false;
    } else {
      final quantity = int.tryParse(_quantityController.text);
      if (quantity == null || quantity < 0) {
        setState(() {
          _quantityError = "Please enter a valid quantity";
        });
        isValid = false;
      }
    }
    
    // Validate price
    if (_priceController.text.trim().isEmpty) {
      setState(() {
        _priceError = "Price is required";
      });
      isValid = false;
    } else {
      final price = double.tryParse(_priceController.text);
      if (price == null || price <= 0) {
        setState(() {
          _priceError = "Please enter a valid price";
        });
        isValid = false;
      }
    }
    
    // Validate product ID
    if (_idController.text.trim().isEmpty) {
      setState(() {
        _idError = "Product ID is required";
      });
      isValid = false;
    }
    
    return isValid;
  }

  // Add product to database
  Future<void> _addProduct() async {
    if (!_validateInputs()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Check if product ID already exists
      final existingProduct = await _dbHelper.getProductById(_idController.text);
      
      if (existingProduct != null) {
        if (!mounted) return;
        setState(() {
          _idError = "Product ID already exists";
          _isLoading = false;
        });
        return;
      }
      
      // Create product map
      final productMap = {
        'id': _idController.text,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'quantity': int.parse(_quantityController.text),
        'image_url': _imagePath ?? '', // Use the selected image path
      };
      
      // Insert into database
      final result = await _dbHelper.insertProduct(productMap);
      
      setState(() {
        _isLoading = false;
      });
      
      if (result > 0) {
        // Show success dialog
        if (!mounted) return;
        showSuccessDialog(
          context, 
          "Product ${_nameController.text} successfully added"
        );
        
        // Clear form fields
        _nameController.clear();
        _quantityController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _idController.clear();
        setState(() {
          _selectedImage = null;
          _imagePath = null;
        });
      } else {
        // Show error
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add product")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
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
                      _buildInputField(
                        "Product ID", 
                        _idController,
                        errorText: _idError,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        "Product Name", 
                        _nameController,
                        errorText: _nameError,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        "Quantity", 
                        _quantityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        errorText: _quantityError,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        "Price", 
                        _priceController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                        ],
                        errorText: _priceError,
                        prefix: "\$",
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        "Product Description", 
                        _descriptionController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _imagePickerButton(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 170,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _addProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C71E8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Add Product", 
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            )
                          ),
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
                borderSide: errorText != null ? 
                    const BorderSide(color: Colors.red, width: 1.0) : 
                    BorderSide.none,
              ),
              enabledBorder: errorText != null ? 
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1.0),
                  ) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixText: prefix,
              suffixIcon: errorText != null 
                  ? Icon(Icons.error_outline, color: Colors.red[400], size: 22)
                  : null,
            ),
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 4.0),
              child: Text(
                errorText,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
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
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    "Tap to upload product image",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}