// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  userId: json['userId'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  fcmToken: json['fcmToken'] as String,
  isOnline: json['isOnline'] as bool,
  lastOnline: json['lastOnline'] as String,
  inChat: json['inChat'] as bool,
  profileUrl: json['profileUrl'] as String,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'fcmToken': instance.fcmToken,
      'isOnline': instance.isOnline,
      'lastOnline': instance.lastOnline,
      'inChat': instance.inChat,
      'profileUrl': instance.profileUrl,
    };
