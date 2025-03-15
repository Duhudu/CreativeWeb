import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/navbar.dart';
import 'package:creativeweb/profile_page.dart';

class ComplaintPage extends StatefulWidget{
  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text(
          "Complaint",
          style: TextStyle(
            color: Colors.white,

          ),
        ),
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
      ),
        //bg color
        backgroundColor: Color(0xFF252422),
      body: SingleChildScrollView(

      ),
    );
  }
}