// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:projectcrm/Assets/buttons.dart';
import '../Helpers/Constants/Styling.dart';

class SelectedContent extends StatelessWidget {
  final VoidCallback? onPressedOpen;
  final VoidCallback? onPressedExport;
  final VoidCallback? onPressedDelete;
  final String label;

  const SelectedContent({
    super.key,
    required this.onPressedOpen,
    required this.onPressedExport,
    required this.onPressedDelete,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: Scaffold(
          appBar: AppBar(
            title: Text(label),
            automaticallyImplyLeading: false,
            backgroundColor: Styling.foreground,
            foregroundColor: Styling.primaryColor,
          ),
          body: Container(
            decoration: BoxDecoration(
              color: Styling.foreground,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Open Button
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: GradientButton(
                      gradient: LinearGradient(colors: [Styling.gradient1, Styling.gradient2]),
                      onPressed: onPressedOpen,
                      label: "Open",
                      icon: Icon(
                        Icons.open_in_new,
                        color: Styling.primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Export Button
                  GradientButton(
                    gradient: LinearGradient(colors: [Styling.gradient1, Styling.gradient2]),
                    onPressed: onPressedExport,
                    label: "Export",
                    icon: Icon(
                      Icons.import_export,
                      color: Styling.primaryColor,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // Delete Button
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GradientButton(
                      gradient: LinearGradient(colors: [Styling.gradient1, Styling.gradient2]),
                      onPressed: onPressedDelete,
                      label: "Delete",
                      icon: Icon(
                        Icons.delete,
                        color: Styling.primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
