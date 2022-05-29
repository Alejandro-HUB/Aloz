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
  Widget build(BuildContext context){
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
          tiny: Container(),
          phone: currentPage == 0 ? 
            currentIndex == 0 
              ? PanelLeftPage() 
              : currentIndex == 1 
                ? PanelCenterPage() 
                : PanelRightPage()
          : currentPage == 3 
            ? ContactsSearchPage()
            : PanelLeftPage(),
          tablet: currentPage == 0 
            ? Row(
              children: [
                Expanded(child: PanelLeftPage(),),
                Expanded(child: PanelCenterPage(),),
              ],
            )
            : currentPage == 3
            ? Row(
              children: [
                Expanded(child: ContactsSearchPage(),),
              ],
            )
            : Row(
              children: [
                Expanded(child: PanelLeftPage(),),
              ],
            ),
          largeTablet: currentPage == 0 
            ? Row(
              children: [
                Expanded(child: PanelLeftPage(),),
                Expanded(child: PanelCenterPage(),),
                Expanded(child: PanelRightPage(),),
              ],
            )
            : currentPage == 3
            ? Row(
              children: [
                Expanded(child: ContactsSearchPage(),),
              ],
            )
            : Row(
              children: [
                Expanded(child: PanelLeftPage(),),
              ],
            ),
          computer: currentPage == 0 
            ? Row(
              children: [
                Expanded(child: DrawerPage(),),
                Expanded(child: PanelLeftPage(),),
                Expanded(child: PanelCenterPage(),),
                Expanded(child: PanelRightPage(),),
              ],
            )
            : currentPage == 3
            ? Row(
              children: [
                Expanded(child: DrawerPage(),),
                Expanded(child: ContactsSearchPage(),),
              ],
            )
            : Row(
              children: [
                Expanded(child: DrawerPage(),),
                Expanded(child: PanelLeftPage(),),
              ],
            ),
          ),
          drawer: DrawerPage(),
          bottomNavigationBar: ResponsiveLayout.isPhone(context) && currentPage == 0 
            ? CurvedNavigationBar(
                index: currentIndex,
                backgroundColor: Styling.purpleDark,
                items: _icons,
                onTap: (index){
                  setState(() {
                    currentIndex = index;
                  });
                },
              ) 
            : SizedBox(),
    );
  }
}
