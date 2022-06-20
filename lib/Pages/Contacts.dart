import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Helpers/Constants/Styling.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ContactsSearchPage extends StatefulWidget {
  @override
  _ContactsSearchPageState createState() => _ContactsSearchPageState();
}

class _ContactsSearchPageState extends State<ContactsSearchPage> {
  final Stream<QuerySnapshot> Contacts =
      FirebaseFirestore.instance.collection("Contacts:" + FirebaseAuth.instance.currentUser!.uid).snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Contacts",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Styling.purpleLight,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Read Data from Cloud Firestore",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  Container(
                      height: 250,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: Contacts,
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot,
                        ) {
                          if (snapshot.hasError) {
                            return Text("Something went wrong", style: TextStyle(color: Colors.white),);
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return (Text("Loading", style: TextStyle(color: Colors.white),));
                          }

                          final data = snapshot.requireData;

                          return ListView.builder(
                            itemCount: data.size,
                            itemBuilder: (context, index) {
                              return Text(
                                "My name is ${data.docs[index]['firstName']} ${data.docs[index]['lastName']}",
                                style: TextStyle(color: Colors.white),
                              );
                            },
                          );
                        },
                      )),
                  Text(
                    "Write Data to Cloud Firestore",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  MyCustomForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();

  var firstName = '';
  var lastName = '';

  @override
  Widget build(BuildContext context) {
    CollectionReference contacts =
        FirebaseFirestore.instance.collection("Contacts:" + FirebaseAuth.instance.currentUser!.uid);

    return Form(
        key: _formKey,
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextFormField(
          style: TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            hintText: 'What\'s Your First Name?',
            hintStyle: TextStyle(
              color: Colors.white,
            ),
            labelText: 'First Name',
            labelStyle: TextStyle(
              color: Colors.white,
            ),
            hoverColor: Colors.white
          ),
          onChanged: (value) {
            firstName = value;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        ),
        TextFormField(
          style: TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            hintText: 'What\'s Your Last Name?',
            hintStyle: TextStyle(
              color: Colors.white,
            ),
            labelText: 'Last Name',
            labelStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          onChanged: (value) {
            lastName = value;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        ),
        SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Sending Data to Cloud Firestore"),
                  ),
                );
                contacts
                    .add({'firstName': firstName, 'lastName': lastName})
                    .then((value) => print('Contact Added'))
                    .catchError((error) => print('Failed to add contact: $error'));
              }
            },
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Ink(
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Styling.redDark, Styling.orangeDark]),
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                width: 100,
                height: 40,
                alignment: Alignment.center,
                child: const Text(
                  'Submit',
                  style: const TextStyle(
                      fontSize: 16, fontStyle: FontStyle.normal),
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
