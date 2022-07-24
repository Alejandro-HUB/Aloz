import 'package:flutter/material.dart';
import 'package:projectcrm/Models/ContactsModel.dart';
import '../Constants/Styling.dart';

class TableHelpers {
  static List<DataRow> buildContactListOfDataRows(BuildContext context,
      List<Contact> rowsData, Color textColor, TextAlign textAlign) {
    List<DataRow> dataRows = [];

    for (int i = 0; i < rowsData.length; i++) {
      String fistName = rowsData[i].firstName;
      String lastName = rowsData[i].lastName;

      DataRow row = DataRow(
        cells: [
          DataCell(Text(
            fistName,
            style: TextStyle(color: textColor),
            textAlign: textAlign,
          )),
          DataCell(Text(
            lastName,
            style: TextStyle(color: textColor),
            textAlign: textAlign,
          )),
        ],
      );

      dataRows.add(row);
    }

    return dataRows;
  }
}
