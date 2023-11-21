import 'package:bookdone/article/model/article_data.dart';
import 'package:bookdone/search/model/book.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

// DateTime 형식 변환을 위한 헬퍼 함수
DateTime? _dateTimeFromIsoString(String? isoString) {
  if (isoString == null || isoString.isEmpty) {
    return null;
  }
  return DateTime.parse(isoString);
}

// 수정된 함수
String? _dateTimeToIsoString(DateTime? dateTime) {
  return dateTime?.toIso8601String();
}

@freezed
class ChatRoomRequest with _$ChatRoomRequest {
  const factory ChatRoomRequest({
    required String user1,
    required String user2,
    required int tradeId,
    required String isbn,
  }) = _ChatRoomRequest;

  factory ChatRoomRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomRequestFromJson(json);
}

@freezed
class ChatListDto with _$ChatListDto {
  const factory ChatListDto({
    required bool success,
    required String msg,
    required List<ChatRoomResponse> data,
  }) = _ChatListDto;

  factory ChatListDto.fromJson(Map<String, dynamic> json) =>
      _$ChatListDtoFromJson(json);
}

@freezed
class ChatRoomResponse with _$ChatRoomResponse {
  const factory ChatRoomResponse({
    required int tradeId,
    required String? userNickname,
    required String? lastMessage,
    @JsonKey(fromJson: _dateTimeFromIsoString, toJson: _dateTimeToIsoString)
    required DateTime? lastMessageTime,
    required String? isbn,
  }) = _ChatRoomResponse;

  factory ChatRoomResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomResponseFromJson(json);
}

@freezed
class ChatMessagesDto with _$ChatMessagesDto {
  const factory ChatMessagesDto({
    required bool success,
    required String msg,
    required List<Message> data,
  }) = _ChatMessagesDto;

  factory ChatMessagesDto.fromJson(Map<String, dynamic> json) =>
      _$ChatMessagesDtoFromJson(json);
}

@freezed
class Message with _$Message {
  const factory Message({
    required int tradeId,
    required String message,
    required String senderNickname,
    required DateTime createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

@freezed
class ChatMessageWriteRequest with _$ChatMessageWriteRequest {
  const factory ChatMessageWriteRequest({
    required String message,
    required int tradeId,
    required String senderNickname,
  }) = _ChatMessageWriteRequest;

  factory ChatMessageWriteRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageWriteRequestFromJson(json);
}