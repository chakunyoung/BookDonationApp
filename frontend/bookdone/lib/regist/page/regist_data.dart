import 'dart:convert';
import 'dart:io';

import 'package:bookdone/bookinfo/model/region.dart';
import 'package:bookdone/onboard/repository/user_repository.dart';
import 'package:bookdone/regist/widgets/register_input_content.dart';
import 'package:bookdone/regist/widgets/register_region_dialog.dart';
import 'package:bookdone/rest_api/rest_client.dart';
import 'package:bookdone/router/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class RegisterRegionNotifier extends StateNotifier<String> {
  RegisterRegionNotifier(this.ref) : super('지역을 선택해주세요');
  final Ref ref;

  Future<void> setRegion(String region) async {
    state = region;
  }
}

final registerRegionStateProvider =
    StateNotifierProvider<RegisterRegionNotifier, String>(
        (ref) => RegisterRegionNotifier(ref));

class RegisterRegionCodeNotifier extends StateNotifier<String> {
  RegisterRegionCodeNotifier(this.ref) : super('');
  final Ref ref;
  Future<void> setRegion(String code) async {
    state = code;
  }
}

final registerRegionCodeStateProvider =
    StateNotifierProvider<RegisterRegionCodeNotifier, String>(
        (ref) => RegisterRegionCodeNotifier(ref));

class RegistData extends HookConsumerWidget {
  const RegistData({super.key, required this.isbn, required this.donationId});
  final String isbn;
  final int donationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picker = ImagePicker();
    var _pickedImgs = useState<List<XFile>>([]);
    final restClient = ref.read(restApiClientProvider);
    final contentController = useTextEditingController();
    var name = useState('');
    var regionName = useState('');
    var regionCode = useState('');
    var regionList = useState<List<RegionInfo>>([]);

    var image = useState<XFile?>(null);
    var multiImage = useState<List<XFile>?>([]);
    var images = useState<List<XFile>?>([]);
    var content = useState('');
    var files = useState<List<MultipartFile>>([]);
    var gotId = useState(0);

    Future<void> createArticle(List<MultipartFile> files) async {
      await restClient.registArticle(
          isbn: isbn,
          address: regionCode.value,
          content: content.value,
          canDelivery: false,
          images: files);
    }

    Future<void> _pickImg() async {
      final List<XFile> images = await picker.pickMultiImage();
      _pickedImgs.value = images;
    }

    Future<String> getNickname() async {
      var nickname =
          await ref.read(userDataRepositoryProvider).restoreNickname();
      return nickname;
    }

    Future<List<RegionInfo>> readJson() async {
      final jsonString =
          await rootBundle.loadString("assets/json/localcode.json");
      final response = await json.decode(jsonString) as Map<String, dynamic>;
      final result = Region.fromJson(response);
      print('데이터 확인 : ${result.region[0].first}');
      return result.region;
    }

    Future<String> getAddressName() async {
      var addressName = '';
      print('지역확인 : ${regionCode.value}');
      bool stop = false;
      for (int i = 0; i < regionList.value.length; i++) {
        if (!stop) {
          for (int j = 0; j < regionList.value[i].secondList.length; j++) {
            if (regionList.value[i].secondList[j].code == regionCode.value) {
              addressName = regionList.value[i].secondList[j].name;
              stop = true;
              break;
            }
          }
        }
      }
      return addressName;
    }

    Future<String> getAddress() async {
      var code = await ref.read(userDataRepositoryProvider).restoreAddress();
      return code;
    }

    void register() async {
      var code = ref.watch(registerRegionCodeStateProvider);
      var input = ref.watch(registerInputProvider);
      var resp = await restClient.registArticle(
          isbn: isbn,
          address: code,
          content: input,
          canDelivery: false,
          images: files.value);
      gotId.value = resp.data;
      ref.invalidate(registerRegionStateProvider);
      ref.invalidate(registerRegionCodeStateProvider);
      // MyPageRoute().go(context);
      StartPageRoute().go(context);
    }

    void registerExist() async {
      var code = ref.watch(registerRegionCodeStateProvider);
      var input = ref.watch(registerInputProvider);
      var resp = await restClient.updateArticle(donationId,
          isbn: isbn,
          address: code,
          content: input,
          canDelivery: false,
          images: files.value);
      gotId.value = resp.data;
      ref.invalidate(registerRegionStateProvider);
      ref.invalidate(registerRegionCodeStateProvider);
      StartPageRoute().go(context);
    }

    useEffect(() {
      void fetchData() async {
        try {
          final json = await readJson();
          regionList.value = json;

          final nickname = await getNickname();
          name.value = nickname;

          final address = await getAddress();
          regionCode.value = address;

          final addressName = await getAddressName();
          regionName.value = addressName;
        } catch (error) {
          print(error);
        }
      }

      fetchData();
      return () {};
    }, []);

    void fullImages(context) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Text('3장이 최대임'),
            ),
          );
        },
      );
    }

    void selectAddress(context) {
      showDialog(
        context: context,
        builder: (context) {
          return RegisterRegionDialog(regionList: regionList.value);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "등록하기",
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 10),
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  FutureBuilder(
                    future: restClient.getDetailBook(isbn),
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.data == null) {
                        return SizedBox.shrink();
                      }
                      final bookDetail = snapshot.data!.data;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CachedNetworkImage(
                            width: 120,
                            imageUrl: bookDetail.titleUrl,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bookDetail.title,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(bookDetail.author),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(bookDetail.publisher),
                                SizedBox(
                                  height: 5,
                                ),
                                Text('ISBN $isbn')
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text("기부자"),
                          ),
                          Flexible(child: Text(name.value)),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text("지역"),
                          ),
                          Flexible(
                              child:
                                  Text(ref.watch(registerRegionStateProvider))),
                          SizedBox(
                            width: 15,
                          ),
                          TextButton(
                            onPressed: () {
                              selectAddress(context);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.brown.shade200,
                              minimumSize: Size.zero,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "변경",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("내용"),
                      SizedBox(
                        height: 10,
                      ),
                      RegisterInputContent(),
                      SizedBox(
                        height: 10,
                      ),
                      Text("사진 업로드"),
                    ],
                  ),
                  Row(
                    children: [
                      //카메라로 촬영하기
                      Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(5),
                        child: IconButton(
                          onPressed: () async {
                            if (images.value!.length == 3) {
                              fullImages(context);
                              return;
                            }
                            image.value = await picker.pickImage(
                                source: ImageSource.camera);
                            images.value!.add(image.value!);
                          },
                          icon: Icon(
                            Icons.add_a_photo,
                            size: 30,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      //갤러리에서 가져오기
                      Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(5),
                        child: IconButton(
                          onPressed: () async {
                            if (images.value!.length == 3) {
                              fullImages(context);
                              return;
                            }
                            multiImage.value = await picker.pickMultiImage();
                            images.value!.addAll(multiImage.value!);
                          },
                          icon: Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 30,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: GridView.builder(
                      padding: EdgeInsets.all(0),
                      shrinkWrap: true,
                      itemCount: images.value!
                          .length, //보여줄 item 개수. images 리스트 변수에 담겨있는 사진 수 만큼.
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, //1 개의 행에 보여줄 사진 개수
                        childAspectRatio: 1 / 1, //사진 의 가로 세로의 비율
                        mainAxisSpacing: 10, //수평 Padding
                        crossAxisSpacing: 10, //수직 Padding
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: DecorationImage(
                                  fit: BoxFit.cover, //사진을 크기를 상자 크기에 맞게 조절
                                  image: FileImage(
                                    File(images.value![index]
                                            .path // images 리스트 변수 안에 있는 사진들을 순서대로 표시함
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 12,
                              height: MediaQuery.of(context).size.width / 12,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              //삭제 버튼
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                icon: Icon(Icons.close,
                                    color: Colors.white, size: 15),
                                onPressed: () {
                                  images.value!.remove(images.value![index]);
                                  images.value = images.value;
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Container(
          width: double.infinity,
          color: Colors.brown.shade200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 17),
                backgroundColor: Colors.brown.shade200,
                foregroundColor: Colors.white,
                shape: BeveledRectangleBorder()),
            onPressed: () async {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text(
                    '기부 등록',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  content: const Text('기부글을 등록할까요?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pop();
                        files.value = images.value!
                            .map((img) => MultipartFile.fromFileSync(img.path))
                            .toList();
                        donationId == -1 ? register() : registerExist();
                      },
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
            },
            child: Text(
              '등록하기',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}