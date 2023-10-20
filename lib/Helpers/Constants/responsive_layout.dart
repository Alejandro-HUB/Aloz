import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget{
  final Widget tiny; //
  final Widget phone;
  final Widget tablet;
  final Widget largeTablet;
  final Widget computer;

  const ResponsiveLayout({super.key, 
    required this.tiny, //
    required this.phone,
    required this.tablet,
    required this.largeTablet,
    required this.computer
  });

  static const int tinyHeightLimit = 100;
  static const int tinyLimit = 270;
  static const int phoneLimit = 550;
  static const int tabletLimit = 800;
  static const int largeTabletLimit = 1100;

//Very Small Displays 
static bool isTinyHeightLimit(BuildContext context)=> 
    MediaQuery.of(context).size.height < tinyHeightLimit;
static bool istinyLimit(BuildContext context)=> 
    MediaQuery.of(context).size.width < tinyLimit;

//Phone Displays
static bool isPhone(BuildContext context)=> 
    MediaQuery.of(context).size.width < phoneLimit &&
    MediaQuery.of(context).size.width >= tinyLimit;

//Tablet Displays
static bool isTablet(BuildContext context)=> 
    MediaQuery.of(context).size.height < tabletLimit &&
    MediaQuery.of(context).size.width >= phoneLimit;

//Large Tablet Displays
static bool isLargeTablet(BuildContext context)=> 
    MediaQuery.of(context).size.height < largeTabletLimit &&
    MediaQuery.of(context).size.width >= tabletLimit;

//Computer Displays
static bool isComputer(BuildContext context)=> 
    MediaQuery.of(context).size.width >= largeTabletLimit;

  @override
  Widget build(BuildContext context){
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints){
        if(constraints.maxWidth < tinyLimit || constraints.maxHeight < tinyHeightLimit){
          return tiny;
        }
        if(constraints.maxWidth < phoneLimit){
          return phone;
        }
        if(constraints.maxWidth < tabletLimit){
          return tablet;
        }
        if(constraints.maxWidth < largeTabletLimit){
          return largeTablet;
        }
        else {
          return computer;
        }
      },
    );
  }
}