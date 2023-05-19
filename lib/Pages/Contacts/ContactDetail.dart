// ignore_for_file: library_private_types_in_public_api, avoid_print, unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/Assets/buttons.dart';
import 'package:projectcrm/Helpers/Constants/Styling.dart';
import '../../Assets/app_bar_widget.dart';
import '../../Helpers/Routing/route.dart';
import '../../Models/ContactsModel.dart';
import 'Contacts.dart';

class ContactDetail extends StatefulWidget {
  final Contact selectedContact;

  const ContactDetail({Key? key, required this.selectedContact})
      : super(key: key);

  @override
  _ContactDetailPageState createState() => _ContactDetailPageState();
}

CollectionReference contacts = FirebaseFirestore.instance
    .collection("Contacts")
    .doc(FirebaseAuth.instance.currentUser!.uid.toString())
    .collection("Contacts:${FirebaseAuth.instance.currentUser!.uid}");

class _ContactDetailPageState extends State<ContactDetail> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the initial values in the controllers
    firstNameController.text = widget.selectedContact.firstName;
    lastNameController.text = widget.selectedContact.lastName;
    emailController.text = widget.selectedContact.emailAddress;
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Styling.purpleLight,
        title: Text(
          "${widget.selectedContact.firstName} ${widget.selectedContact.lastName} - Details",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Form(
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
                    padding: const EdgeInsets.only(left: 110.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            //The name of the contact
                            Text(
                              "${widget.selectedContact.firstName} ${widget.selectedContact.lastName}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            //The email of the contact
                            Text(
                              widget.selectedContact.emailAddress,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              //Form to update contact data
              TextFormField(
                style: const TextStyle(color: Colors.white),
                controller: firstNameController,
                textInputAction: TextInputAction.next,
                // ignore: prefer_const_constructors
                decoration: InputDecoration(
                  labelText: "First Name",
                  // ignore: prefer_const_constructors
                  labelStyle: TextStyle(color: Colors.white),
                  icon: const Icon(Icons.person_pin, color: Colors.white),
                  hintStyle: const TextStyle(color: Colors.white),
                  helperStyle: const TextStyle(color: Colors.white),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                controller: lastNameController,
                textInputAction: TextInputAction.next,
                // ignore: prefer_const_constructors
                decoration: InputDecoration(
                  labelText: "Last Name",
                  labelStyle: const TextStyle(color: Colors.white),
                  icon: const Icon(Icons.person_pin, color: Colors.white),
                  hintStyle: const TextStyle(color: Colors.white),
                  // ignore: prefer_const_constructors
                  helperStyle: TextStyle(color: Colors.white),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                controller: emailController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
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
              const SizedBox(height: 20.0),
              Align(
                alignment: Alignment.centerLeft,
                child: MyElevatedButton(
                  onPressed: () {},
                  label: "Upload Image",
                  icon: const Icon(Icons.image),
                  borderRadius: BorderRadius.circular(10),
                  child: const Text("Upload Image"),
                ),
              ),
              const SizedBox(height: 20.0),
              Align(
                alignment: Alignment.centerRight,
                child: MyElevatedButton(
                  onPressed: () {
                    setState(() {
                      saveContactToFireStore(contacts, firstNameController.text,
                          lastNameController.text, emailController.text);
                    });
                  },
                  label: "Save",
                  icon: const Icon(Icons.arrow_forward),
                  borderRadius: BorderRadius.circular(10),
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> getContactDocumentId(CollectionReference collectionReference,
      String firstName, String lastName, String email) async {
    final QuerySnapshot<Object?> snapshot = await collectionReference
        .where('firstName', isEqualTo: firstName)
        .where('lastName', isEqualTo: lastName)
        .where('emailAddress', isEqualTo: email)
        .limit(1)
        .get();

    final List<QueryDocumentSnapshot<Object?>> documents = snapshot.docs;

    if (documents.isNotEmpty) {
      final QueryDocumentSnapshot<Object?> document = documents.first;
      return document.id;
    }

    return null; // Contact not found
  }

  Future saveContactToFireStore(CollectionReference collectionReference,
      String firstName, String lastName, String email) async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sending Data to Cloud Firestore"),
        ),
      );

      //Get document id from firestore
      var documentId = await getContactDocumentId(
          collectionReference,
          widget.selectedContact.firstName,
          widget.selectedContact.lastName,
          widget.selectedContact.emailAddress);

      if (documentId != null) {
        await collectionReference
            .doc(documentId.toString())
            .update({
              'firstName': firstName,
              'lastName': lastName,
              'emailAddress': email,
            })
            .then((value) => //Return to contacts page
                // ignore: use_build_context_synchronously
                Navigator.of(context).push(MaterialPageRoute(
                    // ignore: prefer_const_constructors
                    builder: (context) => RoutePage(
                          appBar: const AppBarWidget(),
                          page: const ContactsSearchPage(),
                          showDrawer: false,
                        ))))
            .catchError((error) => print('Failed to update user: $error'));
      }
    }
  }
}