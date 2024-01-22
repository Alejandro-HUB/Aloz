import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectcrm/Assets/buttons.dart';
import 'package:projectcrm/Helpers/Constants/Styling.dart';
import 'package:projectcrm/Helpers/Firebase/user_service.dart';
import 'package:projectcrm/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserService _userService = UserService();

  void _updateTheme(String theme) async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Update the theme in Firestore
      _userService.updateTheme(theme);
      // Access the AlozState and trigger a rebuild of the whole app
      alozKey.currentState?.rebuildApp(theme);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styling.foreground,
        foregroundColor: Styling.primaryColor,
        title: Text(
          'Settings',
          style: TextStyle(color: Styling.primaryColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                'Change App Theme:',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Styling.primaryColor),
              ),
              const SizedBox(height: 40),
              // Light theme
              GradientButton(
                gradient: LinearGradient(
                    colors: [Styling.gradient1, Styling.gradient2]),
                label: 'Light Theme',
                width: 150,
                icon: Icon(
                  Icons.light_mode,
                  color: Styling.primaryColor,
                ),
                onPressed: () {
                  // Set the theme to 'light'
                  _updateTheme('light');
                },
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 40),
              // Dark theme
              GradientButton(
                gradient: LinearGradient(
                    colors: [Styling.gradient1, Styling.gradient2]),
                label: 'Dark Theme',
                width: 150,
                icon: Icon(
                  Icons.dark_mode,
                  color: Styling.primaryColor,
                ),
                onPressed: () {
                  // Set the theme to 'dark'
                  _updateTheme('dark');
                },
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 40),
              // Aloz theme
              GradientButton(
                gradient: LinearGradient(
                    colors: [Styling.gradient1, Styling.gradient2]),
                label: 'Aloz Theme',
                width: 150,
                icon: Icon(
                  Icons.burst_mode,
                  color: Styling.primaryColor,
                ),
                onPressed: () {
                  // Set the theme to 'aloz'
                  _updateTheme('aloz');
                },
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
