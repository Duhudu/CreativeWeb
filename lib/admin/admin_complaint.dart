import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/navbar.dart';
import 'package:creativeweb/profile_page.dart';

class ComplaintPage extends StatefulWidget {
  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get complaints from firebase
  Future<List<Map<String, dynamic>>> _getComplaints() async {
    final querySnapShot = await _firestore.collection('complaint').get();
    return querySnapShot.docs.map((doc) => doc.data()..['id'] = doc.id).toList();
  }

  // Function to delete a complaint
  Future<void> _deleteComplaint(String complaintId) async {
    try {
      await _firestore.collection('complaint').doc(complaintId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complaint deleted successfully')),
      );
    } catch (e) {
      print('Error deleting complaint: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete complaint')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text(
          "Complaint",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF252422),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5),
            Text(
              "Employee Complaints",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 40),
            Container(
              width: screenWidth * 90,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40)
                ),
              ),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getComplaints(),
                builder: (context, snapShot) {
                  if (snapShot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapShot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapShot.error}",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  if (!snapShot.hasData || snapShot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "No Complaints Available",
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }
                  var complaints = snapShot.data!;
                  return Column(
                    children: complaints.map((complaint) {
                      // Access the document ID from Firestore
                      String complaintId = complaint['id'];

                      return Container(
                        width: screenWidth * 0.9,
                        padding: EdgeInsets.all(20),
                        margin: EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${complaint['title']}",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "${complaint['body']}",
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () async {
                                  // Show confirmation dialog before deleting
                                  bool? confirmDelete = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Confirm Delete"),
                                        content: Text("Are you sure you want to delete this complaint?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            child: Text("Delete"),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmDelete ?? false) {
                                    _deleteComplaint(complaintId); // Pass the complaint ID
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
