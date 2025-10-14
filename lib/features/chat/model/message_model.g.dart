// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageModel _$MessageModelFromJson(Map<String, dynamic> json) =>
    _MessageModel(
      sender: UserModel.fromJson(json['sender'] as Map<String, dynamic>),
      recipient: UserModel.fromJson(json['recipient'] as Map<String, dynamic>),
      type: json['type'] as String,
      message: json['message'] as String,
      createdAt: json['createdAt'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$MessageModelToJson(_MessageModel instance) =>
    <String, dynamic>{
      'sender': instance.sender,
      'recipient': instance.recipient,
      'type': instance.type,
      'message': instance.message,
      'createdAt': instance.createdAt,
      'status': instance.status,
    };
