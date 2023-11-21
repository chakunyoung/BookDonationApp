import 'package:bookdone/mypage/model/my_book.dart';
import 'package:bookdone/mypage/widgets/book_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MyKeepingList extends HookWidget {
  const MyKeepingList({super.key, required this.keepingList});
  final List<BookInfo> keepingList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: keepingList.length,
      itemBuilder: (context, index) {
        return BookCard(
          book: keepingList[index],
          isLike: false,
          isDonating: false,
        );
      },
    );
  }
}
