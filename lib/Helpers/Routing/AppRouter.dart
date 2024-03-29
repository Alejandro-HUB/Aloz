// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/Assets/Charts/circle_graph.dart';
import 'package:projectcrm/Assets/Charts/curved_chart.dart';
import 'package:projectcrm/Assets/Charts/linear_graph.dart';
import 'package:projectcrm/Assets/Charts/wiggle_graph.dart';
import 'package:projectcrm/Pages/Home/TopAppBar.dart';
import 'package:projectcrm/Pages/Widgets/Presets/panel_center_page.dart';
import 'package:projectcrm/Pages/Widgets/Presets/panel_left_page.dart';
import 'package:projectcrm/Pages/Widgets/Presets/panel_right_page.dart';
import 'package:projectcrm/Helpers/Constants/responsive_layout.dart';
import '../Constants/Styling.dart';
import 'package:projectcrm/Pages/Home/HomePage.dart';
import '../../Pages/Widgets/API/HttpRequestWidget.dart';
import '../../Pages/Widgets/Data/DataWidget.dart';

/// This Flutter code defines the `AppRouter` widget, which serves as the central navigation component for the application.
/// It includes a dynamic user interface that adapts to different screen sizes and user interactions.
/// The `AppRouter` widget allows users to navigate between various app screens and widgets, including `PanelLeftPage`, `PanelCenterPage`, `PanelRightPage`, `DataWidget`, and `HttpRequestWidget`.
/// It also features a responsive design that adjusts its layout based on the available screen real estate. This code provides a flexible and user-friendly way to manage the application's navigation and content display.
/// NOTE: Ensure to customize and expand the `widgetMap` with additional widget mappings as needed for your application.

// ignore: must_be_immutable
class AppRouter extends StatefulWidget {
  WidgetsInfo? currentWidget = WidgetsInfo(
      id: "",
      title: "",
      icon: Icons.arrow_back,
      widgetType: "",
      currentPage: 0,
      documentIdData: "");
  AppRouter({super.key, this.currentWidget});

  @override
  _AppRouterState createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
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
            : const TopAppBar(),
      ),
      body: ResponsiveLayout(
        // Small Sized Screen -> Do not show UI
        tiny: Container(),
        // Phone Sized Screen
        phone: currentWidget?.currentPage == 0
            ? currentIndexBottomNavigationBar == 0
                ? const PanelLeftPage()
                : currentIndexBottomNavigationBar == 1
                    ? const PanelCenterPage()
                    : const PanelRightPage()
            : createDynamicWidget(currentWidget!.widgetType),
        // Tablet Sized Screen
        tablet: currentWidget?.currentPage == 0
            ? const Row(
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
            ? const Row(
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
            ? const Row(
                children: [
                  Expanded(child: HomePage()),
                  Expanded(child: PanelLeftPage()),
                  Expanded(child: PanelCenterPage()),
                  Expanded(child: PanelRightPage()),
                ],
              )
            : Row(
                children: [
                  const Expanded(child: HomePage()),
                  Expanded(
                      child: createDynamicWidget(currentWidget!.widgetType)),
                ],
              ),
      ),
      drawer: const HomePage(),
      bottomNavigationBar:
          ResponsiveLayout.isPhone(context) && currentWidget?.currentPage == 0
              ? CurvedNavigationBar(
                  index: currentIndexBottomNavigationBar,
                  backgroundColor: Styling.background,
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
}
