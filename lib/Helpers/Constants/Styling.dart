// ignore_for_file: file_names
import 'package:flutter/material.dart';

class Styling{
  static const double kPadding = 10.0;
  static const Color purpleLight = Color(0XFF1e224c);
  static const Color purpleDark = Color(0XFF0d193e);
  static const Color purpleBorder = Color(0xFF575C9E);
  static const Color orangeLight = Color(0xfff8b250);
  static const Color orangeDark = Color(0xffec8d2f);
  static const Color redLight = Color(0xffff5182);
  static const Color redDark = Color(0xfff44336);
  static const Color blueLight = Color(0xff0293ee);
  static const Color greenLight = Color(0xff13d38e);
  static const Color logoColor = Color.fromARGB(255 , 0, 210, 255);

  // Theme
  static String theme = "aloz";

  // Theme colors
  static String logo = theme == "light" ? lightLogo : theme == "dark" ? darkLogo : alozLogo;
  static Color primaryColor = theme == "light" ? lightPrimaryColor : theme == "dark" ? darkPrimaryColor : alozPrimaryColor;
  static Color gradient1 = theme == "light" ? lightGradient1 : theme == "dark" ? darkGradient1 : alozGradient1;
  static Color gradient2 = theme == "light" ? lightGradient2 : theme == "dark" ? darkGradient2 : alozGradient2;
  static Color foreground = theme == "light" ? lightForeground : theme == "dark" ? darkForeground : alozForeground;
  static Color background = theme == "light" ? lightBackground : theme == "dark" ? darkBackground : alozBackground;

  // Aloz Theme
  static const String alozLogo = "logo_dark.png";
  static const Color alozPrimaryColor = Colors.white;
  static const Color alozGradient1 = redLight;
  static const Color alozGradient2 = orangeDark;
  static const Color alozForeground = purpleLight;
  static const Color alozBackground = purpleDark;

  // Light Theme
  static const String lightLogo = "logo_light.png";
  static const Color lightPrimaryColor = Colors.black;
  static const Color lightGradient1 = logoColor;
  static const Color lightGradient2 = logoColor;
  static const Color lightForeground = Colors.white;
  static const Color lightBackground = Color.fromARGB(243, 236, 235, 235);

  // Dark Theme
  static const String darkLogo = "logo_dark.png";
  static const Color darkPrimaryColor = Colors.white;
  static const Color darkGradient1 = logoColor;
  static const Color darkGradient2 = logoColor;
  static const Color darkForeground = Colors.black;
  static const Color darkBackground = Color.fromARGB(243, 41, 41, 41);
}