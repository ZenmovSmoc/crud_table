import 'package:crud_table/model/data_model.dart';
import 'package:crud_table/store/table_source.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'table_state.freezed.dart';

@freezed
class TableState<T extends DataModel> with _$TableState<T> {
  const factory TableState({
    required int rowsPerPage,
    required int sortColumnIndex,
    required bool sortAscending,
    required bool updateData,
    required bool loading,
    String? filterBy,
    String? filterText,
    DataSource? tableDataSource,
  }) = _TableState;
}
