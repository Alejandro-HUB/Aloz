// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Home/TopAppBar.dart';
import '../../../Assets/buttons.dart';
import '../../Home/HomePage.dart';
import '../../../Helpers/Constants/Styling.dart';
import '../../../Helpers/Routing/route.dart';
import '../../../Models/ContactsModel.dart';
import 'DataWidget.dart';

class DataEntryForm extends StatefulWidget {
  const DataEntryForm({super.key});

  @override
  DataEntryFormState createState() {
    return DataEntryFormState();
  }
}

class DataEntryFormState extends State<DataEntryForm> {
  final _formKey = GlobalKey<FormState>();

  CollectionReference contacts = FirebaseFirestore.instance
      .collection("UserWidgetData")
      .doc(FirebaseAuth.instance.currentUser!.uid.toString())
      .collection(currentWidget!.documentIdData);

  Contact contactToAdd = Contact();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Styling.primaryColor,
        // ignore: prefer_const_constructors
        title: Text(
          "Import Data",
          style: TextStyle(color: Styling.primaryColor),
        ),
        backgroundColor: Styling.foreground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
                key: _formKey,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        style: TextStyle(color: Styling.primaryColor),
                        onChanged: (value) {
                          contactToAdd.firstName = value;
                        },
                        textInputAction: TextInputAction.next,
                        // ignore: prefer_const_constructors
                        decoration: InputDecoration(
                          labelText: "First Name",
                          // ignore: prefer_const_constructors
                          labelStyle: TextStyle(color: Styling.primaryColor),
                          icon:
                              Icon(Icons.person_pin, color: Styling.primaryColor),
                          hintStyle: TextStyle(color: Styling.primaryColor),
                          helperStyle: TextStyle(color: Styling.primaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        style: TextStyle(color: Styling.primaryColor),
                        onChanged: (value) {
                          contactToAdd.lastName = value;
                        },
                        textInputAction: TextInputAction.next,
                        // ignore: prefer_const_constructors
                        decoration: InputDecoration(
                          labelText: "Last Name",
                          labelStyle: TextStyle(color: Styling.primaryColor),
                          icon:
                              Icon(Icons.person_pin, color: Styling.primaryColor),
                          hintStyle: TextStyle(color: Styling.primaryColor),
                          // ignore: prefer_const_constructors
                          helperStyle: TextStyle(color: Styling.primaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        style: TextStyle(color: Styling.primaryColor),
                        onChanged: (value) {
                          contactToAdd.emailAddress = value;
                        },
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: Styling.primaryColor),
                          icon: Icon(Icons.email, color: Styling.primaryColor),
                          hintStyle: TextStyle(color: Styling.primaryColor),
                          helperStyle: TextStyle(color: Styling.primaryColor),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (email) =>
                            email != null && !EmailValidator.validate(email)
                                ? 'Enter a valid email'
                                : null,
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: GradientButton(
                          gradient: LinearGradient(colors: [Styling.gradient1, Styling.gradient2]),
                          label: 'Add Contact',
                          width: double.infinity,
                          icon: Icon(
                            Icons.person_add,
                            color: Styling.primaryColor,
                          ),
                          onPressed: addContacts,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future addContacts() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sending Data to Cloud Firestore"),
        ),
      );

      var doc = contacts.doc();
      contactToAdd.id = doc.id;
      await doc
          .set(contactToAdd.toJson())
          // ignore: avoid_print
          .then((value) => print('Contact Added'))
          // ignore: avoid_print
          .catchError((error) => print('Failed to add contact: $error'));

      //Return to contacts page
      // ignore: use_build_context_synchronously
      Navigator.of(context).push(MaterialPageRoute(
          // ignore: prefer_const_constructors
          builder: (context) => RoutePage(
                appBar: const TopAppBar(),
                page: const DataWidget(),
                showDrawer: true,
              )));
    }
  }
}
