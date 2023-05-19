// ignore_for_file: library_private_types_in_public_api

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/Assets/app_bar_widget.dart';
import 'package:projectcrm/Pages/Home/panel_center_page.dart';
import 'package:projectcrm/Pages/Home/panel_left_page.dart';
import 'package:projectcrm/Pages/Home/panel_right_page.dart';
import 'package:projectcrm/Helpers/Constants/responsive_layout.dart';
import '../../Helpers/Constants/Styling.dart';
import 'package:projectcrm/Assets/drawer_page.dart';
import '../Contacts/Contacts.dart';

// ignore: must_be_immutable
class WidgetTree extends StatefulWidget {
  int? currentPage = 0;
  WidgetTree({Key? key, this.currentPage}) : super(key: key);

  @override
  _WidgetTreeState createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int currentIndex = 1;

  final List<Widget> _icons = [
    const Icon(Icons.add, size: 30),
    const Icon(Icons.list, size: 30),
    const Icon(Icons.compare_arrows, size: 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 100),
        child: ResponsiveLayout.istinyLimit(context) ||
                ResponsiveLayout.isTinyHeightLimit(context)
            ? Container()
            : const AppBarWidget(),
      ),
      body: ResponsiveLayout(
        // Small Sized Screen -> Do not show UI
        tiny: Container(),
        // Phone Sized Screen
        phone: currentPage == 0
            ? currentIndex == 0
                ? PanelLeftPage()
                : currentIndex == 1
                    ? PanelCenterPage()
                    : PanelRightPage()
            : currentPage == 3
                ? const ContactsSearchPage()
                : PanelLeftPage(),
        // Tablet Sized Screen
        tablet: currentPage == 0
            ? Row(
                children: [
                  Expanded(child: PanelLeftPage()),
                  Expanded(child: PanelCenterPage()),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: currentPage == 3
                        ? const ContactsSearchPage()
                        : PanelLeftPage(),
                  ),
                ],
              ),
        // Large Tablet Sized Screen
        largeTablet: currentPage == 0
            ? Row(
                children: [
                  Expanded(child: PanelLeftPage()),
                  Expanded(child: PanelCenterPage()),
                  Expanded(child: PanelRightPage()),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: currentPage == 3
                        ? const ContactsSearchPage()
                        : PanelLeftPage(),
                  ),
                ],
              ),
        // Computer Sized Screen
        computer: currentPage == 0
            ? Row(
                children: [
                  const Expanded(child: DrawerPage()),
                  Expanded(child: PanelLeftPage()),
                  Expanded(child: PanelCenterPage()),
                  Expanded(child: PanelRightPage()),
                ],
              )
            : currentPage == 3
                ? Row(
                    children: const [
                      Expanded(child: ContactsSearchPage()),
                    ],
                  )
                : Row(
                    children: [
                      const Expanded(child: DrawerPage()),
                      Expanded(child: PanelLeftPage()),
                    ],
                  ),
      ),
      drawer: const DrawerPage(),
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
          : const SizedBox(),
    );
  }
}
