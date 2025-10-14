import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:test_socket/features/auth/model/user_model.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
abstract class MessageModel with _$MessageModel {
  factory MessageModel({
    required UserModel sender,
    required UserModel recipient,
    required String type,
    required String message,
    required String createdAt,
    required String status,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
}
