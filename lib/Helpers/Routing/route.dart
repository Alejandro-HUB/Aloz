import 'package:flutter/material.dart';
import '../../Pages/Home/HomePage.dart';
import '../Constants/responsive_layout.dart';

class RoutePage extends StatelessWidget {
  final Widget appBar;
  final Widget page;
  final bool showDrawer;

  const RoutePage({
    Key? key,
    required this.appBar,
    required this.page,
    required this.showDrawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        // ignore: sort_child_properties_last
        child: (ResponsiveLayout.istinyLimit(context) ||
                ResponsiveLayout.isTinyHeightLimit(context)
            ? Container()
            : appBar),
        // ignore: prefer_const_constructors
        preferredSize: Size(double.infinity, 100),
      ),
      body: ResponsiveLayout(
          //Small Sized Screen -> Do not show UI
          tiny: Container(),
          //Phone Sized Screen
          phone: page,
          //Tablet Sized Screen
          tablet: Row(
            children: [
              Expanded(
                child: page,
              ),
            ],
          ),
          //Large Tabled Sized Screen
          largeTablet: Row(
            children: [
              Expanded(
                child: page,
              ),
            ],
          ),
          //Computer Sized Screen
          computer: Row(
            children: [
              if(showDrawer)
                const Expanded(
                  child: HomePage(),
                ),
              Expanded(
                child: page,
              ),
            ],
          )),
      drawer: const HomePage(),
    );
  }
}
