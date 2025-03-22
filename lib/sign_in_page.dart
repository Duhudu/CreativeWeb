import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Initialization

// Import admin & user home page
import 'admin/admin_home_page.dart';
import 'user/user_home_page.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;  // For loading state management

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  // Initialize Firebase
  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // Show popup dialog for error messages (user-friendly)
  void _showPopupDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // SignIn function
  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if the email and password are valid
      String email = _nameController.text.trim();
      String password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        // Show popup if email or password is empty
        _showPopupDialog("Input Error", "Please enter both your email and password.");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Attempt to sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Get user role
        String role = await _getUserRole(user.uid);

        // Navigate based on role (admin or user)
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserHomePage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuthException errors and show a user-friendly popup
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        _showPopupDialog("Authentication Error", "The email or password you entered is incorrect. Please try again.");
      } else if (e.code == 'invalid-email') {
        _showPopupDialog("Authentication Error", "Please enter a valid email address.");
      } else if (e.code == 'user-disabled') {
        _showPopupDialog("Authentication Error", "This account has been disabled. Please contact support.");
      } else if (e.code == 'too-many-requests') {
        _showPopupDialog("Authentication Error", "Too many login attempts. Please try again later.");
      } else {
        _showPopupDialog("Error", "Incorrect Email or Password. Please try again.");
      }
    } catch (e) {
      // General error handling
      _showPopupDialog("Error", "Incorrect Email or Password. Please try again.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch user role from Firestore
  Future<String> _getUserRole(String uid) async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc['role'] ?? 'user'; // Default to 'user' if no role exists
      } else {
        return 'user'; // Default to 'user' if the user document doesn't exist
      }
    } catch (e) {
      return 'user'; // Return 'user' in case of any error
    }
  }

  // Forgot Password function
  Future<void> _forgotPassword() async {
    String email = _nameController.text.trim();

    if (email.isEmpty) {
      _showPopupDialog("Input Error", "Please enter your email address.");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showPopupDialog("Success", "Password reset link has been sent to your email. Please check your inbox.");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showPopupDialog("Error", "No user found for that email.");
      } else {
        _showPopupDialog("Error", "An error occurred. Please try again.");
      }
    } catch (e) {
      _showPopupDialog("Error", "An error occurred. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.fromRGBO(36, 35, 33, 1.0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.20),
            // Main-heading text
            Text(
              "Sign In",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Sub-heading text
            SizedBox(height: 8),
            Text(
              "Sign in now to begin an amazing journey",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 80),
            Container(
              width: screenWidth,
              padding: EdgeInsets.all(44),
              decoration: BoxDecoration(
                color: Color.fromRGBO(216, 216, 216, 1.0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  // Email section
                  Text(
                    "Email",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Enter Email...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(width: 2.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),
                  // Password Section
                  Text(
                    "Password",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Enter Password...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(width: 2.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Forgot Password Button
                  TextButton(
                    onPressed: _forgotPassword,
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  SizedBox(height: 80),
                  // Sign In Button
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,  // Disable button while loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(36, 35, 33, 1.0),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white) // Show loading indicator
                            : Text(
                          "Sign In",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
