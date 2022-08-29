import 'package:flutter/material.dart';
import 'package:projectcrm/Models/ContactsModel.dart';
import '../Constants/Styling.dart';

class InfoTable extends StatelessWidget {
  List<DataColumn> columnData = [];
  List<DataRow> rowsData = [];

  InfoTable({required this.rowsData, required this.columnData});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DataTable(
          headingTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          decoration: BoxDecoration(
            color: Styling.purpleLight,
          ),
          border: TableBorder.all(
            width: 1.5,
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          columns: columnData,
          rows: rowsData),
    );
  }
}

class TableHelpers {
  static List<DataRow> buildContactListOfDataRows(
      List<Contact> rowsData, Color textColor, TextAlign textAlign) {
    List<DataRow> dataRows = [];

    for (int i = 0; i < rowsData.length; i++) {
      String fistName = rowsData[i].firstName;
      String lastName = rowsData[i].lastName;
      String emailAddress = rowsData[i].emailAddress;

      DataRow row = DataRow(
        cells: [
          DataCell(
            Row(
              children: [
                Text(
                  fistName,
                  style: TextStyle(color: textColor),
                  textAlign: textAlign,
                ),
              ],
            ),
          ),
          DataCell(Text(
            lastName,
            style: TextStyle(color: textColor),
            textAlign: textAlign,
          )),
          DataCell(Text(
            emailAddress,
            style: TextStyle(color: textColor),
            textAlign: textAlign,
          )),
        ],
      );

      dataRows.add(row);
    }

    return dataRows;
  }

  static List<DataColumn> buildListOfDataColumns(
      List<String> columnData, Color textColor, TextAlign textAlign) {
    List<DataColumn> dataColumns = [];

    for (int i = 0; i < columnData.length; i++) {
      String columnName = columnData[i];

      DataColumn column = DataColumn(
        label: Text(
          columnName,
          style: TextStyle(color: textColor),
          textAlign: textAlign,
        ),
      );

      dataColumns.add(column);
    }

    return dataColumns;
  }
}
