import 'package:flutter/material.dart';
import 'firebase_helper.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Mode toggle: true for login, false for sign up
  bool _isLoginMode = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  final FirebaseHelper _dbHelper = FirebaseHelper();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Validation for signup
  bool _validateInputs() {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Email is required";
      });
      return false;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      setState(() {
        _errorMessage = "Please enter a valid email address";
      });
      return false;
    }
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "Password is required";
      });
      return false;
    }
    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = "Password must be at least 6 characters";
      });
      return false;
    }
    if (!_isLoginMode) { // Additional validation for signup
      if (_nameController.text.trim().isEmpty) {
        setState(() {
          _errorMessage = "Full name is required";
        });
        return false;
      }
      if (_confirmPasswordController.text != _passwordController.text) {
        setState(() {
          _errorMessage = "Passwords do not match";
        });
        return false;
      }
    }
    return true;
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
    });
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLoginMode) {
        // LOGIN
        final user = await _dbHelper.loginUser(
          _emailController.text.trim(),
          _passwordController.text,
        );
        setState(() {
          _isLoading = false;
        });
        if (user != null) {
          // Login successful
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/products');
        } else {
          setState(() {
            _errorMessage = "Invalid email or password";
          });
        }
      } else {
        // SIGNUP
        final result = await _dbHelper.registerUser(
          _emailController.text.trim(),
          _passwordController.text,
          name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        );
        setState(() {
          _isLoading = false;
        });
        if (result > 0) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account created successfully")),
          );
          Navigator.pushReplacementNamed(context, '/products');
        } else if (result == -1) {
          setState(() {
            _errorMessage = "Email already registered. Please login or use another email.";
          });
        } else {
          setState(() {
            _errorMessage = "Failed to create account. Please try again.";
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "An error occurred: ${e.toString()}";
      });
    }
  }

  Widget _buildAuthForm() {
    return SingleChildScrollView(
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
                _isLoginMode ? "Login to your account" : "Create your account",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (!_isLoginMode)
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "Full Name (Optional)",
                ),
                keyboardType: TextInputType.name,
              ),
            if (!_isLoginMode) const SizedBox(height: 16),
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
            if (!_isLoginMode) const SizedBox(height: 16),
            if (!_isLoginMode)
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
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C71E8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isLoginMode ? "Sign in" : "Sign up",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoginMode = !_isLoginMode;
                  _errorMessage = null;
                });
              },
              child: Text(_isLoginMode
                  ? "Don't have an account? Sign up"
                  : "Already have an account? Sign in"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _isLoginMode
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    _isLoginMode = true;
                    _errorMessage = null;
                  });
                },
              ),
            ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _buildAuthForm(),
      ),
    );
  }
}