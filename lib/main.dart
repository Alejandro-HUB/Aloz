import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/Pages/auth_page.dart';
import 'package:projectcrm/widget_tree.dart';
import 'Helpers/Constants/Styling.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Pages/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Aloz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Styling.purpleDark,
        canvasColor: Styling.purpleLight,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  bool? isLoggedIn = false;
  MainPage({this.isLoggedIn});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData && !snapshot.hasError) {
              isLoggedIn = true;
              return WidgetTree();
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Something went wrong',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              isLoggedIn = false;
              return AuthPage();
            }
          },
        ),
      );
}
