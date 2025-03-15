import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/navbar.dart';
import 'package:creativeweb/profile_page.dart';

class TaskPage extends StatefulWidget{
  @override
  _TaskPageState createState() => _TaskPageState();
}
class _TaskPageState extends State<TaskPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _startingDateController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();

  //list to store email suggestions
  List<String> emailSuggestions = [];

  // Flag to control the visibility of the email suggestions dropdown
  bool isDropdownVisible = false;

  //get emails from firestore that match the typed email
  Future<void> _searchEmails(String query) async {
    if (query.isEmpty) {
      setState(() {
        emailSuggestions = [];
        isDropdownVisible = false;
      });
    }
    final querySnapShot = await _firestore
        .collection('users')
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThan: query + 'z')
        .get();
    setState(() {
      emailSuggestions = querySnapShot.docs
          .map((doc) => doc['email'] as String)
          .toList();
      isDropdownVisible = emailSuggestions.isNotEmpty;
    });
  }

  //variable to store selected users data
  Map<String, dynamic>? _userDetails;

  //Get user details from firestore using the selected email
  Future<void> _fetchUserDetails(String email) async {
    final querySnapShot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapShot.docs.isNotEmpty) {
      setState(() {
        //store user details
        _userDetails = querySnapShot.docs[0].data();
      });
    }
  }

  //Submit task data to firestore
  Future<void> _submitTask() async {
    if (_emailController.text.isEmpty || _topicController.text.isEmpty ||
        _bodyController.text.isEmpty || _startingDateController.text.isEmpty ||
        _deadlineController.text.isEmpty) {
      //show popup error
      _showPopupDialog("Error", "Please Fill In All The Fields");
    }
    // Save task data to Firestore
    await _firestore.collection('tasks').add({
      'email': _emailController.text.trim(),
      'topic': _topicController.text.trim(),
      'body': _bodyController.text.trim(),
      'startingDate': _startingDateController.text.trim(),
      'deadline': _deadlineController.text.trim(),
      'created_at': FieldValue.serverTimestamp(),
    });
    // Show success message
    _showPopupDialog("Success", "Task assigned successfully!");
    // Clear the input fields after submission
    _emailController.clear();
    _topicController.clear();
    _bodyController.clear();
    _startingDateController.clear();
    _deadlineController.clear();
  }

  //popup dialog function
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    // TODO: implement build
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text(
          "Task Management",
          style: TextStyle(
              color: Colors.white
          ),
        ),
        // back ground color and the app bar icon color
        backgroundColor: Color(0xFF252422),
        iconTheme: IconThemeData(color: Colors.white),
        //btn for profile page
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white,),
            onPressed: () {
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
              "Assign New Task",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: screenWidth * 10,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmailSearchField(),
                  //DropDown for email suggestions
                  if(isDropdownVisible)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(top:8.0),
                      decoration: BoxDecoration(
                        color:Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: emailSuggestions.length,
                          itemBuilder: (context, index){
                            return ListTile(
                              title: Text(emailSuggestions[index]),
                              onTap: (){
                                setState(() {
                                  _emailController.text = emailSuggestions[index];
                                  // Hide dropdown after selection
                                  isDropdownVisible = false;
                                });
                                _fetchUserDetails(emailSuggestions[index]);
                              },
                            );
                          }
                      ),
                    ),
                  //display user details
                  if(_userDetails != null)
                    _buildUserDetails(),
                  _buildTextField(_topicController, "Task Topic"),
                  _buildTextField(_bodyController, "Task Body", maxLines: 3),
                  _buildTextField(_startingDateController, "Starting Date (DD/MM/YYYY)"),
                  _buildTextField(_deadlineController, "Deadline (DD/MM/YYYY)"),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                        onPressed: _submitTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF252422),
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      child: Text(
                          "Assign Task",
                          style: TextStyle(color: Colors.white)
                      ),
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
  // Widget to build the email search field
  Widget _buildEmailSearchField() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        // Label for the email input
        labelText: "Search Email",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onChanged: (text) {
        // Trigger email suggestions when the user types
        _searchEmails(text);
      },
    );
  }
// Widget to display user details after selecting an email
  Widget _buildUserDetails(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          "User Details",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text("Name: ${_userDetails?['name']?? "N/A"}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text("Department: ${_userDetails?['department']??"N/A"}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text("Position:  ${_userDetails?['position']??"N/A"}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        //Text("Role: ${_userDetails?['role']??"N/A"}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
  // Widget to build a general text input field for task details
  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          // Label for the input field
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}