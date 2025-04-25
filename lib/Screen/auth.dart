import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import '../widget/user_image.dart';
import 'package:image/image.dart' as img;
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseAuth = FirebaseAuth.instance;

  var _isLogin = true;
  var _isAuthenticating = false;
  File? _selectedImage;
  String? _imageBase64;
  final _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  Future<File> _compressImage(File file) async {
    try {
      final image = img.decodeImage(await file.readAsBytes())!;
      final smallerImage = img.copyResize(image, width: 300);
      final compressedBytes = img.encodeJpg(smallerImage, quality: 85);

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      return File(path).writeAsBytes(compressedBytes);
    } catch (e) {
      debugPrint('Image compression failed: $e');
      return file;
    }
  }
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isAuthenticating = true;
    });

    try {
      if (_isLogin) {
        // LOGIN LOGIC
        final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Check if email is verified
        if (userCredential.user?.emailVerified == false) {
          await _firebaseAuth.signOut(); // Sign out if not verified
          if (!mounted) return;
          _showEmailNotVerifiedDialog();
          return;
        }else if(userCredential.user?.emailVerified == true){
          // Step 2: Process image if selected
          if (_selectedImage != null) {
            final compressedImage = await _compressImage(_selectedImage!);
            final bytes = await compressedImage.readAsBytes();
            _imageBase64 = base64Encode(bytes);
          }

          // Step 3: Save user data to Firestore
          await _firestore.collection('Users').doc(userCredential.user!.uid).set({
            'email': _emailController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
            'pass':_passwordController.text.trim(),
            'uid': userCredential.user!.uid,
            if (_imageBase64 != null) 'imageBase64': _imageBase64,
          });
        }


        if (!mounted) return;
        _showSnackBar("Login successful!", Colors.green);
      } else {
        // SIGN UP LOGIC
        final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Send verification email
        await userCredential.user?.sendEmailVerification();

        // Sign out the user immediately after sign up
        await _firebaseAuth.signOut();

        if (!mounted) return;
        _showEmailVerificationSentDialog();

        // Clear form and switch to login
        setState(() {
          _isLogin = true;
        });
      }

      // Clear controllers after successful operation
      _emailController.clear();
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          errorMessage = 'Password should be at least 6 characters.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        default:
          errorMessage = e.message ?? 'Authentication failed';
      }
      _showSnackBar(errorMessage, Colors.red);
    } catch (e) {
      _showSnackBar("An unexpected error occurred", Colors.red);
      debugPrint("Unexpected error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  void _showEmailNotVerifiedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Email Not Verified'),
        content: const Text(
          'Please verify your email address before logging in. '
              'Check your inbox for the verification email.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Optionally resend verification email
              // _firebaseAuth.currentUser?.sendEmailVerification();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEmailVerificationSentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify Your Email'),
        content: const Text(
          'A verification email has been sent to your email address. '
              'Please verify your email before logging in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('asset/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isLogin)
                          Column(
                            children: [
                              UserImage(
                                onpickedImage: (pickedImage) {
                                  setState(() {
                                    _selectedImage = pickedImage;
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Profile picture (optional)",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email.';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your password.';
                            }
                            if (value.trim().length < 6) {
                              return 'Password must be at least 6 characters long.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_isAuthenticating)
                          const CircularProgressIndicator(),
                        if (!_isAuthenticating)
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Text(_isLogin ? 'Login' : 'Signup'),
                          ),
                        if (!_isAuthenticating)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                                _selectedImage = null;
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? 'Create an account'
                                  : 'I already have an account',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ///chauhanpankajchabiraj@gmail.com
