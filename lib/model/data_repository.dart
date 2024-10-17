import 'package:crud_table/model/data_model.dart';

abstract class DataRepository<T extends DataModel> with DataRepositoryMixin<T> {
  Future<List<T>> fetch();

  Future<void> create(T model);

  Future<void> update(T model);

  Stream<List<T>> stream();

  Future<void> delete(T model);
}

mixin DataRepositoryMixin<T> {
  Future<List<T>> fetchWithSortCondition({String? sortCondition}) {
    throw UnimplementedError();
  }

  Future<List<T>> fetchDataInRangeDay({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    throw UnimplementedError();
  }
}
