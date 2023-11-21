import 'package:animate_do/animate_do.dart';
import 'package:bookdone/onboard/widgets/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Items {
  final String img;
  final String title;
  final String subTitle;

  ///
  Items({
    required this.img,
    required this.title,
    required this.subTitle,
  });
}

class OnboardingPage extends HookConsumerWidget {
  // const OnboardingPage({Key? key}) : super(key: key);

  Widget animationDo(
    int index,
    int delay,
    Widget child,
  ) {
    if (index == 1) {
      return FadeInDown(
        delay: Duration(milliseconds: delay),
        child: child,
      );
    }
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: child,
    );
  }

  List<Items> listOfItems = [
    Items(
      img: "assets/images/Bibliophile-rafiki.svg",
      title: "책장에 꽂혀있는 그 책",
      subTitle: "공간은 차지하는데, 버리기엔 아까울 때",
    ),
    Items(
      img: "assets/images/Charity-rafiki.svg",
      title: "책이 가진 그 이상의 가치",
      subTitle: "나에게 필요없는 책이 \n누군가에게는 작은 희망으로",
    ),
    Items(
      img: "assets/images/Group-rafiki.svg",
      title: "지속 가능한 선순환",
      subTitle: "책도네로 시작하세요",
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    final pageController = usePageController();
    var currentIndex = useState(0);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 140, 135, 130),
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: listOfItems.length,
                  onPageChanged: (newIndex) {
                    currentIndex.value = newIndex;
                  },
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: ((context, index) {
                    return SizedBox(
                      width: size.width,
                      height: size.height,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width / 10),
                        child: Column(
                          children: [
                            /// IMG
                            Container(
                              margin: const EdgeInsets.fromLTRB(15, 40, 15, 10),
                              width: size.width,
                              height: size.height / 2.5,
                              child: animationDo(
                                index,
                                100,
                                SvgPicture.asset(listOfItems[index].img),
                              ),
                            ),
                            SizedBox(
                              height: 80,
                            ),

                            /// TITLE TEXT
                            animationDo(
                              index,
                              300,
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  listOfItems[index].title,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                              ),
                            ),

                            /// SUBTITLE TEXT
                            animationDo(
                              index,
                              500,
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  listOfItems[index].subTitle,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              /// ---------------------------
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  currentIndex.value == 2

                      /// GET STARTED BTN
                      ? animationDo(
                          3, 200, GetStartBtn(size: size, textTheme: textTheme))

                      /// SKIP BTN
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 30,
                  ),
                  SmoothPageIndicator(
                    controller: pageController,
                    count: listOfItems.length,
                    effect: const ExpandingDotsEffect(
                      spacing: 6.0,
                      radius: 10.0,
                      dotWidth: 10.0,
                      dotHeight: 10.0,
                      expansionFactor: 3.8,
                      dotColor: Color.fromARGB(255, 219, 219, 219),
                      activeDotColor: Color.fromARGB(255, 72, 67, 62),
                    ),
                    onDotClicked: (newIndex) {
                      currentIndex.value = newIndex;
                      pageController.animateToPage(newIndex,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease);
                    },
                  ),
                  SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}