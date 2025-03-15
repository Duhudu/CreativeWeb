import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
// Import admin & user home page
import 'admin/admin_home_page.dart';
import 'user/user_home_page.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  //Controllers for email (email = name) and password
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  //Firebase auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SignIn function
  Future <void> _signIn() async {
    try {
      //auth user with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        //get data entered by user
        email: _nameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        //check the users role after signing in
        String role  = await _getUserRole(user.uid);

        //check if user is an admin if not send to else section
        if (role == 'admin') {
          //send to adminHome page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminHomePage()),
          );
        } else {
          //send to user homePage
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserHomePage())
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  // Fetch user role from Firestore (firebase db)
  Future<String> _getUserRole(String uid) async {
    // Firestore collection 'users' stores the user role
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      // Default to 'user' if no role found
      return userDoc['role'] ?? 'user';
    }
    // Default to 'user' if no role info is found
    return 'user';
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.fromRGBO(36, 35, 33, 1.0),
      body: SingleChildScrollView(  // Make the entire screen scrollable
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.20),
            //main-heading text
            Text(
              "Sign In",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            //sub-heading text
            SizedBox(height: 8),
            Text(
              "Sign in now to begin an amazing journey",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 80),
            Container(  // Remove Expanded widget
              width: screenWidth,
              padding: EdgeInsets.all(44),
              decoration: BoxDecoration(
                color: Color.fromRGBO(216, 216, 216, 1.0),
                //form style
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
                  //Password Section
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
                  SizedBox(height: 80),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(36, 35, 33, 1.0),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
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
