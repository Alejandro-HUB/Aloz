// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:projectcrm/Assets/Charts/circle_graph.dart';
import 'package:projectcrm/Assets/Charts/curved_chart.dart';
import 'package:projectcrm/Assets/Charts/linear_graph.dart';
import 'package:projectcrm/Assets/Charts/wiggle_graph.dart';
import 'package:projectcrm/Pages/Users/profile_page.dart';
import 'package:projectcrm/Helpers/Routing/route.dart';
import 'package:projectcrm/Pages/Users/settings_page.dart';
import 'package:projectcrm/main.dart';
import 'package:projectcrm/Helpers/Constants/responsive_layout.dart';
import '../../Helpers/Constants/Styling.dart';
import '../../Helpers/Firebase/storage_service.dart';
import '../Widgets/API/HttpRequestWidget.dart';
import '../Widgets/Data/DataWidget.dart';
import 'HomePage.dart';

// This Dart code defines a custom Flutter widget called TopAppBar, which serves as the top app bar for the application.
// The TopAppBar includes features like navigation buttons, search functionality, user profile information, and a menu dropdown.
// It also dynamically loads different widgets based on user selections and provides access to the user's profile and logout functionality.
// The code is organized into classes and functions for better modularity and readability.
// Note: Make sure to customize the widget's behavior as needed for your specific application.

List<String> _buttonNames = ["Overview", "Revenue", "Sales", "Control"];
List<String> _menuItems = ["My Profile", "Settings", "Logout"];
String? index;
String email = "user";
int _currentSelectedButton = 0;

class TopAppBar extends StatefulWidget {
  const TopAppBar({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TopAppBarState createState() => _TopAppBarState();
}

class _TopAppBarState extends State<TopAppBar> {
  final TextEditingController _iconController = TextEditingController();
  // ignore: prefer_final_fields
  late List<WidgetsInfo> _widgetNames = [];

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.currentUser == null
        ? email = "user"
        : email = FirebaseAuth.instance.currentUser!.email!;

    Widget createDynamicWidget(String widgetName) {
      final Map<String, Widget Function()> widgetMap = {
        'CircleGraph': () => const PieChartSample2(),
        'LineChart1': () => const LineChartSample1(),
        'LineChart2': () => const LineChartSample2(),
        'BarChart': () => BarChartSample2(),
        'DataWidget': () => const DataWidget(),
        'HttpRequestWidget': () => const HttpRequestWidget(),
        // Add more widget mappings here
      };

      if (widgetMap.containsKey(widgetName)) {
        return widgetMap[widgetName]!();
      } else {
        // Return a fallback widget or handle the case when the widget name is not found
        return Container();
      }
    }

    return Container(
      color: Styling.foreground,
      child: Row(
        children: [
          if (ResponsiveLayout.isComputer(context))
            Container(
              margin: const EdgeInsets.all(Styling.kPadding),
              height: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  // ignore: unnecessary_const
                  BoxShadow(
                      color: Styling.foreground,
                      offset: const Offset(0, 0),
                      spreadRadius: 1,
                      blurRadius: 0),
                ],
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 60,
                child: Image.asset("images/${Styling.logo}"),
              ),
            )
          else
            IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              iconSize: 30,
              color: Styling.primaryColor,
              icon: Icon(
                Icons.menu,
                color: Styling.primaryColor,
              ),
            ),
          const SizedBox(
            width: Styling.kPadding,
          ),
          const Spacer(),
          if (ResponsiveLayout.isComputer(context))
            ...List.generate(
              _buttonNames.length,
              (index) => TextButton(
                onPressed: () {
                  setState(() {
                    _currentSelectedButton = index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(Styling.kPadding * 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _buttonNames[index],
                        style: TextStyle(
                            color: _currentSelectedButton == index
                                ? Styling.primaryColor
                                : Styling.primaryColor),
                      ),
                      Container(
                        margin: const EdgeInsets.all(Styling.kPadding / 2),
                        width: 60,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: _currentSelectedButton == index
                              ? LinearGradient(
                                  colors: [
                                    Styling.gradient1,
                                    Styling.gradient2,
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(Styling.kPadding * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _buttonNames[_currentSelectedButton],
                    style: TextStyle(color: Styling.primaryColor),
                  ),
                  Container(
                    margin: const EdgeInsets.all(Styling.kPadding / 2),
                    width: 60,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Styling.gradient1,
                          Styling.gradient2,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          if (!ResponsiveLayout.isPhone(context))
            //Search Button
            Expanded(
              child: TypeAheadFormField<Map<String, String>>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: TextEditingController(),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Styling.primaryColor,
                    ),
                    prefixIconColor: Styling.primaryColor,
                    labelText: 'Search',
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
                  // Fetch data from the collection and return suggestions based on the pattern
                  const collectionName = "UserWidgets";
                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  final querySnapshot = await FirebaseFirestore.instance
                      .collection(collectionName)
                      .doc(uid)
                      .collection("UserWidgets:$uid")
                      .get();

                  for (final doc in querySnapshot.docs) {
                    final id = doc.get('id') as String;
                    final title = doc.get('title') as String;
                    final iconName = doc.get('icon') as String;
                    final icon = IconsExtension.getIconData(iconName);
                    final widgetType = doc.get('widgetType') as String;
                    final documentIdData = doc.get('documentIdData') as String;
                    _widgetNames.add(WidgetsInfo(
                        id: id,
                        title: title,
                        icon: icon,
                        widgetType: widgetType,
                        currentPage: 0,
                        documentIdData: documentIdData));
                  }

                  // Extract suggestions from the querySnapshot and return them
                  // Replace 'fieldName' with the actual field name in your collection documents
                  return querySnapshot.docs
                      .map((doc) => {
                            'title': doc.get('title') as String,
                            'widgetType': doc.get('widgetType') as String,
                          })
                      .where((suggestion) => suggestion['title']!
                          .toLowerCase()
                          .contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, suggestion) {
                  final title = suggestion['title']!;
                  final widgetType = suggestion['widgetType']!;

                  return ListTile(
                    title: Text(
                      title,
                      style: TextStyle(
                          color: Styling.primaryColor, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Type: $widgetType',
                      style: TextStyle(color: Styling.primaryColor),
                    ),
                  );
                },
                onSuggestionSelected: (Map<String, String> value) {
                  // Perform actions when a suggestion is selected
                  // Replace '_iconController' with the actual controller for the search field
                  setState(() {
                    _iconController.text =
                        '${value['title']},${value['widgetType']}';

                    //Parse widget properties
                    var title = _iconController.text.split(',')[0];
                    var type = _iconController.text.split(',')[1];

                    //Get widget
                    var widgetSelected = _widgetNames.firstWhere((element) =>
                        element.title == title && element.widgetType == type);
                    currentWidget = widgetSelected;
                    currentWidget!.currentPage =
                        _widgetNames.indexOf(widgetSelected) + 1;

                    //Navigate to selected widget
                    Navigator.of(context).push(MaterialPageRoute(
                        // ignore: prefer_const_constructors
                        builder: (context) => RoutePage(
                              appBar: const TopAppBar(),
                              page: createDynamicWidget(
                                  currentWidget!.widgetType),
                              showDrawer: true,
                            )));
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a search query';
                  }
                  return null;
                },
              ),
            ),
          if (!ResponsiveLayout.isPhone(context))
            Stack(
              children: [
                IconButton(
                  color: Styling.primaryColor,
                  iconSize: 30,
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications_none_outlined,
                    color: Styling.primaryColor,
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  // ignore: unnecessary_const
                  child: CircleAvatar(
                    backgroundColor: Styling.gradient1,
                    radius: 8,
                    child: Text(
                      "3",
                      style: TextStyle(
                        fontSize: 10,
                        color: Styling.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          DropdownButton<String>(
            hint: Text(
              email,
              style: TextStyle(
                  color: Styling.primaryColor,
                  fontSize: ResponsiveLayout.isPhone(context) ? 9 : 15),
            ),
            autofocus: true,
            isDense: true,
            borderRadius: BorderRadius.circular(20),
            icon: Icon(
              Icons.arrow_drop_down,
              color: Styling.primaryColor,
            ),
            items: _menuItems.map(buildMenuItem).toList(),
            onChanged: (value) => setState(() {
              index = value;
              if (index == "Logout") {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const MainPage(),
                ));
              } else if (index == "My Profile") {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const RoutePage(
                          appBar: TopAppBar(),
                          page: ProfilePage(),
                          showDrawer: false,
                        )));
              }
              else if (index == "Settings") {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const RoutePage(
                          appBar: TopAppBar(),
                          page: SettingsPage(),
                          showDrawer: false,
                        )));
              }
            }),
            style: const TextStyle(fontSize: 15),
          ),
          Container(
            margin: const EdgeInsets.all(Styling.kPadding),
            height: double.infinity,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: listImages(
              backgroundColor: Styling.gradient2,
              collectionName: "Users",
              documentName: FirebaseAuth.instance.currentUser?.uid == null
                  ? ""
                  : FirebaseAuth.instance.currentUser!.uid,
              fieldName: "profile_picture",
              circleAvatar: true,
              profilePicture: true,
              radius: 30,
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(color: Styling.primaryColor),
        ),
      );
}
