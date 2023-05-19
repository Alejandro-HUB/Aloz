// ignore_for_file: file_names

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';

class ExcelHelper {

  void exportToExcel(List<DataRow> rows, List<DataColumn> columns, 
  String fileName, bool skipFirstColumn) {
    final excel = Excel.createExcel();
    final sheet = excel[excel.getDefaultSheet()!];

    // Write column headers
    for (var columnIndex = 0; columnIndex < columns.length; columnIndex++) {
      if (columnIndex == 0 && skipFirstColumn) {
        continue; // Skip the first column
      }
      final column = columns[columnIndex];
      final labelText = column.label is Text
          ? (column.label as Text).data
          : column.label.toString();
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: columnIndex - 1, rowIndex: 0))
          .value = labelText;
    }

    // Write data rows
    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      for (var columnIndex = 0; columnIndex < columns.length; columnIndex++) {
        if (columnIndex == 0 && skipFirstColumn) {
          continue; // Skip the first column
        }
        final cellData = row.cells.elementAt(columnIndex).child;
        final cellText =
            cellData is Text ? (cellData).data : cellData.toString();
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndex - 1, rowIndex: rowIndex + 1))
            .value = cellText;
      }
    }

    // Save the Excel file
    excel.save(fileName: '$fileName.xlsx');
  }
}



