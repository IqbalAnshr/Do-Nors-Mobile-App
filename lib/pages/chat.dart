import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dio_client.dart';
import '../services/socket_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatPage extends StatefulWidget {
  final int userId2;
  final String name;
  final String? chat;

  ChatPage({required this.userId2, required this.name, this.chat});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isLoading = true;
  bool hasMore = true;
  bool isLoadingMore = false;
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _messageController = TextEditingController();
  late SocketService _socketService;
  int currentPage = 1;
  final int messagesPerPage = 20;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _socketService = Provider.of<SocketService>(context, listen: false);
    fetchMessages();

    if (widget.chat != null && widget.chat!.isNotEmpty) {
      _messageController.text = widget.chat!;
      sendMessage();
    }

    _socketService.socket?.on('chatlist', (data) {
      print('Message received: $data');
      final newMessage = {
        'receiver': data['user'],
        'senderId': data['senderId'],
        'content': data['lastMessage'],
        'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
      };
      if (mounted) {
        setState(() {
          messages.insert(0, newMessage);
        });
      }
    });

    _timer = Timer.periodic(Duration(minutes: 1), (Timer t) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _timer?.cancel();
    _socketService.socket?.off('chatlist');
    _socketService.socket?.off('online');
    super.dispose();
  }

  Future<void> fetchMessages({int page = 1}) async {
    final String apiUrl =
        '/api/chats/with/${widget.userId2}?page=$page&limit=$messagesPerPage';
    setState(() {
      if (page == 1)
        isLoading = true;
      else
        isLoadingMore = true;
    });

    try {
      final response = await DioClient.instance.get(apiUrl);
      if (response.statusCode == 200) {
        final jsonData = response.data['data'];
        if (mounted) {
          setState(() {
            if (page == 1) {
              messages = List<Map<String, dynamic>>.from(jsonData);
            } else {
              messages.addAll(List<Map<String, dynamic>>.from(jsonData));
            }
            hasMore = jsonData.length == messagesPerPage;
            currentPage = page;
          });
        }
      } else {
        print('Failed to load messages');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    } finally {
      if (mounted) {
        setState(() {
          if (page == 1)
            isLoading = false;
          else
            isLoadingMore = false;
        });
      }
    }
  }

  Future<void> sendMessage() async {
    final messageContent = _messageController.text.trim();
    if (messageContent.isEmpty) return;

    final message = {
      'receiverId': widget.userId2,
      'content': messageContent,
    };

    try {
      _socketService.socket?.emit('message', message);

      final newMessage = {
        'receiver': {
          'id': widget.userId2,
          'name': widget.name,
        },
        'senderId': message['authId'],
        'content': messageContent,
        'createdAt': DateTime.now().toIso8601String(),
      };

      if (mounted) {
        setState(() {
          messages.insert(0, newMessage);
        });
      }

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/Messages');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          centerTitle: true,
          toolbarHeight: 70,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/Messages');
            },
            child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!isLoadingMore &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.minScrollExtent) {
                    if (hasMore) {
                      fetchMessages(page: currentPage + 1);
                    }
                  }
                  return true;
                },
                child: ListView.builder(
                  reverse: true,
                  itemCount: messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return isLoadingMore
                          ? Center(child: CircularProgressIndicator())
                          : SizedBox.shrink();
                    }

                    final message = messages[index];
                    final isSelf = message['senderId'] != widget.userId2;
                    return Align(
                      alignment:
                          isSelf ? Alignment.centerRight : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: 300), // Set max width
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color:
                                isSelf ? Colors.blueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: isSelf
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSelf ? 'You' : widget.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelf ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                message['message'] ?? message['content'],
                                style: TextStyle(
                                  color: isSelf ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _calculateTimeAgo(message['createdAt']),
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isSelf ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Scrollbar(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        ),
                        maxLines: 2,
                        onSubmitted: (value) => sendMessage(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTimeAgo(String createdAt) {
    DateTime createdAtDateTime = DateTime.parse(createdAt);
    return timeago.format(createdAtDateTime);
  }
}
