import 'package:creativeweb/userNavBar.dart';
import 'package:flutter/material.dart';
import 'package:creativeweb/userProfile.dart';
import 'user_announcement.dart';
import 'user_complaint.dart';
import 'user_salary.dart';
import 'user_task.dart';


class UserHomePage extends StatefulWidget{
  _UserHomePageState createState() => _UserHomePageState();
}
class _UserHomePageState extends State<UserHomePage>{

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: UserNavBar(),
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF252422),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfilePage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFF252422),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            // Logo
            Center(
              child: Image.asset(
                'assets/crewebLogo.png',
                width: 300,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            // Main Menu Grid
            Container(
              width: screenWidth * 0.9,
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
                        MaterialPageRoute(builder: (context) => SalaryPage()),
                      ),
                  ),
                  // Task
                  _buildGridButton(
                    icon: 'assets/Task.png',
                    label: "Task",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TaskPage()),
                    ),
                  ),

                  //Announcement
                  _buildGridButton(
                    icon: 'assets/announcementsnew.png',
                    label: "Announcement",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AnnouncementPage()),
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
            )
          ],
        ),
      ),
    );
  }

  // Grid Button Widget
  Widget _buildGridButton ({required String icon, required String label, required VoidCallback onTap}){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                icon,
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
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

