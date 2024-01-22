// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../Helpers/Constants/Styling.dart';

class SideBarEntry extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback action;

  const SideBarEntry({
    super.key,
    required this.title,
    required this.icon,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: action,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Styling.primaryColor,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Styling.gradient1.withOpacity(0.9),
                  Styling.gradient2.withOpacity(0.9),
                ],
              ),
            ),
            child: Icon(
              icon,
              color: Styling.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}