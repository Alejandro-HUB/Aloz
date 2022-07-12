import 'package:firebase_auth/firebase_auth.dart';
import 'package:firedart/generated/google/firestore/v1/document.pb.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/Pages/Login_Signup/login_page.dart';
import 'package:projectcrm/Pages/Users/profile_page.dart';
import 'package:projectcrm/Helpers/Routing/route.dart';
import 'package:projectcrm/main.dart';
import 'package:projectcrm/Helpers/Constants/responsive_layout.dart';
import '../Helpers/Constants/Styling.dart';
import '../Helpers/Firebase/storage_service.dart';
import 'drawer_page.dart';
import '../Pages/Home/widget_tree.dart';

List<String> _buttonNames = ["Overview", "Revenue", "Sales", "Control"];
List<String> _menuItems = ["My Profile", "Logout"];
String? index;
String email = "user";
int _currentSelectedButton = 0;

class AppBarWidget extends StatefulWidget {
  @override
  _AppBarWidgetState createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.currentUser == null
        ? email = "user"
        : email = FirebaseAuth.instance.currentUser!.email!;

    return Container(
      color: Styling.purpleLight,
      child: Row(
        children: [
          if (ResponsiveLayout.isComputer(context))
            Container(
              margin: EdgeInsets.all(Styling.kPadding),
              height: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
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
              icon: Icon(Icons.menu),
            ),
          SizedBox(
            width: Styling.kPadding,
          ),
          Spacer(),
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
                  padding: EdgeInsets.all(Styling.kPadding * 2),
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
                        margin: EdgeInsets.all(Styling.kPadding / 2),
                        width: 60,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: _currentSelectedButton == index
                              ? LinearGradient(
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
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    margin: EdgeInsets.all(Styling.kPadding / 2),
                    width: 60,
                    height: 2,
                    decoration: BoxDecoration(
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
          Spacer(),
          if (!ResponsiveLayout.isPhone(context))
            IconButton(
              color: Colors.white,
              iconSize: 30,
              onPressed: () {},
              icon: Icon(Icons.search),
            ),
          if (!ResponsiveLayout.isPhone(context))
            Stack(
              children: [
                IconButton(
                  color: Colors.white,
                  iconSize: 30,
                  onPressed: () {},
                  icon: Icon(Icons.notifications_none_outlined),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
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
          Container(
            child: DropdownButton<String>(
              hint: Text(
                email,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveLayout.isPhone(context) ? 9 : 15),
              ),
              autofocus: true,
              isDense: true,
              borderRadius: BorderRadius.circular(20),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
              items: _menuItems.map(buildMenuItem).toList(),
              onChanged: (value) => setState(() {
                index = value;
                if (index == "Logout") {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MainPage(),
                  ));
                } else if (index == "My Profile") {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => RoutePage(
                            appBar: AppBarWidget(),
                            page: ProfilePage(),
                            showDrawer: false,
                          )));
                }
              }),
              style: TextStyle(fontSize: 15),
            ),
          ),
          Container(
            margin: EdgeInsets.all(Styling.kPadding),
            height: double.infinity,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: listImages(
              collectionName: "Users",
              documentName: FirebaseAuth.instance.currentUser!.uid.toString(),
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
          style: TextStyle(color: Colors.white),
        ),
      );
}
