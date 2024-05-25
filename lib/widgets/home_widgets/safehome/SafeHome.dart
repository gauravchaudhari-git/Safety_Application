import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myfirstproject/components/PrimaryButton.dart';
import 'package:myfirstproject/db/db_services.dart';
import 'package:myfirstproject/model/contact_sm.dart';
import 'package:permission_handler/permission_handler.dart';

class SafeHome extends StatefulWidget {
  const SafeHome({super.key});

  @override
  State<SafeHome> createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> {
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

  @override
  void initState() {
    super.initState();
    _getPermissions();
    _getCurrentLocation();
    
  }

  showModelSafeHome(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.4,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "SEND YOUR CURRENT LOCATION IMMEDIATELY TO YOUR EMERGENCY CONTACTS",
                  textAlign: TextAlign.center, 
                  style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  if (_currentPosition != null)
                    _currentAddress != null
                   ? Text(_currentAddress!)
                   : Text("Loading..."),
                  PrimaryButton(title: "GET LOCATION", onPressed: () {
                    _getCurrentLocation();
                  }),
                  const SizedBox(height: 10),
                  PrimaryButton(title: "SEND ALERT",
                   onPressed: () async {
                    List<TContact> contactList =
                      await DatabaseHelper().getContactList();
                    // ignore: unused_local_variable
                    String recipients = "";
                    
                    int i = 1;
                    for (TContact contact in contactList) {
                      recipients += contact.number;
                      if (i != contactList.length) {
                        recipients += ";";
                        i++;
                      }
                    }
                    
                    String messageBody = 
                      "http://www.google.com/maps/search/?api=1&query=${_currentPosition?.latitude}%2C${_currentPosition?.longitude}. $_currentAddress";
                    if (await _isPermissionGranted()) {
                      for (var element in contactList) {
                        _sendSms(element.number, "Iam in Trouble please reach me out at $messageBody",
                         simSlot: 1);
                      }
                    } else {
                      
                      Fluttertoast.showToast(msg: "something went wrong");
                    }
                  }),
              ],
              ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModelSafeHome(context),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: 180,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: const BoxDecoration(),
          child: Row(
            children: [
              const Expanded(
                  child: Column(
                children: [
                  ListTile(
                    title: Text("Send Location"),
                    subtitle: Text("Share Location"),
                  ),
                ],
              )),
              ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/route.jpg')),
            ],
          ),
        ),
      ),
    );
  }
}
