import 'package:bookdone/rest_api/rest_client.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RankingList extends HookConsumerWidget {
  const RankingList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restClient = ref.read(restApiClientProvider);
    return FutureBuilder(
      future: restClient.getRanking(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data == null) {
          return SizedBox.shrink();
        }
        final rankings = snapshot.data!.data;

        return Column(
          children: rankings.map((ranking) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('${rankings.indexOf(ranking) + 1}등'),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          ranking.nickname,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // Text('dd'),
                      ],
                    ),
                    Text('${ranking.score.floor()}점'),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

