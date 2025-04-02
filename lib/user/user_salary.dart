import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creativeweb/userNavBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:creativeweb/userNavBar.dart';
import 'package:creativeweb/userProfile.dart';

class SalaryPage extends StatefulWidget{
  _SalaryPageState createState() => _SalaryPageState();
}

class _SalaryPageState extends State<SalaryPage>{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch the current logged-in user's salary data from Firestore
  Future<List<Map<String, dynamic>>> _getUserSalary() async{
    // Get the currently logged-in user
    User? user = _auth.currentUser;
    if(user != null){
      final querSnapShot = await _firestore
          .collection('salaries')
          .where('email', isEqualTo: user.email)
          .get();
      return querSnapShot.docs
          .map((doc) => doc.data())
          // Return the salary data
          .toList();
    }else{
      // Return empty list if the user is not logged in
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // TODO: implement build
    return Scaffold(
      drawer: UserNavBar(),
      appBar: AppBar(
        title: Text("Salary Management",
        style: TextStyle(
            color: Colors.white,
          fontWeight: FontWeight.bold
        ),
        ),
        backgroundColor: Color(0xFF252422),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
              icon: Icon(Icons.account_circle, color: Colors.white),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage()));
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
              "Salary",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold
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
                  bottomLeft: Radius.circular(40)
                )
              ),
              //end of border
              //text area start
              // Fetch and display salary data
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future:
                // Fetch salary data for the logged-in user
                _getUserSalary(),
                builder: (context, snapShot){
                  if(snapShot.connectionState == ConnectionState.waiting){
                    return Center(
                      // Loading indicator while getting data
                      child: CircularProgressIndicator(),
                    );
                  }
                  // Display error if any
                  if(snapShot.hasError){
                    return Center(
                      child: Text("Error: ${snapShot.error}",
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                    );
                  }
                  // If no salary data
                  if (!snapShot.hasData || snapShot.data!.isEmpty) {
                    return Center(
                        child: Text("No Salary Information Available",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold
                            )
                        )
                    );
                  }
                  var salaries = snapShot.data!;
                  return Column(
                    children: salaries.map((salary) {
                      return Container(
                        width: screenWidth * 0.9,
                        padding: EdgeInsets.all(20),
                        margin: EdgeInsets.only(top: 15),// Margin between salary entries
                        decoration: BoxDecoration(
                          color: Color(0xFFF1F1F1),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 50,
                              offset: Offset(0, 5),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display salary amount
                            Text(
                              "Rs ${salary['salary']}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                            // Space between amount and other details
                            SizedBox(height: 10),
                            //Display Date
                            Text(
                              "${salary['date']}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            // Space between amount and other details
                            SizedBox(height: 10),
                            //Display PaymentMethod
                            Text(
                              "${salary['paymentMethod']}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
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
