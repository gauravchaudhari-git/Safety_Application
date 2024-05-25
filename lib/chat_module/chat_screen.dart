import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myfirstproject/chat_module/message_textfield.dart';
import 'package:myfirstproject/chat_module/singleMessage.dart';
import 'package:myfirstproject/utils/constants.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String friendId;
  final String friendName;


  const ChatScreen({super.key, 
  required this.currentUserId, 
  required this.friendId, required this.friendName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? type;
  String? myname;

  getStatus() async {
  final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(widget.currentUserId).get();

  if (mounted) {
    setState(() {
      type = currentUserDoc['type'];
      myname = currentUserDoc['name'];
    });
  }
}

  @override
  void initState() {
    getStatus();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(widget.friendName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.currentUserId)
              .collection('message')
              .doc(widget.friendId)
              .collection('chats')
              .orderBy('date',descending: false)
              .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.length < 1) {
                    return  Center(
                      child: Text(
                        type == "parent" ? "TALK WITH CHILD" : "TALK WITH PARENT",
                        style: const TextStyle(fontSize: 30),
                      ),
                    );                   
                  }
                  return Container(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      bool isMe = snapshot.data!.docs[index]['senderId'] == 
                         widget.currentUserId;
                      final data = snapshot.data!.docs[index];
                      return Dismissible(
                        key: UniqueKey(),
                        onDismissed:(direction) async {
                          await FirebaseFirestore.instance.collection('users')
                            .doc(widget.currentUserId)
                            .collection('message')
                            .doc(widget.friendId)
                            .collection('chats')
                            .doc(data.id)
                            .delete();
                          await FirebaseFirestore.instance.collection('users')
                            .doc(widget.currentUserId)
                            .collection('message')
                            .doc(widget.friendId)
                            .collection('chats')
                            .doc(data.id)
                            .delete().then((value) => Fluttertoast.showToast(msg: 'message deleted successfully'));

                        },
                        child: SingleMessage(
                          message: data['message'],
                          date: data['date'],
                          isMe: isMe,
                          friendName: widget.friendName,
                          myName: myname,
                          type: data['type'],
                                    
                        ),
                      );
                    },
                  ),
                );
                }
                return progressIndicator(context);
              },
              ),
          ),
          MessageTextField(
            currentId: widget.currentUserId,
            friendId: widget.friendId,
          ),
        ],
      ),
    );
  }
}