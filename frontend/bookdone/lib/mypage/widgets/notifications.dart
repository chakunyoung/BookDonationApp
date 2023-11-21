import 'package:bookdone/rest_api/rest_client.dart';
import 'package:bookdone/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Notifications extends HookConsumerWidget {
  const Notifications(
      {super.key,
      required this.id,
      required this.message,
      required this.createdAt});
  final int id;
  final String message;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restClient = ref.read(restApiClientProvider);
    return Container(
      width: double.infinity,
      height: 100,
      color: Color.fromARGB(255, 244, 250, 252),
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: 10.0, horizontal: MediaQuery.of(context).size.width / 10),
        child: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${createdAt.month}월 ${createdAt.day}일 ${createdAt.hour}:${createdAt.minute}'),
                        Container(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: () async {
                              await restClient.deleteNotifications(id);
                              NotificationRoute().pushReplacement(context);
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "닫기",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
