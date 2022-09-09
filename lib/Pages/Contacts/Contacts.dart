import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Assets/app_bar_widget.dart';
import '../../Assets/buttons.dart';
import '../../Helpers/Constants/Styling.dart';
import '../../Helpers/Routing/route.dart';
import '../../Models/ContactsModel.dart';
import 'ContactEntryForm.dart';
import '../../Helpers/Tables/TableHelpers.dart';

class ContactsSearchPage extends StatefulWidget {
  const ContactsSearchPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ContactsSearchPageState createState() => _ContactsSearchPageState();
}

//Firebase connection to collection in firestore
String? query;
CollectionReference contacts = FirebaseFirestore.instance
    .collection("Contacts")
    .doc(FirebaseAuth.instance.currentUser!.uid.toString())
    .collection("Contacts:${FirebaseAuth.instance.currentUser!.uid}");

class _ContactsSearchPageState extends State<ContactsSearchPage> {
  final searchController = TextEditingController();

  //List to hold selected contacts
  List<Contact> selectedContacts = [];
  bool allContactsSelected = false;
  
  //Initialize data table data
  List<DataRow> contactRows = [];
  List<Contact> rowsData = [];
  List<DataColumn> contactColumns = [];
  List<String> columnsData = [
    "",
    "First Name",
    "Last Name",
    "Email Address",
  ];

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  // ignore: non_constant_identifier_names
  Stream<QuerySnapshot> Contacts = FirebaseFirestore.instance
      .collection("Contacts")
      .doc(FirebaseAuth.instance.currentUser!.uid.toString())
      .collection("Contacts:${FirebaseAuth.instance.currentUser!.uid}")
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ignore: prefer_const_constructors
        title: Text(
          "Contacts",
          style: const TextStyle(color: Colors.white),
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
                    const SizedBox(height: 10),
                    if (selectedContacts.isNotEmpty)
                      Text(
                        // ignore: prefer_interpolation_to_compose_strings
                        "Selected Contacts: " +
                            selectedContacts.length.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(),

                        //Text box for querying contacts
                        FittedBox(
                          child: SizedBox(
                            width: 200,
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              controller: searchController,
                              onChanged: (value) {
                                setState(() {
                                  //Update Contacts based on query specified by the user
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

                                  contactRows = buildContactListOfDataRows(
                                      context,
                                      rowsData,
                                      Colors.white,
                                      TextAlign.center);
                                });
                              },
                              textInputAction: TextInputAction.search,
                              // ignore: prefer_const_constructors
                              decoration: InputDecoration(
                                hintText: 'Search for Contacts',
                                icon: const Icon(Icons.search,
                                    color: Colors.white),
                                hintStyle: const TextStyle(color: Colors.white),
                                helperStyle:
                                    const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),

                        //Button for importing data
                        FittedBox(
                          child: MyElevatedButton(
                            label: "Import Data",
                            width: 150,
                            icon: const Icon(Icons.import_export),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  // ignore: prefer_const_constructors
                                  builder: (context) => RoutePage(
                                        appBar: AppBarWidget(),
                                        page: const ContactEntryForm(),
                                        showDrawer: false,
                                      )));
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: const Text('Import Data'),
                          ),
                        ),
                      ],
                    ),

                    //Contains the Data Table and data
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: Contacts,
                          builder: (
                            BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot,
                          ) {
                            if (snapshot.hasError) {
                              // ignore: prefer_const_constructors
                              return Text(
                                "Something went wrong",
                                style: const TextStyle(color: Colors.white),
                              );
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return (const Text(
                                "Loading",
                                style: TextStyle(color: Colors.white),
                              ));
                            }

                            final data = snapshot.requireData;

                            //Fill the list of Columns
                            contactColumns = buildListOfDataColumns(
                                columnsData, Colors.white, TextAlign.center);

                            //Fill the list of Contacts from Firebase
                            if (data != null &&
                                contactRows.length < data.size) {
                              if (query == null || query == "") {
                                rowsData.clear();
                                contactRows.clear();

                                rowsData = Contact.populateContactsList(
                                    data, rowsData);

                                contactRows = buildContactListOfDataRows(
                                    context,
                                    rowsData,
                                    Colors.white,
                                    TextAlign.center);
                              }
                            }

                            //Data Table to show Contact Data
                            return Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: DataTable(
                                        // ignore: prefer_const_constructors
                                        headingTextStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        // ignore: prefer_const_constructors
                                        decoration: BoxDecoration(
                                          color: Styling.purpleLight,
                                        ),
                                        border: TableBorder.all(
                                          width: 1.5,
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        columns: contactColumns,
                                        rows: contactRows),
                                  ),
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

  List<DataRow> buildContactListOfDataRows(BuildContext context,
      List<Contact> rowsData, Color textColor, TextAlign textAlign) {
    List<DataRow> dataRows = [];

    for (int i = 0; i < rowsData.length; i++) {
      String firstName = rowsData[i].firstName;
      String lastName = rowsData[i].lastName;
      String emailAddress = rowsData[i].emailAddress;

      DataRow row = DataRow(
        cells: [
          DataCell(Theme(
              data: ThemeData(unselectedWidgetColor: Colors.white),
              child: Checkbox(
                value: rowsData[i].selected,
                onChanged: (value) {
                  setState(() {
                    Test = value.toString() + rowsData[i].firstName;
                    rowsData[i].selected = value == null
                        ? false
                        : value == false
                            ? false
                            : true;
                  });

                  if (value == true) {
                    selectedContacts.add(rowsData[i]);
                  } else {
                    selectedContacts.remove(rowsData[i]);
                  }
                },
                activeColor: Colors.orange,
                tristate: true,
              ))),
          DataCell(Text(
            firstName,
            style: TextStyle(color: textColor),
            textAlign: textAlign,
          )),
          DataCell(Text(
            lastName,
            style: TextStyle(color: textColor),
            textAlign: textAlign,
          )),
          DataCell(Text(
            emailAddress,
            style: TextStyle(color: textColor),
            textAlign: textAlign,
          )),
        ],
      );

      dataRows.add(row);
    }

    return dataRows;
  }

  List<DataColumn> buildListOfDataColumns(
      List<String> columnData, Color textColor, TextAlign textAlign) {
    List<DataColumn> dataColumns = [];

    for (int i = 0; i < columnData.length; i++) {
      String columnName = columnData[i];
      DataColumn column = const DataColumn(label: Text(""));

      if (columnName == "") {
        column = DataColumn(
            label: Theme(
                data: ThemeData(unselectedWidgetColor: Colors.white),
                child: Checkbox(
                  value: allContactsSelected,
                  onChanged: (value) {
                    setState(() {
                      allContactsSelected = value == null
                          ? false
                          : value == false
                              ? false
                              : true;

                      if (selectedContacts.isNotEmpty) {
                        selectedContacts.clear();
                      }

                      if (allContactsSelected) {
                        for (var element in rowsData) {
                          element.selected = true;
                          selectedContacts.add(element);
                        }
                      } else {
                        for (var element in rowsData) {
                          element.selected = false;
                        }
                        selectedContacts.clear();
                      }
                    });
                  },
                  activeColor: Colors.orange,
                  tristate: true,
                )));
      } else {
        column = DataColumn(
          label: Text(
            columnName,
            style: TextStyle(color: textColor),
            textAlign: textAlign,
          ),
        );
      }

      dataColumns.add(column);
    }

    return dataColumns;
  }
}
