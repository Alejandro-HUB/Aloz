import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Assets/app_bar_widget.dart';
import '../../Assets/buttons.dart';
import '../../Helpers/Constants/Styling.dart';
import '../../Helpers/Constants/responsive_layout.dart';
import '../../Helpers/Routing/route.dart';
import '../../Models/ContactsModel.dart';
import '../../Helpers/Tables/TableHelpers.dart';
import 'ContactEntryForm.dart';

class ContactsSearchPage extends StatefulWidget {
  const ContactsSearchPage({Key? key}) : super(key: key);

  @override
  _ContactsSearchPageState createState() => _ContactsSearchPageState();
}

String? query;
CollectionReference contacts = FirebaseFirestore.instance
    .collection("Contacts")
    .doc(FirebaseAuth.instance.currentUser!.uid.toString())
    .collection("Contacts:${FirebaseAuth.instance.currentUser!.uid}");

class _ContactsSearchPageState extends State<ContactsSearchPage> {
  final searchController = TextEditingController();

  //List to hold the selected Contacts
  List<Contact> selectedContacts = [];

  //Initialize data table data
  List<DataColumn> contactColumns = [];
  List<String> columnsData = [
    "First Name",
    "Last Name",
    "Email Address",
  ];
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
      .collection("Contacts:${FirebaseAuth.instance.currentUser!.uid}")
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (MediaQuery.of(context).size.width >
                                ResponsiveLayout.phoneLimit &&
                            selectedContacts.isNotEmpty)
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 90),
                              child: Text(
                                "Selected Contacts: ${selectedContacts.length}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        if (selectedContacts.isEmpty)
                          Container(
                            padding: const EdgeInsets.only(left: 90),
                          ),
                        SizedBox(
                          width: 200,
                          child: TextFormField(
                            style: const TextStyle(color: Colors.white),
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
                                        rowsData,
                                        Colors.white,
                                        TextAlign.center);
                              });
                            },
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
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
                          icon: const Icon(Icons.import_export),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => RoutePage(
                                      appBar: AppBarWidget(),
                                      page: ContactEntryForm(),
                                      showDrawer: false,
                                    )));
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: const Text('Import Data'),
                        ),
                      ],
                    ),
                    if (ResponsiveLayout.isPhone(context) &&
                        selectedContacts.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.only(right: 220),
                        child: Text(
                          "Selected Contacts: ${selectedContacts.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
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
                              return const Text(
                                "Something went wrong",
                                style: TextStyle(color: Colors.white),
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
                            contactColumns =
                                TableHelpers.buildListOfDataColumns(columnsData,
                                    Colors.white, TextAlign.center);

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
                                        rowsData,
                                        Colors.white,
                                        TextAlign.center);
                              }
                            }
                            return SizedBox(
                              height: 344,
                              width: double.infinity,
                              child: SingleChildScrollView(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 344,
                                      padding: const EdgeInsets.only(
                                        top: 30,
                                      ),
                                      child: ScrollConfiguration(
                                        behavior:
                                            ScrollConfiguration.of(context)
                                                .copyWith(scrollbars: false),
                                        child: ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: rowsData.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Container(
                                                padding: const EdgeInsets.all(
                                                  4.0,
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    CheckboxListTile(
                                                        checkColor:
                                                            Colors.white,
                                                        activeColor:
                                                            Styling.orangeDark,
                                                        dense: true,
                                                        value: rowsData[index]
                                                            .selected,
                                                        onChanged: (bool? val) {
                                                          itemChange(
                                                              val, index);
                                                        })
                                                  ],
                                                ),
                                              );
                                            }),
                                      ),
                                    ),
                                    Flexible(
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: InfoTable(
                                          rowsData: contactRows,
                                          columnData: contactColumns,
                                        ),
                                      ),
                                    ),
                                  ],
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

  void itemChange(bool? val, int index) {
    setState(() {
      rowsData[index].selected = val;
      selectedContacts =
          rowsData.where((element) => element.selected = true).toList();
    });
  }
}
