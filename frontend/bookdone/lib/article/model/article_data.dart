import 'package:freezed_annotation/freezed_annotation.dart';

part 'article_data.freezed.dart';
part 'article_data.g.dart';

@freezed
class ArticleRespByid with _$ArticleRespByid {
  const factory ArticleRespByid({
    required bool success,
    required String msg,
    required ArticleData data,
  }) = _ArticleRespByid;

  factory ArticleRespByid.fromJson(Map<String, dynamic> json) =>
      _$ArticleRespByidFromJson(json);
}

@freezed
class ArticleData with _$ArticleData {
  const factory ArticleData({
    required int id,
    required String isbn,
    required String nickname,
    required String address,
    required String content,
    required bool canDelivery,
    required List<HistoryData> historyResponseList,
    required List<String> imageUrlList,
  }) = _ArticleData;

  factory ArticleData.fromJson(Map<String, dynamic> json) =>
      _$ArticleDataFromJson(json);
}

@freezed
class HistoryData with _$HistoryData {
  const factory HistoryData({
    required String title,
    required String titleUrl,
    String? content,
    required String nickname,
    required String createdAt,
  }) = _HistoryData;

  factory HistoryData.fromJson(Map<String, dynamic> json) =>
      _$HistoryDataFromJson(json);
}

@freezed
class HistoryResp with _$HistoryResp {
  const factory HistoryResp({
    required bool success,
    required String msg,
    required List<HistoryData> data,
  }) = _HistoryResp;

  factory HistoryResp.fromJson(Map<String, dynamic> json) =>
      _$HistoryRespFromJson(json);
}

@freezed
class RankResp with _$RankResp {
  const factory RankResp({
    required bool success,
    required String msg,
    required List<RankData> data,
  }) = _RankResp;

  factory RankResp.fromJson(Map<String, dynamic> json) =>
      _$RankRespFromJson(json);
}

@freezed
class RankData with _$RankData {
  const factory RankData({
    required String nickname,
    required double score,
  }) = _RankData;

  factory RankData.fromJson(Map<String, dynamic> json) =>
      _$RankDataFromJson(json);
}

@freezed
class TradeResponseDto with _$TradeResponseDto {
  const factory TradeResponseDto({
    required bool success,
    required String msg,
    required int data,
  }) = _TradeResponseDto;

  factory TradeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TradeResponseDtoFromJson(json);
}

@freezed
class TradeStringResponseDto with _$TradeStringResponseDto {
  const factory TradeStringResponseDto({
    required bool success,
    required String msg,
    required TradeInfo data,
  }) = _TradeStringResponseDto;

  factory TradeStringResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TradeStringResponseDtoFromJson(json);
}

@freezed
class TradeServerConfirm with _$TradeServerConfirm {
  const factory TradeServerConfirm({
    required bool success,
    required String msg,
    required String? data,
  }) = _TradeServerConfirm;

  factory TradeServerConfirm.fromJson(Map<String, dynamic> json) =>
      _$TradeServerConfirmFromJson(json);
}

@freezed
class TradeResponse with _$TradeResponse {
  const factory TradeResponse({
    required int id,
  }) = _TradeResponse;

  factory TradeResponse.fromJson(Map<String, dynamic> json) =>
      _$TradeResponseFromJson(json);
}

@freezed
class DonationIdResponseDto with _$DonationIdResponseDto {
  const factory DonationIdResponseDto({
    required bool success,
    required String msg,
    required TradeInfo data,
  }) = _DonationIdResponseDto;

  factory DonationIdResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DonationIdResponseDtoFromJson(json);
}

@freezed
class TradeInfo with _$TradeInfo {
  const factory TradeInfo({
    required int id,
    required int donationId,
    required int memberId,
    required String tradeStatus,
  }) = _TradeInfo;

  factory TradeInfo.fromJson(Map<String, dynamic> json) =>
      _$TradeInfoFromJson(json);
}