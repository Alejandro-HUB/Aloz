import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/Helpers/Firebase/user_service.dart';
import 'Pages/Login_Signup/Verification/auth_page.dart';
import 'Helpers/Constants/Styling.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Pages/Login_Signup/Verification/verify_email_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Aloz(key: alozKey)); // Use alozKey here
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<AlozState> alozKey =
    GlobalKey<AlozState>(); // Define the GlobalKey

class Aloz extends StatefulWidget {
  const Aloz({super.key});

  @override
  AlozState createState() => AlozState();
}

class AlozState extends State<Aloz> {
// Default theme

  @override
  void initState() {
    super.initState();
    _updateTheme(); // Retrieve the theme during initialization
  }

  // Method to retrieve and update the theme
  Future<void> _updateTheme() async {
    final userService = UserService();
    String theme = await userService.getUserTheme();
    setState(() {
      Styling.theme = theme;
      Styling.updateThemeValues();
    });
  }

  // Method to rebuild the entire app
  void rebuildApp(String theme) {
    setState(() {
      Styling.theme = theme;
      Styling.updateThemeValues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Aloz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Styling.background,
        canvasColor: Styling.foreground,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData && !snapshot.hasError) {
          return const VerifyEmailPage();
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(color: Styling.primaryColor),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return const AuthPage();
        }
      },
    ));
  }
}
