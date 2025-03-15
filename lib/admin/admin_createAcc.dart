import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/navbar.dart';
import 'package:creativeweb/profile_page.dart';
import 'package:firebase_core/firebase_core.dart';



class CreateAnn extends StatefulWidget{
  @override
  _CreateAnnState createState() =>  _CreateAnnState();
}

class _CreateAnnState extends State<CreateAnn>{

  //Data fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  final _phoneController = TextEditingController();
  //firebase auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedRole = 'user';
  final List<String> _roles = ['user', 'admin'];

  //signUp/ create new user function
  Future <void> _signUp() async{
    try{
      //create new user with email and password
      // UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      //   email: _emailController.text.trim(),
      //   password: _passwordController.text.trim(),
      // );
      //
      // Check if the email already exists
      final signInMethods = await _auth.fetchSignInMethodsForEmail(_emailController.text.trim());
      // If the email is already in use
      if (signInMethods.isNotEmpty) {
        // Show pop-up for email already used
        _showPopupDialog("Error", "Email is already in use.");
        return;
      }
      // Password Length Validation Ensure password is at least 6 characters
      if (_passwordController.text.trim().length < 6) {
        // Pop-up for short password
        _showPopupDialog("Error", "Password must be at least 6 characters long.");
        return;
      }

      // **Create new user** with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );



      User? user = userCredential.user;
      if(user != null){
        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'department': _departmentController.text.trim(),
          'position': _positionController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': _selectedRole,
        });
        //notification
        _showPopupDialog("Success", "Account created successfully!");
        //clear input fields
        _emailController.clear();
        _nameController.clear();
        _departmentController.clear();
        _positionController.clear();
        _phoneController.clear();
        _passwordController.clear();


      }
    }
    catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create account')),
      );
    }
  }//end of signUp function
  //notification function
  void _showPopupDialog(String title, String message){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: (){
                  //close the dialog
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        }
    );
  }//end of notification function

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text("Create Account",
        style: TextStyle(
          color: Colors.white
        ),

        ),
        // back ground color and the app bar icon color
        backgroundColor: Color(0xFF252422),
        iconTheme: IconThemeData(color: Colors.white),
        //profile icon/page navi
        actions: [
          IconButton(
              icon: Icon(Icons.account_circle, color: Colors.white,),
              onPressed: (){
                //Navigate to the profile page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },

      ),
        ],
        centerTitle: true,
      ),
        backgroundColor: Color(0xFF252422),
        body:SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 5),
              //title
              Text(
                "New",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              //Text area
              SizedBox(height: 40),
              Container(
                width: screenWidth *90,
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  //text area bg color
                  color: Color(0xFFD8D8D8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                //Text area headers
                child: Column(
                  //text area body
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(_nameController, "Full Name"),
                    _buildTextField(_departmentController, "Department"),
                    _buildTextField(_positionController, "Position"),
                    _buildTextField(_emailController, "Email", TextInputType.emailAddress),
                    _buildTextField(_phoneController, "phone Number", TextInputType.phone),
                  _buildTextField(_passwordController, "Password", TextInputType.text, true),
                    //Drop down role to select a role
                    SizedBox(height: 10),
                    Text("Role", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: _selectedRole,
                      onChanged: (String? newRole){
                        setState(() {
                          _selectedRole = newRole;
                        });
                      },
                      items: _roles.map<DropdownMenuItem<String>>((String role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF252422),
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                          ),
                          child: Text("Create Account", style: TextStyle(color: Colors.white)),
                      ),
                    )

                  ],
                ),
              )
            ],
          ),

        ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      [TextInputType keyboardType = TextInputType.text, bool isPassword = false]){
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
