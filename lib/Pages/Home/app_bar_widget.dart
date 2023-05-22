import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:projectcrm/Pages/Users/profile_page.dart';
import 'package:projectcrm/Helpers/Routing/route.dart';
import 'package:projectcrm/main.dart';
import 'package:projectcrm/Helpers/Constants/responsive_layout.dart';
import '../../Helpers/Constants/Styling.dart';
import '../../Helpers/Firebase/storage_service.dart';
import '../Widgets/API/HttpRequestWidget.dart';
import '../Widgets/Data/DataWidget.dart';
import '../Widgets/GraphWidgets/panel_center_page.dart';
import '../Widgets/GraphWidgets/panel_left_page.dart';
import '../Widgets/GraphWidgets/panel_right_page.dart';
import 'drawer_page.dart';

List<String> _buttonNames = ["Overview", "Revenue", "Sales", "Control"];
List<String> _menuItems = ["My Profile", "Logout"];
String? index;
String email = "user";
int _currentSelectedButton = 0;

class AppBarWidget extends StatefulWidget {
  const AppBarWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AppBarWidgetState createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  final TextEditingController _iconController = TextEditingController();
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
        'PanelLeftPage': () => PanelLeftPage(),
        'PanelCenterPage': () => PanelCenterPage(),
        'PanelRightPage': () => PanelRightPage(),
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
      color: Styling.purpleLight,
      child: Row(
        children: [
          if (ResponsiveLayout.isComputer(context))
            Container(
              margin: const EdgeInsets.all(Styling.kPadding),
              height: double.infinity,
              decoration: const BoxDecoration(
                boxShadow: [
                  // ignore: unnecessary_const
                  const BoxShadow(
                      color: Styling.purpleLight,
                      offset: Offset(0, 0),
                      spreadRadius: 1,
                      blurRadius: 0),
                ],
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 60,
                child: Image.asset("images/mapp.png"),
              ),
            )
          else
            IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              iconSize: 30,
              color: Colors.white,
              icon: const Icon(Icons.menu),
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
                                ? Colors.white
                                : Colors.white70),
                      ),
                      Container(
                        margin: const EdgeInsets.all(Styling.kPadding / 2),
                        width: 60,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: _currentSelectedButton == index
                              ? const LinearGradient(
                                  colors: [
                                    Styling.redDark,
                                    Styling.orangeDark,
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
                    style: const TextStyle(color: Colors.white),
                  ),
                  Container(
                    margin: const EdgeInsets.all(Styling.kPadding / 2),
                    width: 60,
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Styling.redDark,
                          Styling.orangeDark,
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
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    prefixIconColor: Colors.white,
                    labelText: 'Search',
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
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Type: $widgetType',
                      style: const TextStyle(color: Colors.white),
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
                              appBar: const AppBarWidget(),
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
                  color: Colors.white,
                  iconSize: 30,
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_outlined),
                ),
                const Positioned(
                  right: 6,
                  top: 6,
                  // ignore: unnecessary_const
                  child: const CircleAvatar(
                    backgroundColor: Colors.pink,
                    radius: 8,
                    child: Text(
                      "3",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
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
                  color: Colors.white,
                  fontSize: ResponsiveLayout.isPhone(context) ? 9 : 15),
            ),
            autofocus: true,
            isDense: true,
            borderRadius: BorderRadius.circular(20),
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
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
                          appBar: AppBarWidget(),
                          page: ProfilePage(),
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
          style: const TextStyle(color: Colors.white),
        ),
      );
}
