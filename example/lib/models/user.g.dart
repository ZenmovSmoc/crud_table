// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_UserModel _$_$_UserModelFromJson(Map<String, dynamic> json) {
  return _$_UserModel(
    docId: json['docId'] as String?,
    name: json['name'] as String?,
    tel: json['tel'] as String?,
    email: json['email'] as String?,
    address: json['address'] as String?,
    nationality: json['nationality'] as String?,
    fcmToken: json['fcmToken'] as String?,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
  );
}

Map<String, dynamic> _$_$_UserModelToJson(_$_UserModel instance) =>
    <String, dynamic>{
      'docId': instance.docId,
      'name': instance.name,
      'tel': instance.tel,
      'email': instance.email,
      'address': instance.address,
      'nationality': instance.nationality,
      'fcmToken': instance.fcmToken,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
