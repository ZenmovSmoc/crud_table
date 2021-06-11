library crud_table;

import 'package:crud_table/model/data_model.dart';
import 'package:crud_table/model/data_repository.dart';
import 'package:crud_table/state/table_state.dart';
import 'package:crud_table/store/table_notifier.dart';
import 'package:flutter/material.dart';

typedef ItemCreator<S> = S Function();

class CRUDTable<T extends DataModel> extends StatefulWidget {
  final String headerTitle;
  final bool isEditable;
  final DataRepository repository;
  final ItemCreator<T> instance;

  const CRUDTable({
    Key? key,
    required this.headerTitle,
    required this.isEditable,
    required this.repository,
    required this.instance,
  }) : super(key: key);

  @override
  _CRUDTableState createState() => _CRUDTableState();
}

class _CRUDTableState extends State<CRUDTable> {
  late final TableStateNotifier _notifier;

  @override
  void initState() {
    super.initState();

    _notifier = TableStateNotifier(repository: widget.repository);
  }

  List<DataColumn> createDataColumns() {
    List<DataColumn> columns = [];
    final map = widget.instance.call().getDisplayParamsList();

    map.forEach(
      (element, type) {
        // if (type == GeoPoint || type == Image) {
        if (type == Image) {
          columns.add(
            DataColumn(
              label: Text("${element.toString()}"),
            ),
          );
        } else {
          columns.add(
            DataColumn(
              label: Text("${element.toString()}"),
              // onSort: (columnIndex, ascending) => _provider.sort<dynamic>(
              //   element,
              //   columnIndex,
              //   ascending,
              // ),
            ),
          );
        }
      },
    );

    if (widget.isEditable) {
      columns.insert(
        0,
        const DataColumn(
          label: Text(''),
        ),
      );

      columns.add(
        const DataColumn(
          label: Text(''),
        ),
      );
    }

    columns.insert(
      0,
      const DataColumn(
        label: Text(''),
      ),
    );

    return columns;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TableState>(
      valueListenable: _notifier,
      builder: (context, state, child) {
        return SingleChildScrollView(
          child: Stack(
            children: [
              PaginatedDataTable(
                header: Text(widget.headerTitle),
                columns: createDataColumns(),
                columnSpacing: 40,
                dataRowHeight: 100,
                // actions: _buildActions(context),
                rowsPerPage: state.rowsPerPage,
                onRowsPerPageChanged: _notifier.rowsPerPage,
                sortColumnIndex: state.sortColumnIndex,
                sortAscending: state.sortAscending,
                source: state.tableDataSource!,
              )
            ],
          ),
        );
      },
    );
  }
}
