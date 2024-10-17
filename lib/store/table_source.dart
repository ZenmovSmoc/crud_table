import 'package:crud_table/crud_table.dart';
import 'package:crud_table/model/data_model.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore_for_file: avoid_setters_without_getters
// Generic class `DataSource` extending `DataTableSource` to handle tabular data display.
// It is constrained to types extending `DataModel`, ensuring it works with a specific data model.
class DataSource<T extends DataModel> extends DataTableSource {
  // Constructor for DataSource that accepts a list of data of type T and an optional last update time.
  DataSource(this.data, {this.lastUpdateTime});
  // List of data to be managed by the DataSource.
  final List<T> data;
  // Optional property to store the last update time of the data.
  final DateTime? lastUpdateTime;
  // Flags indicating different behaviors of the data table.
  late bool _isEditable; // Whether the table rows are editable.
  late bool _isDeletable; // Whether the rows can be deleted.
  late bool _isQRDisplayable; // Whether QR codes should be displayed.
  late bool
      _isLabelDisplayFirstColumn; // Whether the first column should display a label.

  // Functions or handlers for different row operations.
  late Function(T) _editHandler; // Handler function for editing rows.
  late Function(T) _deleteHandler; // Handler function for deleting rows.
  late Function(T)
      _qrHandler; // Handler function for displaying QR codes for rows.
  late VoidCallback
      _refreshHandler; // Function to trigger a refresh of the table.
  late VoidCallback _refreshOneRowHandler;

  // Optional handler for when a row is tapped.
  Function(T)? _onRowTap;

  // A map of custom handlers for specific types, allowing specialized behavior per row type.
  late Map<Type, CustomHandler>? _customHandlers;

  // Controller for handling pagination of the table.
  late PaginatorController _controller;

  late bool _isFetchInRangeDay;

  late DateTime? startDay;

  late DateTime? endDay;

  // Setter for the PaginatorController. Assigns the pagination controller for the data source.
  set paginatorController(PaginatorController controller) {
    _controller = controller;
  }

  // Getter for the PaginatorController, returns the assigned controller.
  PaginatorController get paginatorController => _controller;

  // Setter for the edit handler. Allows setting a function to handle row edits.
  set editHandler(Function(T) handler) {
    _editHandler = handler;
  }

  // Setter for the delete handler. Allows setting a function to handle row deletions.
  set deleteHandler(Function(T) handler) {
    _deleteHandler = handler;
  }

  // Setter for the QR handler. Allows setting a function to handle QR code display for rows.
  set qrHandler(Function(T) handler) {
    _qrHandler = handler;
  }

  // Setter for the refresh handler. Assigns a callback function to refresh the table.
  set refreshHandler(VoidCallback handler) {
    _refreshHandler = handler;
  }

  // Setter for the editability flag. Defines whether rows in the table are editable.
  set isEditable(bool editable) {
    _isEditable = editable;
  }

  // Setter for the deletability flag. Defines whether rows in the table can be deleted.
  set isDeletable(bool deletable) {
    _isDeletable = deletable;
  }

  // Setter for the QR display flag. Defines whether a QR code should be displayed for rows.
  set isQRDisplayable(bool qrDisplayable) {
    _isQRDisplayable = qrDisplayable;
  }

  // Setter for the label display flag. Determines whether the first column should show a label.
  set isLabelDisplayFirstColumn(bool labelDisplayFirstColumn) {
    _isLabelDisplayFirstColumn = labelDisplayFirstColumn;
  }

  // Setter for custom handlers. Allows assigning custom logic for handling different row types.
  set customHandlers(Map<Type, CustomHandler>? customHandlers) {
    _customHandlers = customHandlers;
  }

  // Setter for the row tap handler. Allows assigning a function to handle row tap events.
  set rowTapHandler(void Function(T)? handler) {
    _onRowTap = handler;
  }

  set isFetchInRangeDay(bool value) {
    _isFetchInRangeDay = value;
  }

  bool get isFetchingInRangeDay => _isFetchInRangeDay;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);

    final T item = data[index];
    print("data: $item");

    return DataRow.byIndex(
      index: index,
      cells: createDataCell(item),
      onSelectChanged: _onRowTap != null
          ? (selected) {
              _onRowTap?.call(item);
            }
          : null,
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;

  /// Creates a list of `DataCell` widgets for each item of type `T`.
  ///
  /// The function generates a row of `DataCell`s based on the properties of the `item`
  /// and the display parameters specified in the `getDisplayParamsList()` method of `T`.
  /// It customizes the content of the `DataCell` based on the type of data being displayed,
  /// such as `DateTime`, `Image`, or any custom handlers provided. Additionally, it adds
  /// edit, delete, and QR code buttons if the corresponding flags are enabled.
  ///
  /// - [item]: The data item of type `T` for which the data cells are created.
  ///
  /// Returns a list of `DataCell` widgets representing the data and action buttons for the item.
  List<DataCell> createDataCell(T item) {
    // List to hold the created `DataCell`s.
    final List<DataCell> cells = [];
    // Retrieve the display parameters and data map for the item.
    final params =
        item.getDisplayParamsList(); // List of parameters to display.
    final map = item.toMap(); // Map of the item's data properties.
    // Iterate through each display parameter and generate the corresponding `DataCell`.
    params.forEach(
      (element, type) {
        if (type == DateTime) {
          cells.add(
            _dateTimeCell(map[element]),
          );
        } else if (type == Image) {
          cells.add(
            _imageCell(map[element]),
          );
        } else if (_customHandlers != null &&
            _customHandlers!.containsKey(type)) {
          final handler = _customHandlers?[type];

          final e = handler!.call(item, _refreshHandler);
          cells.add(e);
        } else {
          cells.add(
            _defaultDataCell(map[element]),
          );
        }
      },
    );
    // Add action buttons (QR code, edit, delete) if any of the corresponding flags are enabled.
    if (_isEditable || _isDeletable || _isQRDisplayable) {
      cells.add(
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display QR code button if enabled.
              if (_isQRDisplayable)
                Flexible(
                  child: IconButton(
                    icon: const Icon(Icons.qr_code, color: Colors.black),
                    onPressed: () {
                      _qrHandler(item);
                    },
                  ),
                ),
              // Display edit button if enabled.
              if (_isEditable)
                Flexible(
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _editHandler(item);
                    },
                  ),
                ),
              // Display delete button if enabled.
              if (_isDeletable)
                Flexible(
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteHandler(item);
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    }
    // If displaying labels in the first column is enabled, insert a label as the first `DataCell`.
    if (_isLabelDisplayFirstColumn) {
      if (lastUpdateTime == null) {
        // If last update time is null, insert an empty cell.
        cells.insert(0, const DataCell(Text('')));
      } else {
        // If the item was created or updated after the last update time, insert a notice label.
        if (map['createdAt'] != null &&
            lastUpdateTime!.isBefore(map['createdAt'])) {
          cells.insert(0, const DataCell(_TableNoticeWidget('New Data')));
        } else if (map['updatedAt'] != null &&
            lastUpdateTime!.isBefore(map['updatedAt'])) {
          cells.insert(0, const DataCell(_TableNoticeWidget('Latest Update')));
        } else {
          cells.insert(0, const DataCell(Text('')));
        }
      }
    }
    // Return the list of generated `DataCell`s.
    return cells;
  }

  DataCell _dateTimeCell(DateTime? data) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return data != null
        ? DataCell(
            Text(formatter.format(data)),
          )
        : const DataCell(Text(''));
  }

  /// Creates a `DataCell` widget containing an image fetched from a network URL.
  ///
  /// If the image fails to load, it displays a fallback icon (`Icons.broken_image`).
  ///
  /// - [data]: The URL of the image to be displayed inside the `DataCell`.
  ///
  /// Returns a `DataCell` containing a `SizedBox` with the image or an error icon if the image fails to load.
  DataCell _imageCell(String data) {
    return DataCell(
      // `SizedBox` to define the fixed dimensions of the image cell.
      SizedBox(
        height: 90,
        width: 90,
        // `Image` widget to display the image from the provided network URL.
        child: Image(
          image:
              NetworkImage(data), // Loads the image from the given network URL.
          fit: BoxFit
              .contain, // Ensures the image fits within the bounds while preserving its aspect ratio.
          // If an error occurs (e.g., image not found), display a broken image icon.
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        ),
      ),
    );
  }

  DataCell _defaultDataCell(dynamic data) {
    return DataCell(
      Text('${data ?? ''}'),
    );
  }
}

class _TableNoticeWidget extends StatelessWidget {
  final String text;
  const _TableNoticeWidget(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepOrange,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
