import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class MessageTextField extends StatefulWidget {
  final String currentId;
  final String friendId;
  File? imageFile;

  MessageTextField({super.key, required this.currentId, required this.friendId});

  @override
  State<MessageTextField> createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
   final TextEditingController _controller = TextEditingController();
   Position? _currentPosition;
  String? _currentAddress;
  String? message;
  File? imageFile;

  LocationPermission? permission;
 Future getImage() async {
  ImagePicker _picker = ImagePicker();
  await _picker.pickImage(source: ImageSource.gallery).then((XFile? xFile) {
      if (xFile!= null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }
  Future getImageFromCamera() async {
  ImagePicker _picker = ImagePicker();
  await _picker.pickImage(source: ImageSource.camera).then((XFile? xFile) {
      if (xFile!= null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }
   
  Future uploadImage() async {
  String fileName = const Uuid().v1();
  int status = 1;
  var ref = FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
  
  try {
    var uploadTask = await ref.putFile(imageFile!);
    String imageUrl = await uploadTask.ref.getDownloadURL();
    await sendMessage(imageUrl, 'img');
  } catch (e) {
    // Retry logic
    if (status < 3) {
      await Future.delayed(const Duration(seconds: 5)); // Wait for 5 seconds before retrying
      status++;
      await uploadImage(); // Retry the upload
    } else {
      // Maximum retry limit exceeded, handle error
      print("Maximum retry limit exceeded: $e");
      // You can show a message to the user or handle the error in some other way
    }
  }
}


  Future _getCurrentLocation() async {
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

  sendMessage(String message, String type) async{
    await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.currentId)
                  .collection('message')
                  .doc(widget.friendId)
                  .collection('chats')
                  .add({
                    'senderId': widget.currentId,
                    'receiverId': widget.friendId,
                    'message': message,
                    'type': type,
                    'date': DateTime.now(),

                  });
                   await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.friendId)
                  .collection('message')
                  .doc(widget.currentId)
                  .collection('chats')
                  .add({
                    'senderId': widget.currentId,
                    'receiverId': widget.friendId,
                    'message': message,
                    'text': type,
                    'date': DateTime.now(),

                  });
  }

  @override
  Widget build(BuildContext context) {
    return Padding( 
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                cursorColor: Colors.pink,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'type your message',
                  fillColor: Colors.grey[100],
                  filled: true,
                  prefixIcon: IconButton(onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context, 
                      builder: (context) => bottomsheet(),
                      );
                  },
                   icon: const Icon(Icons.add_box_rounded) )
                ),
              ),
            ),  
             Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () async {
                  message = _controller.text;
                  sendMessage(message!, 'text');
                  _controller.clear();
                  
                },
                child: const Icon(
                  Icons.send,
                  color: Colors.pink,
                  size: 30,
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  bottomsheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2  ,
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child:  Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              chatsIcon(Icons.location_pin, "Location", () async {
                await _getCurrentLocation();
                Future.delayed(const Duration(seconds: 2), () {
                  message="http://www.google.com/maps/search/?api=1&query=${_currentPosition?.latitude}%2C${_currentPosition?.longitude}. $_currentAddress";
                sendMessage(message!, "link");
                });
                
              }),
              chatsIcon(Icons.camera_alt, "Camera", () async {
                await getImageFromCamera();
              }),
              chatsIcon(Icons.insert_photo, "Photo", () async{
                getImage();
              }),
            ],
          ),
        ),
      ),
    );
  }
  
  chatsIcon(IconData icons, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.pink,
            child: Icon(icons),
          ),
          Text("$title")
        ],
      ),
    );

  }
}
