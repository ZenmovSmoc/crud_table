import 'package:crud_table/crud_table.dart';
import 'package:crud_table_example/models/user.dart';
import 'package:crud_table_example/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CRUD example app'),
        ),
        body: Center(
          child: CRUDTable<UserModel>(
            headerTitle: 'User',
            repository: UserRepository(),
            instance: () => const UserModel(),
            isEditable: true,
            isDeletable: true,
            canAddEntry: true,
            onRowTap: (data) {
              print('tapped! ${data}');
            },
            customAddHandler: () async {
              final test = UserModel(
                docId: '1',
                name: 'asdf',
                address: 'sadf',
                email: 'asdf',
                nationality: 'asdf',
              );

              return test;
            },
            customEditHandler: (val) async {
              final model = val as UserModel;

              return model.copyWith(name: 'new name');
            },
            customDisplayHandlers: {
              CustomType: (val, refresh) {
                final model = val as UserModel;

                return DataCell(
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        print('tapped ${model.customType?.text}');
                        refresh.call();
                      },
                      child: Text(model.customType?.text ?? 'A'),
                    ),
                  ),
                );
              },
              LatLng: (val, _) {
                final model = val as UserModel;

                return DataCell(
                  Text(
                      '${model.location!.latitude},${model.location!.longitude}'),
                );
              },
            },
            customEditHandlers: {
              CustomType: (data, controller) {
                controller.text = 'DATA'; // set text data using controller.text
                return Container();
              }
            },
            empty: Center(
              child: Text('Empty table'),
            ),
          ),
        ),
      ),
    );
  }
}
