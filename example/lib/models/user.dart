import 'package:crud_table/model/data_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'user.freezed.dart';

@freezed
class UserModel with _$UserModel, DataModel {
  const UserModel._();

  const factory UserModel({
    String? docId,
    String? name,
    String? tel,
    String? email,
    String? address,
    String? nationality,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserModel;

  @override
  Map<String, Type> getCreateParamsList() {
    return {
      'name': String,
      'email': String,
    };
  }

  @override
  Map<String, Type> getDisplayParamsList() {
    return {
      'name': String,
      'email': String,
      'createdAt': DateTime,
      'updatedAt': DateTime,
    };
  }

  @override
  Map<String, Type> getEditableParamsList() {
    return {};
  }

  @override
  void setParameter(String key, value) {}

  @override
  Map<String, dynamic> toMap() {
    return {};
  }
}
