import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creativeweb/userNavBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:creativeweb/userProfile.dart';

class TaskPage extends StatefulWidget{
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Get the current logged in users task data from firebase
  Future<List<Map<String, dynamic>>> _getUserTask() async{
    User? user = _auth.currentUser;
    if(user != null){
      final querSnapShot = await _firestore
          .collection('tasks')
          .where('email', isEqualTo: user.email)
          .get();
      return querSnapShot.docs
          .map((doc) => doc.data())
          //return the task data
          .toList();
    }
    else{
      //return empty list if the user is not logged in
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: UserNavBar(),
      appBar: AppBar(
        title: Text(
            "Task",
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
              "Task For You",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              //end of border
              //text area start
              // Fetch and display tasks data
              child: FutureBuilder<List<Map<String, dynamic>>>(
                  future:
                  // Fetch task data for the logged-in user
                    _getUserTask(),
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
                        child: Text(
                            "Error ${snapShot.error}",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                    }
                    // If no salary data
                    if(!snapShot.hasData || snapShot.data!.isEmpty){
                      return Center(
                        child: Text(
                          "You Don't Have Any Tasks",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      );
                    }
                    var tasks = snapShot.data!;
                    return Column(
                      children: tasks.map((task){
                        return Container(
                          width: screenWidth * 0.9,
                          padding: EdgeInsets.all(20),
                          // Margin between task entries
                          margin: EdgeInsets.only(top:15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //display task topic
                              Text(
                                "${task['topic']}",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              //display body
                              SizedBox(height: 10),
                              Text(
                                "${task['body']}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              //display starting date
                              SizedBox(height: 10),
                              Text(
                                "Starting Date: ${task['startingDate']}",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              //display end date
                              SizedBox(height: 10),
                              Text(
                                "End Date: ${task['deadline']}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
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