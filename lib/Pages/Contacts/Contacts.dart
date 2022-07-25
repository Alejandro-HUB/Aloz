import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Assets/app_bar_widget.dart';
import '../../Assets/buttons.dart';
import '../../Helpers/Constants/Styling.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../Helpers/Routing/route.dart';
import '../../Models/ContactsModel.dart';
import '../../firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../Helpers/Tables/TableHelpers.dart';

class ContactsSearchPage extends StatefulWidget {
  @override
  _ContactsSearchPageState createState() => _ContactsSearchPageState();
}

String? query;
CollectionReference contacts = FirebaseFirestore.instance
    .collection("Contacts")
    .doc(FirebaseAuth.instance.currentUser!.uid.toString())
    .collection(
        "Contacts:" + FirebaseAuth.instance.currentUser!.uid.toString());

class _ContactsSearchPageState extends State<ContactsSearchPage> {
  final searchController = TextEditingController();
  List<DataRow> contactRows = [];
  List<Contact> rowsData = [];

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  Stream<QuerySnapshot> Contacts = FirebaseFirestore.instance
      .collection("Contacts")
      .doc(FirebaseAuth.instance.currentUser!.uid.toString())
      .collection(
          "Contacts:" + FirebaseAuth.instance.currentUser!.uid.toString())
      .snapshots();

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
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(),
                        SizedBox(
                          width: 200,
                          child: TextFormField(
                            style: TextStyle(color: Colors.white),
                            controller: searchController,
                            onChanged: (value) {
                              setState(() {
                                query = value;

                                rowsData = rowsData
                                    .where((element) =>
                                        element.firstName
                                            .toLowerCase()
                                            .contains(value.toLowerCase()) ||
                                        element.lastName
                                            .toLowerCase()
                                            .contains(value.toLowerCase()) ||
                                        element.emailAddress
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                    .toList();

                                contactRows =
                                    TableHelpers.buildContactListOfDataRows(
                                        context,
                                        rowsData,
                                        Colors.white,
                                        TextAlign.center);
                              });
                            },
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search for Contacts',
                              icon: Icon(Icons.search, color: Colors.white),
                              hintStyle: TextStyle(color: Colors.white),
                              helperStyle: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        MyElevatedButton(
                          label: 'Import Data',
                          width: 150,
                          icon: Icon(Icons.import_export),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => RoutePage(
                                      appBar: AppBarWidget(),
                                      page: MyCustomForm(),
                                      showDrawer: false,
                                    )));
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Text('Import Data'),
                        ),
                      ],
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: Contacts,
                          builder: (
                            BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot,
                          ) {
                            if (snapshot.hasError) {
                              return Text(
                                "Something went wrong",
                                style: TextStyle(color: Colors.white),
                              );
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return (Text(
                                "Loading",
                                style: TextStyle(color: Colors.white),
                              ));
                            }

                            final data = snapshot.requireData;

                            //Fill the list of Contacts from Firebase
                            if (data != null &&
                                contactRows.length < data.size) {
                              if (query == null || query == "") {
                                rowsData.clear();
                                contactRows.clear();

                                rowsData = Contact.populateContactsList(
                                    data, rowsData);

                                contactRows =
                                    TableHelpers.buildContactListOfDataRows(
                                        context,
                                        rowsData,
                                        Colors.white,
                                        TextAlign.center);
                              }
                            }

                            return Center(
                              child: Column(
                                children: [
                                  Container(
                                    height: 344,
                                    width: double.infinity,
                                    child: SingleChildScrollView(
                                      child: DataTable(
                                          headingTextStyle: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Styling.purpleLight,
                                          ),
                                          border: TableBorder.all(
                                            width: 1.5,
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                          columns: [
                                            DataColumn(
                                              label: Text(
                                                'First Name',
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Last Name',
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Email Address',
                                              ),
                                            ),
                                          ],
                                          rows: contactRows),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )),
                  ],
                ),
              ),
            ],
          ),
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
