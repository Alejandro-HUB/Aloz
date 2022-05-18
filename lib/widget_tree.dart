import 'package:flutter/material.dart';
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
          phone: Container(),
          tablet: Container(),
          largeTablet: Container(),
          computer: Container(),
          ),
          drawer: DrawerPage(),
    );
  }
}
