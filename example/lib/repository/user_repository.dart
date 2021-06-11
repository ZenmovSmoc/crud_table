import 'package:crud_table/model/data_repository.dart';
import 'package:crud_table_example/models/user.dart';

class UserRepository extends DataRepository<UserModel> {
  @override
  Future<void> create(UserModel model) async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future<void> delete(UserModel model) async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future<List<UserModel>> fetch() async {
    await Future.delayed(const Duration(seconds: 2));

    return List.generate(
        5,
        (index) => UserModel(
              docId: 'id $index',
              name: 'name $index',
              tel: 'tel $index',
              email: 'email $index',
              address: 'address $index',
              nationality: 'nat $index',
              fcmToken: 'tok $index',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));
  }

  @override
  Stream<List<UserModel>> stream() {
    // TODO: implement stream
    throw UnimplementedError();
  }

  @override
  Future<void> update(UserModel model) async {
    await Future.delayed(const Duration(seconds: 2));
  }
}
