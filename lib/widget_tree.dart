import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/app_bar/app_bar_widget.dart';
import 'package:projectcrm/Pages/panel_center_page.dart';
import 'package:projectcrm/Pages/panel_left_page.dart';
import 'package:projectcrm/Pages/panel_right_page.dart';
import 'package:projectcrm/responsive_layout.dart';
import 'Helpers/Constants/Styling.dart';
import 'package:projectcrm/drawer/drawer_page.dart';

import 'Pages/Contacts.dart';
import 'Pages/profile_page.dart';

class WidgetTree extends StatefulWidget {
  int? currentPage = 0;
  WidgetTree({this.currentPage});

  @override
  _WidgetTreeState createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int currentIndex = 1;

  List<Widget> _icons = [
    Icon(Icons.add, size: 30),
    Icon(Icons.list, size: 30),
    Icon(Icons.compare_arrows, size: 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        // ignore: sort_child_properties_last
        child: (ResponsiveLayout.istinyLimit(context) ||
                ResponsiveLayout.isTinyHeightLimit(context)
            ? Container()
            : AppBarWidget()),
        // ignore: prefer_const_constructors
        preferredSize: Size(double.infinity, 100),
      ),
      body: ResponsiveLayout(
          //Small Sized Screen -> Do not show UI
          tiny: Container(),
          //Phone Sized Screen
          phone: currentPage == 0
              ? currentIndex == 0
                  ? PanelLeftPage()
                  : currentIndex == 1
                      ? PanelCenterPage()
                      : PanelRightPage()
              : currentPage == 3
                  ? ContactsSearchPage()
                  : PanelLeftPage(),
          //Tablet Sized Screen
          tablet: currentPage == 0
              ? Row(
                  children: [
                    Expanded(
                      child: PanelLeftPage(),
                    ),
                    Expanded(
                      child: PanelCenterPage(),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: currentPage == 3
                          ? ContactsSearchPage()
                          : PanelLeftPage(),
                    ),
                  ],
                ),
          //Large Tabled Sized Screen
          largeTablet: currentPage == 0
              ? Row(
                  children: [
                    Expanded(
                      child: PanelLeftPage(),
                    ),
                    Expanded(
                      child: PanelCenterPage(),
                    ),
                    Expanded(
                      child: PanelRightPage(),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: currentPage == 3
                          ? ContactsSearchPage()
                          : PanelLeftPage(),
                    ),
                  ],
                ),
          //Computer Sized Screen
          computer: currentPage == 0
              ? Row(
                  children: [
                    Expanded(
                      child: DrawerPage(),
                    ),
                    Expanded(
                      child: PanelLeftPage(),
                    ),
                    Expanded(
                      child: PanelCenterPage(),
                    ),
                    Expanded(
                      child: PanelRightPage(),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: DrawerPage(),
                    ),
                    Expanded(
                      child: currentPage == 3
                          ? ContactsSearchPage()
                          : PanelLeftPage(),
                    ),
                  ],
                )),
      drawer: DrawerPage(),
      bottomNavigationBar: ResponsiveLayout.isPhone(context) && currentPage == 0
          ? CurvedNavigationBar(
              index: currentIndex,
              backgroundColor: Styling.purpleDark,
              items: _icons,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            )
          : SizedBox(),
    );
  }
}
