import 'package:flutter/material.dart';
import 'package:projectcrm/Helpers/DB/mongodb.dart';
import 'package:projectcrm/widget_tree.dart';
import 'Helpers/Constants/Styling.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabase.Connect();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Styling.purpleDark,
        canvasColor: Styling.purpleLight,
      ),
      home: WidgetTree(),
    );
  }
}

