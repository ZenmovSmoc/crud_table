import 'package:crud_table/model/data_model.dart';
import 'package:crud_table/model/data_repository.dart';
import 'package:crud_table/state/table_state.dart';
import 'package:crud_table/store/table_source.dart';
import 'package:flutter/material.dart';

class TableStateNotifier<T extends DataModel>
    extends ValueNotifier<TableState> {
  final DataRepository<T> repository;
  final Map<String, Type> displayParameters;

  TableStateNotifier({
    required this.repository,
    required this.displayParameters,
  }) : super(TableState(
          rowsPerPage: PaginatedDataTable.defaultRowsPerPage,
          sortAscending: true,
          updateData: false,
          sortColumnIndex: 1,
          loading: true,
          filterBy: displayParameters.entries.first.key,
          tableDataSource: DataSource<T>([]),
        )) {
    init();
  }

  late List<T> _data;

  late DateTime _lastUpdateTime;

  Future<void> init() async {
    value = value.copyWith(loading: true);

    _data = await repository.fetch();

    value = value.copyWith(
      tableDataSource: DataSource<T>(_data),
      loading: false,
    );
    filter(value.filterText);
  }

  Future<void> delete(T data) async {
    value = value.copyWith(loading: true);
    await repository.delete(data);
    init();
  }

  Future<void> create(T data) async {
    value = value.copyWith(loading: true);
    await repository.create(data);
    init();
  }

  void rowsPerPage(int? rowsPerPage) => value = value.copyWith(
      rowsPerPage: rowsPerPage ?? PaginatedDataTable.defaultRowsPerPage);

  void sortColumnIndex(int sortColumnIndex) =>
      value = value.copyWith(sortColumnIndex: sortColumnIndex);

  void sortAscending(bool sortAscending) =>
      value = value.copyWith(sortAscending: sortAscending);

  void setFilterKey(String filterKey) {
    value = value.copyWith(filterBy: filterKey);
    filter(value.filterText);
  }

  void filter(String? filter) {
    if (filter != null && filter.isNotEmpty) {
      value = value.copyWith(
        tableDataSource: DataSource(_data.where((e) {
          final param = e.toMap();

          return param[value.filterBy]
              .toString()
              .toLowerCase()
              .contains(filter.toLowerCase());
        }).toList()),
        filterText: filter,
      );
    } else {
      value =
          value.copyWith(tableDataSource: DataSource(_data), filterText: null);
    }
  }

  void sort<T>(String key, int columnIndex, bool ascending) {
    _data.sort(
      (a, b) {
        final aMap = a.toMap();
        final bMap = b.toMap();

        final Comparable<T> aValue = aMap[key];
        final Comparable<T> bValue = bMap[key];

        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      },
    );

    value = value.copyWith(
      tableDataSource: DataSource(_data),
    );

    sortColumnIndex(columnIndex);
    sortAscending(ascending);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
