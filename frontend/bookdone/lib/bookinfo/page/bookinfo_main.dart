import 'package:bookdone/article/model/article_data.dart';
import 'package:bookdone/bookinfo/model/donation.dart';
import 'package:bookdone/bookinfo/widgets/comment_card.dart';
import 'package:bookdone/bookinfo/widgets/comment_input.dart';
import 'package:bookdone/onboard/repository/user_repository.dart';
import 'package:bookdone/rest_api/rest_client.dart';
import 'package:bookdone/router/app_routes.dart';
import 'package:bookdone/search/model/book.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BookinfoMain extends HookConsumerWidget {
  const BookinfoMain({super.key, required this.isbn});
  final String isbn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restClient = ref.read(restApiClientProvider);
    // final userNickname =
    //     ref.watch(userDataRepositoryProvider).restoreNickname();
    var username = useState('');
    var like = useState(false);
    var curBook = useState<BookData?>(null);

    void getNickname() async {
      final userNickname =
          await ref.watch(userDataRepositoryProvider).restoreNickname();
      username.value = userNickname;
      debugPrint('여기얌 ${username.value}');
    }

    Future<void> setLikesNotification() async {
      BooksLikeResp bookslikes = await restClient.setBooksLikes({
        'localCode': '9999',
        'isbn': isbn,
      });
      print(bookslikes.data);
    }

    // void getBookinfo() async {
    //   try {
    //     var data = await restClient.getDetailBook(isbn);
    //     curBook.value = data.data;
    //     like.value = curBook.value!.likeStatus;
    //     print('------------------${like.value}--------');
    //   } catch (error) {
    //     print(error);
    //   }
    // }

    useEffect(() {
      void getBookinfo() async {
        try {
          var data = await restClient.getDetailBook(isbn);
          curBook.value = data.data;
          like.value = curBook.value!.likeStatus;
          print('------------------${like.value}--------');
        } catch (error) {
          print(error);
        }
      }

      getBookinfo();
      return () {};
    }, []);

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.transparent,
        elevation: 0,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {
        //     context.pop();
        //   },
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 10),
          child: Center(
            child: ListView(
              // child: Column(
              children: [
                FutureBuilder(
                  future: restClient.getDetailBook(isbn), // TODO: 수정
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.data == null) {
                      // return SizedBox.shrink();
                      return SizedBox(
                        height: 10,
                      );
                    }

                    final book = snapshot.data!.data;

                    // like.value = book.likeStatus;

                    return Column(
                      children: [
                        CachedNetworkImage(
                          width: 200,
                          imageUrl: book.titleUrl != ''
                              ? book.titleUrl
                              : 'assets/images/sample-bookdone.png',
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Image(
                              image: AssetImage(
                                  'assets/images/sample-bookdone.png')),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 2 / 3,
                              child: Text(
                                book.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            IconButton(
                              // isSelected: like.value,
                              // selectedIcon: const Icon(Icons.notifications_active_sharp),
                              onPressed: () {
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const Text(
                                      '관심도서 설정',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: book.likeStatus
                                        ? Text('관심도서에서 해제할까요?')
                                        : Text('기부글이 등록되면 알림을 보낼까요?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          context.pop();
                                        },
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setLikesNotification();
                                          // context.pop();
                                          // getBookinfo();
                                          BookinfoMainRoute(isbn: isbn)
                                              .pushReplacement(context);
                                        },
                                        child: const Text('확인'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: book.likeStatus
                                  ? Icon(
                                      Icons.notifications_active_sharp,
                                      size: 20,
                                    )
                                  : Icon(
                                      Icons.notifications_none_outlined,
                                      size: 20,
                                    ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Divider(thickness: 1, height: 1),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "책 정보",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              book.author,
                            ),
                            Text(
                              book.publisher,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Divider(thickness: 1, height: 1),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            BookinfoDetailRoute(isbn: isbn).push(context);
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  //모서리를 둥글게
                                  borderRadius: BorderRadius.circular(15)),
                              fixedSize: Size(110, 40),
                              textStyle: const TextStyle(fontSize: 13),
                              backgroundColor: Colors.brown[300],
                              foregroundColor: Colors.white),
                          child: Text(
                            "찾아보기",
                            style: TextStyle(fontFamily: "SCDream4"),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    );
                  },
                ),
                Divider(thickness: 1, height: 1),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "댓글",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                CommentInput(isbn: isbn, nickname: username.value),
                FutureBuilder(
                  future: restClient.getCommentsList(isbn),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.data == null) {
                      return SizedBox.shrink();
                    }

                    final commentlist = snapshot.data!.data;

                    return Column(
                      children: commentlist.map((comment) {
                        return CommentCard(comment: comment);
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      // ),
    );
  }
}
