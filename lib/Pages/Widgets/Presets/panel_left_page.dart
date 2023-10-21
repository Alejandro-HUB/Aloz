// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:projectcrm/Helpers/Constants/responsive_layout.dart';
import '../../../Assets/Charts/circle_graph.dart';
import '../../../Assets/Charts/curved_chart.dart';
import '../../../Helpers/Constants/Styling.dart';

class Todo {
  String name;
  bool enable;
  Todo({this.enable = true, required this.name});
}

class PanelLeftPage extends StatefulWidget {
  const PanelLeftPage({super.key});

  @override
  _PanelLeftPageState createState() => _PanelLeftPageState();
}

class _PanelLeftPageState extends State<PanelLeftPage> {
  final List<Todo> _toDo = [
    Todo(name: "Purchase Paper", enable: true),
    Todo(name: "Refill the inventory of speakers", enable: true),
    Todo(name: "Hire someone", enable: true),
    Todo(name: "Marketing Strategy", enable: true),
    Todo(name: "Selling furniture", enable: true),
    Todo(name: "Finish the disclosure", enable: true),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (ResponsiveLayout.isComputer(context))
            Container(
              color: Styling.foreground,
              width: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: Styling.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                  ),
                ),
              ),
            ),
          SingleChildScrollView(
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
                          "Products Sold",
                          style: TextStyle(color: Styling.primaryColor),
                        ),
                        subtitle: Text(
                          "18% of Products Sold",
                          style: TextStyle(color: Styling.primaryColor),
                        ),
                        trailing: Chip(
                          label: Text(
                            "4,500",
                            style: TextStyle(color: Styling.primaryColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const LineChartSample2(),
                const PieChartSample2(),
                Padding(
                  padding: const EdgeInsets.only(
                    left: Styling.kPadding / 2,
                    right: Styling.kPadding / 2,
                    top: Styling.kPadding / 2,
                    bottom: Styling.kPadding,
                  ),
                  child: Card(
                    color: Styling.foreground,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Column(
                      children: List.generate(
                        _toDo.length,
                        (index) => CheckboxListTile(
                          title: Text(
                            _toDo[index].name,
                            style: TextStyle(color: Styling.primaryColor),
                          ),
                          value: _toDo[index].enable,
                          onChanged: (newValue) {
                            setState(() {
                              _toDo[index].enable = newValue ?? true;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
