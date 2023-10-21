// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../../../Assets/Charts/linear_graph.dart';
import '../../../Helpers/Constants/Styling.dart';

class Person {
  String name;
  Color color;
  Person({required this.name, required this.color});
}

class PanelCenterPage extends StatefulWidget {
  const PanelCenterPage({super.key});

  @override
  _PanelCenterPageState createState() => _PanelCenterPageState();
}

class _PanelCenterPageState extends State<PanelCenterPage> {
  final List<Person> _persons = [
    Person(name: "Alejandro Lopez", color: Styling.orangeLight),
    Person(name: "Fariha Odling", color: Styling.gradient1),
    Person(name: "Viola Willis", color: Styling.blueLight),
    Person(name: "Emmet Forrest", color: Styling.orangeLight),
    Person(name: "Nick Jarvis", color: Styling.greenLight),
    Person(name: "Amit Clayela", color: Styling.orangeLight),
    Person(name: "Amelie Lens", color: Styling.gradient1),
    Person(name: "Campbell Britton", color: Styling.blueLight),
    Person(name: "Haley Mellor", color: Styling.gradient1),
    Person(name: "Harlen Higgins", color: Styling.greenLight),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: Styling.kPadding / 2,
                right: Styling.kPadding / 2,
                top: Styling.kPadding / 2,
              ),
              child: Card(
                color: Styling.foreground,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ListTile(
                    title: Text(
                      "Products Available",
                      style: TextStyle(color: Styling.primaryColor),
                    ),
                    subtitle: Text(
                      "82% of the Products Avail.",
                      style: TextStyle(color: Styling.primaryColor),
                    ),
                    trailing: Chip(
                      label: Text(
                        "20,500",
                        style: TextStyle(color: Styling.primaryColor),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            BarChartSample2(),
            Padding(
              padding: const EdgeInsets.only(
                top: Styling.kPadding,
                left: Styling.kPadding / 2,
                right: Styling.kPadding / 2,
                bottom: Styling.kPadding,
              ),
              child: Card(
                color: Styling.foreground,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: List.generate(
                    _persons.length,
                    (index) => ListTile(
                      leading: CircleAvatar(
                        radius: 15,
                        backgroundColor: _persons[index].color,
                        child: Text(
                          _persons[index].name.substring(0, 1),
                          style: TextStyle(color: Styling.primaryColor),
                        ),
                      ),
                      title: Text(
                        _persons[index].name,
                        style: TextStyle(color: Styling.primaryColor),
                      ),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.message,
                          color: Styling.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
