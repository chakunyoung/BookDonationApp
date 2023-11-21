import 'package:bookdone/search/model/book.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'donation.freezed.dart';
part 'donation.g.dart';

// 기부 중 목록
@freezed
class DonationByRegionData with _$DonationByRegionData {
  const factory DonationByRegionData({
    required bool success,
    required String msg,
    required List<DonationByRegion> data,
  }) = _DonationByRegionData;

  factory DonationByRegionData.fromJson(Map<String, Object?> json) =>
      _$DonationByRegionDataFromJson(json);
}

@freezed
class DonationByRegion with _$DonationByRegion {
  const factory DonationByRegion({
    required int id,
    required String nickname,
    required int historyCount,
    required String address,
    required String createdAt,
  }) = _DonationByRegion;

  factory DonationByRegion.fromJson(Map<String, Object?> json) =>
      _$DonationByRegionFromJson(json);
}

// 보유 중 목록
@freezed
class KeepingBookByRegion with _$KeepingBookByRegion {
  const factory KeepingBookByRegion({
    required bool success,
    required String msg,
    required List<KeepingBookData> data,
  }) = _KeepingBookByRegion;

  factory KeepingBookByRegion.fromJson(Map<String, dynamic> json) =>
      _$KeepingBookByRegionFromJson(json);
}

@freezed
class KeepingBookData with _$KeepingBookData {
  const factory KeepingBookData({
    required String address,
    required int bookCount,
  }) = _KeepingBookData;

  factory KeepingBookData.fromJson(Map<String, dynamic> json) =>
      _$KeepingBookDataFromJson(json);
}

// 알림 관련
@freezed
class BooksLikeResp with _$BooksLikeResp {
  const factory BooksLikeResp({
    required bool success,
    required String msg,
    List<BooksLikeData>? data,
  }) = _BooksLikeResp;

  factory BooksLikeResp.fromJson(Map<String, dynamic> json) =>
      _$BooksLikeRespFromJson(json);
}

@freezed
class BooksLikeData with _$BooksLikeData {
  const factory BooksLikeData({
    required BookData book,
    required String localCode,
    required int count,
    required bool likes,
  }) = _BooksLikeData;

  factory BooksLikeData.fromJson(Map<String, dynamic> json) =>
      _$BooksLikeDataFromJson(json);
}

