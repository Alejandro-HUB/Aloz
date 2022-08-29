import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Assets/app_bar_widget.dart';
import '../../Assets/buttons.dart';
import '../../Helpers/Constants/Styling.dart';
import '../../Helpers/Routing/route.dart';
import 'Contacts.dart';

class ContactEntryForm extends StatefulWidget {
  @override
  ContactEntryFormState createState() {
    return ContactEntryFormState();
  }
}

class ContactEntryFormState extends State<ContactEntryForm> {
  final _formKey = GlobalKey<FormState>();

  CollectionReference contacts = FirebaseFirestore.instance
      .collection("Contacts")
      .doc(FirebaseAuth.instance.currentUser!.uid.toString())
      .collection(
          "Contacts:" + FirebaseAuth.instance.currentUser!.uid.toString());

  var firstName = '';
  var lastName = '';
  var emailAddress = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Import Data",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Styling.purpleLight,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
                key: _formKey,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        onChanged: (value) {
                          firstName = value;
                        },
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: "First Name",
                          labelStyle: TextStyle(color: Colors.white),
                          icon: Icon(Icons.person_pin, color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white),
                          helperStyle: TextStyle(color: Colors.white),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 4),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        onChanged: (value) {
                          lastName = value;
                        },
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: "Last Name",
                          labelStyle: TextStyle(color: Colors.white),
                          icon: Icon(Icons.person_pin, color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white),
                          helperStyle: TextStyle(color: Colors.white),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 4),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        onChanged: (value) {
                          emailAddress = value;
                        },
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colors.white),
                          icon: Icon(Icons.email, color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white),
                          helperStyle: TextStyle(color: Colors.white),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (email) =>
                            email != null && !EmailValidator.validate(email)
                                ? 'Enter a valid email'
                                : null,
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: MyElevatedButton(
                          label: 'Add Contact',
                          width: double.infinity,
                          icon: Icon(Icons.person_add),
                          onPressed: addContacts,
                          borderRadius: BorderRadius.circular(10),
                          child: Text('Add Contact'),
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
        SnackBar(
          content: Text("Sending Data to Cloud Firestore"),
        ),
      );
      contacts
          .add({
            'firstName': firstName,
            'lastName': lastName,
            'emailAddress': emailAddress
          })
          .then((value) => print('Contact Added'))
          .catchError((error) => print('Failed to add contact: $error'));

      //Return to contacts page
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RoutePage(
                appBar: AppBarWidget(),
                page: ContactsSearchPage(),
                showDrawer: false,
              )));
    }
  }
}
