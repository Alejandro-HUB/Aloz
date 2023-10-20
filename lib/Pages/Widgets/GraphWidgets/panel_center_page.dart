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
    Person(name: "Fariha Odling", color: Styling.redLight),
    Person(name: "Viola Willis", color: Styling.blueLight),
    Person(name: "Emmet Forrest", color: Styling.orangeLight),
    Person(name: "Nick Jarvis", color: Styling.greenLight),
    Person(name: "Amit Clayela", color: Styling.orangeLight),
    Person(name: "Amelie Lens", color: Styling.redLight),
    Person(name: "Campbell Britton", color: Styling.blueLight),
    Person(name: "Haley Mellor", color: Styling.redLight),
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
                color: Styling.purpleLight,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const SizedBox(
                  width: double.infinity,
                  child: ListTile(
                    title: Text(
                      "Products Available",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "82% of the Products Avail.",
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Chip(
                      label: Text(
                        "20,500",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const BarChartSample2(),
            Padding(
              padding: const EdgeInsets.only(
                top: Styling.kPadding,
                left: Styling.kPadding / 2,
                right: Styling.kPadding / 2,
                bottom: Styling.kPadding,
              ),
              child: Card(
                color: Styling.purpleLight,
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
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        _persons[index].name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.message,
                          color: Colors.white,
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
