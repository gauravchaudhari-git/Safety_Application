
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfirstproject/child/bottom_page.dart';
import 'package:myfirstproject/child/register_child.dart';
import 'package:myfirstproject/components/PrimaryButton.dart';
import 'package:myfirstproject/components/SecondaryButton.dart';
import 'package:myfirstproject/components/custom_textfield.dart';
import 'package:myfirstproject/db/shared_pref.dart';
import 'package:myfirstproject/parent/parent_home_screen.dart';
import 'package:myfirstproject/parent/parent_register_screen.dart';
import 'package:myfirstproject/utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordShown = false;
  final _fromKey = GlobalKey<FormState>();
  final _fromdata = <String, Object>{};
  bool isloading = false;
  _onSubmit() async{
    _fromKey.currentState!.save();
    try {
      setState(() {
        isloading = true;
      });
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _fromdata['email'].toString(),
            password: _fromdata['password'].toString());
      if (userCredential.user != null) {
        setState(() {
        isloading = false;
      });
      FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get()
            .then((value) {
              if (value['type'] =='parent') {
                print(value['type']);
                MySharedPreference.saveUserType('parent');
                goTo(context, const ParentHomeScreen()); 
              } else {
                MySharedPreference.saveUserType('child');
                goTo(context, const BottomPage());
              }
            });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isloading = false;
      });
      if (e.code == 'user-not-found') {
        dialogueBox(context, 'No user found for that email.');
        // ignore: duplicate_ignore
        // ignore: avoid_print
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        dialogueBox(context, 'Wrong password provided for that user.');
        print('Wrong password provided for that user.');
      }
    }
    print(_fromdata['email']);
    print(_fromdata['password']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
          padding: const EdgeInsets.all(8.0),   
          child:    SingleChildScrollView(
                    child: Stack(
                      children: [
                        isloading
                          ? progressIndicator(context)
                          :  Column(
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.3,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Text(
                                          "USER LOGIN",
                                          style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor),
                                        ),
                                        Image.asset(
                                          'assets/logo.png',
                                          height: 100,
                                          width: 100,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.4,
                                  child: Form(
                                    key: _fromKey,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        CustomTextField(
                                          hintText: 'enter email',
                                          textInputAction: TextInputAction.next,
                                          keyboardtype: TextInputType.emailAddress,
                                          prefix: const Icon(Icons.person),
                                          onsave: (email) {
                                            _fromdata['email'] = email ?? "";
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
                                        PrimaryButton(
                                            title: 'LOGIN',
                                            onPressed: () {
                                              // progressIndicator(context);
                                              if (_fromKey.currentState!.validate()) {}
                                              _onSubmit();
                                            }),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Forgot Password?',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    SecondaryButton(title: 'Click here', onPressed: () {}),
                                  ],
                                ),
                                SecondaryButton(
                                    title: 'Register as child', 
                                    onPressed: () {
                                      goTo(context, const RegisterChildScreen());
                                    }),
                                SecondaryButton(
                                    title: 'Register as parent', 
                                    onPressed: () {
                                      goTo(context, const RegisterParentScreen());
                                    }), 
                              ]),
                          ],
                        ),
                          )),
                    ));
                  }
                }
