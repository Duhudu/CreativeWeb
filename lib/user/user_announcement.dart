import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creativeweb/userNavBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:creativeweb/userProfile.dart';

class AnnouncementPage extends StatefulWidget{
  _AnnouncementPageState createState() => _AnnouncementPageState();
}
class _AnnouncementPageState extends State<AnnouncementPage>{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  //Get announcements from Firestore
  Future <List<Map<String, dynamic>>> _getAnnouncements() async{
    final querySnapshot = await _firestore.collection('announcements').get();
    // Return the announcement data
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: UserNavBar(),
      appBar: AppBar(
        title: Text(
          "Announcements",
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
            //title
            Text(
              "New Announcements",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            //body area
            SizedBox(height: 40),
            Container(
              width: screenWidth * 90,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
              ),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future:_getAnnouncements(),
                builder: (context, snapShot){
                  if (snapShot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());  // Loading indicator while fetching data
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
                        "No Announcements Available",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  var announcements = snapShot.data!;
                  return Column(
                    children: announcements.map((announcement){
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
                          ]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Display announcement title
                            Text(
                              "${announcement['title']}",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            //Display body
                            Text(
                              "${announcement['body']}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}