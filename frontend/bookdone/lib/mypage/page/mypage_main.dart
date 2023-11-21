import 'package:bookdone/mypage/model/like_book.dart';
import 'package:bookdone/mypage/model/my_book.dart';
import 'package:bookdone/mypage/widgets/my_donating_list.dart';
import 'package:bookdone/mypage/widgets/my_keeping_list.dart';
import 'package:bookdone/mypage/widgets/my_like_book_list.dart';
import 'package:bookdone/onboard/repository/user_repository.dart';
import 'package:bookdone/onboard/service/set_user_api.dart';
import 'package:bookdone/rest_api/rest_client.dart';
import 'package:bookdone/router/app_routes.dart';
import 'package:bookdone/widgets/floating_register_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPageMain extends HookConsumerWidget {
  MyPageMain({Key? key}) : super(key: key);

  final List<Tab> tabs = <Tab>[
    Tab(
      text: '기부 중',
    ),
    Tab(
      text: "보유 중",
    ),
    Tab(
      text: "관심도서",
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _tabController =
        useTabController(initialLength: tabs.length, initialIndex: 0);
    final restClient = ref.read(restApiClientProvider);
    var nickname = useState('');
    var point = useState(0);

    var keepingList = useState<MyKeepingList>(MyKeepingList(keepingList: []));
    var donatingList =
        useState<MyDonatingList>(MyDonatingList(donatingList: []));
    var likeBookList =
        useState<MyLikeBookList>(MyLikeBookList(likeBookList: []));
    // ref.read(userDataRepositoryProvider).restoreNickname().then((value) => {nickname=value});

    // Future<String> getUser() async {
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   String name = pref.getString('nickname') ?? '';
    //   return name;
    // }

    Future<void> logOut() async {
      print('로그아웃 : 니아러니아런이');
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setInt('loginStatus', 0);
      try {
        await UserApi.instance.logout();
        print('로그아웃댐!');
      } catch (error) {
        print('로그아웃안댐!');
      }
      FirstPageRoute().go(context);
    }

    var repository = ref.read(userDataRepositoryProvider);
    useEffect(() {
      void fetchData() async {
        await SetUserApi.updateMyInfo(ref);
        try {
          repository.restoreNickname().then((name) {
            nickname.value = name;
          }).catchError((error) {
            print(error);
          });
          repository.restorePoint().then((value) {
            point.value = value;
          }).catchError((error) {
            print(error);
          });
          List<BookInfo> donating = [];
          List<BookInfo> keeping = [];
          restClient.getMyBook().then((bookData) {
            for (var book in bookData.data) {
              if (book.donationStatus == 'KEEPING') {
                keeping.add(book);
              } else {
                if (book.historyResponseList.isNotEmpty) {
                  keeping.add(book);
                }
                donating.add(book);
              }
            }
            keepingList.value = MyKeepingList(keepingList: keeping);
            donatingList.value = MyDonatingList(donatingList: donating);
          });
          restClient.getLikeBooks().then((bookInfo) {
            List<LikeInfo> likeBooks = [];
            for (var likeInfo in bookInfo.data) {
              likeBooks.add(likeInfo);
            }
            likeBookList.value = MyLikeBookList(likeBookList: likeBooks);
          });
        } catch (error) {
          print(error);
        }
      }

      fetchData();

      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(),
      endDrawer: Drawer(
        child: Container(
          color: Color.fromARGB(255, 223, 218, 213),
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 140, 135, 130),
                ),
                child: Center(
                  child: Text(
                    'B O O K D O N E -',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              ListTile(
                title: Text('나의 히스토리'),
                onTap: () {
                  MyHistoriesRoute().push(context);
                },
              ),
              ListTile(
                title: Text('로그아웃'),
                onTap: () {
                  // logOut();
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      content: const Text('로그아웃 하시겠습니까?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            context.pop();
                          },
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            logOut();
                          },
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 8),
              child: Column(
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: Image(
                                image: AssetImage(
                                    "assets/images/defaultimage.png"),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${nickname.value}님의 서재",
                                  style: TextStyle(fontSize: 13),
                                ),
                                Row(
                                  children: [
                                    Image(
                                      image: AssetImage(
                                          "assets/images/bookmark.png"),
                                      width: 30,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      "${point.value}",
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.notifications),
                          onPressed: () {
                            NotificationRoute().push(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                        onPressed: () {
                          AddHistoryRoute().push(context);
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 5.0),
                            // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                                //모서리를 둥글게
                                borderRadius: BorderRadius.circular(8)),
                            textStyle: const TextStyle(fontSize: 12),
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white),
                        child: Text(
                          "히스토리 작성",
                          style: TextStyle(fontFamily: "SCDream4"),
                        )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TabBar(
              tabs: tabs,
              controller: _tabController,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.brown,
              indicatorSize: TabBarIndicatorSize.tab,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              labelColor: Colors.black,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 12),
                    child: donatingList.value,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 12),
                    child: keepingList.value,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 12),
                    child: likeBookList.value,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      // bottomNavigationBar: TopNavigationBar(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      // floatingActionButton: FloatingRegisterBtn(),
    );
  }
}
