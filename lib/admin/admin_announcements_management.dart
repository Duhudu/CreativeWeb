import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/navbar.dart';
import 'package:creativeweb/profile_page.dart';
import 'package:creativeweb/navbar.dart';
import 'admin_announcements_management.dart';

class ManageAnnouncementsPage extends StatefulWidget{
  @override
  _ManageAnnouncementsPageState createState() => _ManageAnnouncementsPageState();
}
class _ManageAnnouncementsPageState extends State<ManageAnnouncementsPage>{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Stream to listen for updates in Announcements collection
  Stream<QuerySnapshot> _announcementsStream(){
    return _firestore.collection('announcements').orderBy('created_at', descending: true).snapshots();
  }
  //Function to delete an Announcements
  Future<void> _deleteAnnouncement(String announcementId) async{
    try{
      await _firestore.collection('announcements').doc(announcementId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Announcement deleted successfully')));
    } catch (e) {
      print('Error deleting announcement: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete announcement')));
    }
  }
  //Function to navigate to the announcements editing page
  void _editAnnouncement(Map<String, dynamic> announcementData, String announcementId){
    showDialog(
        context: context,
        builder: (BuildContext context){
          final titleController = TextEditingController(text: announcementData['title']);
          final bodyController =  TextEditingController(text: announcementData['body']);
          return AlertDialog(
            title: Text("Edit Announcements"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: bodyController,
                  decoration: InputDecoration(labelText: "Body"),
                  maxLines: 5,
                )
              ],
            ),
              actions: [
                TextButton(
                  onPressed: () async {
                    try {
                      // Update the announcement in Firestore
                      await _firestore.collection('announcements').doc(announcementId).update({
                        'title': titleController.text.trim(),
                        'body': bodyController.text.trim(),
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Announcement updated successfully')));
                    } catch (e) {
                      print('Error updating announcement: $e');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update announcement')));
                    }
                  },
                  child: Text("Save Changes"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
              ],
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {

    return  Scaffold(
        appBar: AppBar(
          title: Text(
            "Manage Announcements",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF252422),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);  // Go back to the previous screen (announcements page)
            },
          ),
        ),
        backgroundColor: Color(0xFF252422),
        body: StreamBuilder<QuerySnapshot>(
          stream: _announcementsStream(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator());
            }

            if(snapshot.hasError){
              return Center(child: Text('Error loading announcements'));
            }
            if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
              return Center(child: Text("No announcements available", style: TextStyle(color: Colors.white),));
            }
            var announcements = snapshot.data!.docs;
            return ListView.builder(
                itemCount: announcements.length,
                itemBuilder: (context, index){
                  var announcement = announcements[index];
                  var announcementData = announcement.data() as Map<String, dynamic>;
                  String announcementId = announcement.id;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcementData['title'],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          announcementData['body'],
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editAnnouncement(announcementData, announcementId),
                                ),
                            IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteAnnouncement(announcementId),

                            ),
                          ],
                        )

                      ],
                    ),
                  );

                }
            );
        },
        )
    );
  }
}