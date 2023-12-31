import 'dart:math';

import 'package:bookdone/article/model/article_data.dart';
import 'package:bookdone/rest_api/rest_client.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HistoryMain extends HookConsumerWidget {
  const HistoryMain(
      {super.key,
      required this.title,
      required this.titleUrl,
      required this.donationId});
  final int donationId;
  final String title;
  final String titleUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restClient = ref.read(restApiClientProvider);
    var histories = useState<List<HistoryData>?>(null);
    Future<HistoryResp> getHistories() async {
      var data = restClient.getHistoriesByDonation(donationId);
      return data;
    }

    final List<Color> lowSaturationColors = [
      const Color.fromARGB(255, 200, 211, 215),
      Color.fromARGB(255, 241, 232, 232),
      Color.fromARGB(255, 237, 241, 243),
      const Color.fromARGB(255, 215, 218, 235),
      Color.fromARGB(255, 227, 235, 234),
    ];

    useEffect(() {
      void fetchData() async {
        try {
          final data = await getHistories();
          histories.value = data.data;
        } catch (error) {
          print(error);
        }
      }

      fetchData();
      return null;
    }, []);

    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 238, 236, 233),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                  shadows: [
                    Shadow(
                      blurRadius: 7.0, // shadow blur
                      color: Color.fromARGB(255, 86, 86, 86), // shadow color
                      offset: Offset(0.0, 0.0), // how much shadow will be shown
                    ),
                  ],
                ),
              ),
              background: CachedNetworkImage(
                imageUrl: titleUrl != ''
                    ? titleUrl
                    : 'https://images.pexels.com/photos/19670/pexels-photo.jpg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      opacity: 0.4,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: histories.value == null
                ? Text(' ')
                : histories.value!.isEmpty
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
                            Text('아직 작성된 히스토리가 없습니다',
                                style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: ListView.builder(
                          // gridDelegate:
                          //     SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
                          itemCount: histories.value != null
                              ? histories.value!.length
                              : 0,
                          primary: false,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            var date =
                                histories.value![index].createdAt.split('T');
                            var day = date[0];
                            var time = date[1];
                            final randomColorIndex =
                                Random().nextInt(lowSaturationColors.length);
                            final randomColor =
                                lowSaturationColors[randomColorIndex];
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: randomColor,
                                  ),
                                  height: 200,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(30.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: histories
                                                      .value![index].content !=
                                                  null
                                              ? Text(
                                                  histories
                                                      .value![index].content!,
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                )
                                              : Text('content 없음'),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0, vertical: 15),
                                        color: Colors.white,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(histories
                                                .value![index].nickname),
                                            Text('$day $time'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
