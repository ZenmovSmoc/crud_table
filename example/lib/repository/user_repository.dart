import 'package:crud_table/model/data_exception.dart';
import 'package:crud_table/model/data_repository.dart';
import 'package:crud_table_example/models/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRepository extends DataRepository<UserModel> {
  List<UserModel> users = List.generate(
    5,
    (index) => UserModel(
      docId: 'id $index',
      name: 'name $index',
      tel: 'tel $index',
      email: 'email_$index@gmail.com',
      address: 'address $index',
      nationality: index.isEven ? 'nat $index' : null,
      fcmToken: 'tok $index',
      createdAt: DateTime.now().subtract(Duration(days: index)),
      updatedAt: DateTime.now().subtract(Duration(days: index)),
      customType: CustomType('$index'),
      location: LatLng(0, 0),
    ),
  );

  @override
  Future<void> create(UserModel model) async {
    await Future.delayed(const Duration(seconds: 1));

    throw CrudException('Failed to add User!');

    // users.add(model.copyWith(
    //   updatedAt: DateTime.now(),
    // ));
  }

  @override
  Future<void> delete(UserModel model) async {
    await Future.delayed(const Duration(seconds: 1));

    users.removeWhere((element) => element.docId == model.docId);
  }

  @override
  Future<List<UserModel>> fetch() async {
    await Future.delayed(const Duration(seconds: 1));
    return users;
  }

  @override
  Stream<List<UserModel>> stream() {
    return Stream.fromIterable([
      [UserModel()]
    ]);
  }

  @override
  Future<void> update(UserModel model) async {
    await Future.delayed(const Duration(seconds: 1));
    users[users.indexWhere((element) => element.docId == model.docId)] =
        model.copyWith(updatedAt: DateTime.now());
  }
}
