import 'package:bookdone/onboard/model/user_res.dart';
import 'package:bookdone/rest_api/rest_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetUserApi {
  static Future<void> updateMyInfo(ref) async {
    UserInfoRes user = await ref.read(restApiClientProvider).getMyInfo();
    SharedPreferences pref = await SharedPreferences.getInstance();

    await pref.setInt('userId', user.data.id);
    await pref.setString('nickname', user.data.nickname);
    await pref.setInt('bookmarkCnt', user.data.point);
    await pref.setString('address', user.data.address);
    await pref.setString('profileImage', user.data.image);
    await pref.setString('oauthId', user.data.oauthId);
    await pref.setString('getFcmToken', user.data.fcmToken);
  }
}
