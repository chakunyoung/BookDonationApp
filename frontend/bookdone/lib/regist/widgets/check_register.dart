import 'package:bookdone/regist/page/regist_data.dart';
import 'package:bookdone/rest_api/rest_client.dart';
import 'package:bookdone/router/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class CheckRegister extends HookConsumerWidget {
  const CheckRegister(
      {super.key,
      required this.isbn,
      required this.address,
      required this.content,
      required this.donationId,
      this.images});
  final List<XFile>? images;
  final String isbn;
  final String address;
  final String content;
  final int donationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var files = useState<List<MultipartFile>>([]);
    useEffect(() {
      if (images != null) {
        files.value =
            images!.map((img) => MultipartFile.fromFileSync(img.path)).toList();
      } else {
        files.value = [];
      }
      return null;
    }, []);
    final restClient = ref.read(restApiClientProvider);
    var gotId = useState(0);

    void register() async {
      print(isbn);
      var resp = await restClient.registArticle(
          isbn: isbn,
          address: address,
          content: content,
          canDelivery: false,
          images: files.value);
      gotId.value = resp.data;
    }

    void registerExist() async {
      var resp = await restClient.updateArticle(donationId,
          isbn: isbn,
          address: address,
          content: content,
          canDelivery: false,
          images: files.value);
      gotId.value = resp.data;
    }

    return ElevatedButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('기부글을 등록할까요?'),
          // content: const Text('AlertDialog description'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                print('dd');
                // print(files.value);
                files.value = images!
                    .map((img) => MultipartFile.fromFileSync(img.path))
                    .toList();
                donationId == -1 ? register() : registerExist();
                // ref.invalidate(registerRegionStateProvider);
                // ref.invalidate(registerRegionCodeStateProvider);
                MyPageRoute().go(context);
              },
              child: const Text('등록'),
            ),
          ],
        ),
      ),
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          fixedSize: Size(20, 100),
          backgroundColor: Colors.brown.shade300,
          foregroundColor: Colors.white),
      child: const Text('등록하기'),
    );
  }
}
