import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'book.freezed.dart';
part 'book.g.dart';

@freezed
class Book with _$Book {
  const factory Book({
    required bool success,
    required String msg,
    required List<BookData> data,
  }) = _Book;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
}

@freezed
class BookData with _$BookData {
  const factory BookData({
    required int id,
    required String title,
    required String seriesTitle,
    required String seriesNo,
    required String author,
    required String isbn,
    required String titleUrl,
    required String publisher,
    required bool likeStatus,
  }) = _BookData;

  factory BookData.fromJson(Map<String, dynamic> json) =>
      _$BookDataFromJson(json);
}

@freezed
class BookDetail with _$BookDetail {
  const factory BookDetail({
    required bool success,
    required String msg,
    required BookData data,
  }) = _BookDetail;

  factory BookDetail.fromJson(Map<String, dynamic> json) =>
      _$BookDetailFromJson(json);
}

@freezed
class AutoList with _$AutoList {
  const factory AutoList({
    required bool success,
    required String msg,
    required List<AutoListData> data,
  }) = _AutoList;

  factory AutoList.fromJson(Map<String, dynamic> json) =>
      _$AutoListFromJson(json);
}

@freezed
class AutoListData with _$AutoListData {
  const factory AutoListData({
    required String title,
    required String isbn,
  }) = _AutoListData;

  factory AutoListData.fromJson(Map<String, dynamic> json) =>
      _$AutoListDataFromJson(json);
}

@freezed
class BooksDto with _$BooksDto {
  const factory BooksDto({
    required bool success,
    required String msg,
    required Map<String, BookData> data,
  }) = _BooksDto;

  factory BooksDto.fromJson(Map<String, dynamic> json) =>
      _$BooksDtoFromJson(json);
}