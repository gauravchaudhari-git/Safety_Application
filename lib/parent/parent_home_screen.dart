import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfirstproject/chat_module/chat_screen.dart';
import 'package:myfirstproject/child/child_login_screen.dart';
import 'package:myfirstproject/utils/constants.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:  Drawer(
          child: Column(
            children: [
              DrawerHeader(child: Container(),
              ),
              ListTile(
                title: TextButton(
          onPressed: () async {
            try {
              await FirebaseAuth.instance.signOut();
              goTo(context, const LoginScreen());
            } on FirebaseAuthException catch (e) {
              dialogueBox(context, e.toString());
            }
          },
          child: const Text("Sign Out"),
        ),
              )
            ],
          ),

        
      ),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text("SELECT CHILD"),
      ),
      body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
      .collection('users')
      .where('type', isEqualTo: 'child').where('parentEmail',isEqualTo: FirebaseAuth.instance.currentUser?.email)
      .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: progressIndicator(context));
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            final user = snapshot.data!.docs[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: const Color.fromARGB(255, 250, 163, 192),
                child: ListTile(
                  onTap: () {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    final user = snapshot.data!.docs[index];
                    if (currentUser!= null) {
                      goTo(context,
                        ChatScreen(currentUserId: currentUser.uid,
                        friendId: user.id, friendName: user['name']));
                    } else {
                      // Handle the case where currentUser or user is null
                      dialogueBox(context, 'You are not logged in or user is null');
                    }
                  },
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(user['name']),
                  ),
                ),
              ),
            );
          },
        );
      },
    )
    );
  }
}