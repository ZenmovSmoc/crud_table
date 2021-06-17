import 'package:crud_table/model/data_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

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

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @override
  Map<String, Type> getCreateParamsList() {
    return {
      'name': String,
      'email': String,
      'nationality': String,
      'tel': String,
      'address': String,
    };
  }

  @override
  Map<String, Type> getDisplayParamsList() {
    return {
      'name': String,
      'email': String,
      'nationality': String,
      'tel': String,
      'address': String,
      'createdAt': DateTime,
      'updatedAt': DateTime,
    };
  }

  @override
  Map<String, Type> getEditableParamsList() {
    return {
      'name': String,
      'email': String,
      'nationality': String,
      'tel': String,
      'address': String,
    };
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': this.name,
      'tel': this.tel,
      'email': this.email,
      'address': this.address,
      'nationality': this.nationality,
      'fcmToken': this.fcmToken,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt,
    };
  }

  @override
  DataModel setParameter(String key, value) {
    switch (key) {
      case 'name':
        return this.copyWith(name: value);
      case 'email':
        return this.copyWith(email: value);
      case 'nationality':
        return this.copyWith(nationality: value);
      case 'tel':
        return this.copyWith(tel: value);
      case 'address':
        return this.copyWith(address: value);
      default:
        return this.copyWith();
    }
  }
}
