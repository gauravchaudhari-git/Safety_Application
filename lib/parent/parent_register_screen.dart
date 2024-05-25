// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfirstproject/child/child_login_screen.dart';
import 'package:myfirstproject/components/PrimaryButton.dart';
import 'package:myfirstproject/components/SecondaryButton.dart';
import 'package:myfirstproject/components/custom_textfield.dart';
import 'package:myfirstproject/model/user_model.dart';
import 'package:myfirstproject/utils/constants.dart';

class RegisterParentScreen extends StatefulWidget {
  const RegisterParentScreen({super.key});

  @override
  State<RegisterParentScreen> createState() => _RegisterChildScreenState();
}

class _RegisterChildScreenState extends State<RegisterParentScreen> {
  bool isPasswordShown = true;
  bool isConfirmPasswordShown = true;

  final _fromKey = GlobalKey<FormState>();
  final _fromdata = <String, Object>{};
  bool isloading = false;
  

  _onSubmit() async {
    _fromKey.currentState!.save();
    if (_fromdata['password']!=_fromdata['cpassword']) {
      dialogueBox(context, 'password and confirm password should be same');
    } else {
      progressIndicator(context);

      try {
        setState(() {
        isloading = true;
      });
  UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: _fromdata['gemail'].toString(), 
    password: _fromdata['password'].toString()
  );
  if(userCredential.user != null) {
    final v = userCredential.user!.uid;
    DocumentReference<Map<String, dynamic>> db = 
              FirebaseFirestore.instance.collection('users').doc(v);
          
          final user = UserModel(
            name: _fromdata['name'].toString(),
            phone: _fromdata['phone'].toString(),
            childEmail: _fromdata['cemail'].toString(),
            parentEmail: _fromdata['gemail'].toString(),
            id: v,
            type: 'parent'
          );
          final jsonData=user.toJson();
          await db.set(jsonData);
          // ignore: use_build_context_synchronously
          goTo(context, const LoginScreen());
          setState(() {
        isloading = false;
      });
  }
} on FirebaseAuthException catch (e) {
  setState(() {
        isloading = false;
      });
  if (e.code == 'weak-password') {
    print('The password provided is too weak.');
    dialogueBox(context, 'The password provided is too weak.');
  } else if (e.code == 'email-already-in-use') {
    print('The account already exists for that email.');
    dialogueBox(context, 'The account already exists for that email.');
  }
} catch (e) {
  print(e);
  setState(() {
        isloading = false;
      });
  dialogueBox(context, e.toString());
}
        
    }
    // ignore: duplicate_ignore
    // ignore: avoid_print
    print(_fromdata['email']);
    print(_fromdata['password']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              isloading
                  ? progressIndicator(context)
                  : SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                    "REGISTER AS PARENT",
                                    style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor),
                                  ),
                                  Image.asset(
                                    'assets/logo.png',
                                    height: 150,
                                    width: 100,
                                  ),
                                ],
                              ),
                            ),
                          ),
                              // ignore: sized_box_for_whitespace
                              Container(
                        height: MediaQuery.of(context).size.height * 0.79,
                        child: Form(
                          key: _fromKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomTextField(
                                hintText: 'enter name',
                                textInputAction: TextInputAction.next,
                                keyboardtype: TextInputType.name,
                                prefix: const Icon(Icons.person),
                                onsave: (name) {
                                  _fromdata['name'] = name ?? "";
                                },
                                validate: (email) {
                                  if (email!.isEmpty || email.length < 3){
                                    return 'enter correct name';
                                  }
                                  return null;
                                },
                              ),
                              CustomTextField(
                                hintText: 'enter phone',
                                textInputAction: TextInputAction.next,
                                keyboardtype: TextInputType.phone,
                                prefix: const Icon(Icons.phone),
                                onsave: (phone) {
                                  _fromdata['phone'] = phone ?? "";
                                },
                                validate: (email) {
                                  if (email!.isEmpty || email.length < 10) {
                                    return 'enter correct email';
                                  }
                                  return null;
                                },
                              ),
                              CustomTextField(
                                hintText: 'enter email',
                                textInputAction: TextInputAction.next,
                                keyboardtype: TextInputType.emailAddress,
                                prefix: const Icon(Icons.person),
                                onsave: (email) {
                                  _fromdata['gemail'] = email ?? "";
                                },
                                validate: (email) {
                                  if (email!.isEmpty ||
                                      email.length < 3 ||
                                      !email.contains("@")) {
                                    return 'enter correct email';
                                  }
                                  return null;
                                },
                              ),
                              CustomTextField(
                                hintText: 'enter child email',
                                textInputAction: TextInputAction.next,
                                keyboardtype: TextInputType.emailAddress,
                                prefix: const Icon(Icons.person),
                                onsave: (cemail) {
                                  _fromdata['cemail'] = cemail ?? "";
                                },
                                validate: (email) {
                                  if (email!.isEmpty ||
                                      email.length < 3 ||
                                      !email.contains("@")) {
                                    return 'enter correct email';
                                  }
                                  return null;
                                },
                              ),
                              CustomTextField(
                                hintText: 'enter password',
                                isPassword: isPasswordShown,
                                prefix: const Icon(Icons.vpn_key_rounded),
                                onsave: (password) {
                                  _fromdata['password'] = password ?? "";
                                },
                                validate: (password) {
                                  if (password!.isEmpty || password.length < 7) {
                                    return 'enter correct password';
                                  }
                                  return null;
                                },
                                suffix: IconButton(
                                  onPressed: () {
                                    setState(() {});
                                    isPasswordShown = !isPasswordShown;
                                  },
                                  icon: isPasswordShown
                                      ? const Icon(Icons.visibility_off)
                                      : const Icon(Icons.visibility),
                                ),
                              ),
                              CustomTextField(
                                hintText: 'confirm password',
                                isPassword: isConfirmPasswordShown,
                                prefix: const Icon(Icons.vpn_key_rounded),
                                onsave: (password) {
                                  _fromdata['cpassword'] = password ?? "";
                                },
                                validate: (password) {
                                  if (password!.isEmpty || password.length < 7) {
                                    return 'enter correct password';
                                  }
                                  return null;
                                },
                                suffix: IconButton(
                                  onPressed: () {
                                    setState(() {});
                                    isConfirmPasswordShown = !isConfirmPasswordShown;
                                  },
                                  icon: isConfirmPasswordShown
                                      ? const Icon(Icons.visibility_off)
                                      : const Icon(Icons.visibility),
                                ),
                              ),
                              PrimaryButton(
                                  title: 'REGISTER',
                                  onPressed: () {
                                    if (_fromKey.currentState!.validate()) {}
                                    _onSubmit();
                                  }),
                            ],
                          ),
                        ),
                      ),
                      
                      SecondaryButton(title: 'Register new user', onPressed: () {
                        goTo(context, const RegisterParentScreen());
                      })
                            ]),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
