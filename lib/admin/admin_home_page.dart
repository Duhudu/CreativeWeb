import 'package:creativeweb/navbar.dart';
import 'package:flutter/material.dart';
import '/navbar.dart';
import 'package:creativeweb/profile_page.dart';
import 'admin_announce.dart';
import 'admin_createAcc.dart';
import 'admin_salary.dart';
import 'admin_complaint.dart';
import 'admin_viewAcc.dart';
import 'admin_task.dart';

class AdminHomePage extends StatefulWidget{
  @override
  _AdminHomePageState createState() => _AdminHomePageState();

}
class _AdminHomePageState extends State<AdminHomePage>{


  //Main UI
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text(
            "Home",
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
        //center text
        centerTitle: true,
      ),
      backgroundColor: Color(0xFF252422),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5),
            Center(
              child: Image.asset(
                'assets/creativemain1.png',
                width: 300,
                  height: 200,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            // Main Menu
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFD8D8D8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
                children: [
                  //salary
                  _buildGridButton(
                    icon: 'assets/salary.png',
                    label: "Salary",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SalaryPage())
                    ),
                  ),
                  //task
                  _buildGridButton(
                    icon: 'assets/Task.png',
                    label: "Task",
                    onTap:() => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TaskPage())
                    ),
                  ),
                  //announcements
                  _buildGridButton(
                    icon: 'assets/edit.png',
                    label: "Create Account",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateAnn()),
                    ),
                  ),
                  //create account
                  _buildGridButton(
                    icon: 'assets/announcementsnew.png',
                      label: "Announcements",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AnnPage()),
                      ),
                  ),
                  //search account
                  _buildGridButton(
                    icon: 'assets/search.png',
                    label: "Search",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewAccount()),
                    ),
                  ),
                  //Complaint
                  _buildGridButton(
                    icon: 'assets/complaint.png',
                    label: "Complaint",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ComplaintPage()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),


    );
  }
// Grid Button Widget
Widget _buildGridButton({required String icon, required String label, required VoidCallback onTap}){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            //image box shadow
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2)
            )
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //image style and things
            Image.asset(
              icon,
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
            //text inside the menu
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
}
}

