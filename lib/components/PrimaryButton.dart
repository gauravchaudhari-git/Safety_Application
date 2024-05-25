import 'package:flutter/material.dart';
import 'package:myfirstproject/utils/constants.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final Function onPressed;
  final bool loading;
  const PrimaryButton(
      {super.key, required this.title, required this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          onPressed();
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
