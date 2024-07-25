import 'dart:async';
import 'package:flutter/material.dart';
import '../components/appbar.dart';
import '../components/navigation.dart';
import '../services/dio_client.dart';
import 'package:provider/provider.dart';
import '../services/socket_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../pages/chat.dart';

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  bool isLoading = true;
  List<Map<String, dynamic>> chatMessages = [];
  List<int> onlineUserIds = [];
  late SocketService _socketService;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchOnlineUsers();
    _timer = Timer.periodic(Duration(minutes: 1), (Timer t) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _socketService = Provider.of<SocketService>(context, listen: false);

    _socketService.socket?.on('chatlist', (data) {
      print('Chat list received: $data');
      final newChatMessage = Map<String, dynamic>.from(data);

      if (mounted) {
        setState(() {
          bool messageExists = false;

          for (int i = 0; i < chatMessages.length; i++) {
            if (chatMessages[i]['user']['id'] == newChatMessage['senderId'] &&
                chatMessages[i]['authId'] != newChatMessage['authId']) {
              chatMessages[i]['lastMessage'] = newChatMessage['lastMessage'];
              chatMessages[i]['createdAt'] = newChatMessage['createdAt'];
              chatMessages[i]['senderId'] = newChatMessage['senderId'];
              messageExists = true;
              break;
            }
          }

          if (!messageExists) {
            chatMessages.insert(
                0, newChatMessage); // Add new message to the top
          }

          chatMessages.sort((a, b) {
            return b['createdAt'].compareTo(a['createdAt']);
          });
        });
      }
    });

    _socketService.socket?.on('online', (data) {
      print('Online users updated: $data');
      if (mounted) {
        setState(() {
          onlineUserIds = List<int>.from(data.map((user) => user['userId']));
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _socketService.socket?.off('chatlist');
    _socketService.socket?.off('online');
    super.dispose();
  }

  Future<void> fetchOnlineUsers() async {
    final String apiUrl = '/api/chats/online-users';
    try {
      final response = await DioClient.instance.get(apiUrl);
      if (response.statusCode == 200) {
        final jsonData = response.data['onlineUsers'];
        if (mounted) {
          setState(() {
            onlineUserIds =
                List<int>.from(jsonData.map((user) => user['userId']));
          });
        }
      } else {
        throw Exception('Failed to load online users');
      }
    } catch (e) {
      print('Error fetching online users: $e');
    }
  }

  Future<void> fetchData() async {
    final String apiUrl = '/api/chats';
    setState(() {
      isLoading = true;
    });
    try {
      final response = await DioClient.instance.get(apiUrl);
      if (response.statusCode == 200) {
        final jsonData = response.data;
        if (mounted) {
          setState(() {
            chatMessages = List<Map<String, dynamic>>.from(jsonData);
          });
        }
      } else {
        throw Exception('Failed to load chat messages');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool isUserOnline(int userId) {
    return onlineUserIds.contains(userId);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/Dashboard');
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Messages'),
        bottomNavigationBar: FluidNavBar(selectedIndex: 3),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: fetchData,
                child: chatMessages.length == 0
                    ? Center(
                        child: Text(
                        'No messages found.',
                        style: TextStyle(fontSize: 20),
                      ))
                    : Container(
                        color: Colors.white,
                        child: ListView.builder(
                          itemCount: chatMessages.length,
                          itemBuilder: (context, index) {
                            final message = chatMessages[index];
                            final isSelf =
                                message['senderId'] == message['authId'];
                            final isOnline =
                                isUserOnline(message['user']['id']);
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      userId2: message['user']['id'],
                                      name: message['user']['name'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: Stack(
                                    children: [
                                      CircleAvatar(
                                        child: Text(
                                            message['user']?['name'] != null
                                                ? message['user']['name'][0]
                                                    .toUpperCase()
                                                : 'U'),
                                        backgroundColor: Colors.grey,
                                      ),
                                      if (isOnline)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.green,
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.5),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  title: Text(
                                    message['user']?['name'] ?? 'Unknown',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(
                                    isSelf
                                        ? 'You: ${_shorten(message['lastMessage'])}'
                                        : _shorten(message['lastMessage']),
                                    style: TextStyle(fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Text(
                                      _calculateTimeAgo(message['createdAt'])),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
      ),
    );
  }

  String _calculateTimeAgo(String createdAt) {
    DateTime createdAtDateTime = DateTime.parse(createdAt);
    return timeago.format(createdAtDateTime);
  }

  String _shorten(String text, {int maxLength = 25}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
