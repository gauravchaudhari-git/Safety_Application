import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myfirstproject/components/PrimaryButton.dart';
import 'package:myfirstproject/components/custom_textfield.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameC = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? id;

  @override
  void initState() {
    super.initState();
    getName();
  }

  getName() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    nameC.text = querySnapshot.docs.first['name'];
    id = querySnapshot.docs.first.id;
  } else {
    // Handle the case where no matching document is found
    print('No matching document found');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "UPDATE YOUR PROFILE",
                style: TextStyle(fontSize: 25),
              ),
              const SizedBox(height: 15),
              CircleAvatar(
                radius: 40,
                child: Center(child: Image.asset( 'assets/add_pic.png', 
                height: 35,
                width: 35,
                
                )),

              ),
              CustomTextField(
                controller: nameC,
                hintText: "Enter your name", // Update hintText
                validate: (v) {
                  if (v!.isEmpty) {
                    return 'Please enter your updated name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),
              PrimaryButton(
                title: "UPDATE",
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(id) // Specify document ID to update
                        .update({'name': nameC.text});
                    
                  }
                  Fluttertoast.showToast(msg: "name updated successfully");
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
