import 'package:flutter/material.dart';
import 'package:myfirstproject/utils/quotes.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatelessWidget {
  final Function()? onTap;
  final int? quoteIndex;
  const CustomAppBar({super.key, required this.onTap, required this.quoteIndex});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        sweetSayings[quoteIndex!],
        style: const TextStyle(
          fontSize: 22,
        ),
      ),
    );
  }
}