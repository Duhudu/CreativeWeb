import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'signUp.dart';
import 'sign_in_page.dart';
import 'admin/admin_home_page.dart';
import 'user/user_home_page.dart';

import 'navbar.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Initialize Firebase
  runApp(MyApp());
}
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Firebase Sign Up',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: SignUpScreen(),  // Directing to the sign-up screen
//     );
//   }
// }
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign In Example',
      initialRoute: '/', // Set initial route to SignInPage
      routes: {
        '/': (context) => AdminHomePage(), // SignInPage route
        '/admin': (context) => AdminHomePage(), // Admin Home route
        '/user': (context) => UserHomePage(), // User Home route
      },
    );
  }
}