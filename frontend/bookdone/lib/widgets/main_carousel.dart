import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MainCarousel extends HookConsumerWidget {
  const MainCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var carouselIndex = useState(0);
    return Column(
      children: [
        CarouselSlider(
          items: [
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 12),
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 89, 87, 84),
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        '서로가 서로의 도서관으로',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '주변의 책을 찾아봐요',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SvgPicture.asset(
                    'assets/images/undraw_reading.svg',
                    height: 120,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 12),
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 197, 193, 189),
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SvgPicture.asset(
                    'assets/images/undraw_reading_time.svg',
                    height: 120,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          '기억조차 나지않는\n책장 속의 오래된 책들',
                        ),
                        Text(
                          '\n누군가가 찾고있다면?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 12),
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 78, 88, 98),
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SvgPicture.asset(
                    'assets/images/undraw_the_world.svg',
                    height: 120,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          '앞으로 읽게 될 책들은\n어떤 여정을 거쳤을까요?',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          '히스토리를 꺼내봐요',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          options: CarouselOptions(
              viewportFraction: 1,
              height: 200,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              onPageChanged: (index, reason) {
                carouselIndex.value = index;
              }),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == carouselIndex.value
                        ? Colors.white
                        : Color.fromARGB(255, 112, 101, 90),
                  ),
                ),
              )
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
