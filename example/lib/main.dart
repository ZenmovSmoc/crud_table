import 'package:crud_table/crud_table.dart';
import 'package:crud_table_example/models/user.dart';
import 'package:crud_table_example/repository/user_repository.dart';
import 'package:flutter/material.dart';

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
            isEditable: true,
            repository: UserRepository(),
            instance: () => const UserModel(),
          ),
        ),
      ),
    );
  }
}
