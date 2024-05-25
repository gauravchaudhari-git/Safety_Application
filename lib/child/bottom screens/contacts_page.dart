
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myfirstproject/db/db_services.dart';
import 'package:myfirstproject/model/contact_sm.dart';
import 'package:myfirstproject/utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  final DatabaseHelper _databaseHelper=DatabaseHelper();
  TextEditingController searchController = TextEditingController();
  @override
    void initState() {
        super.initState();
        askPermissions();
      }

      String flattenPhoneNumber(String phoneStr) {
        return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
          return m[0] == "+" ? "+" : "";
        });
      }


      filterContact() {
      List<Contact> _contacts = [];
      _contacts.addAll(contacts);
      if (searchController.text.isNotEmpty) {
        _contacts.retainWhere((element) {
          String searchTerm = searchController.text.toLowerCase();
          String searchTermFlattren = flattenPhoneNumber(searchTerm);
          String contactName = element.displayName!.toLowerCase();
          bool nameMatch = contactName.contains(searchTerm);
          if (nameMatch == true) {
        
            return true; 
          }
          if (searchTermFlattren.isEmpty) {
            return false;
          }
          var phone = element.phones!.firstWhere((p) {
            String phnFlattered = flattenPhoneNumber(p.value!);
            return phnFlattered.contains(searchTermFlattren);
          });
          return phone.value!=null;

        });       
      }
      setState(() {
        contactsFiltered = _contacts;
        });
      }
  Future<void> askPermissions() async {
    PermissionStatus permissionStatus = await getContactsPermissions();
    if (permissionStatus==PermissionStatus.granted) {
      getAllContacts();
      searchController.addListener(() { 
        filterContact();
      });

    } else {
      handInvalidPermissions(permissionStatus);
    }

  }
  handInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      dialogueBox(context, "Access to the contacts denied by the user");
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      dialogueBox(context, "May contacts does exist in the device");
    }
  }

  Future<PermissionStatus> getContactsPermissions() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
          PermissionStatus permissionStatus = await Permission.contacts.request();
          return permissionStatus;
        } else {
          return permission;
        }
  }
  getAllContacts() async {
    List<Contact> _contacts = await ContactsService.getContacts(
      withThumbnails: false
    );
    if (mounted) {
    setState(() {
      contacts = _contacts;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    bool isSearching=searchController.text.isNotEmpty;
    bool ListItemExit = (contactsFiltered.isNotEmpty || contacts.isNotEmpty ); 
    return Scaffold(
      body: contacts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    autofocus: true,
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: "search contacts",
                      prefixIcon: Icon(Icons.search)
                    ),
                  ),
                ),
                ListItemExit==true
                ?
                Expanded(
                  child: ListView.builder(
                    itemCount: isSearching==true
                          ? contactsFiltered.length
                          : contacts.length,
                    itemBuilder: (BuildContext context, int index) {
                      Contact contact = isSearching==true
                          ? contactsFiltered[index]
                          : contacts[index];
                  
                      return ListTile(
                        title: Text(contact.displayName!),
                        // subtitle: Text(contact.phones!.elementAt(0)
                        // .value!) ,
                        leading:contact.avatar != null && contact.avatar!.isNotEmpty
                              ? CircleAvatar (
                                backgroundColor: primaryColor,
                                  backgroundImage: MemoryImage(contact.avatar!),
                                )
                              : CircleAvatar (
                                backgroundColor: primaryColor,
                                  child: Text(contact.initials()),
                                ),
                                onTap: () {
                                  if (contact.phones!.isNotEmpty) {
                                    final String phoneNum = 
                                        contact.phones!.elementAt(0).value!;
                                    final String name = contact.displayName!;
                                    _addContact(TContact(phoneNum, name));
                                  } else {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Oops! phone number does not exists" );
                                   }
                                },
                        );
                    },
                  ),
                ) 
                : Container(
                  child: const Text("searching"),
                ),
              ],
            ),
          ),
    );
  }
  void _addContact(TContact newContact) async{
    int result = await _databaseHelper.insertContact(newContact);
    if (result != 0) {
      Fluttertoast.showToast(msg: "contact added successfully");
    } else {
      Fluttertoast.showToast(msg: "Failed to add contacts");
    }
    Navigator.of(context).pop(true);
  }
}