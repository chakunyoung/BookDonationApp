import 'dart:convert';
import 'dart:ffi';

import 'package:bookdone/bookinfo/model/region.dart';
import 'package:bookdone/onboard/service/set_user_api.dart';
import 'package:bookdone/regist/page/regist_data.dart';
import 'package:bookdone/regist/widgets/register_region_dialog.dart';
import 'package:bookdone/rest_api/rest_client.dart';
import 'package:bookdone/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAdditionalInfo extends HookConsumerWidget {
  const AddAdditionalInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickNameController = useTextEditingController();
    // final restClient = useMemoized(() => RestClient(Dio()));
    final restClient = ref.read(restApiClientProvider);
    var nickName = useState('');
    var regionCode = useState('');
    var regionName = useState('지역을 선택해주세요');
    var validate = useState(0);
    // 0 : 확인 전, 1 : 확인 후 사용 가능, 2 : 확인 후 사용 불가능, 3 : 입력안함

    var regionList = useState<List<RegionInfo>>([]);
    var secondRegionList = useState<List<SecondList>>([]);
    // XFile? _pickedFile; // XFile
    final imageSize = MediaQuery.of(context).size.width / 5;

    var fcmToken = useState('');

    void getFcmToken() async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? token = pref.getString('fcmToken');
      if (token != null) {
        fcmToken.value = token;
      }
      print(fcmToken.value);
    }

    Future<void> sendInfo() async {
      await restClient.postAdditionalInfo({
        'nickname': nickName.value,
        'address': ref.watch(registerRegionCodeStateProvider),
        'fcmToken': fcmToken.value
      });
    }

    // _getCameraImage() async {
    //   final pickedFile =
    //       await ImagePicker().pickImage(source: ImageSource.camera);
    //   if (pickedFile != null) {
    //     // setState(() {
    //       _pickedFile = pickedFile;
    //     // });
    //   } else {
    //     if (kDebugMode) {
    //       print('이미지 선택안함');
    //     }
    //   }
    // }

    // _getPhotoLibraryImage() async {
    //   final pickedFile =
    //       await ImagePicker().pickImage(source: ImageSource.gallery);
    //   if (pickedFile != null) {
    //     setState(() {
    //       _pickedFile = _pickedFile;
    //     });
    //   } else {
    //     if (kDebugMode) {
    //       print('이미지 선택안함');
    //     }
    //   }
    // }

    // _showBottomSheet() {
    //   return showModalBottomSheet(
    //     context: context,
    //     shape: const RoundedRectangleBorder(
    //       borderRadius: BorderRadius.vertical(
    //         top: Radius.circular(25),
    //       ),
    //     ),
    //     builder: (context) {
    //       return Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           const SizedBox(
    //             height: 20,
    //           ),
    //           ElevatedButton(
    //             onPressed: () => _getCameraImage(),
    //             child: const Text('사진찍기'),
    //           ),
    //           const SizedBox(
    //             height: 10,
    //           ),
    //           const Divider(
    //             thickness: 1,
    //           ),
    //           const SizedBox(
    //             height: 10,
    //           ),
    //           ElevatedButton(
    //             onPressed: () => _getPhotoLibraryImage(),
    //             child: const Text('라이브러리에서 불러오기'),
    //           ),
    //           const SizedBox(
    //             height: 20,
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }

    Future<void> addFinalInfo() async {
      await restClient.postAdditionalInfo({
        'nickname': nickName.value,
        'address': regionCode.value,
        'fcmToken': fcmToken.value
      });
      print('fcm토큰 주 ㅓ !!! ${fcmToken.value}');

      // MemberInfo user =await ref.read(userInfoRepositoryProvider).restoreUserData(user);
      // await pref.setInt('loginStatus', 1);
      // await pref.setString('nickname', nickName.value);
      // await pref.setInt('bookmarkCnt', user.member.point);
      // await pref.setString('address', user.member.address);
      // await pref.setString('profileImage', user.member.image);
      // await pref.setString('accessToken', user.accessToken);
      // await pref.setString('oauthId', user.member.oauthId);
    }

    Future<void> readJson() async {
      final jsonString =
          await rootBundle.loadString("assets/json/localcode.json");
      final response = await json.decode(jsonString) as Map<String, dynamic>;
      final result = Region.fromJson(response);
      // print('테스트 : ${result.region[0].first}');
      regionList.value = result.region;
      // regionList.value = List<Region>.from(data['region']);
    }

    void selectAddress(context) {
      showDialog(
        context: context,
        builder: (context) {
          return RegisterRegionDialog(regionList: regionList.value);
        },
      );
    }

    Future<void> _checkValidAlert() async {
      return showDialog<void>(
        //다이얼로그 위젯 소환
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              '회원 가입',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            content: Text('닉네임 중복확인을 해주세요'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    }

    Future<void> _checkAlert() async {
      return showDialog<void>(
        //다이얼로그 위젯 소환
        context: context,
        barrierDismissible: false, // 다이얼로그 이외의 바탕 눌러도 안꺼지도록 설정
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        '${nickName.value}님 입력한 정보로 회원가입을 진행할까요?',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: Text('취소'),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          sendInfo();
                          // complete.value = true;
                          SetUserApi.updateMyInfo(ref);
                          ref.invalidate(registerRegionStateProvider);
                          ref.invalidate(registerRegionCodeStateProvider);
                          AddCompleteRoute().push(context);
                        },
                        child: Text('확인'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
          // title: Text('정보 입력'),
          ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 10),
          child: Column(
            // TODO: 닉네임 프로필사진 주소선택
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                '안녕하세요!\n추가 정보를 입력해주세요',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              SizedBox(
                height: 15,
              ),
              // if (_pickedFile == null)
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: AssetImage('assets/images/defaultimage.png')),
                ),
                // child: GestureDetector(
                //   onTap: () {
                //     _showBottomSheet();
                //   },
                // ),
              ),
              // else
              //   Container(
              //     width: imageSize,
              //     height: imageSize,
              //     decoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       image: DecorationImage(
              //           image: FileImage(File(_pickedFile!.path)),
              //           fit: BoxFit.cover),
              //     ),
              //   ),
              SizedBox(
                height: 30,
              ),
              Text(
                '닉네임을 입력해주세요',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 3 / 5,
                    child: Form(
                      // key: _formKey,
                      child: TextField(
                        style: TextStyle(fontSize: 12),
                        controller: nickNameController,
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                          hintText: '닉네임을 입력하세요',
                          filled: true,
                          fillColor: Color.fromARGB(255, 240, 240, 240),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 240, 240, 240),
                              )),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 240, 240, 240),
                            ),
                          ),
                        ),
                        maxLength: 8,
                        maxLines: 1,
                        onChanged: (text) {
                          nickName.value = nickNameController.text;
                          print(nickNameController.text);
                          validate.value = 0;
                        },
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      // textStyle: const TextStyle(
                      //     fontSize: 15, fontFamily: "SCDream4"),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () async {
                      if (nickName.value == '') {
                        validate.value = 3;
                        return;
                      }
                      final result =
                          await restClient.checkNickname(nickName.value);
                      print(result.toString());
                      if (result.data.available) {
                        validate.value = 1;
                      } else {
                        validate.value = 2;
                      }
                      // validate.value = 1;
                    },
                    child: Text('중복확인'),
                  ),
                ],
              ),
              if (validate.value == 1)
                Text(
                  '사용할 수 있는 닉네임입니다',
                  style: TextStyle(color: Colors.green),
                ),
              if (validate.value == 2)
                Text(
                  '이미 사용중인 닉네임입니다',
                  style: TextStyle(color: Colors.red),
                ),
              if (validate.value == 3)
                Text(
                  '닉네임을 입력해주세요',
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(
                height: 10,
              ),
              Text(
                '지역을 설정해주세요',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  readJson();

                  selectAddress(context);
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    textStyle:
                        const TextStyle(fontSize: 13, fontFamily: "SCDream4"),
                    backgroundColor: Colors.brown.shade100,
                    foregroundColor: Colors.black87),
                child: Wrap(
                  children: [
                    Icon(Icons.location_on, size: 17),
                    SizedBox(
                      width: 5.0,
                    ),
                    Text(ref.watch(registerRegionStateProvider)),
                  ],
                ),
              ),
            ],
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
              // TODO: 로그인 구현
              if (validate.value != 1) {
                _checkValidAlert();
                return;
              }
              getFcmToken();
              // print('토큰토큰 ${fcmToken.value}');

              await showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text(
                    '회원 가입',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  content: Text('${nickName.value}님\n입력한 정보로 회원가입을 진행할까요?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        sendInfo();
                        // complete.value = true;
                        SetUserApi.updateMyInfo(ref);
                        ref.invalidate(registerRegionStateProvider);
                        ref.invalidate(registerRegionCodeStateProvider);
                        AddCompleteRoute().go(context);
                      },
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
              ;

              // context.goNamed('home');
              // if (complete.value) {
              //   AddCompleteRoute().push(context);
              // }
            },
            child: Text(
              '다음',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}
