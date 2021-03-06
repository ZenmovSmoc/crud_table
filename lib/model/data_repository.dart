import 'package:crud_table/model/data_model.dart';

abstract class DataRepository<T extends DataModel> {
  Future<List<T>> fetch();

  Future<void> create(T model);

  Future<void> update(T model);

  Stream<List<T>> stream();

  Future<void> delete(T model);
}
