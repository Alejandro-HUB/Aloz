// ignore_for_file: library_private_types_in_public_api, prefer_const_literals_to_create_immutables, non_constant_identifier_names, file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:projectcrm/Assets/SideBarEntry.dart';
import 'package:projectcrm/Helpers/Constants/IconHelper.dart';
import 'package:projectcrm/Helpers/Constants/RoutingConstants.dart';
import 'package:projectcrm/Helpers/Firebase/widget_service.dart';
import 'package:projectcrm/Helpers/Routing/route.dart';
import 'package:projectcrm/Pages/Home/TopAppBar.dart';
import 'package:projectcrm/Pages/Widgets/ViewAllWidgets.dart';
import '../../Helpers/Constants/Styling.dart';
import '../../Helpers/Routing/AppRouter.dart';

// This Dart code defines a Flutter application's HomePage, which is a part of a widget management system.
// The HomePage presents a drawer with an admin menu for adding, editing, and deleting widgets.
// Users can create custom widgets with titles, icons, and associated pages.
// Widgets are stored in Firebase Firestore, and the application provides a user-friendly interface for managing them.
// Icons are chosen using a typeahead input, and there's a preview of selected icons.
// When a widget is selected, users can navigate to its associated page.
// Additionally, there are functions for adding, editing, and deleting widgets, with Firestore integration.

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class WidgetsInfo {
  String id;
  String title;
  IconData icon;
  String widgetType;
  int currentPage;
  String documentIdData;
  WidgetsInfo(
      {required this.id,
      required this.title,
      required this.icon,
      required this.widgetType,
      required this.currentPage,
      required this.documentIdData});
}

// Home page widget
WidgetsInfo _defaultWidget = WidgetsInfo(
    id: "0",
    title: "Home",
    icon: Icons.home,
    widgetType: "Home",
    currentPage: 0,
    documentIdData: "0");
WidgetsInfo? currentWidget = _defaultWidget;

class _HomePageState extends State<HomePage> {
  late List<WidgetsInfo> _widgetNames = [];
  final WidgetService _widgetService = WidgetService();

  //Settings to create a new widget
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _iconController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();

  //Widget Tittle Controller
  @override
  void dispose() {
    _titleController.dispose();
    _iconController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Fetch widgets from Firebase
    fetchWidgetNames();
  }

  Future<void> fetchWidgetNames() async {
    var widgetsResponse = await _widgetService.fetchWidgets(10, 1, null);

    setState(() {
      _widgetNames = widgetsResponse.widgetsInfoList!;
    });
  }

  CollectionReference widgetsCollection = FirebaseFirestore.instance
      .collection("UserWidgets")
      .doc(FirebaseAuth.instance.currentUser!.uid.toString())
      .collection("UserWidgets:${FirebaseAuth.instance.currentUser!.uid}");

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Styling.foreground,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Styling.kPadding),
            child: Column(
              children: [
                ListTile(
                  title: Row(
                    children: [
                      Text(
                        "Admin Menu",
                        style: TextStyle(
                          color: Styling.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SideBarEntry(
                    title: "View all Widgets",
                    icon: Icons.arrow_forward,
                    action: () {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).push(MaterialPageRoute(
                          // ignore: prefer_const_constructors
                          builder: (context) => RoutePage(
                                appBar: const TopAppBar(),
                                page: const ViewAllWidgets(),
                                showDrawer: true,
                              )));
                    }),
                // List of Widgets
                ...List.generate(
                  _widgetNames.length,
                  (index) {
                    final WidgetsInfo widgetInfo = _widgetNames[index];
                    return Column(
                      children: [
                        Container(
                          decoration: index == currentWidget?.currentPage
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      Styling.gradient1.withOpacity(0.9),
                                      Styling.gradient2.withOpacity(0.9),
                                    ],
                                  ),
                                )
                              : null,
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                currentWidget = WidgetsInfo(
                                    id: widgetInfo.id,
                                    title: widgetInfo.title,
                                    icon: widgetInfo.icon,
                                    widgetType: widgetInfo.widgetType,
                                    currentPage: index,
                                    documentIdData: widgetInfo.documentIdData);
                              });
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    AppRouter(currentWidget: currentWidget!),
                              ));
                            },
                            title: Text(
                              widgetInfo.title,
                              style: TextStyle(
                                color: Styling.primaryColor,
                              ),
                            ),
                            leading: Padding(
                              padding: const EdgeInsets.all(Styling.kPadding),
                              child: Icon(
                                widgetInfo.icon,
                                color: Styling.primaryColor,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            trailing: widgetInfo.title !=
                                    _defaultWidget
                                        .title // Only show trash icon for non-home entries
                                ? IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Styling.primaryColor,
                                    ),
                                    onPressed: () {
                                      showAddWidgetDialog(
                                          true, widgetInfo, widgetsCollection);
                                    },
                                  )
                                : null, // No trash icon for home entry
                          ),
                        ),
                        Divider(
                          color: Styling.homeBorder,
                          thickness: 0.1,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showAddWidgetDialog(bool edit, WidgetsInfo widgetInfo,
      CollectionReference collectionReference) {
    String title = edit ? "Edit/Delete ${widgetInfo.title}" : "Add Widgets";
    String buttonName = edit ? "Save" : "Submit";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color: Styling.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Title:",
                style: TextStyle(color: Styling.primaryColor),
              ),
              TextField(
                controller: _titleController,
                style: TextStyle(
                  color: Styling.primaryColor,
                ),
                decoration: InputDecoration(
                  hintText: "Enter the widget title",
                  hintStyle: TextStyle(color: Styling.primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Icon:",
                style: TextStyle(color: Styling.primaryColor),
              ),
              TypeAheadFormField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _iconController,
                  decoration: InputDecoration(
                    labelText: 'Select Icon',
                    labelStyle: TextStyle(color: Styling.primaryColor),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Styling.primaryColor),
                ),
                suggestionsCallback: (pattern) async {
                  return IconHelper.iconNames
                      .where((iconName) => iconName
                          .toLowerCase()
                          .contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, String suggestion) {
                  return ListTile(
                    leading: IconsExtension.getIconPreview(suggestion),
                    title: Text(
                      suggestion,
                      style: TextStyle(color: Styling.primaryColor),
                    ),
                  );
                },
                onSuggestionSelected: (String value) {
                  setState(() {
                    _iconController.text = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an icon';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              //Do not show select page if edit
              if (!edit)
                Text(
                  "Page:",
                  style: TextStyle(color: Styling.primaryColor),
                ),
              if (!edit)
                TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _pageController,
                    decoration: InputDecoration(
                      labelText: 'Select Page',
                      labelStyle: TextStyle(color: Styling.primaryColor),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      hintText: '',
                      hintStyle: TextStyle(color: Styling.primaryColor),
                    ),
                    style: TextStyle(color: Styling.primaryColor),
                  ),
                  suggestionsCallback: (pattern) async {
                    return RoutingConstants.PAGENAMES
                        .where((pageName) => pageName
                            .toLowerCase()
                            .contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, String suggestion) {
                    return ListTile(
                      title: Text(
                        suggestion,
                        style: TextStyle(color: Styling.primaryColor),
                      ),
                    );
                  },
                  onSuggestionSelected: (String value) {
                    setState(() {
                      _pageController.text = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a page';
                    }
                    return null;
                  },
                ),
            ],
          ),
        ),
        actions: [
          if (edit)
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Styling.primaryColor,
              ),
              onPressed: () {
                ShowDeleteDialog(widgetInfo);
              },
            ),
          TextButton(
            onPressed: () {
              if (edit) {
                _widgetService.saveWidgetToFireStore(
                    collectionReference,
                    widgetInfo,
                    context,
                    _titleController.text,
                    _iconController.text);
              } else {
                _widgetService.addWidgets(
                    widgetsCollection,
                    context,
                    _titleController.text,
                    _iconController.text,
                    _pageController.text);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Styling.gradient1.withOpacity(0.9),
                    Styling.gradient2.withOpacity(0.9),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              child: Text(
                buttonName,
                style: TextStyle(
                  color: Styling.primaryColor,
                ),
              ),
            ),
          ),
        ],
        backgroundColor: Styling.foreground,
      ),
    );
  }

  void ShowDeleteDialog(WidgetsInfo widgetInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Confirm Delete",
          style: TextStyle(
            color: Styling.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you wish to delete this widget?",
          style: TextStyle(color: Styling.primaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () {
              deleteWidget(widgetInfo);
              Navigator.of(context).pop();
            },
            child: Text(
              "Confirm",
              style: TextStyle(
                color: Styling.primaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Styling.primaryColor,
              ),
            ),
          ),
        ],
        backgroundColor: Styling.foreground, // Modify the background color here
      ),
    );
  }

  Future deleteWidget(WidgetsInfo widgetToDelete) async {
    //Load collection for the widget's data
    CollectionReference widgetData = FirebaseFirestore.instance
        .collection("UserWidgetData")
        .doc(FirebaseAuth.instance.currentUser!.uid.toString())
        .collection(widgetToDelete.documentIdData);

    await widgetsCollection
        .doc(widgetToDelete.id)
        .delete()
        .then((value) => {
              setState(
                () {
                  // ignore: avoid_print
                  print("Widget Deleted: ${widgetToDelete.title}");
                },
              )
            })
        // ignore: avoid_print, invalid_return_type_for_catch_error
        .catchError((error) => print('Failed to delete widget: $error'));

    try {
      // Delete documents in the UserWidgetData collection
      QuerySnapshot querySnapshot = await widgetData.get();
      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        await docSnapshot.reference.delete();
      }
    } catch (e) {
      // Handle any errors that occurred during deletion
      // ignore: avoid_print
      print('Error deleting collection: $e');
    }

    // ignore: use_build_context_synchronously
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AppRouter(currentWidget: _defaultWidget),
    ));
  }
}
