import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/Pages/Users/profile_page.dart';
import 'package:projectcrm/Helpers/Routing/route.dart';
import 'package:projectcrm/main.dart';
import 'package:projectcrm/Helpers/Constants/responsive_layout.dart';
import '../Helpers/Constants/Styling.dart';
import '../Helpers/Firebase/storage_service.dart';

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
            IconButton(
              color: Colors.white,
              iconSize: 30,
              onPressed: () {},
              icon: const Icon(Icons.search),
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
                    builder: (context) => RoutePage(
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
