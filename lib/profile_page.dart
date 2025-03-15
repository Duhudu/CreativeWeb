import 'package:flutter/material.dart';
import '/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfilePage extends StatefulWidget{
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>{

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore  = FirebaseFirestore.instance;

  // User Data
  String name ="Loading... ";
  String department = " ";
  String position = " ";
  String email = " ";
  String phone = " ";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
  // Fetch User Data from Firestore
  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user == null) {
      print("No user is signed in.");
      return;
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        print("No user document found for UID: ${user.uid}");
        return;
      }

      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      print("User data found: $data"); // Debugging log
      //text area data
      setState(() {
        name = data['name'] ?? "Unknown";
        department = data['department'] ?? "Unknown";
        position = data['position'] ?? "Unknown";
        email = user.email ?? "Unknown";
        phone = data['phone'] ?? "Unknown";
      });
    } catch (e) {
      print("Firestore fetch error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text("Profile",
        style: TextStyle(
          color: Colors.white,

        ) ,
        ),

        //App bar bg color

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
        //center text
        centerTitle: true,
      ),
      backgroundColor: Color(0xFF252422),
      body:SingleChildScrollView(

        child: Column(
          children: [
            SizedBox(height: 5),
            // CREATIVEWEB IMAGE (Logo)
            Center(
              child: Image.asset(
                'assets/creativemain.png',
                width: 250,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: 5),

            // PROFILE IMAGE
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  'assets/profile.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),


            SizedBox(height: 5,),
            //title & its style
            // Text(
            //     "Profile",
            //     style: TextStyle(
            //       fontSize: 24,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.white,
            //     ),
            // ),
            //text area
            SizedBox(height: 40),
            Container(
              width: screenWidth * 90,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                //body section bg color
                color: Color(0xFFD8D8D8),
               // borderRadius: BorderRadius.circular(30),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              //text area data section headers
              child: Column(
                children: [
                  _buildInfoTile("Name", name),
                  _buildInfoTile("Department", department),
                  _buildInfoTile("Position", position),
                  _buildInfoTile("Email", email),
                  _buildInfoTile("Phone", phone)
                ],
              ),
            )
          ],
        ),
      ),
    );

  }
  //widget for info tiles
  Widget _buildInfoTile(String title, String value){
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            //text box colors
            color: Color(0xFF3E3D3C),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              )
            ],
          ),
        ),
    );
  }
}