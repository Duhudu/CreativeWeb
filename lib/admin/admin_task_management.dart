import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/navbar.dart';
import 'package:creativeweb/profile_page.dart';

class ManageTaskPage extends StatefulWidget{
  _ManageTaskPageState createState() => _ManageTaskPageState();
}
class _ManageTaskPageState extends State<ManageTaskPage>{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Stream to listen for updates in Tasks collection
  Stream<QuerySnapshot> _taskStream(){
    return _firestore
        .collection('tasks')
        .orderBy('created_at', descending: true)
        .snapshots();
  }
  //Function to delete an task
  Future<void> _deletetask(String taskId) async{
    try{
      await _firestore.collection('tasks').doc(taskId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Task Deleted Successfully"))
      );
    }catch (e) {
      print('Error deleting Task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete Task')));
    }
  }
  // Function to navigate to the task editing page
  void _editTask(Map<String, dynamic> taskData, String taskId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final topicController = TextEditingController(text: taskData['topic']);
        final bodyController = TextEditingController(text: taskData['body']);
        final deadlineController = TextEditingController(text: taskData['deadline']);
        final startingDateController = TextEditingController(text: taskData['startingDate']);

        return AlertDialog(
          title: Text("Edit Task"),
          content: SingleChildScrollView(  // Wrap in SingleChildScrollView
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: topicController,
                  decoration: InputDecoration(labelText: "Topic"),
                ),
                TextField(
                  controller: bodyController,
                  decoration: InputDecoration(labelText: "Body"),
                  maxLines: 5,
                ),
                TextField(
                  controller: deadlineController,
                  decoration: InputDecoration(labelText: "Deadline"),
                ),
                TextField(
                  controller: startingDateController,
                  decoration: InputDecoration(labelText: "Starting Date"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  // Update the task in Firestore
                  await _firestore.collection('tasks').doc(taskId).update({
                    'topic': topicController.text.trim(),
                    'body': bodyController.text.trim(),
                    'deadline': deadlineController.text.trim(),
                    'startingDate': startingDateController.text.trim(),
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Task updated successfully')),
                  );
                } catch (e) {
                  print('Error updating task: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update Task')),
                  );
                }
              },
              child: Text("Save Changes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Manage Tasks",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF252422),
        centerTitle: true,
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);// go back
            },
            icon: Icon(Icons.arrow_back, color: Colors.white)
        ),
      ),
      backgroundColor: Color(0xFF252422),
      body: StreamBuilder<QuerySnapshot>(
        stream: _taskStream(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading task'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(
                  "No tasks available",
                  style: TextStyle(color: Colors.white),
                ));
          }
          var tasks = snapshot.data!.docs;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index){
              var task = tasks[index];
              var taskData = task.data() as Map<String, dynamic>;
              String taskId = task.id;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskData['topic'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      taskData['body'],
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () =>{
                              _editTask(taskData, taskId)
                            },
                            icon: Icon(Icons.edit),
                        ),
                        IconButton(
                            onPressed: () =>{
                              _deletetask(taskId)
                            },
                            icon: Icon(Icons.delete)
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },

      ),
    );
  }
}
