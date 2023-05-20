// ignore_for_file: library_private_types_in_public_api, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Helpers/Constants/responsive_layout.dart';
import '../../Helpers/Constants/Styling.dart';
import '../../Helpers/Routing/route.dart';
import '../../Models/WidgetsEntity.dart';
import 'widget_tree.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  _DrawerPageState createState() => _DrawerPageState();
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

class _DrawerPageState extends State<DrawerPage> {
  late List<WidgetsInfo> _widgetNames = [];

  //Settings to create a new widget
  final TextEditingController _titleController = TextEditingController();
  String? _selectedIcon;
  String? _selectedPage;

  //Widget Tittle Controller
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  //Icon Names
  final List<String> _iconNames = [
    'settings',
    'notifications',
    'contact_phone_rounded',
    'sell',
    'mark_email_read',
    'verified_user',
    'supervised_user_circle_rounded',
    'person_pin'
    // Add more icon names as needed
  ];
  //Widget Names
  final List<String> _pageNames = [
    'PanelLeftPage',
    'PanelCenterPage',
    'PanelRightPage',
    'DataWidget',
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

  CollectionReference widgets = FirebaseFirestore.instance
      .collection("UserWidgets")
      .doc(FirebaseAuth.instance.currentUser!.uid.toString())
      .collection("UserWidgets:${FirebaseAuth.instance.currentUser!.uid}");

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(
                        "Add Widgets",
                        style: TextStyle(
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
                                  color: Colors
                                      .white), // Set the input text color to white
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
                            DropdownButtonFormField<String>(
                              value: _selectedIcon,
                              items: _iconNames
                                  .map((iconName) => DropdownMenuItem<String>(
                                        value: iconName,
                                        child: Text(
                                          iconName,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedIcon = value;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: "Select an icon",
                                hintStyle: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Page:",
                              style: TextStyle(color: Colors.white),
                            ),
                            DropdownButtonFormField<String>(
                              value: _selectedPage,
                              items: _pageNames
                                  .map((pageName) => DropdownMenuItem<String>(
                                        value: pageName,
                                        child: Text(
                                          pageName,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPage = value;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: "Select a page",
                                hintStyle: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: addWidgets,
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
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                      backgroundColor: Styling
                          .purpleLight, // Modify the background color here
                    ),
                  );
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
                                  WidgetTree(currentWidget: currentWidget!),
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
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
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
                                              deleteContact(widgetInfo);
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
                                        backgroundColor: Styling
                                            .purpleLight, // Modify the background color here
                                      ),
                                    );
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
        icon: _selectedIcon.toString(),
        widgetType: _selectedPage.toString(),
        documentIdData: _titleController.text + doc.id);
    await doc
        .set(widgetToAdd.toJson())
        // ignore: avoid_print
        .then((value) => print('Widget Added'))
        // ignore: avoid_print
        .catchError((error) => print('Failed to add Widget: $error'));

    // ignore: use_build_context_synchronously
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => WidgetTree(currentWidget: currentWidget!),
    ));
  }

  Future deleteContact(WidgetsInfo widgetToDelete) async {
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
      builder: (context) => WidgetTree(currentWidget: defaultWidget),
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
      case 'contact_phone_rounded':
        return Icons.contact_phone_rounded;
      case 'sell':
        return Icons.sell;
      case 'mark_email_read':
        return Icons.mark_email_read;
      case 'verified_user':
        return Icons.verified_user;
      case 'supervised_user_circle_rounded':
        return Icons.supervised_user_circle_rounded;
      case 'person_pin':
        return Icons.person_pin;
      default:
        return Icons.error;
    }
  }
}
