// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'table_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TableState<T extends DataModel> {
  int get rowsPerPage => throw _privateConstructorUsedError;
  int get sortColumnIndex => throw _privateConstructorUsedError;
  bool get sortAscending => throw _privateConstructorUsedError;
  bool get updateData => throw _privateConstructorUsedError;
  bool get loading => throw _privateConstructorUsedError;
  String? get filterBy => throw _privateConstructorUsedError;
  String? get filterText => throw _privateConstructorUsedError;
  DataSource<DataModel>? get tableDataSource =>
      throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TableStateCopyWith<T, TableState<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TableStateCopyWith<T extends DataModel, $Res> {
  factory $TableStateCopyWith(
          TableState<T> value, $Res Function(TableState<T>) then) =
      _$TableStateCopyWithImpl<T, $Res, TableState<T>>;
  @useResult
  $Res call(
      {int rowsPerPage,
      int sortColumnIndex,
      bool sortAscending,
      bool updateData,
      bool loading,
      String? filterBy,
      String? filterText,
      DataSource<DataModel>? tableDataSource,
      String? error});
}

/// @nodoc
class _$TableStateCopyWithImpl<T extends DataModel, $Res,
    $Val extends TableState<T>> implements $TableStateCopyWith<T, $Res> {
  _$TableStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rowsPerPage = null,
    Object? sortColumnIndex = null,
    Object? sortAscending = null,
    Object? updateData = null,
    Object? loading = null,
    Object? filterBy = freezed,
    Object? filterText = freezed,
    Object? tableDataSource = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      rowsPerPage: null == rowsPerPage
          ? _value.rowsPerPage
          : rowsPerPage // ignore: cast_nullable_to_non_nullable
              as int,
      sortColumnIndex: null == sortColumnIndex
          ? _value.sortColumnIndex
          : sortColumnIndex // ignore: cast_nullable_to_non_nullable
              as int,
      sortAscending: null == sortAscending
          ? _value.sortAscending
          : sortAscending // ignore: cast_nullable_to_non_nullable
              as bool,
      updateData: null == updateData
          ? _value.updateData
          : updateData // ignore: cast_nullable_to_non_nullable
              as bool,
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
      filterBy: freezed == filterBy
          ? _value.filterBy
          : filterBy // ignore: cast_nullable_to_non_nullable
              as String?,
      filterText: freezed == filterText
          ? _value.filterText
          : filterText // ignore: cast_nullable_to_non_nullable
              as String?,
      tableDataSource: freezed == tableDataSource
          ? _value.tableDataSource
          : tableDataSource // ignore: cast_nullable_to_non_nullable
              as DataSource<DataModel>?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TableStateImplCopyWith<T extends DataModel, $Res>
    implements $TableStateCopyWith<T, $Res> {
  factory _$$TableStateImplCopyWith(
          _$TableStateImpl<T> value, $Res Function(_$TableStateImpl<T>) then) =
      __$$TableStateImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call(
      {int rowsPerPage,
      int sortColumnIndex,
      bool sortAscending,
      bool updateData,
      bool loading,
      String? filterBy,
      String? filterText,
      DataSource<DataModel>? tableDataSource,
      String? error});
}

/// @nodoc
class __$$TableStateImplCopyWithImpl<T extends DataModel, $Res>
    extends _$TableStateCopyWithImpl<T, $Res, _$TableStateImpl<T>>
    implements _$$TableStateImplCopyWith<T, $Res> {
  __$$TableStateImplCopyWithImpl(
      _$TableStateImpl<T> _value, $Res Function(_$TableStateImpl<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rowsPerPage = null,
    Object? sortColumnIndex = null,
    Object? sortAscending = null,
    Object? updateData = null,
    Object? loading = null,
    Object? filterBy = freezed,
    Object? filterText = freezed,
    Object? tableDataSource = freezed,
    Object? error = freezed,
  }) {
    return _then(_$TableStateImpl<T>(
      rowsPerPage: null == rowsPerPage
          ? _value.rowsPerPage
          : rowsPerPage // ignore: cast_nullable_to_non_nullable
              as int,
      sortColumnIndex: null == sortColumnIndex
          ? _value.sortColumnIndex
          : sortColumnIndex // ignore: cast_nullable_to_non_nullable
              as int,
      sortAscending: null == sortAscending
          ? _value.sortAscending
          : sortAscending // ignore: cast_nullable_to_non_nullable
              as bool,
      updateData: null == updateData
          ? _value.updateData
          : updateData // ignore: cast_nullable_to_non_nullable
              as bool,
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
      filterBy: freezed == filterBy
          ? _value.filterBy
          : filterBy // ignore: cast_nullable_to_non_nullable
              as String?,
      filterText: freezed == filterText
          ? _value.filterText
          : filterText // ignore: cast_nullable_to_non_nullable
              as String?,
      tableDataSource: freezed == tableDataSource
          ? _value.tableDataSource
          : tableDataSource // ignore: cast_nullable_to_non_nullable
              as DataSource<DataModel>?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TableStateImpl<T extends DataModel>
    with DiagnosticableTreeMixin
    implements _TableState<T> {
  const _$TableStateImpl(
      {required this.rowsPerPage,
      required this.sortColumnIndex,
      required this.sortAscending,
      required this.updateData,
      required this.loading,
      this.filterBy,
      this.filterText,
      this.tableDataSource,
      this.error});

  @override
  final int rowsPerPage;
  @override
  final int sortColumnIndex;
  @override
  final bool sortAscending;
  @override
  final bool updateData;
  @override
  final bool loading;
  @override
  final String? filterBy;
  @override
  final String? filterText;
  @override
  final DataSource<DataModel>? tableDataSource;
  @override
  final String? error;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TableState<$T>(rowsPerPage: $rowsPerPage, sortColumnIndex: $sortColumnIndex, sortAscending: $sortAscending, updateData: $updateData, loading: $loading, filterBy: $filterBy, filterText: $filterText, tableDataSource: $tableDataSource, error: $error)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TableState<$T>'))
      ..add(DiagnosticsProperty('rowsPerPage', rowsPerPage))
      ..add(DiagnosticsProperty('sortColumnIndex', sortColumnIndex))
      ..add(DiagnosticsProperty('sortAscending', sortAscending))
      ..add(DiagnosticsProperty('updateData', updateData))
      ..add(DiagnosticsProperty('loading', loading))
      ..add(DiagnosticsProperty('filterBy', filterBy))
      ..add(DiagnosticsProperty('filterText', filterText))
      ..add(DiagnosticsProperty('tableDataSource', tableDataSource))
      ..add(DiagnosticsProperty('error', error));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TableStateImpl<T> &&
            (identical(other.rowsPerPage, rowsPerPage) ||
                other.rowsPerPage == rowsPerPage) &&
            (identical(other.sortColumnIndex, sortColumnIndex) ||
                other.sortColumnIndex == sortColumnIndex) &&
            (identical(other.sortAscending, sortAscending) ||
                other.sortAscending == sortAscending) &&
            (identical(other.updateData, updateData) ||
                other.updateData == updateData) &&
            (identical(other.loading, loading) || other.loading == loading) &&
            (identical(other.filterBy, filterBy) ||
                other.filterBy == filterBy) &&
            (identical(other.filterText, filterText) ||
                other.filterText == filterText) &&
            (identical(other.tableDataSource, tableDataSource) ||
                other.tableDataSource == tableDataSource) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      rowsPerPage,
      sortColumnIndex,
      sortAscending,
      updateData,
      loading,
      filterBy,
      filterText,
      tableDataSource,
      error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TableStateImplCopyWith<T, _$TableStateImpl<T>> get copyWith =>
      __$$TableStateImplCopyWithImpl<T, _$TableStateImpl<T>>(this, _$identity);
}

abstract class _TableState<T extends DataModel> implements TableState<T> {
  const factory _TableState(
      {required final int rowsPerPage,
      required final int sortColumnIndex,
      required final bool sortAscending,
      required final bool updateData,
      required final bool loading,
      final String? filterBy,
      final String? filterText,
      final DataSource<DataModel>? tableDataSource,
      final String? error}) = _$TableStateImpl<T>;

  @override
  int get rowsPerPage;
  @override
  int get sortColumnIndex;
  @override
  bool get sortAscending;
  @override
  bool get updateData;
  @override
  bool get loading;
  @override
  String? get filterBy;
  @override
  String? get filterText;
  @override
  DataSource<DataModel>? get tableDataSource;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$TableStateImplCopyWith<T, _$TableStateImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
