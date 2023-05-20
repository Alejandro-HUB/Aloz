// ignore_for_file: library_private_types_in_public_api

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/Pages/Home/app_bar_widget.dart';
import 'package:projectcrm/Pages/Widgets/GraphWidgets/panel_center_page.dart';
import 'package:projectcrm/Pages/Widgets/GraphWidgets/panel_left_page.dart';
import 'package:projectcrm/Pages/Widgets/GraphWidgets/panel_right_page.dart';
import 'package:projectcrm/Helpers/Constants/responsive_layout.dart';
import '../../Helpers/Constants/Styling.dart';
import 'package:projectcrm/Pages/Home/drawer_page.dart';
import '../Widgets/Data/DataWidget.dart';

// ignore: must_be_immutable
class WidgetTree extends StatefulWidget {
  WidgetsInfo? currentWidget = WidgetsInfo(
      id: "",
      title: "",
      icon: Icons.arrow_back,
      widgetType: "",
      currentPage: 0,
      documentIdData: "");
  WidgetTree({Key? key, this.currentWidget}) : super(key: key);

  @override
  _WidgetTreeState createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int currentIndexBottomNavigationBar = 1;

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
        phone: currentWidget?.currentPage == 0
            ? currentIndexBottomNavigationBar == 0
                ? PanelLeftPage()
                : currentIndexBottomNavigationBar == 1
                    ? PanelCenterPage()
                    : PanelRightPage()
            : createDynamicWidget(currentWidget!.widgetType),
        // Tablet Sized Screen
        tablet: currentWidget?.currentPage == 0
            ? Row(
                children: [
                  Expanded(child: PanelLeftPage()),
                  Expanded(child: PanelCenterPage()),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: createDynamicWidget(currentWidget!.widgetType),
                  ),
                ],
              ),
        // Large Tablet Sized Screen
        largeTablet: currentWidget?.currentPage == 0
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
                    child: createDynamicWidget(currentWidget!.widgetType),
                  ),
                ],
              ),
        // Computer Sized Screen
        computer: currentWidget?.currentPage == 0
            ? Row(
                children: [
                  const Expanded(child: DrawerPage()),
                  Expanded(child: PanelLeftPage()),
                  Expanded(child: PanelCenterPage()),
                  Expanded(child: PanelRightPage()),
                ],
              )
            : Row(
                children: [
                  const Expanded(child: DrawerPage()),
                  Expanded(
                      child: createDynamicWidget(currentWidget!.widgetType)),
                ],
              ),
      ),
      drawer: const DrawerPage(),
      bottomNavigationBar:
          ResponsiveLayout.isPhone(context) && currentWidget?.currentPage == 0
              ? CurvedNavigationBar(
                  index: currentIndexBottomNavigationBar,
                  backgroundColor: Styling.purpleDark,
                  items: _icons,
                  onTap: (index) {
                    setState(() {
                      currentIndexBottomNavigationBar = index;
                    });
                  },
                )
              : const SizedBox(),
    );
  }

  Widget createDynamicWidget(String widgetName) {
    final Map<String, Widget Function()> widgetMap = {
      'PanelLeftPage': () => PanelLeftPage(),
      'PanelCenterPage': () => PanelCenterPage(),
      'PanelRightPage': () => PanelRightPage(),
      'DataWidget': () => const DataWidget(),
      // Add more widget mappings here
    };

    if (widgetMap.containsKey(widgetName)) {
      return widgetMap[widgetName]!();
    } else {
      // Return a fallback widget or handle the case when the widget name is not found
      return Container();
    }
  }
}
