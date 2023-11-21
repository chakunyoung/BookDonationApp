import 'package:bookdone/rest_api/rest_client.dart';
import 'package:flutter/material.dart';
import 'package:bookdone/mypage/widgets/notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyPageNotifications extends HookConsumerWidget {
  const MyPageNotifications({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restClient = ref.read(restApiClientProvider);
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Text("알림"),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {},
        // ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: restClient.getNotifications(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data == null) {
              // return SizedBox.shrink();
              return SizedBox.shrink();
            }

            final notificationData = snapshot.data!.data;

            return notificationData.isEmpty
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
                        Text('알림이 없습니다', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: notificationData.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Notifications(
                        id: notificationData[index].id,
                        message: notificationData[index].message,
                        createdAt: notificationData[index].createdAt,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        SizedBox(
                      height: 3,
                    ),
                  );
          },
        ),
      ),
    );
  }
}
