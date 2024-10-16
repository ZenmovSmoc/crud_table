library crud_table;

import 'package:crud_table/model/data_model.dart';
import 'package:crud_table/model/data_repository.dart';
import 'package:crud_table/state/table_state.dart';
import 'package:crud_table/store/table_notifier.dart';
import 'package:crud_table/util/confirmation_dialog.dart';
import 'package:crud_table/widgets/edit_view.dart';
import 'package:crud_table/widgets/qr_view.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef ItemCreator<S> = S Function();
typedef CustomHandler<T extends DataModel> = DataCell Function(
  T,
  VoidCallback refresh,
);

typedef CustomEditHandlers<T> = Widget Function(T, TextEditingController);

typedef CustomAddHandler<T> = Future<T?> Function();
typedef CustomEditHandler<T> = Future<T?> Function(T);

class CRUDTable<T extends DataModel> extends StatefulWidget {
  /// A widget that provides a customizable CRUD (Create, Read, Update, Delete) table for managing data models.
  ///
  /// The [CRUDTable] widget displays data in a table format and provides options for
  /// editing, deleting, and adding new entries. It uses a [PaginatedDataTable2] widget
  /// to enable pagination, sorting, and filtering. This table is generic and works with
  /// any model that extends [DataModel].
  ///
  /// ### Type Parameter:
  /// - `T`: A type that extends [DataModel], representing the type of data displayed in the table.
  ///
  /// ### Constructor Parameters:
  ///
  /// #### Required:
  /// - [headerTitle]: A [String] representing the title displayed at the top of the table.
  /// - [repository]: A [DataRepository] that manages the data to be displayed in the table.
  /// - [instance]: A function of type [ItemCreator] that creates an instance of the data model.
  ///
  /// #### Optional:
  /// - [isEditable]: A [bool] that specifies if the table entries are editable. Defaults to `true`.
  /// - [canAddEntry]: A [bool] that specifies if new entries can be added to the table. Defaults to `true`.
  /// - [isDeletable]: A [bool] that specifies if the table entries are deletable. Defaults to `true`.
  /// - [isLabelDisplayFirstColumn]: A [bool] that determines if the label is displayed in the first column. Defaults to `true`.
  /// - [isDisplayRefreshButton]: A [bool] that determines if a refresh button is displayed. Defaults to `true`.
  /// - [isQRDisplayable]: A [bool] that enables QR code display functionality for each entry. Defaults to `false`.
  /// - [padding]: The padding around the table. Defaults to `EdgeInsets.all(12)`.
  /// - [dataRowHeight]: A [double] representing the height of each data row. Defaults to [kMinInteractiveDimension].
  /// - [minWidth]: A [double] that sets the minimum width of the table.
  /// - [customDisplayHandlers]: A [Map] of custom handlers for displaying specific types of data.
  /// - [customEditHandlers]: A [Map] of custom handlers for editing specific types of data.
  /// - [onRowTap]: A callback function triggered when a row is tapped, receiving a [DataModel] as a parameter.
  /// - [customAddHandler]: A custom handler for adding new entries.
  /// - [customEditHandler]: A custom handler for editing existing entries.
  /// - [jumpToFirstPage]: A [bool] that determines if the table should jump to the first page when data changes. Defaults to `false`.
  /// - [empty]: A [Widget] displayed when there are no records in the table. Defaults to [_EmptyWidget].
  ///
  /// ### Example:
  ///
  /// ```dart
  /// CRUDTable<DataModel>(
  ///   headerTitle: 'User List',
  ///   repository: userRepository,
  ///   instance: () => UserModel(),
  ///   customDisplayHandlers: {
  ///     CustomType: (data, refresh) => CustomDisplayWidget(data, refresh),
  ///   },
  ///   customEditHandlers: {
  ///     CustomType: (data, controller) => CustomEditWidget(data, controller),
  ///   },
  ///   customAddHandler: () async => await addHandler(),
  ///   customEditHandler: (data) async => await editHandler(data),
  /// );
  /// ```
  ///
  /// This widget makes it easy to create dynamic tables with custom display and editing logic.
  const CRUDTable({
    Key? key,
    required this.headerTitle,
    required this.repository,
    required this.instance,
    this.isEditable = true,
    this.canAddEntry = true,
    this.isDeletable = true,
    this.isLabelDisplayFirstColumn = true,
    this.isDisplayRefreshButton = true,
    this.isQRDisplayable = false,
    this.padding = const EdgeInsets.all(12),
    this.dataRowHeight = kMinInteractiveDimension,
    this.customDisplayHandlers,
    this.minWidth,
    this.customEditHandlers,
    this.onRowTap,
    this.customAddHandler,
    this.customEditHandler,
    this.jumpToFirstPage = false,
    this.empty = const _EmptyWidget(),
    this.onSelectedStartDay,
    this.onSelectedEndDay,
    this.startDay,
    this.endDay,
    this.isFetchInRangeDay = false,
  }) : super(key: key);

  /// The title displayed at the top of the table.
  final String headerTitle;

  /// Whether the table entries are editable.
  final bool isEditable;

  /// Whether the table entries are deletable.
  final bool isDeletable;

  /// Whether the table entries can display QR codes.
  final bool isQRDisplayable;

  /// Whether new entries can be added to the table.
  final bool canAddEntry;

  /// Whether the table should jump to the first page when data changes.
  final bool jumpToFirstPage;

  /// The repository that manages the data for the table.
  final DataRepository repository;

  /// A function that creates an instance of the data model.
  final ItemCreator<T> instance;

  /// The padding around the table.
  final EdgeInsetsGeometry padding;

  /// The minimum width of the table.
  final double? minWidth;

  /// The height of each data row.
  final double dataRowHeight;

  /// A callback function that is triggered when a row is tapped.
  final void Function(DataModel)? onRowTap;

  /// A map of custom handlers for displaying specific types of data.
  final Map<Type, CustomHandler>? customDisplayHandlers;

  /// A map of custom handlers for editing specific types of data.
  final Map<Type, CustomEditHandlers>? customEditHandlers;

  /// A custom handler for adding new entries.
  final CustomAddHandler<T>? customAddHandler;

  /// A custom handler for editing existing entries.
  final CustomEditHandler<DataModel>? customEditHandler;

  /// A widget displayed when there are no records in the table.
  final Widget? empty;

  /// Whether to display the label in the first column of the table.
  final bool isLabelDisplayFirstColumn;

  /// Whether to display the refresh button.
  final bool isDisplayRefreshButton;

  final DateTime? startDay;

  final DateTime? endDay;

  final VoidCallback? onSelectedStartDay;

  final VoidCallback? onSelectedEndDay;

  final bool isFetchInRangeDay;

  @override
  _CRUDTableState<T> createState() => _CRUDTableState<T>();
}

class _CRUDTableState<T extends DataModel> extends State<CRUDTable<T>> {
  late final TableStateNotifier _notifier;
  late final PaginatorController controller;
  final startDayController = TextEditingController();

  final endDayController = TextEditingController();

  String formatDate = 'yyyy/MM/dd';

  @override
  void initState() {
    super.initState();
    final displayParams = widget.instance().getDisplayParamsList();
    final customHandlers = widget.customDisplayHandlers?.keys.toList() ?? [];

    displayParams.removeWhere((key, value) => customHandlers.contains(value));

    _notifier = TableStateNotifier(
      repository: widget.repository,
      displayParameters: displayParams,
    );
    controller = PaginatorController();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.startDay != null && widget.endDay != null) {
      startDayController.text = DateFormat(formatDate).format(widget.startDay!);
      endDayController.text = DateFormat(formatDate).format(widget.endDay!);
      if (validateDate(widget.startDay!, widget.endDay!)) {
        _notifier.retrieveDataWithinDateRange(
          startDate: widget.startDay!,
          endDate: widget.endDay!,
        );
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.startDay != null &&
          widget.endDay != null &&
          !validateDate(widget.startDay!, widget.endDay!)) {
        showConfirmDialog(context, widget.startDay!, widget.endDay!);
      }
    });
    return ValueListenableBuilder<TableState>(
      valueListenable: _notifier,
      builder: (context, state, child) {
        if (state.tableDataSource != null) {
          _updateTableDataSource(state);
        }
        // when record that created will show in first page
        if ((state.updateData && state.isNewRecord) || widget.jumpToFirstPage) {
          state.tableDataSource!.paginatorController.goToFirstPage();
        }

        return Stack(
          children: [
            Padding(
              padding: widget.padding,
              child: PaginatedDataTable2(
                controller: controller,
                header: Text(widget.headerTitle),
                columns: _buildDataColumns(),
                source: state.tableDataSource!,
                actions: _buildActions(state),
                rowsPerPage: state.rowsPerPage,
                onRowsPerPageChanged: _notifier.rowsPerPage,
                sortColumnIndex: state.sortColumnIndex,
                sortAscending: state.sortAscending,
                horizontalMargin: 20,
                checkboxHorizontalMargin: 12,
                columnSpacing: 0,
                minWidth: widget.minWidth,
                dataRowHeight: widget.dataRowHeight,
                showCheckboxColumn: false,
                empty: widget.empty,
              ),
            ),
            if (state.updateData && widget.isDisplayRefreshButton)
              const _NewDataButton(),
            if (state.loading) const _LoadingOverlay(),
          ],
        );
      },
    );
  }

  void showConfirmDialog(
    BuildContext context,
    DateTime startDate,
    DateTime endDate,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Invalid Date Range"),
          content:
              const Text("The start date cannot be later than the end date."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _updateTableDataSource(TableState state) {
    state.tableDataSource!
      ..isEditable = widget.isEditable
      ..isDeletable = widget.isDeletable
      ..isQRDisplayable = widget.isQRDisplayable
      ..customHandlers = widget.customDisplayHandlers
      ..rowTapHandler = widget.onRowTap
      ..isLabelDisplayFirstColumn = widget.isLabelDisplayFirstColumn
      ..paginatorController = controller
      ..isFetchInRangeDay = widget.isFetchInRangeDay
      ..startDay = widget.startDay
      ..endDay = widget.endDay
      ..qrHandler = (model) async {
        await showDialog(
          context: context,
          builder: (context) => QRView(data: model),
        );
      }
      ..editHandler = (model) async {
        DataModel? result;

        if (widget.customEditHandler != null) {
          result = await widget.customEditHandler!(model);
        } else {
          result = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => EditView(
              type: EditType.update,
              data: model,
              dataTable: state.tableDataSource!.data,
              customEditHandlers: widget.customEditHandlers,
            ),
          );
        }

        if (result != null) {
          _notifier.update(result);
        }
      }
      ..deleteHandler = (model) async {
        final result = await showConfirmationDialog(context);
        if (result != null && result) {
          _notifier.delete(model);
        }
      }
      ..refreshHandler = () {
        _notifier.init();
      };

    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.error ?? '')));
      });
    }
  }

  List<Widget> _buildActions(TableState state) {
    final params = widget.instance().getDisplayParamsList();
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
      if (widget.startDay != null)
        SizedBox(
          width: 150,
          child: TextFormField(
            controller: startDayController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            onTap: () {
              widget.onSelectedStartDay?.call();
            },
          ),
        ),
      if (widget.endDay != null)
        SizedBox(
          width: 150,
          child: TextFormField(
            controller: endDayController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            onTap: () {
              widget.onSelectedEndDay?.call();
            },
          ),
        ),
      DropdownButton<String>(
        items: dropDownItems,
        value: state.filterBy,
        onChanged: (val) => _notifier.setFilterKey(val!),
      ),
      SizedBox(
        width: 150,
        child: TextField(
          controller: _notifier.filterTextController,
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
        onPressed: !widget.isFetchInRangeDay
            ? _notifier.init
            : () {
                _notifier.retrieveDataWithinDateRange(
                  startDate: widget.startDay!,
                  endDate: widget.endDay!,
                );
              },
      ),
      if (widget.canAddEntry)
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            DataModel? result;

            if (widget.customAddHandler != null) {
              result = await widget.customAddHandler!();
            } else {
              result = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => EditView(
                  type: EditType.add,
                  data: widget.instance(),
                  dataTable: state.tableDataSource!.data,
                  customEditHandlers: widget.customEditHandlers,
                ),
              );
            }

            if (result != null) {
              _notifier.create(result);
            }
          },
        ),
    ];
  }

  List<DataColumn> _buildDataColumns() {
    final List<DataColumn> columns = [];
    final params = widget.instance().getDisplayParamsList();

    params.forEach(
      (element, type) {
        final isCustomType =
            widget.customDisplayHandlers?.containsKey(type) ?? false;

        columns.add(
          DataColumn2(
            label: Text(element),
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
    if (widget.isLabelDisplayFirstColumn) {
      columns.insert(0, const DataColumn2(label: Text(''), size: ColumnSize.S));
    }

    return columns;
  }

  bool validateDate(DateTime startDay, DateTime endDay) {
    final newStartDay = DateTime(
      startDay.year,
      startDay.month,
      startDay.day,
    );
    final newEndDay = DateTime(
      endDay.year,
      endDay.month,
      endDay.day,
    );

    return newStartDay.isBefore(newEndDay.add(const Duration(seconds: 1)));
  }

  @override
  void dispose() {
    super.dispose();
    startDayController.dispose();
    endDayController.dispose();
  }
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No records'));
  }
}

class _NewDataButton extends StatelessWidget {
  const _NewDataButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrangeAccent,
            minimumSize: const Size(88, 36),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          onPressed: () => context
              .findAncestorStateOfType<_CRUDTableState>()
              ?._notifier
              .init(),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'New data available',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 4),
              Icon(Icons.refresh, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.black45,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
