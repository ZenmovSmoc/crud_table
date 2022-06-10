library crud_table;

import 'package:crud_table/model/data_model.dart';
import 'package:crud_table/model/data_repository.dart';
import 'package:crud_table/state/table_state.dart';
import 'package:crud_table/store/table_notifier.dart';
import 'package:crud_table/util/confirmation_dialog.dart';
import 'package:crud_table/widgets/edit_view.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

typedef ItemCreator<S> = S Function();
typedef CustomHandler<T extends DataModel> = DataCell Function(
  T,
  VoidCallback refresh,
);

typedef CustomEditHandlers<T> = Widget Function(T, TextEditingController);

typedef CustomAddHandler<T> = Future<T?> Function();
typedef CustomEditHandler<T> = Future<T?> Function(T);

class CRUDTable<T extends DataModel> extends StatefulWidget {
  final String headerTitle;
  final bool isEditable;
  final bool isDeletable;
  final bool canAddEntry;
  final DataRepository repository;
  final ItemCreator<T> instance;
  final EdgeInsetsGeometry padding;
  final double? minWidth;
  final double dataRowHeight;
  final void Function(DataModel)? onRowTap;
  final Map<Type, CustomHandler>? customDisplayHandlers;
  final Map<Type, CustomEditHandlers>? customEditHandlers;
  final CustomAddHandler<T>? customAddHandler;
  final CustomEditHandler<DataModel>? customEditHandler;
  final Widget? empty;

  const CRUDTable({
    Key? key,
    required this.headerTitle,
    required this.repository,
    required this.instance,
    this.isEditable = true,
    this.canAddEntry = true,
    this.isDeletable = true,
    this.padding = const EdgeInsets.all(12),
    this.dataRowHeight = kMinInteractiveDimension,
    this.customDisplayHandlers,
    this.minWidth,
    this.customEditHandlers,
    this.onRowTap,
    this.customAddHandler,
    this.customEditHandler,
    this.empty = const _EmptyWidget(),
  }) : super(key: key);

  @override
  _CRUDTableState createState() => _CRUDTableState();
}

class _CRUDTableState<T extends DataModel> extends State<CRUDTable> {
  late final TableStateNotifier _notifier;

  @override
  void initState() {
    super.initState();

    final displayParams = widget.instance.call().getDisplayParamsList();
    final customHandlers = widget.customDisplayHandlers?.keys.toList() ?? [];

    displayParams.removeWhere((key, value) => customHandlers.contains(value));

    _notifier = TableStateNotifier(
      repository: widget.repository,
      displayParameters: displayParams,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TableState>(
      valueListenable: _notifier,
      builder: (context, state, child) {
        if (state.tableDataSource != null) {
          state.tableDataSource!.isEditable = widget.isEditable;
          state.tableDataSource!.isDeletable = widget.isDeletable;
          state.tableDataSource!.customHandlers = widget.customDisplayHandlers;
          state.tableDataSource!.rowTapHandler = widget.onRowTap;
          state.tableDataSource!.editHandler = (model) async {
            DataModel? result;

            if (widget.customEditHandler != null) {
              result = await widget.customEditHandler!.call(model);
            } else {
              result = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => EditView(
                  type: EditType.update,
                  data: model,
                  customEditHandlers: widget.customEditHandlers,
                ),
              );
            }

            if (result != null) {
              _notifier.update(result);
            }
          };
          state.tableDataSource!.deleteHandler = (model) async {
            final result = await showConfirmationDialog(context);
            if (result != null && result) {
              _notifier.delete(model);
            }
          };
          state.tableDataSource!.refreshHandler = () {
            _notifier.init();
          };

          if (state.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error ?? ''),
                ),
              );
            });
          }
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
                horizontalMargin: 20,
                checkboxHorizontalMargin: 12,
                columnSpacing: 0,
                minWidth: widget.minWidth,
                dataRowHeight: widget.dataRowHeight,
                showCheckboxColumn: false,
                empty: widget.empty,
              ),
            ),
            if (state.updateData)
              SizedBox(
                height: 50,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.deepOrangeAccent,
                      minimumSize: const Size(88, 36),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                    onPressed: () => _notifier.init(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'New data available',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.refresh, color: Colors.white)
                      ],
                    ),
                  ),
                ),
              ),
            if (state.loading)
              Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.black45,
                child: const Center(
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
    final customHandlers = widget.customDisplayHandlers?.keys.toList() ?? [];

    params.removeWhere((key, value) => customHandlers.contains(value));

    final dropDownItems = params.entries
        .map(
          (e) => DropdownMenuItem<String>(
            value: e.key,
            child: Text(e.key),
          ),
        )
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
      if (widget.canAddEntry)
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            DataModel? result;

            if (widget.customAddHandler != null) {
              result = await widget.customAddHandler!.call();
            } else {
              result = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => EditView(
                  type: EditType.add,
                  data: widget.instance.call(),
                  customEditHandlers: widget.customEditHandlers,
                ),
              );
            }

            if (result != null) {
              _notifier.create(result);
            }
          },
        )
    ];
  }

  List<DataColumn> buildDataColumns() {
    final List<DataColumn> columns = [];
    final params = widget.instance.call().getDisplayParamsList();

    params.forEach(
      (element, type) {
        final isCustomType =
            widget.customDisplayHandlers?.containsKey(type) ?? false;

        columns.add(
          DataColumn2(
            label: Text(element.toString()),
            onSort: isCustomType
                ? null
                : (columnIndex, ascending) => _notifier.sort(
                      key: element,
                      columnIndex: columnIndex,
                      ascending: ascending,
                    ),
          ),
        );
      },
    );

    if (widget.isEditable || widget.isDeletable) {
      columns.add(
        const DataColumn2(label: Text('Actions'), size: ColumnSize.S),
      );
    }

    columns.insert(0, const DataColumn2(label: Text(''), size: ColumnSize.S));

    return columns;
  }
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No records'));
  }
}
