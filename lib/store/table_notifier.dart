import 'package:crud_table/model/data_model.dart';
import 'package:crud_table/model/data_repository.dart';
import 'package:crud_table/state/table_state.dart';
import 'package:crud_table/store/table_source.dart';
import 'package:flutter/material.dart';

class TableStateNotifier<T extends DataModel>
    extends ValueNotifier<TableState> {
  final DataRepository<T> repository;

  TableStateNotifier({required this.repository})
      : super(TableState(
          rowsPerPage: PaginatedDataTable.defaultRowsPerPage,
          sortAscending: true,
          updateData: false,
          sortColumnIndex: 1,
          loading: true,
          tableDataSource: DataSource<T>([]),
        )) {
    init();
  }

  Future<void> init() async {
    value = value.copyWith(loading: true);

    List<T> data = await repository.fetch();

    value = value.copyWith(
      tableDataSource: DataSource<T>(data),
    );
  }

  Future<void> delete(T data) async {
    await repository.delete(data);
  }

  void rowsPerPage(int? rowsPerPage) => value = value.copyWith(
      rowsPerPage: rowsPerPage ?? PaginatedDataTable.defaultRowsPerPage);

  void sortColumnIndex(int sortColumnIndex) =>
      value = value.copyWith(sortColumnIndex: sortColumnIndex);

  void sortAscending(bool sortAscending) =>
      value = value.copyWith(sortAscending: sortAscending);

  @override
  void dispose() {
    super.dispose();
  }
}
