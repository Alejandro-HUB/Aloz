import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:projectcrm/responsive_layout.dart';
import '../Helpers/Constants/Styling.dart';
import 'curved_chart.dart';
import 'circle_graph.dart';

class Todo {
  String name;
  bool enable;
  Todo({this.enable = true, required this.name});
}

class PanelLeftPage extends StatefulWidget {
  @override
  _PanelLeftPageState createState() => _PanelLeftPageState();
}

class _PanelLeftPageState extends State<PanelLeftPage> {
  List<Todo> _toDo = [
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
              color: Styling.purpleLight,
              width: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: Styling.purpleDark,
                  borderRadius: BorderRadius.only(
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
                    color: Styling.purpleLight,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      width: double.infinity,
                      child: ListTile(
                        title: Text(
                          "Products Sold",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "18% of Products Sold",
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: Chip(
                          label: Text(
                            "4,500",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                LineChartSample2(),
                PieChartSample2(),
                Padding(
                  padding: const EdgeInsets.only(
                    left: Styling.kPadding / 2,
                    right: Styling.kPadding / 2,
                    top: Styling.kPadding / 2,
                    bottom: Styling.kPadding,
                  ),
                  child: Card(
                    color: Styling.purpleLight,
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
                            style: TextStyle(color: Colors.white),
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
