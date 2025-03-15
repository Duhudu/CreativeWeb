import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/navbar.dart';
import 'package:creativeweb/profile_page.dart';

class ViewAccount extends StatefulWidget{
  @override
  _ViewAccount createState() => _ViewAccount();
}

class _ViewAccount extends State<ViewAccount>{
  //Firebase details
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();
  String? _searchedEmail;
  Map<String, dynamic>? _userData;
  //list to store email suggestions
  List<String> _emailSuggestions = [];
  // Flag to control the visibility of the email suggestions dropdown
  bool _isDropdownVisible = false;

  //function to search for emails
  Future<void> _searchEmails(String query) async{
    if(query.isEmpty){
      setState(() {
        _emailSuggestions = [];
        _isDropdownVisible = false;
      });
      return;
    }
    try{
      //Fetch emails that match the query (this assumes emails are indexed in Firestore)
      var userDocs = await _firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThan: query + 'z')
          .get();

      if(userDocs.docs.isNotEmpty){
        setState(() {
          _emailSuggestions = userDocs.docs
              .map((doc) => doc['email'] as String)
              .toList();
          _isDropdownVisible = true;
        });
      }else{
        setState(() {
          _emailSuggestions = [];
          _isDropdownVisible = false;
        });
      }
    }catch (e) {
      print('Error fetching email suggestions: $e');
    }
  }
  //Function to search user by email and display details
  Future<void> _searchUser() async{
    try{
      String email = _searchController.text.trim();
      if(email.isEmpty){
        _showPopupDialog("Error", "Please enter an email address");
        return;
      }
      // Check if user exists in Firestore
      var userDoc = await _firestore.collection('users').where('email',isEqualTo: email).get();

      if(userDoc.docs.isEmpty){
        _showPopupDialog("Error", "No user found with that email");
        return;
      }
      //Get user data if found
      setState(() {
        _userData = userDoc.docs[0].data();
      });
    }
    catch (e) {
      print('Error: $e');
      _showPopupDialog("Error", "An error occurred while fetching user data.");
    }
  }

  //Notification function
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
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context){
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text(
            "Search Accounts",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        // back ground color and the app bar icon color
        backgroundColor: Color(0xFF252422),
        iconTheme: IconThemeData(color: Colors.white),
        //btn for profile page
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white,),
            onPressed: (){
              //Navigate to the profile page
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage())
              );
            },

          ),
        ],
        centerTitle: true,
      ),
      backgroundColor: Color(0xFF252422),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5),
            Text(
              "Search User by Email",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            //Text body
            SizedBox(height: 60),
            Container(
              width: screenWidth * 10,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Color(0xFFD8D8D8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40)
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //search user text area
                  _buildTextField(_searchController, "Enter Email", TextInputType.emailAddress),
                  SizedBox(height: 10),
                  if(_isDropdownVisible)
                    _buildEmailSuggestionsDropdown(),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                        onPressed: _searchUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF252422),
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text("Search", style: TextStyle(color: Colors.white))
                    ),
                  ),
                  SizedBox(height: 20),
                  if(_userData != null)...[
                    Text(
                      "User Information",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _buildInfoRow("Name", _userData?['name']),
                    _buildInfoRow("Department", _userData?['department']),
                    _buildInfoRow("Position", _userData?['position']),
                    _buildInfoRow("Email", _userData?['email']),
                    _buildInfoRow("Phone", _userData?['phone']),
                    _buildInfoRow("Role", _userData?['role']),
                  ],
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
      [TextInputType keyboradType = TextInputType.text]
      ){
    return Padding(
      //btn section gap
    padding: const EdgeInsets.symmetric(vertical: 9.0),
      child: TextField(
        controller: controller,
        keyboardType:   keyboradType,
        onChanged: (text){
          //Trigger email suggestions
          _searchEmails(text);
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          focusColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
  //Build the drop-down for email suggestions
  Widget _buildEmailSuggestionsDropdown(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: _emailSuggestions.length,
          itemBuilder: (context, index){
            return ListTile(
              title: Text(_emailSuggestions[index]),
              onTap: (){
                setState(() {
                  _searchController.text = _emailSuggestions[index];
                  // Hide dropdown after selection
                  _isDropdownVisible = false;
                });

              },
            );
          }
      ),
    );
  }
  //user data section
  Widget _buildInfoRow(String label, String? value){
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
              child: Text(value ?? "Not available", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
