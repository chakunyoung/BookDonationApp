import 'package:bookdone/mypage/model/my_book.dart';
import 'package:bookdone/mypage/widgets/book_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MyDonatingList extends HookWidget {
  const MyDonatingList({
    super.key,
    required this.donatingList,
  });
  final List<BookInfo> donatingList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: donatingList.length,
      itemBuilder: (context, index) {
        return BookCard(
          book: donatingList[index],
          isLike: false,
          isDonating: true,
        );
      },
    );
  }
}
