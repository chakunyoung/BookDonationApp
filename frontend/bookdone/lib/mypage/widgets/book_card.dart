import 'package:bookdone/bookinfo/model/donation.dart';
import 'package:bookdone/mypage/model/my_book.dart';
import 'package:bookdone/rest_api/rest_client.dart';
import 'package:bookdone/router/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BookCard extends HookConsumerWidget {
  const BookCard(
      {super.key,
      required this.book,
      required this.isLike,
      required this.isDonating});
  final BookInfo book;
  final bool isLike;
  final bool isDonating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restClient = ref.read(restApiClientProvider);

    Future<void> setLikesNotification() async {
      BooksLikeResp bookslikes = await restClient.setBooksLikes({
        'localCode': '9999',
        'isbn': book.isbn,
      });
      print(bookslikes.data);
    }

    void likeAlert(context) {
      showDialog<String>(
        context: context,
        builder: (BuildContext contextAlert) => AlertDialog(
          title: const Text(
            '관심도서 해제',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          content: Text('관심도서에서 해제되었습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                contextAlert.pop();
                // MyPageRoute().push(context);
                StartPageRoute().pushReplacement(context);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        isDonating
            ? ArticleMainRoute(isbn: book.isbn, id: book.id).push(context)
            : null;
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
        child: Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black12,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: CachedNetworkImage(
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    imageUrl: book.titleUrl != '' ? book.titleUrl : '',
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Image(
                        image: AssetImage('assets/images/sample-bookdone.png')),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            book.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        isLike == false
                            ? Container(
                                alignment: Alignment.bottomRight,
                                child: TextButton(
                                  onPressed: () {
                                    book.historyResponseList.isNotEmpty
                                        ? HistoryRoute(
                                            donationId: book.id,
                                            title: book.title,
                                            titleUrl: book.titleUrl,
                                          ).push(context)
                                        : null;
                                  },
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: book.historyResponseList.isEmpty
                                      ? Text("히스토리 없음")
                                      : Text(
                                          "히스토리 ${book.historyResponseList.length}개"),
                                ),
                              )
                            : Container(
                                alignment: Alignment.bottomRight,
                                child: TextButton(
                                  onPressed: () {
                                    setLikesNotification();
                                    likeAlert(context);
                                  },
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text("관심도서 해제"),
                                ),
                              ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
