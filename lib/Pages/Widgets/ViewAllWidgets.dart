// ignore_for_file: file_names, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:projectcrm/Assets/SideBarEntry.dart';
import 'package:projectcrm/Assets/buttons.dart';
import 'package:projectcrm/Helpers/Constants/IconHelper.dart';
import 'package:projectcrm/Helpers/Constants/RoutingConstants.dart';
import 'package:projectcrm/Helpers/Constants/Styling.dart';
import 'package:projectcrm/Helpers/Firebase/widget_service.dart';
import 'package:projectcrm/Helpers/Routing/AppRouter.dart';
import '../Home/HomePage.dart';

class ViewAllWidgets extends StatefulWidget {
  const ViewAllWidgets({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ViewAllWidgetsState createState() => _ViewAllWidgetsState();
}

// Widgets collection
CollectionReference widgetsCollection = FirebaseFirestore.instance
    .collection("UserWidgets")
    .doc(FirebaseAuth.instance.currentUser!.uid.toString())
    .collection("UserWidgets:${FirebaseAuth.instance.currentUser!.uid}");

// Home page widget
WidgetsInfo _defaultWidget = WidgetsInfo(
    id: "0",
    title: "Home",
    icon: Icons.home,
    widgetType: "Home",
    currentPage: 0,
    documentIdData: "0");

class _ViewAllWidgetsState extends State<ViewAllWidgets> {
  late List<WidgetsInfo> _widgets = [];
  final WidgetService _widgetsService = WidgetService();

  // Paging
  int _currentPage = 1;
  final int _pageSize = 10;
  int _totalPages = 0;

  //Settings to create a new widget
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _iconController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();

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
    fetchWidgets();
  }

  Future<void> fetchWidgets() async {
    var widgetsResponse =
        await _widgetsService.fetchWidgets(_pageSize, _currentPage, null);

    setState(() {
      _widgets = widgetsResponse.widgetsInfoList!;
      _totalPages = widgetsResponse.totalPages!;
    });
  }

  void nextPage() {
    setState(() {
      _currentPage++;
    });

    fetchWidgets();
  }

  void previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });

      fetchWidgets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "View All Widgets",
            style: TextStyle(color: Styling.primaryColor),
          ),
          backgroundColor: Styling.foreground,
          foregroundColor: Styling.primaryColor,
        ),
        body: SingleChildScrollView(
            child: Center(
                child: Column(children: [
          const SizedBox(
            height: 20,
          ),
          SideBarEntry(
            title: "Add Widgets",
            icon: Icons.add,
            action: () {
              showAddWidgetDialog(false, _defaultWidget, widgetsCollection);
            },
          ),
          // List of Widgets
          ...List.generate(
            _widgets.length,
            (index) {
              final WidgetsInfo widgetInfo = _widgets[index];
              return Column(
                children: [
                  if (widgetInfo.title != "Home")
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
                                    .title // Only show edit icon for non-home entries
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
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_currentPage > 1)
                GradientButton(
                  gradient: LinearGradient(
                      colors: [Styling.gradient1, Styling.gradient2]),
                  label: 'Page ${_currentPage - 1}',
                  width: 150,
                  icon: Icon(
                    Icons.arrow_back,
                    color: Styling.primaryColor,
                  ),
                  onPressed: previousPage,
                  borderRadius: BorderRadius.circular(10),
                ),
              if (_currentPage < _totalPages)
                GradientButton(
                  gradient: LinearGradient(
                      colors: [Styling.gradient1, Styling.gradient2]),
                  label: 'Page ${_currentPage + 1}',
                  width: 150,
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Styling.primaryColor,
                  ),
                  onPressed: nextPage,
                  borderRadius: BorderRadius.circular(10),
                ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Page $_currentPage of $_totalPages",
                style: TextStyle(
                  color: Styling.primaryColor,
                ),
              ),
            ],
          ),
        ]))));
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
                _widgetsService.saveWidgetToFireStore(
                    collectionReference,
                    widgetInfo,
                    context,
                    _titleController.text,
                    _iconController.text);
              } else {
                _widgetsService.addWidgets(context, _titleController.text,
                    _iconController.text, _pageController.text);
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
