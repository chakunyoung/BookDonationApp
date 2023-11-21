import 'package:bookdone/chat/widgets/chatroom_card.dart';
import 'package:bookdone/search/model/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../rest_api/rest_client.dart';
import '../model/chat.dart';

class ChatMain extends HookConsumerWidget {
  const ChatMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRooms = useState<List<ChatRoomResponse>>([]);
    final restClient = ref.read(restApiClientProvider);
    final isChatRoomFetched = useState(false);
    final booksData = useState<Map<String, BookData>>({});

    fetchChatRooms() async {
      try {
        final chatRoomResponse = await restClient.chatRoomList();
        chatRooms.value = chatRoomResponse.data;
        isChatRoomFetched.value = true;

        if(chatRooms.value.isEmpty) return;

        // 채팅방에서 ISBN 수집
        List<String> isbnList = chatRooms.value
            .map((chatRoom) => chatRoom.isbn!)
            .toList();

        // 모아서 한번에 요청
        BooksDto booksDto = await restClient.getBooksDetails(isbnList);
        booksData.value = booksDto.data;

      } catch (e) {
        print('채팅방 또는 책 정보 가져오기 오류: $e');
      }
    }

    useEffect(() {
      if (chatRooms.value.isEmpty && !isChatRoomFetched.value) {
        fetchChatRooms();
      }

      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
      ),
      body: chatRooms.value.isEmpty && isChatRoomFetched.value
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.chat_bubble_outline,
              size: 100,
              color: Colors.grey[400],
            ),
            Text(
              "채팅이 없습니다.",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "도서 검색을 통해 책도네를 시작해보세요.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      )
          : ListView.separated(
        itemCount: chatRooms.value.length,
        itemBuilder: (context, index) {
          final chatRoom = chatRooms.value[index];
          final isbn = chatRoom.isbn;

          // 해당 ISBN에 대한 책 정보 찾기
          final bookData = booksData.value[isbn];

          // ChatRoomCard에 채팅방 정보와 책 정보 전달
          return ChatRoomCard(chatRoom: chatRoom, bookData: bookData);
        },
        separatorBuilder: (context, index) => const SizedBox.shrink(),
      ),
    );
  }
}