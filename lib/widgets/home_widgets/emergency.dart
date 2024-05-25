import 'package:flutter/material.dart';
import 'package:myfirstproject/widgets/home_widgets/emergencies/NationalEmergency.dart';
import 'package:myfirstproject/widgets/home_widgets/emergencies/AmbulanceEmergency.dart';
import 'package:myfirstproject/widgets/home_widgets/emergencies/PoliceEmergency.dart';
import 'package:myfirstproject/widgets/home_widgets/emergencies/FirebrigadeEmergency.dart';

class Emergency extends StatelessWidget {
  const Emergency({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 180,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          NationalEmergency(),
          const AmbulanceEmergency(),
          FirebrigadeEmergency(),
          PoliceEmergency(),
        ],
      ),
    );
  }
}
