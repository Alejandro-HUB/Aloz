// ignore_for_file: avoid_print, invalid_return_type_for_catch_error, duplicate_ignore, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/Assets/SelectedContent.dart';
import 'package:projectcrm/Pages/Home/drawer_page.dart';
import 'package:projectcrm/Helpers/ExportData/ExcelHelper.dart';
import 'package:projectcrm/Pages/Widgets/Data/DataDetail.dart';
import '../../Home/app_bar_widget.dart';
import '../../../Assets/buttons.dart';
import '../../../Helpers/Constants/Styling.dart';
import '../../../Helpers/Constants/responsive_layout.dart';
import '../../../Helpers/Routing/route.dart';
import '../../../Models/ContactsModel.dart';
import 'DataEntryForm.dart';

class DataWidget extends StatefulWidget {
  const DataWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DataWidgetState createState() => _DataWidgetState();
}

//Firebase connection to collection in firestore
String? query;
CollectionReference contacts = FirebaseFirestore.instance
    .collection("UserWidgetData")
    .doc(FirebaseAuth.instance.currentUser!.uid.toString())
    .collection(currentWidget!.documentIdData);

//Tabs
enum DataWidgetTab {
  dataTable,
  rawData,
}

Contact _selectedContact = Contact();
DataWidgetTab _currentTab = DataWidgetTab.dataTable;

class _DataWidgetState extends State<DataWidget> {
  final _searchController = TextEditingController();
  final _rawDataController = TextEditingController();

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
    _searchController.dispose();
    _rawDataController.dispose();
    super.dispose();
  }

  // ignore: non_constant_identifier_names
  Stream<QuerySnapshot> Contacts = FirebaseFirestore.instance
      .collection("UserWidgetData")
      .doc(FirebaseAuth.instance.currentUser!.uid.toString())
      .collection(currentWidget!.documentIdData)
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
              currentWidget!.title,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Styling.purpleLight,
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  //Tabs
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: MyElevatedButton(
                            gradient: _currentTab == DataWidgetTab.dataTable
                                ? const LinearGradient(colors: [
                                    Styling.redDark,
                                    Styling.orangeDark
                                  ])
                                : const LinearGradient(colors: [
                                    Styling.purpleLight,
                                    Styling.purpleLight
                                  ]),
                            label: "Data Table",
                            width: 150,
                            icon: const Icon(Icons.table_chart),
                            onPressed: () {
                              setState(() {
                                _currentTab = DataWidgetTab.dataTable;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: const Text('Data Table'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MyElevatedButton(
                            gradient: _currentTab == DataWidgetTab.rawData
                                ? const LinearGradient(colors: [
                                    Styling.redDark,
                                    Styling.orangeDark
                                  ])
                                : const LinearGradient(colors: [
                                    Styling.purpleLight,
                                    Styling.purpleLight
                                  ]),
                            label: "Raw Data",
                            width: 150,
                            icon: const Icon(Icons.data_object),
                            onPressed: () {
                              setState(() {
                                _currentTab = DataWidgetTab.rawData;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: const Text('Raw Data'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  if (_currentTab == DataWidgetTab.dataTable)
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
                              controller: _searchController,
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
                                            appBar: const AppBarWidget(),
                                            page: const DataEntryForm(),
                                            showDrawer: true,
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

                  // Tab Content
                  //Contains the Data Table and data
                  if (_currentTab == DataWidgetTab.dataTable)
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

                                //Populate raw data controller to show json object
                                _rawDataController.text =
                                    const JsonEncoder.withIndent('  ')
                                        .convert(rowsData);

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
                  if (_currentTab == DataWidgetTab.rawData)
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _rawDataController,
                            maxLines: null,
                            onChanged: (value) {
                              final previousSelection =
                                  _rawDataController.selection;
                              _rawDataController.text = value;
                              _rawDataController.selection = previousSelection;
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Raw JSON Data',
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          MyElevatedButton(
                            label: "Save",
                            width: 150,
                            icon: const Icon(Icons.save),
                            onPressed: saveRawData,
                            borderRadius: BorderRadius.circular(10),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ),
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
                      getRowByText(contactRows, _selectedContact.firstName);
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
                  "Contact selected: ${_selectedContact.firstName} ${_selectedContact.lastName}")
      ]),
    );
  }

  Future<void> saveRawData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid.toString();
      CollectionReference collectionRef = FirebaseFirestore.instance
          .collection("UserWidgetData")
          .doc(uid)
          .collection(currentWidget!.documentIdData);

      final contactMethod = Contact();
      List<Contact> contactsList =
          contactMethod.convertJsonToContactList(_rawDataController.text);

      for (var element in contactsList) {
        if (element.id.isEmpty) {
          // Add a new contact if the ID is empty
          var contactToAdd = element;
          var doc = contacts.doc();
          contactToAdd.id = doc.id;
          await doc
              .set(contactToAdd.toJson())
              // ignore: avoid_print
              .then((value) => print('Contact Added'))
              // ignore: avoid_print
              .catchError((error) => print('Failed to add contact: $error'));
        } else {
          // Update an existing contact
          await collectionRef.doc(element.id).set({
            "emailAddress": element.emailAddress,
            "firstName": element.firstName,
            "lastName": element.lastName,
            "id": element.id,
          });
        }
      }

      print("Data saved successfully!");
    } catch (error) {
      print("Error saving data: $error");
    }
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
                    _selectedContact = rowsData[i];
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
              page: DataDetail(selectedContact: _selectedContact),
              showDrawer: true,
            )));
  }

  Future deleteContact() async {
    await contacts
        .doc(_selectedContact.id)
        .delete()
        .then((value) => {
              setState(
                () {
                  // ignore: avoid_print
                  print(
                      "Contact Deleted: ${_selectedContact.firstName} ${_selectedContact.lastName}");
                  rowsData.remove(_selectedContact);
                  contactRows = buildContactListOfDataRows(
                      context, rowsData, Colors.white, TextAlign.center);
                },
              )
            })
        .catchError((error) => print('Failed to add contact: $error'));
  }
}
