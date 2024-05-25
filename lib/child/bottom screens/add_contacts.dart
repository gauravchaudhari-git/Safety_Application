import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:myfirstproject/child/bottom%20screens/contacts_page.dart';
import 'package:myfirstproject/components/PrimaryButton.dart';
import 'package:myfirstproject/db/db_services.dart';
import 'package:myfirstproject/model/contact_sm.dart';
import 'package:sqflite/sqflite.dart';

class AddContactsPage extends StatefulWidget {
  const AddContactsPage({super.key});

  @override
  State<AddContactsPage> createState() => _AddContactsPageState();
}

class _AddContactsPageState extends State<AddContactsPage> {

  DatabaseHelper databasehelper = DatabaseHelper();
  List<TContact>? contactList=[];
  int count=0;

  void showList() {
    Future<Database> dbFuture = databasehelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<TContact>> contactListFuture =  
        databasehelper.getContactList();
      contactListFuture.then((value) {
        setState(() {
          contactList = value;
          count = value.length;
        });
      });
    });  
  }
  
  void  deleteContact( TContact contact) async {
    int result = await databasehelper.deleteContact(contact.id);
    if(result != 0) {
      if (mounted) {
        setState(() {
          showList();
        });
        
      }
      
    }
  }
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
     showList(); 
    });
    

    super.initState();
  }
  Widget build(BuildContext context) {
  contactList??= [];
  return SafeArea(
    child: Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          PrimaryButton(
            title: "Add Trusted Contacts",
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactsPage(),
                ),
              );
            if (result == true || result == null) {
              showList();
            }

            }),
            Expanded(
              child: ListView.builder (
                // shrinkWrap: true,
                itemCount: count,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(contactList![index].name),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                    await FlutterPhoneDirectCaller.callNumber(
                                        contactList![index].number);
                                    
                                  
                                },
                                 icon:  const Icon(
                                  Icons.call,
                                  color: Colors.red,
                              )),
                              IconButton(
                                onPressed: ()  {
                                    deleteContact(contactList![index]);
                                  
                                },
                                 icon:  const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                              )),
                              
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              ),
            )  
          ],
        ),
      ),
    );
  }
}