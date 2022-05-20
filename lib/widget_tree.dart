import 'package:flutter/material.dart';
import 'package:projectcrm/panel_center/panel_center_page.dart';
import 'package:projectcrm/panel_left/panel_left_page.dart';
import 'package:projectcrm/panel_right/panel_right_page.dart';
import 'package:projectcrm/responsive_layout.dart';
import 'package:projectcrm/drawer/drawer_page.dart';

class WidgetTree extends StatefulWidget {
  @override
  _WidgetTreeState createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: PreferredSize(
        child: (ResponsiveLayout.istinyLimit(context) || 
            ResponsiveLayout.isTinyHeightLimit(context) ? Container() : AppBar()), 
        preferredSize: Size(double.infinity, 100),
        ), 
        body: ResponsiveLayout(
          tiny: Container(),
          phone: PanelCenterPage(),
          tablet: Row(
            children: [
              Expanded(child: PanelLeftPage(),),
              Expanded(child: PanelCenterPage(),),
            ],
          ),
          largeTablet: Row(
            children: [
              Expanded(child: PanelLeftPage(),),
              Expanded(child: PanelCenterPage(),),
              Expanded(child: PanelRightPage(),),
            ],
          ),
          computer: Row(
            children: [
              Expanded(child: DrawerPage(),),
              Expanded(child: PanelLeftPage(),),
              Expanded(child: PanelCenterPage(),),
              Expanded(child: PanelRightPage(),),
            ],
          ),
          ),
          drawer: DrawerPage(),
    );
  }
}
