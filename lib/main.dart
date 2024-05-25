import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myfirstproject/child/bottom_page.dart';
import 'package:myfirstproject/child/child_login_screen.dart';
import 'package:myfirstproject/db/shared_pref.dart';
import 'package:myfirstproject/parent/parent_home_screen.dart';
import 'package:myfirstproject/utils/constants.dart';

final navigatorkey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseOptions firebaseOptions = const FirebaseOptions(
    apiKey: 'AIzaSyArP_Fqzb830lF09ATYpMOEJNIMlxp7iLU',
    appId: '1:240284293944:android:ff0064f53344ad69e37fcd',
    messagingSenderId: '240284293944',
    projectId: 'myfirstproject-3a795',
    storageBucket: "myfirstproject-3a795.appspot.com"
  );

  if (Platform.isAndroid) {
    await Firebase.initializeApp(options: firebaseOptions);
  } else {
    await Firebase.initializeApp();
  }

  await MySharedPreference.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
        home: FutureBuilder(
          future: MySharedPreference.getUserType(), 
          builder: (BuildContext context, AsyncSnapshot snapshot) { 
            if (snapshot.data == "") {
              return const LoginScreen();
            }
            if (snapshot.data == "child") {
              return const BottomPage();
              
            }
            if (snapshot.data == "parent") {
              return const ParentHomeScreen();
              
            }

            return progressIndicator(context);
          },
        ),    
    );
  }
}

 