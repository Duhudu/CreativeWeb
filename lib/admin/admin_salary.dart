import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/navbar.dart';
import 'package:creativeweb/profile_page.dart';

class SalaryPage extends StatefulWidget{
  @override
  _SalaryPageState createState() => _SalaryPageState();
}
class _SalaryPageState extends State<SalaryPage>{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  List<String> emailSuggestions =[];
  bool isDropdownVisible = false;

  //Get emails from firestore that match the the typed email
  Future<void> _searchEmails(String query) async{
    if(query.isEmpty){
      setState(() {
        emailSuggestions = [];
        isDropdownVisible = false;
      });
      return;
    }
     final querySnapshot = await _firestore
      .collection('users')
      .where('email', isGreaterThanOrEqualTo: query)
      .where('email', isLessThan: query + 'z')
      .get();
    setState(() {
      emailSuggestions = querySnapshot.docs
          .map((doc) => doc['email'] as String)
          .toList();
      isDropdownVisible= emailSuggestions.isNotEmpty;
    });
  }
  //variable to store user data
  Map<String, dynamic>? _userDetails;
  //get user detials from firestore using the selected email
  Future<void> _fetchUserDetails(String email) async{
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if(querySnapshot.docs.isNotEmpty){
      setState(() {
        //store user details
        _userDetails =querySnapshot.docs[0].data();
      });
    }
  }
//submit salary data funtion
  Future<void> _submitSalary () async{
    if(_emailController.text.isEmpty || _salaryController.text.isEmpty || _dateController.text.isEmpty){
      _showPopupDialog("Error", "Please Fill In All the Details");
      return;
    }
    // Save task data to Firestore
    await _firestore.collection('salaries').add({
      'email': _emailController.text.trim(),
      'salary': _salaryController.text.trim(),
      'date': _dateController.text.trim(),
      'paymentMethod': 'Online',
      'created_at': FieldValue.serverTimestamp(),
    });
    _showPopupDialog("Success", "Salary Information Added Successfully");
    _emailController.clear();
    _salaryController.clear();
    _dateController.clear();
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
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK")
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text(
            "Salary Management",
            style: TextStyle(
              color: Colors.white,
            ),
        ),
        // back ground color and the app bar icon color
        backgroundColor: Color(0xFF252422),
        iconTheme: IconThemeData(color: Colors.black45),
        //btn for profile page
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.black45,),
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
              "Add Salary Information",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 60),
            Container(
              width: screenWidth * 10,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                  //bottomRight: Radius.circular(40),
                  //bottomLeft: Radius.circular(40)
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmailSearchField(),
                  //drop-down for email suggestions
                  if(isDropdownVisible)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(top: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                                  //hide dropdown after selection
                                  isDropdownVisible = false;
                                });
                                _fetchUserDetails(emailSuggestions[index]);
                              },
                            );
                          }
                      ),
                    ),
                  if (_userDetails != null) _buildUserDetails(),
                  _buildTextField(_salaryController, "Salary"),
                  _buildTextField(_dateController, "Date (DD/MM/YYYY)"),
                  SizedBox(height: 320),
                  Center(
                    child: ElevatedButton(
                        onPressed: _submitSalary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF252422),
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      child: Text(
                          "Submit Sa",
                          style:
                          TextStyle(
                              color: Colors.red
                          )
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
  //Widget to build the email search field
  Widget _buildEmailSearchField(){
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: "Search Email",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onChanged: (text){
        //Trigger email suggestions
        _searchEmails(text);
      },
    );
  }//end of email search widget
  //Widget to display user details after select an email
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
        Text("Role: ${_userDetails?['role']??"N/A"}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
  //Widget to build a text input field for salary and date
  Widget _buildTextField(TextEditingController controller, String label){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
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

