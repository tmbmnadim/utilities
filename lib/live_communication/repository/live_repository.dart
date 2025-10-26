import 'dart:convert';
import 'package:utilities/utils/data_state.dart';
import 'package:utilities/utils/repository_error_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import '../models/live_user.dart';
import '../models/live_meeting.dart';

class LiveRepository {
  final String apiBase = "http://localhost:3000/api";
  final String wsUrl = "ws://localhost:8080/ws";

  late WebSocketChannel _channel;

  Future<DataState<Stream>> connectWebSocket() async {
    return RepositoryErrorHandler.call<Stream>(
      network: () async {
        _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
        return _channel.stream;
      },
      proxyMessage: "Failed to connect to web socket!",
    );
  }

  Future<DataState> disconnectWebSocket() async {
    return RepositoryErrorHandler.call<void>(
      network: () async {
        _channel.sink.close();
      },
      proxyMessage: "Failed to disconnect from web socket!",
    );
  }

  Future<DataState> sendWS(Map<String, dynamic> message) async {
    return RepositoryErrorHandler.call<void>(
      network: () async {
        _channel.sink.add(jsonEncode(message));
      },
      proxyMessage: "Failed to send socket message!",
    );
  }

  Future<DataState<List<LiveUser>>> getUsers() async {
    return RepositoryErrorHandler.call(
      network: () async {
        final res = await http.get(Uri.parse('$apiBase/users'));
        final List<dynamic> jsonData = jsonDecode(res.body);
        return jsonData.map((e) => LiveUser.fromJson(e)).toList();
      },
      proxyMessage: "Failed to get users!",
    );
  }

  Future<DataState<LiveMeeting>> createMeeting(String name) async {
    return RepositoryErrorHandler.call(
      network: () async {
        final res = await http.post(
          Uri.parse('$apiBase/meetings'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': name}),
        );
        return LiveMeeting.fromJson(jsonDecode(res.body));
      },
      proxyMessage: "Filed to create meeting!",
    );
  }
}
