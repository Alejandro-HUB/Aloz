import 'package:flutter/material.dart';
import 'package:projectcrm/Assets/buttons.dart';
import '../Helpers/Constants/Styling.dart';

class SelectedContent extends StatelessWidget {
  final VoidCallback? onPressedOpen;
  final VoidCallback? onPressedExport;
  final VoidCallback? onPressedDelete;
  final String label;

  const SelectedContent({
    Key? key,
    required this.onPressedOpen,
    required this.onPressedExport,
    required this.onPressedDelete,
    required this.label,
  }) : super(key: key);

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
            backgroundColor: Styling.purpleDark,
          ),
          body: Container(
            decoration: const BoxDecoration(
              color: Styling.purpleDark,
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
                    child: MyElevatedButton(
                      onPressed: onPressedOpen,
                      label: "Open",
                      icon: const Icon(Icons.open_in_new),
                      borderRadius: BorderRadius.circular(10),
                      child: const Text("Open"),
                    ),
                  ),
                  // Export Button
                  MyElevatedButton(
                    onPressed: onPressedExport,
                    label: "Export",
                    icon: const Icon(Icons.import_export),
                    borderRadius: BorderRadius.circular(10),
                    child: const Text("Export"),
                  ),
                  // Delete Button
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: MyElevatedButton(
                      onPressed: onPressedDelete,
                      label: "Delete",
                      icon: const Icon(Icons.delete),
                      borderRadius: BorderRadius.circular(10),
                      child: const Text("Delete"),
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
