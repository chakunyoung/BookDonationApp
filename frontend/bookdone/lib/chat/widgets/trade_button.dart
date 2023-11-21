import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../rest_api/rest_client.dart';
import '../../router/app_routes.dart';

class TradeButton extends HookConsumerWidget {
  final tradeId;
  final int refreshTrigger; // 채팅 입력 시 렌더링

  const TradeButton(
      {super.key, required this.tradeId, required this.refreshTrigger});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restClient = ref.read(restApiClientProvider);
    final userId = useState<int>(-1);
    final receiveUserId = useState<int>(-1);
    final donationId = useState<int>(-1);
    final tradeStatus = useState<String?>(null);

    // 유저 정보 읽기
    Future<void> readUserInfo() async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      userId.value = pref.getInt('userId')!;
    }

    // 거래 정보 가져오기
    fetchTradeInfo() async {
      try {
        await readUserInfo();

        if (userId.value != -1) {
          final tradeResponse =
              await restClient.getDonationIdByTradeId(tradeId);
          receiveUserId.value = tradeResponse.data.memberId;
          donationId.value = tradeResponse.data.donationId;
          tradeStatus.value = tradeResponse.data.tradeStatus;

          print('tradeId: $tradeId');
          print('receiveUserId: ${receiveUserId.value}');
          print('tradeStatus: ${tradeStatus.value}');
        }
      } catch (e) {
        print('Error fetching trade widget call info: $e');
      }
    }

    useEffect(() {
      fetchTradeInfo();
      print("refreshTrigger!! : $refreshTrigger");
    }, [refreshTrigger]);

    Future<void> updateTradeStatus() async {
      try {
        switch (tradeStatus.value) {
          case "NONE":
            await restClient.reservationRequestTrade(
                donationId.value, receiveUserId.value);
            break;
          case "DONATION_REQUESTED":
            await restClient.reservationConfirmTrade(
                donationId.value, receiveUserId.value);
            break;
          case "DONATION_CONFIRMED":
            await restClient.completionRequestTrade(
                donationId.value, receiveUserId.value);
            break;
          case "COMPLETION_REQUESTED":
            await restClient.completionConfirmTrade(
                donationId.value, receiveUserId.value);
            break;
          default:
            print("Invalid trade status");
        }
        await fetchTradeInfo();

        print(tradeStatus.value);
      } catch (e) {
        print('Error in updating trade status: $e');
      }
    }

    bool isButtonEnabled() {
      if (userId.value == receiveUserId.value) {
        return tradeStatus.value == "NONE" ||
            tradeStatus.value == "COMPLETION_REQUESTED";
      } else {
        return tradeStatus.value == "DONATION_REQUESTED" ||
            tradeStatus.value == "DONATION_CONFIRMED";
      }
    }

    String buttonText() {
      // 현재 상태에 따라 버튼 텍스트 결정
      switch (tradeStatus.value) {
        case "NONE":
          return "예약 요청";
        case "DONATION_REQUESTED":
          return "예약 확인";
        case "DONATION_CONFIRMED":
          return "완료 요청";
        case "COMPLETION_REQUESTED":
          return "완료 확인";
        case "COMPLETION_CONFIRMED":
          return "거래 완료";
        default:
          return "서버 에러";
      }
    }

    // 버튼 액션
    buttonAction() {
      // 현재 상태에 따라 적절한 네트워크 요청 수행
      if (isButtonEnabled()) {
        updateTradeStatus();
      }
    }

    Future<void> requestCancelTrade() async {
      try {
        // 서버에 거래 취소 요청 보내기
        // TODO: 적절한 서버 요청 함수를 호출하십시오.
        await restClient.cancelTrade(donationId.value, receiveUserId.value);
        await restClient.cancelChatRoom(tradeId);

        print('거래 취소 요청 성공');
        Navigator.pop(context, 'refreshNeeded');
        StartPageRoute()
            .push(context)
            .then((value) => ChatMainRoute().push(context));
      } catch (e) {
        print('거래 취소 요청 실패: $e');
      }
    }

    // 취소 버튼 활성화 조건
    bool isCancelButtonEnabled() {
      bool isTradeCancel = false;
      if (tradeStatus.value == "COMPLETION_CONFIRMED") {
        isTradeCancel = true;
      }

      if (tradeStatus.value == "NONE") {
        isTradeCancel = true;
      }
      return isTradeCancel;
    }

    // 취소 버튼 액션
    cancelTradeAction() async {
      if (isCancelButtonEnabled()) {
        final confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('채팅 종료'),
              content: Text('채팅을 종료하면 거래 내역과 채팅 방이 삭제됩니다.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('확인'),
                ),
              ],
            );
          },
        );

        if (confirm) {
          await requestCancelTrade();
        }
      }
    }

    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  backgroundColor: Color.fromARGB(255, 179, 170, 164),
                  foregroundColor: Colors.white),
              onPressed: isButtonEnabled() ? buttonAction : null,
              child: Text(buttonText()),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  backgroundColor: Color.fromARGB(255, 179, 170, 164),
                  foregroundColor: Colors.white),
              onPressed: isCancelButtonEnabled() ? cancelTradeAction : null,
              // 여기에 cancelTradeAction 함수 연결
              child: Text("채팅 종료"),
            ),
          ),
        ],
      ),
    );
  }
}
