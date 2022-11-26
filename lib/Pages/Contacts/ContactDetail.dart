import 'package:flutter/material.dart';
import 'package:projectcrm/Assets/buttons.dart';
import 'package:projectcrm/Helpers/Constants/Styling.dart';
import 'package:projectcrm/Pages/Contacts/Contacts.dart';
import '../../Models/ContactsModel.dart';

class ContactDetail extends StatefulWidget {
  Contact selectedContact = Contact();
  ContactDetail({Key? key, required this.selectedContact}) : super(key: key);

  @override
  _ContactDetailPageState createState() => new _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetail> {
  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Styling.purpleLight,
          title: Text(
              "${selectedContact.firstName} ${selectedContact.lastName} - Details",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600)),
        ),
        body: SingleChildScrollView(
            child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Builder(
            builder: (context) => Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 60,
                            child: Image.asset("images/profile.png"),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 110.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                      "${selectedContact.firstName} ${selectedContact.lastName}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                          color: Colors.white))
                                ],
                              ),
                              Row(
                                children: [
                                  Text(selectedContact.emailAddress,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.white))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'First Name',
                          labelStyle: TextStyle(color: Colors.white)),
                    ),
                    TextFormField(
                      maxLines: 3,
                      decoration: InputDecoration(
                          labelText: 'Last Name',
                          labelStyle: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(height: 20.0),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: MyElevatedButton(
                            onPressed: () {},
                            label: "Upload Image",
                            icon: const Icon(Icons.image),
                            borderRadius: BorderRadius.circular(10),
                            child: const Text("Upload Image"))),
                    SizedBox(
                      height: 20.0,
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: MyElevatedButton(
                            onPressed: () {},
                            label: "Save",
                            icon: const Icon(Icons.arrow_forward),
                            borderRadius: BorderRadius.circular(10),
                            child: const Text("Save"))),
                  ],
                )),
          ),
        )));
  }
}
