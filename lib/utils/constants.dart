import 'package:flutter/material.dart';

Color primaryColor = const Color(0xfffc3b77);

void goTo(BuildContext context, Widget nextScreen) {
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => nextScreen,
      ));
}

dialogueBox(BuildContext context, String text) {
  showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      title: Text(text),
    ),
  );
}
  


Widget progressIndicator(BuildContext context) {
  return const Center(
      child: CircularProgressIndicator(
    backgroundColor: Color(0xfffc3b77),
    color: Colors.red,
    strokeWidth: 7,
  ));
}