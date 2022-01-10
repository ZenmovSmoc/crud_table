import 'dart:async';

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
  }) : super(
          TableState(
            rowsPerPage: PaginatedDataTable.defaultRowsPerPage,
            sortAscending: true,
            updateData: false,
            sortColumnIndex: 0,
            loading: false,
            filterBy: displayParameters.entries.first.key,
            tableDataSource: DataSource<T>([]),
          ),
        ) {
    init();
    _initStream();
  }

  late List<T> _data;

  DateTime? _lastUpdateTime;

  late StreamSubscription<List<T>> _streamSubscription;

  void _initStream() {
    _streamSubscription = repository.stream().listen(
      (data) {
        value = value.copyWith(updateData: true);
      },
    );
  }

  Future<void> init() async {
    value = value.copyWith(loading: true);

    _data = await repository.fetch();

    value = value.copyWith(
      tableDataSource: DataSource<T>(_data, lastUpdateTime: _lastUpdateTime),
      loading: false,
      updateData: false,
    );

    filter(value.filterText);
    _lastUpdateTime = DateTime.now();
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

  Future<void> update(T data) async {
    value = value.copyWith(loading: true);
    await repository.update(data);
    init();
  }

  void rowsPerPage(int? rowsPerPage) => value = value.copyWith(
        rowsPerPage: rowsPerPage ?? PaginatedDataTable.defaultRowsPerPage,
      );

  void sortColumnIndex(int sortColumnIndex) =>
      value = value.copyWith(sortColumnIndex: sortColumnIndex);

  void sortAscending({required bool sortAscending}) =>
      value = value.copyWith(sortAscending: sortAscending);

  void setFilterKey(String filterKey) {
    value = value.copyWith(filterBy: filterKey);
    filter(value.filterText);
  }

  void filter(String? filter) {
    if (filter != null && filter.isNotEmpty) {
      value = value.copyWith(
        tableDataSource: DataSource(
          _data.where((e) {
            final param = e.toMap();

            return param[value.filterBy]
                .toString()
                .toLowerCase()
                .contains(filter.toLowerCase());
          }).toList(),
          lastUpdateTime: _lastUpdateTime,
        ),
        filterText: filter,
      );
    } else {
      value = value.copyWith(
        tableDataSource: DataSource(_data, lastUpdateTime: _lastUpdateTime),
        filterText: null,
      );
    }
  }

  void sort({
    required String key,
    required int columnIndex,
    required bool ascending,
  }) {
    _data.sort(
      (a, b) {
        final aMap = a.toMap();
        final bMap = b.toMap();

        if (aMap[key] == null) {
          return 1;
        }
        if (bMap[key] == null) {
          return -1;
        }

        final Comparable aValue = aMap[key];
        final Comparable bValue = bMap[key];

        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      },
    );

    value = value.copyWith(
      tableDataSource: DataSource(_data, lastUpdateTime: _lastUpdateTime),
    );

    filter(value.filterText);

    sortColumnIndex(columnIndex);
    sortAscending(sortAscending: ascending);
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
