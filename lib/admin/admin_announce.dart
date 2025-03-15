import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/navbar.dart';
import 'package:creativeweb/profile_page.dart';
import 'package:creativeweb/navbar.dart';
import 'admin_announcements_management.dart';
class AnnPage extends StatefulWidget{
  @override
  _AnnPageState createState() => _AnnPageState();

}
class _AnnPageState extends State<AnnPage>{
  //firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for the announcement title and body
  final TextEditingController _titleController =TextEditingController();
  final TextEditingController _bodyController =TextEditingController();

  //Function for the announcement
  Future<void> _submitAnnouncement() async{
    try{
      //Check if both title and body are filled
      if(_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty){
        //show success message
        _showPopupDialog("Error", "Please fill in both the title and body of the announcement.");
        return;
      }
      // Save the announcement to Firestore
      await _firestore.collection('announcements').add({
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });
      // Show success message
      _showPopupDialog("Success", "Announcement posted successfully!");
      // Clear the text fields after submission
      _titleController.clear();
      _bodyController.clear();

    }
    catch (e) {
      print('Error: $e');
      _showPopupDialog("Error", "An error occurred while posting the announcement.");
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
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
          title: Text(
              "Announcements ",
              style: TextStyle(
                color: Colors.white,

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
              "Create New Announcement",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 60),
            Container(
              width: screenWidth * 20,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Color(0xFFD8D8D8),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(_titleController, "Title"),
                  _buildTextField(_bodyController, "Body" ,maxLines: 5),
                  SizedBox(height: 60),
                  Center(
                    child: ElevatedButton(
                        onPressed: _submitAnnouncement,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF252422),
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text("Submit Announcement", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 165),
                  //Button to navigate to anther page for editing and removing announcements
                  Center(
                    child: ElevatedButton(
                        onPressed: (){
                          Navigator.push(
                              context,
                              //Move to the editing and removing page
                              MaterialPageRoute(builder: (context) => ManageAnnouncementsPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF252422),
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text("Manage Announcements", style: TextStyle(color: Colors.white))
                    ),
                  )
                ],
              ),
            ),

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
