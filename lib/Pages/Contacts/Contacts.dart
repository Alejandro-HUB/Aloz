import 'package:cloud_firestore/cloud_firestore.dart';
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

class _ContactsSearchPageState extends State<ContactsSearchPage> {
  final Stream<QuerySnapshot> Contacts = FirebaseFirestore.instance
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
                    Text(
                      "Read Data from Cloud Firestore",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(),
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
                            List<DataRow> contactRows = [];
                            List<Contact> rowsData = [];

                            if (data != null) {
                              rowsData =
                                  Contact.populateContactsList(data, rowsData);
                            }

                            contactRows =
                                TableHelpers.buildContactListOfDataRows(context,
                                    rowsData, Colors.white, TextAlign.center);

                            return Center(
                              child: SingleChildScrollView(
                                child: Container(
                                  width: double.infinity,
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
                                      ],
                                      rows: contactRows),
                                ),
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

  @override
  Widget build(BuildContext context) {
    CollectionReference contacts = FirebaseFirestore.instance
        .collection("Contacts")
        .doc(FirebaseAuth.instance.currentUser!.uid.toString())
        .collection(
            "Contacts:" + FirebaseAuth.instance.currentUser!.uid.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Import Data",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Styling.purpleLight,
      ),
      body: Form(
          key: _formKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Text(
                    "Write Data to Cloud Firestore",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
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
                          hoverColor: Colors.white),
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
                  ),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
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
                              .add({
                                'firstName': firstName,
                                'lastName': lastName
                              })
                              .then((value) => print('Contact Added'))
                              .catchError((error) =>
                                  print('Failed to add contact: $error'));

                          //Return to contacts page
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => RoutePage(
                                    appBar: AppBarWidget(),
                                    page: ContactsSearchPage(),
                                    showDrawer: false,
                                  )));
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
              ),
            ),
          )),
    );
  }
}
