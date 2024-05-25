import 'dart:math';
import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myfirstproject/db/db_services.dart';
import 'package:myfirstproject/model/contact_sm.dart';
import 'package:myfirstproject/widgets/home_widgets/CustomCarouel.dart';
import 'package:myfirstproject/widgets/home_widgets/custom_appBar.dart';
import 'package:myfirstproject/widgets/home_widgets/emergency.dart';
import 'package:myfirstproject/widgets/home_widgets/safehome/SafeHome.dart';
import 'package:myfirstproject/widgets/live_safe.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shake/shake.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // const HomeScreen({super.key});
  int qIndex = 0;
  Position? _currentPosition;
  String? _currentAddress;
  LocationPermission? permission;
  _getPermissions() async => await [Permission.sms].request();
  _isPermissionGranted() async => await Permission.sms.status.isGranted;
  _sendSms(String phoneNumber, String message, {int? simSlot}) async {
    await BackgroundSms.sendMessage(
      phoneNumber: phoneNumber,
      message: message,
      simSlot: simSlot,
      ).then((SmsStatus status) {
        
          Fluttertoast.showToast(msg: "sent");
        
      });
    
  }
  _getCurrentLocation() async {
  bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!isLocationServiceEnabled) {
    Fluttertoast.showToast(msg: "Location services are disabled. Please enable them in the device settings.");
    return;
  }

  permission = await Geolocator.checkPermission();
  if (permission ==  LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    Fluttertoast.showToast(
      msg: "Location permissions are denied");
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
        msg: "Location permission are permanently denied",
        );
        return;
    }
  }

  Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
    forceAndroidLocationManager: true)
    .then((Position position)  {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLon();
    }).catchError((e) {
      Fluttertoast.showToast(msg: "Error getting location: $e");
    });
}

  _getAddressFromLatLon() async {
    try {
      if (_currentPosition != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placemarks[0];
      setState(() {
          _currentAddress = "${place.locality}, ${place.postalCode}, ${place.street}";
        });
    } else {
      Fluttertoast.showToast(msg: "Current position is null");
    }
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
  }
}


  getRandomQuote() {
    Random random = Random();

    setState(() {
      qIndex = random.nextInt(6);
    });

    getAndSendSms() async {
                      List<TContact> contactList = 
                          await DatabaseHelper().getContactList();
      String messageBody = 
                      "https://maps.google.com/?daddr=${_currentPosition!.latitude},${_currentPosition!.longitude}";
                    if (await _isPermissionGranted()) {
                      for (var element in contactList) {
                        _sendSms(element.number, "Iam in Trouble please reach me out at $messageBody",
                         simSlot: 1);
                      }
                    } else {
                      
                      Fluttertoast.showToast(msg: "something went wrong");
                    }
    }
    _getPermissions();
    _getCurrentLocation();
   
    ///// shake feature /////
    ShakeDetector.autoStart(

      onPhoneShake: () {
        getAndSendSms();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shake!'),
          ),
        );
        // Do stuff on phone shake
      },
      minimumShakeCount: 1,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 2.7,
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CustomAppBar(
                  quoteIndex: qIndex,
                  onTap: () {
                    getRandomQuote();
                  }),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: const [
                    CustomCarouel(),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Emergency",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Emergency(),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Explore LiveSafe",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    LiveSafe(),
                    SafeHome(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
