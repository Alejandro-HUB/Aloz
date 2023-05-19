// ignore_for_file: avoid_print, invalid_return_type_for_catch_error, duplicate_ignore

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/Assets/SelectedContent.dart';
import 'package:projectcrm/Helpers/ExportData/ExcelHelper.dart';
import 'package:projectcrm/Pages/Contacts/ContactDetail.dart';
import '../../Assets/app_bar_widget.dart';
import '../../Assets/buttons.dart';
import '../../Helpers/Constants/Styling.dart';
import '../../Helpers/Constants/responsive_layout.dart';
import '../../Helpers/Routing/route.dart';
import '../../Models/ContactsModel.dart';
import 'ContactEntryForm.dart';

class ContactsSearchPage extends StatefulWidget {
  const ContactsSearchPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ContactsSearchPageState createState() => _ContactsSearchPageState();
}

Contact selectedContact = Contact();

//Firebase connection to collection in firestore
String? query;
CollectionReference contacts = FirebaseFirestore.instance
    .collection("Contacts")
    .doc(FirebaseAuth.instance.currentUser!.uid.toString())
    .collection("Contacts:${FirebaseAuth.instance.currentUser!.uid}");

class _ContactsSearchPageState extends State<ContactsSearchPage> {
  final searchController = TextEditingController();

  //Shows Contact Menu Bar
  bool isContactSelected = false;

  //Initialize data table data
  List<DataRow> contactRows = [];
  List<Contact> rowsData = [];
  List<DataColumn> contactColumns = [];
  List<String> columnsData = [
    "Select",
    "First Name",
    "Last Name",
    "Email Address",
  ];

  //Export file
  ExcelHelper excelHelper = ExcelHelper();

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
    return GestureDetector(
      onTap: () {
        setState(() {
          isContactSelected = false;
        });
      },
      child: Stack(children: [
        Scaffold(
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
                  const SizedBox(height: 10),
                  //Page Controls
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //Button for exporting data
                        if (!ResponsiveLayout.isPhone(context))
                          MyElevatedButton(
                            label: "Export Data",
                            width: 150,
                            icon: const Icon(Icons.download),
                            onPressed: () {
                              excelHelper.exportToExcel(contactRows,
                                  contactColumns, 'Contacts', true);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: const Text('Export Data'),
                          ),
                        //Text box for querying contacts
                        SizedBox(
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
                              icon:
                                  const Icon(Icons.search, color: Colors.white),
                              hintStyle: const TextStyle(color: Colors.white),
                              helperStyle: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                        //Buttons for importing and exporting data
                        Column(
                          children: [
                            if (ResponsiveLayout.isPhone(context))
                              MyElevatedButton(
                                label: "Export Data",
                                width: 150,
                                icon: const Icon(Icons.download),
                                onPressed: () {
                                  excelHelper.exportToExcel(contactRows,
                                      contactColumns, 'Contacts', true);
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: const Text('Export Data'),
                              ),
                            const SizedBox(height: 10),
                            MyElevatedButton(
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
                          ],
                        )
                      ],
                    ),
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
                          if (data != null && contactRows.length < data.size) {
                            if (query == null || query == "") {
                              rowsData.clear();
                              contactRows.clear();

                              rowsData =
                                  Contact.populateContactsList(data, rowsData);

                              contactRows = buildContactListOfDataRows(context,
                                  rowsData, Colors.white, TextAlign.center);
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
          ),
        ),
        //Shows Contact Menu Bar
        if (isContactSelected)
          SelectedContent(
              onPressedOpen: (() {
                setState(() {
                  openContact();
                  isContactSelected = false;
                });
              }),
              onPressedExport: (() {
                setState(() {
                  List<DataRow> dataRows = [];
                  DataRow? row =
                      getRowByText(contactRows, selectedContact.firstName);
                  if (row != null) {
                    dataRows.add(row);
                    excelHelper.exportToExcel(
                        dataRows, contactColumns, "Contacts", true);
                  }
                  isContactSelected = false;
                });
              }),
              onPressedDelete: (() {
                setState(() {
                  deleteContact();
                  isContactSelected = false;
                });
              }),
              label:
                  "Contact selected: ${selectedContact.firstName} ${selectedContact.lastName}")
      ]),
    );
  }

  DataRow? getRowByText(List<DataRow> rows, String searchText) {
    try {
      return rows.firstWhere((element) {
        return element.cells.any((cell) {
          if (cell.child is Text && (cell.child as Text).data == searchText) {
            return true;
          }
          return false;
        });
      });
    } catch (e) {
      return null;
    }
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
          DataCell(
            IconButton(
                onPressed: () {
                  setState(() {
                    selectedContact = rowsData[i];
                    isContactSelected = true;
                  });
                },
                icon: const Icon(
                  Icons.pending,
                  color: Colors.white,
                )),
          ),
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

      column = DataColumn(
        label: Text(
          columnName,
          style: TextStyle(color: textColor),
          textAlign: textAlign,
        ),
      );

      dataColumns.add(column);
    }

    return dataColumns;
  }

  Future openContact() async {
    // ignore: use_build_context_synchronously
    Navigator.of(context).push(MaterialPageRoute(
        // ignore: prefer_const_constructors
        builder: (context) => RoutePage(
              appBar: const AppBarWidget(),
              page: ContactDetail(selectedContact: selectedContact),
              showDrawer: false,
            )));
  }

  Future deleteContact() async {
    await contacts
        .doc(selectedContact.id)
        .delete()
        .then((value) => {
              setState(
                () {
                  // ignore: avoid_print
                  print(
                      "Contact Deleted: ${selectedContact.firstName} ${selectedContact.lastName}");
                  rowsData.remove(selectedContact);
                  contactRows = buildContactListOfDataRows(
                      context, rowsData, Colors.white, TextAlign.center);
                },
              )
            })
        .catchError((error) => print('Failed to add contact: $error'));
  }
}
