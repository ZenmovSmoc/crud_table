import 'dart:convert';

import 'package:crud_table/model/data_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'user.freezed.dart';
part 'user.g.dart';

class CustomType {
  final String text;

  CustomType(this.text);
}

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
    LatLng? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    CustomType? customType,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @override
  Map<String, Type> getCreateParamsList() {
    return {
      'name': String,
      'email': String,
      'nationality': String,
      'customType': CustomType,
    };
  }

  @override
  Map<String, Type> getDisplayParamsList() {
    return {
      'name': String,
      'email': String,
      'nationality': String,
      'customType': CustomType,
    };
  }

  @override
  Map<String, Type> getEditableParamsList() {
    return this.getCreateParamsList();
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
      'customType': this.customType,
      'location': this.location,
    };
  }

  @override
  DataModel setParameter(String key, String value) {
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
      case 'createdAt':
        return this.copyWith(createdAt: DateTime.parse(value));
      case 'location':
        final Map<String, dynamic> data = json.decode(value);

        return this.copyWith(
            location: LatLng(
          double.parse(data['latitude']),
          double.parse(data['longitude']),
        ));
      case 'customType':
        return this.copyWith(customType: CustomType(value));
      default:
        return this.copyWith();
    }
  }
}
