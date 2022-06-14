import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/responsive_layout.dart';
import '../Helpers/Constants/Styling.dart';
import '../widget_tree.dart';
import '../app_bar/app_bar_widget.dart' as appbar;

class DrawerPage extends StatefulWidget {
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class ButtonsInfo {
  String tittle;
  IconData Icon;
  ButtonsInfo({required this.tittle, required this.Icon});
}

int? currentPage = 0;

List<ButtonsInfo> _buttonNames = [
  ButtonsInfo(tittle: "Home", Icon: Icons.home),
  ButtonsInfo(tittle: "Setting", Icon: Icons.settings),
  ButtonsInfo(tittle: "Notifications", Icon: Icons.notifications),
  ButtonsInfo(tittle: "Contacts", Icon: Icons.contact_phone_rounded),
  ButtonsInfo(tittle: "Sales", Icon: Icons.sell),
  ButtonsInfo(tittle: "Marketing", Icon: Icons.mark_email_read),
  ButtonsInfo(tittle: "Security", Icon: Icons.verified_user),
  ButtonsInfo(tittle: "Users", Icon: Icons.supervised_user_circle_rounded),
];

class _DrawerPageState extends State<DrawerPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Drawer(
      child: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(Styling.kPadding),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    "Admin Menu",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  trailing: ResponsiveLayout.isComputer(context)
                      ? null
                      : IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                ),
                //List of Widgets
                ...List.generate(
                  _buttonNames.length,
                  (index) => Column(
                    children: [
                      Container(
                        decoration: index == currentPage
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [
                                    Styling.redDark.withOpacity(0.9),
                                    Styling.orangeDark.withOpacity(0.9)
                                  ],
                                ),
                              )
                            : null,
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              currentPage = index;
                            });
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => WidgetTree(currentPage: currentPage),
                            ));
                          },
                          title: Text(
                            _buttonNames[index].tittle,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.all(Styling.kPadding),
                            child: Icon(
                              _buttonNames[index].Icon,
                              color: Colors.white,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.white,
                        thickness: 0.1,
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
