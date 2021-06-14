library crud_table;

import 'package:crud_table/model/data_model.dart';
import 'package:crud_table/model/data_repository.dart';
import 'package:crud_table/state/table_state.dart';
import 'package:crud_table/store/table_notifier.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:data_table_2/paginated_data_table_2.dart';
import 'package:flutter/material.dart';

import 'util/confirmation_dialog.dart';

typedef ItemCreator<S> = S Function();

class CRUDTable<T extends DataModel> extends StatefulWidget {
  final String headerTitle;
  final bool isEditable;
  final DataRepository repository;
  final ItemCreator<T> instance;
  final EdgeInsetsGeometry padding;

  const CRUDTable({
    Key? key,
    required this.headerTitle,
    this.isEditable = true,
    required this.repository,
    required this.instance,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  _CRUDTableState createState() => _CRUDTableState();
}

class _CRUDTableState extends State<CRUDTable> {
  late final TableStateNotifier _notifier;

  @override
  void initState() {
    super.initState();

    _notifier = TableStateNotifier(
      repository: widget.repository,
      displayParameters: widget.instance.call().getDisplayParamsList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TableState>(
      valueListenable: _notifier,
      builder: (context, state, child) {
        if (state.tableDataSource != null) {
          state.tableDataSource!.isEditable = widget.isEditable;
          state.tableDataSource!.editHandler = (model) {
            print(model);
          };
          state.tableDataSource!.deleteHandler = (model) async {
            final result = await showConfirmationDialog(context);
            if (result != null && result) {
              _notifier.delete(model);
            }
          };
        }

        return Stack(
          children: [
            Padding(
              padding: widget.padding,
              child: PaginatedDataTable2(
                header: Text(widget.headerTitle),
                columns: buildDataColumns(),
                actions: buildActions(filterBy: state.filterBy),
                rowsPerPage: state.rowsPerPage,
                onRowsPerPageChanged: _notifier.rowsPerPage,
                sortColumnIndex: state.sortColumnIndex,
                sortAscending: state.sortAscending,
                source: state.tableDataSource!,
                fit: FlexFit.tight,
                horizontalMargin: 20,
                checkboxHorizontalMargin: 12,
                columnSpacing: 0,
              ),
            ),
            if (state.loading)
              Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.black45,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
          ],
        );
      },
    );
  }

  List<Widget> buildActions({String? filterBy}) {
    final params = widget.instance.call().getDisplayParamsList();

    final dropDownItems = params.entries
        .map((e) => DropdownMenuItem<String>(
              value: e.key,
              child: Text(e.key),
            ))
        .toList();

    return [
      DropdownButton<String>(
        items: dropDownItems,
        value: filterBy,
        onChanged: (val) => _notifier.setFilterKey(val!),
      ),
      SizedBox(
        width: 150,
        child: TextField(
          decoration: const InputDecoration(
            labelText: 'Filter',
            hintText: 'Filter',
            border: OutlineInputBorder(),
          ),
          onChanged: _notifier.filter,
        ),
      ),
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: _notifier.init,
      ),
      IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          final model = widget.instance.call();
          _notifier.create(model);
        },
      )
    ];
  }

  List<DataColumn> buildDataColumns() {
    List<DataColumn> columns = [];
    final params = widget.instance.call().getDisplayParamsList();

    params.forEach(
      (element, type) {
        // if (type == GeoPoint || type == Image) {
        if (type == Image) {
          columns.add(
            DataColumn2(
              label: Text("${element.toString()}"),
            ),
          );
        } else {
          columns.add(
            DataColumn2(
              label: Text("${element.toString()}"),
              onSort: (columnIndex, ascending) => _notifier.sort<dynamic>(
                element,
                columnIndex,
                ascending,
              ),
            ),
          );
        }
      },
    );

    if (widget.isEditable) {
      columns.add(
        const DataColumn2(label: Text('Actions'), size: ColumnSize.S),
      );
    }

    return columns;
  }
}
