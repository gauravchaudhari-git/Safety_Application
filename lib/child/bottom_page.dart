import 'package:flutter/material.dart';
import 'package:myfirstproject/child/bottom%20screens/add_contacts.dart';
import 'package:myfirstproject/child/bottom%20screens/chat_page.dart';
import 'package:myfirstproject/child/bottom%20screens/child_home_page.dart';
import 'package:myfirstproject/child/bottom%20screens/profile_page.dart';
import 'package:myfirstproject/child/bottom%20screens/review_page.dart';

class BottomPage extends StatefulWidget {
  const BottomPage({super.key});

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  int currentIndex = 0;
  final List<Widget> pages = [
   
    const HomeScreen(),
    const AddContactsPage(),
    
    const ChatPage(),
    ProfilePage(),
    const ReviewPage(),
  ];

  void onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: onTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),  
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review),
            label: 'Review',
          ),
        ],
      ),
    );
  }
}