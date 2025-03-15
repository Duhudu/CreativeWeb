import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//admin imports
import 'admin/admin_home_page.dart';
import 'admin/admin_announce.dart';
import 'admin/admin_createAcc.dart';
import 'admin/admin_salary.dart';
import 'admin/admin_task.dart';
import 'admin/admin_viewAcc.dart';
//import signin
import 'sign_in_page.dart';
import 'admin/admin_complaint.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user from firebase db
    User? user = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            //display user name and email taken from the firebase bd
              //accountName: Text(user?.displayName ?? 'Test'),
            accountName: Text(user?.displayName?.isEmpty ?? true ? 'No name' : user?.displayName ?? 'No name'),
            accountEmail: Text(user?.email ?? 'No name'),
            //user acc pic(default)
            currentAccountPicture: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.transparent,

              child: ClipOval(
                child: Image(
                    image: AssetImage('assets/profile.png'),
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover ,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Color(0xFF252422),

            ),
          ),
          Divider(),
          //home link
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () {
              // Close the drawer first
              Navigator.pop(context);
              // Navigate to the HomePage and replace the current page
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminHomePage()),
              );
            },

          ),
          //salary tab link
          ListTile(
            leading: Icon(Icons.money),
            title: Text("Salary"),
            onTap: () {
              // Close the drawer first
              Navigator.pop(context);

              // Navigate to the HomePage and replace the current page
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SalaryPage())
              );
            },
          ),
          //task tab link
          ListTile(
            leading: Icon(Icons.task),
            title: Text("Task"),
            onTap: () {
              // Close the drawer first
              Navigator.pop(context);
              // Navigate to the HomePage and replace the current page
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TaskPage())
              );
            },
          ),
          Divider(),
          //Announcement link
          ListTile(
            leading: Icon(Icons.announcement),
            title: Text("Announcement"),
            onTap: () {
              // Close the drawer first
              Navigator.pop(context);

              // Navigate to the HomePage and replace the current page
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AnnPage()),
              );
            },
          ),
          //acount create
          ListTile(
            leading: Icon(Icons.create),
            title: Text("Create Account"),
            onTap: () {
              // Close the drawer first
              Navigator.pop(context);

              // Navigate to the HomePage and replace the current page
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CreateAnn())
              );
            },
          ),
          //search account
          ListTile(
            leading: Icon(Icons.search),
            title: Text("Search Account"),
            onTap: () {
              //Close the drawer first
              Navigator.pop(context);

              // Navigate to the HomePage and replace the current page
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ViewAccount())
              );
            },
          ),
          //Complaint
          ListTile(
            leading: Icon(Icons.dangerous),
            title: Text("Complaint"),
            onTap: () {
              //Close the drawer first
              Navigator.pop(context);

              // Navigate to the HomePage and replace the current page
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ComplaintPage())
              );
            },
          ),
          Divider(),
          //logout
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("LogOut"),
            onTap: () {
              // Show a confirmation dialog
              showDialog(
                  context: context,
                  builder: (BuildContext){
                    return AlertDialog(
                      title: Text("Confirm LogOut"),
                      content: Text("Are You Sure You Want To Logout?"),
                      actions: <Widget>[
                        TextButton(
                            child: Text("Cancel"),
                            onPressed: (){
                              Navigator.pop(context);
                            },
                        ),
                        TextButton(
                            child: Text("Yes"),
                            onPressed: () async  {
                              //Logout the user
                              await FirebaseAuth.instance.signOut();
                              //Close the dialog
                              Navigator.pop(context);
                              //Navigate to the signin page
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignInPage()))
                              ;
                            },

                        ),
                      ],
                    );
                  }
              );

            },
          ),
        ],
      ),
    );

  }
}
