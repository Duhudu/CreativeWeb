import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creativeweb/userNavBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:creativeweb/userProfile.dart';

class ComplaintPage extends StatefulWidget{
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage>{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Controllers for the Complaint title and body
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  // Function to submit the complaint
    Future<void> _submitComplaint() async{
      try{
        //check if both title and body are filled
        if(_titleController.text.isEmpty || _bodyController.text.isEmpty){
          _showPopupDialog("Error", "Please Fill In All The Details");
        }
        // Save the complaint in firebase
        await _firestore.collection('complaint').add({
          'title': _titleController.text.trim(),
          'body': _bodyController.text.trim(),
          'created_at': FieldValue.serverTimestamp(),
        });
        //show success message
        _showPopupDialog("Success", "Complaint Sent");
        //clear
        _titleController.clear();
        _bodyController.clear();
      }
      catch (e) {
        print('Error: $e');
        _showPopupDialog("Error", "An error occurred while posting the announcement.");
      }

    }

    //Notification pop up function
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
      drawer: UserNavBar(),
      appBar: AppBar(
        title: Text(
          "Complaint",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF252422),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserProfilePage()));
            },
          )
        ],
        centerTitle: true,
      ),
      backgroundColor: Color(0xFF252422),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5),
            Text(
              "Add Complaint",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
            SizedBox(height: 60),
            Container(
              width: screenWidth * 20,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40)
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(_titleController, "Title"),
                  _buildTextField(_bodyController, "Body", maxLines: 10),
                  SizedBox(height: 160),
                  Center(
                    child: ElevatedButton(
                        onPressed: _submitComplaint,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF252422),
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                        ),
                        child: Text("Submit Complaint",style: TextStyle(color: Colors.white),)),
                  )

                ],
              ),
            )
          ],
        ),

      ),
    );
  }
// Helper function to build text fields
  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
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