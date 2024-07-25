import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dio_client.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? _socket;
  int _socketReconnectionAttempts = 0;
  final int _maxReconnectAttempts = 10;

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  Future<void> connect() async {
    await _initializeSocket();
  }

  Future<void> disconnect() async {
    await _disconnectSocket();
  }

  Future<void> _initializeSocket() async {
    if (_socket != null && _socket!.connected) {
      await _disconnectSocket();
    }
    await _connectSocket();
  }

  Future<void> _connectSocket() async {
    final serverUrl =
        dotenv.env['SOCKET_SERVER_URL'] ?? 'http://147.139.169.78';
    String? token = null;
    token = await _refreshToken();

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({"x-access-token": "Bearer $token"})
          .enableForceNew()
          .build(),
    );

    _socket!.connect();

    _socket!.on('connect', (_) {
      print('Socket connected: ${_socket!.id}');
      _socket!.emit('online');
      _socketReconnectionAttempts =
          0; // Reset reconnection attempts on successful connection
    });

    _socket!.on('disconnect', (reason) async {
      print('Socket disconnected, reason: $reason');
      if (reason == 'transport close' || reason == 'unauthorized') {
        _reconnectWithBackoff(reason);
      } else {
        print('Could not reconnect');
      }
    });

    _socket!.on('error', (error) async {
      print('Socket Error: $error');
      if (error['message'] == 'invalid_token' ||
          error['message'] == 'authentication_error' ||
          error['message'] == 'Token expired') {
        _reconnectWithBackoff(error['message']);
      } else {
        print('Could not reconnect');
      }
    });

    _socket!.on('online', (data) {
      print('Online users: $data');
    });

    _socket!.on('chatlist', (data) {
      print('Chat list received: $data');
    });

    _socket!.on('message', (data) {
      print('Message received: $data');
      // Handle the received message data
    });

    _socket!.on('updateChatList', (data) {
      print('Update chat list: $data');
      // Handle the chat list update
    });
  }

  Future<void> _disconnectSocket() async {
    await _socket!.disconnect();
    _socket!.destroy();
    _socket!.dispose();
    await _socket!.close();
    _socket = null;
    _socketReconnectionAttempts = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('refreshToken');
  }

  Future<void> _handleDisconnect() async {
    await _initializeSocket();
  }

  Future<String> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    print("Refresh Token: $refreshToken");

    if (refreshToken == null) {
      print('No refresh token found');
      throw Exception('No refresh token found');
    }

    try {
      final response = await DioClient.instance.post(
        '/api/auth/refresh-token',
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: {
          'token': refreshToken,
        },
      );

      print(response.data['data']['accessToken']);

      if (response.statusCode == 200) {
        return response.data['data']['accessToken'];
      } else {
        print('Error refreshing token');
        throw Exception('Error refreshing token');
      }
    } catch (e) {
      print("Error refreshing token: $e");
      throw Exception('Error refreshing token');
    }
  }

  void _reconnectWithBackoff(String reason) async {
    if (_socketReconnectionAttempts >= _maxReconnectAttempts) {
      print('Max reconnection attempts reached. Giving up.');
      return;
    }

    var timeout = (_socketReconnectionAttempts == 0 ? 5000 : 60000);
    print('Reconnecting in ${timeout / 1000} seconds...');

    Timer(Duration(milliseconds: timeout), () async {
      print('Trying to reconnect manually');
      _socketReconnectionAttempts++;
      await connect();
    });
  }

  IO.Socket? get socket => _socket;

  void sendMessage(String event, Map<String, dynamic> data) {
    _socket?.emit(event, data);
  }

  void dispose() async {
    await _disconnectSocket();
  }
}
