import 'package:bookdone/router/app_routes.dart';
import 'package:bookdone/search/model/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AutocompleteList extends HookWidget {
  const AutocompleteList(
      {super.key, required this.autoListData, required this.searchPage});
  final List<AutoListData> autoListData;
  final bool searchPage;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: searchPage ? 55 : 353,
      right: searchPage ? 0 : MediaQuery.of(context).size.width / 12,
      left: searchPage ? 0 : MediaQuery.of(context).size.width / 12,
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: autoListData.map((item) {
            return GestureDetector(
              onTap: () {
                BookinfoMainRoute(isbn: item.isbn).push(context);
                // print('잘 눌려용');
              },
              child: Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    // style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
