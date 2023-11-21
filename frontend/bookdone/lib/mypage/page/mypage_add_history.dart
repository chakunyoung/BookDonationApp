import 'package:bookdone/mypage/model/my_book.dart';
import 'package:bookdone/onboard/repository/user_repository.dart';
import 'package:bookdone/rest_api/rest_client.dart';
import 'package:bookdone/router/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyPageAddHistory extends HookConsumerWidget {
  const MyPageAddHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restClient = ref.read(restApiClientProvider);
    final userData = ref.read(userDataRepositoryProvider);
    var nickname = useState('');

    useEffect(() {
      void fetchData() async {
        try {
          userData.restoreNickname().then((name) {
            nickname.value = name;
          }).catchError((error) {
            print(error);
          });
        } catch (error) {
          print(error);
        }
      }

      fetchData();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("히스토리 작성"),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {},
        // ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                  future: restClient.getUnwrittenHistoryDonations(),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.data == null) {
                      return SizedBox.shrink();
                    }

                    final donationList = snapshot.data!.data;

                    return Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        donationList.isEmpty
                            ? Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 100,
                                    ),
                                    SvgPicture.asset(
                                      'assets/images/undraw_notify.svg',
                                      height: 150,
                                    ),
                                    SizedBox(
                                      height: 50,
                                    ),
                                    Text('히스토리를 작성하지 않은 책이 없어요',
                                        style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                              )
                            : Column(
                                children: donationList.map((data) {
                                  return AddHitoryCard(
                                    info: data,
                                  );
                                }).toList(),
                              ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddHitoryCard extends HookConsumerWidget {
  const AddHitoryCard({super.key, required this.info});
  final UnwrittenResponse info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black12,
            width: 2,
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
                  imageUrl: info.titleUrl != '' ? info.titleUrl : '',
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
                          info.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () {
                            HistoryRegisterRoute(
                                    donationId: info.id,
                                    title: info.title,
                                    titleUrl: info.titleUrl)
                                .push(context);
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text("작성하기"),
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
    );
  }
}

class CompleteHistoryCard extends HookConsumerWidget {
  const CompleteHistoryCard({super.key, required this.info});
  final BookInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0), color: Colors.black12),
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
                  imageUrl: info.titleUrl,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
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
                          info.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text("작성완료"),
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
    );
  }
}
