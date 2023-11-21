import 'package:bookdone/onboard/model/user_res.dart';
import 'package:bookdone/onboard/repository/user_repository.dart';
import 'package:bookdone/rest_api/rest_client.dart';
import 'package:bookdone/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentInput extends HookConsumerWidget {
  const CommentInput({super.key, required this.isbn, required this.nickname});
  final String isbn;
  final String nickname;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final _formKey = GlobalKey<FormState>();
    var comment = useState('');
    var userNickname = useState('');
    var commentValidate = useState(0);
    var commentController = useTextEditingController();
    // final getUserData = ref.read(userDataRepositoryProvider).restoreNickname();

    Future<String> getUser() async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      return pref.getString('nickname') ?? '';
    }

    useEffect(() {
      getUser().then((name) {
        userNickname.value = name;
      }).catchError((error) {
        print(error);
      });
      return null;
    }, []);

    // void _tryValidation() {
    //   final isValid = _formKey.currentState!.validate();
    //   if (isValid) {
    //     _formKey.currentState!.save();
    //   }
    // }

    return Column(
      children: [
        Form(
          // key: _formKey,
          child: TextField(
            controller: commentController,
            // onTapOutside: (event) =>
            //     FocusManager.instance.primaryFocus?.unfocus(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.brown,
                ),
              ),
            ),
            maxLength: 100,
            maxLines: 2,
            onChanged: (text) {
              comment.value = commentController.text;
              commentValidate.value = 0;
            },
          ),
        ),
        if (commentValidate.value == -1) Text('댓글을 입력해주세요'),
        ElevatedButton(
          onPressed: () {
            if (comment.value == '') {
              commentValidate.value = -1;
              return;
            } else {
              // _tryValidation();
              // print(nickname);
              ref.read(restApiClientProvider).postComment({
                "isbn": isbn,
                "writer": userNickname.value,
                "review": comment.value,
              });
              BookinfoMainRoute(isbn: isbn).pushReplacement(context);
            }
          },
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              fixedSize: Size(double.maxFinite, 40),
              textStyle: const TextStyle(fontSize: 15, fontFamily: "SCDream4"),
              backgroundColor: Colors.brown[200],
              foregroundColor: Colors.white),
          child: const Text(
            "등록",
          ),
        ),
      ],
    );
  }
}
