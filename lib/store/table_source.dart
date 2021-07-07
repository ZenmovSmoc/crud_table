import 'package:crud_table/model/data_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../crud_table.dart';

// ignore_for_file: avoid_setters_without_getters
class DataSource<T extends DataModel> extends DataTableSource {
  DataSource(this.data, {this.lastUpdateTime});

  final List<T> data;

  final DateTime? lastUpdateTime;
  late bool _isEditable;

  late Function(T) _editHandler;
  late Function(T) _deleteHandler;
  late VoidCallback _refreshHandler;

  late Map<Type, CustomHandler>? _customHandlers;

  set editHandler(Function(T) handler) {
    _editHandler = handler;
  }

  set deleteHandler(Function(T) handler) {
    _deleteHandler = handler;
  }

  set refreshHandler(VoidCallback handler) {
    _refreshHandler = handler;
  }

  set isEditable(bool editable) {
    _isEditable = editable;
  }

  set customHandlers(Map<Type, CustomHandler>? customHandlers) {
    _customHandlers = customHandlers;
  }

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);

    final T item = data[index];

    return DataRow.byIndex(
      index: index,
      cells: createDataCell(item),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;

  List<DataCell> createDataCell(T item) {
    final List<DataCell> cells = [];
    final params = item.getDisplayParamsList();
    final map = item.toMap();

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
          final handler = _customHandlers![type];

          final e = handler!.call(item, _refreshHandler);
          cells.add(e);
        } else {
          cells.add(
            _defaultDataCell(map[element]),
          );
        }
      },
    );

    if (_isEditable) {
      cells.add(
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _editHandler(item);
                  },
                ),
              ),
              Flexible(
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteHandler(item);
                  },
                ),
              )
            ],
          ),
        ),
      );
    }

    // ToDo: 更新時に
    if (lastUpdateTime == null) {
      cells.insert(0, const DataCell(Text('')));
    } else {
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

  DataCell _imageCell(String data) {
    return DataCell(
      SizedBox(
        height: 90,
        width: 90,
        child: Image(
          image: NetworkImage(data),
          fit: BoxFit.contain,
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
