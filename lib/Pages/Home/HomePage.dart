// ignore_for_file: library_private_types_in_public_api, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../Helpers/Constants/Styling.dart';
import '../../Models/WidgetsEntity.dart';
import 'AppRouter.dart';

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

WidgetsInfo defaultWidget = WidgetsInfo(
    id: "0",
    title: "Home",
    icon: Icons.home,
    widgetType: "Home",
    currentPage: 0,
    documentIdData: "0");
WidgetsInfo? currentWidget = defaultWidget;

class _HomePageState extends State<HomePage> {
  late List<WidgetsInfo> _widgetNames = [];

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

  //Icon Names
  final List<String> _iconNames = [
    'home',
    'settings',
    'notifications',
    'phone',
    'email',
    'person',
    'account_balance',
    'work',
    'date_range',
    'message',
    'location_on',
    'attach_file',
    'cloud_upload',
    'cloud_download',
    'photo_camera',
    'photo_library',
    'check',
    'close',
    'search',
    'edit',
    'delete',
    'star',
    'favorite',
    'bookmark',
    'share',
    'arrow_back',
    'arrow_forward',
    'play_arrow',
    'pause',
    'stop',
    'add',
    'info',
    'code',
    'payment',
    'list',
    // Add more icon names as needed
  ];

  //Widget Names
  final List<String> _pageNames = [
    'PanelLeftPage',
    'PanelCenterPage',
    'PanelRightPage',
    'DataWidget',
    'HttpRequestWidget'
    // Add more page names as needed
  ];

  @override
  void initState() {
    super.initState();
    fetchWidgetNames();
  }

  Future<void> fetchWidgetNames() async {
    const collectionName = "UserWidgets";
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(uid)
        .collection("UserWidgets:$uid")
        .get();

    final List<WidgetsInfo> widgetNames = [];

    // Add the default home widget which always goes first
    widgetNames.add(WidgetsInfo(
        id: "0",
        title: "Home",
        icon: Icons.home,
        widgetType: "Home",
        currentPage: 0,
        documentIdData: "0"));

    for (final doc in querySnapshot.docs) {
      final id = doc.get('id') as String;
      final title = doc.get('title') as String;
      final iconName = doc.get('icon') as String;
      final icon = IconsExtension.getIconData(iconName);
      final widgetType = doc.get('widgetType') as String;
      final documentIdData = doc.get('documentIdData') as String;
      widgetNames.add(WidgetsInfo(
          id: id,
          title: title,
          icon: icon,
          widgetType: widgetType,
          currentPage: 0,
          documentIdData: documentIdData));
    }

    setState(() {
      _widgetNames = widgetNames;
    });
  }

  Widget _getIconPreview(String iconName) {
    final iconData = IconsExtension.getIconData(iconName);
    return Icon(
      iconData,
      size: 24,
      color: Colors.white,
    );
  }

  CollectionReference widgets = FirebaseFirestore.instance
      .collection("UserWidgets")
      .doc(FirebaseAuth.instance.currentUser!.uid.toString())
      .collection("UserWidgets:${FirebaseAuth.instance.currentUser!.uid}");

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Styling.purpleLight,
      child: Drawer(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Styling.kPadding),
            child: Column(
              children: [
                const ListTile(
                  title: Row(
                    children: [
                      Text(
                        "Admin Menu",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  onTap: () {
                    showAddWidgetDialog(false, defaultWidget, widgets);
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Add Widgets",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Styling.redDark.withOpacity(0.9),
                              Styling.orangeDark.withOpacity(0.9),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
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
                                      Styling.redDark.withOpacity(0.9),
                                      Styling.orangeDark.withOpacity(0.9),
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
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            leading: Padding(
                              padding: const EdgeInsets.all(Styling.kPadding),
                              child: Icon(
                                widgetInfo.icon,
                                color: Colors.white,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            trailing: widgetInfo.title !=
                                    "Home" // Only show trash icon for non-home entries
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      showAddWidgetDialog(
                                          true, widgetInfo, widgets);
                                    },
                                  )
                                : null, // No trash icon for home entry
                          ),
                        ),
                        const Divider(
                          color: Styling.purpleBorder,
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Title:",
                style: TextStyle(color: Colors.white),
              ),
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  hintText: "Enter the widget title",
                  hintStyle: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Icon:",
                style: TextStyle(color: Colors.white),
              ),
              TypeAheadFormField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _iconController,
                  decoration: const InputDecoration(
                    labelText: 'Select Icon',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                suggestionsCallback: (pattern) async {
                  return _iconNames
                      .where((iconName) => iconName
                          .toLowerCase()
                          .contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, String suggestion) {
                  return ListTile(
                    leading: _getIconPreview(suggestion),
                    title: Text(
                      suggestion,
                      style: const TextStyle(color: Colors.white),
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
                const Text(
                  "Page:",
                  style: TextStyle(color: Colors.white),
                ),
              if (!edit)
                TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _pageController,
                    decoration: const InputDecoration(
                      labelText: 'Select Page',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      hintText: '',
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  suggestionsCallback: (pattern) async {
                    return _pageNames
                        .where((pageName) => pageName
                            .toLowerCase()
                            .contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, String suggestion) {
                    return ListTile(
                      title: Text(
                        suggestion,
                        style: const TextStyle(color: Colors.white),
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
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () {
                ShowDeleteDialog(widgetInfo);
              },
            ),
          TextButton(
            onPressed: () {
              if (edit) {
                saveWidgetToFireStore(collectionReference, widgetInfo);
              } else {
                addWidgets();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Styling.redDark.withOpacity(0.9),
                    Styling.orangeDark.withOpacity(0.9),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              child: Text(
                buttonName,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
        backgroundColor: Styling.purpleLight,
      ),
    );
  }

  void ShowDeleteDialog(WidgetsInfo widgetInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Confirm Delete",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure you wish to delete this widget?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              deleteWidget(widgetInfo);
              Navigator.of(context).pop();
            },
            child: const Text(
              "Confirm",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
        backgroundColor:
            Styling.purpleLight, // Modify the background color here
      ),
    );
  }

  Future addWidgets() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sending Data to Cloud Firestore"),
      ),
    );

    var doc = widgets.doc();
    WidgetsEntity widgetToAdd = WidgetsEntity(
        id: doc.id,
        title: _titleController.text,
        icon: _iconController.text.toString(),
        widgetType: _pageController.text.toString(),
        documentIdData: _titleController.text + doc.id);
    await doc
        .set(widgetToAdd.toJson())
        // ignore: avoid_print
        .then((value) => print('Widget Added'))
        // ignore: avoid_print
        .catchError((error) => print('Failed to add Widget: $error'));

    // ignore: use_build_context_synchronously
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AppRouter(currentWidget: currentWidget!),
    ));
  }

  Future saveWidgetToFireStore(
      CollectionReference collectionReference, WidgetsInfo widget) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sending Data to Cloud Firestore"),
      ),
    );

    await collectionReference
        .doc(widget.id.toString())
        .update({
          'id': widget.id,
          'title': _titleController.text,
          'icon': _iconController.text.toString(),
          'widgetType': widget.widgetType,
          'documentIdData': widget.documentIdData
        })
        .then((value) => //Return to contacts page
            // ignore: use_build_context_synchronously
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AppRouter(currentWidget: currentWidget!),
            )))
        // ignore: avoid_print
        .catchError((error) => print('Failed to update widget: $error'));
  }

  Future deleteWidget(WidgetsInfo widgetToDelete) async {
    //Load collection for the widget's data
    CollectionReference widgetData = FirebaseFirestore.instance
        .collection("UserWidgetData")
        .doc(FirebaseAuth.instance.currentUser!.uid.toString())
        .collection(widgetToDelete.documentIdData);

    await widgets
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
      builder: (context) => AppRouter(currentWidget: defaultWidget),
    ));
  }
}

extension IconsExtension on IconData {
  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      case 'notifications':
        return Icons.notifications;
      case 'phone':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'person':
        return Icons.person;
      case 'account_balance':
        return Icons.account_balance;
      case 'work':
        return Icons.work;
      case 'date_range':
        return Icons.date_range;
      case 'message':
        return Icons.message;
      case 'location_on':
        return Icons.location_on;
      case 'attach_file':
        return Icons.attach_file;
      case 'cloud_upload':
        return Icons.cloud_upload;
      case 'cloud_download':
        return Icons.cloud_download;
      case 'photo_camera':
        return Icons.photo_camera;
      case 'photo_library':
        return Icons.photo_library;
      case 'check':
        return Icons.check;
      case 'close':
        return Icons.close;
      case 'search':
        return Icons.search;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'star':
        return Icons.star;
      case 'favorite':
        return Icons.favorite;
      case 'bookmark':
        return Icons.bookmark;
      case 'share':
        return Icons.share;
      case 'arrow_back':
        return Icons.arrow_back;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'play_arrow':
        return Icons.play_arrow;
      case 'pause':
        return Icons.pause;
      case 'stop':
        return Icons.stop;
      case 'add':
        return Icons.add;
      case 'info':
        return Icons.info;
      case 'code':
        return Icons.code;
      case 'payment':
        return Icons.payment;
      case 'list':
        return Icons.list;
      default:
        return Icons.error;
    }
  }
}
