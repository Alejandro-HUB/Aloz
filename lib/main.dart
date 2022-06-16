import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  @override  
  Widget build (BuildContext context) => Scaffold(
    body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return WidgetTree();
        }
        else {
          return LoginWidget();
        }
      },
    ),
  );
}

