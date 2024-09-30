import 'package:crud_table/model/data_model.dart';
import 'package:crud_table/store/table_source.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'table_state.freezed.dart';

@freezed
class TableState<T extends DataModel> with _$TableState<T> {
  const factory TableState({
    /// Number of records displayed on page
    required int rowsPerPage,

    /// column position is sorted
    required int sortColumnIndex,

    /// Flag to check whether sorted by ASC or not
    required bool sortAscending,

    /// Flag to check record is updated or created
    required bool updateData,

    /// Loading progress indicator
    required bool loading,

    /// [isNewRecord] Flag to check if record is newly created
    @Default(false) bool isNewRecord,

    /// Filter by
    String? filterBy,

    /// filter Text
    String? filterText,

    /// DataSource
    DataSource? tableDataSource,

    /// error
    String? error,
  }) = _TableState;
}
