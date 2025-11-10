import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:utilities/live_communication/models/live_meeting.dart';
import 'package:utilities/live_communication/models/live_user.dart';
import 'package:utilities/live_communication/models/server_error.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LiveSource {
  final String? _apiBase = dotenv.env["API_BASE"];
  final String? _wsUrl = dotenv.env["WEB_SOCKET"];

  Future<LiveUser> createUser(String name) async {
    try {
      log("LiveSource<createUser> Called");
      final endpoint = "/users";
      Uri? uri = Uri.tryParse("$_apiBase$endpoint");
      if (uri == null) throw Exception("Invalid or Empty API");

      final body = {"name": name};

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final resBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (resBody.containsKey("id")) {
        return LiveUser.fromJson(resBody);
      } else {
        throw WebRTCServerException.fromJson(resBody);
      }
    } catch (e, s) {
      log("LiveSource<createUser>: $e\n$s");
      rethrow;
    }
  }

  Future<List<LiveUser>> listUsers() async {
    final endpoint = "/users";
    Uri? uri = Uri.tryParse("$_apiBase$endpoint");
    if (uri == null) throw Exception("Invalid or Empty API");
    final headers = {"Content-Type": "application/json"};

    final response = await http.get(uri, headers: headers);

    final resBody = jsonDecode(response.body);

    log("LiveSource<listUsers> DATA: $resBody");
    if (resBody is List) {
      return resBody.map((e) => LiveUser.fromJson(e)).toList();
    } else {
      throw WebRTCServerException.fromJson(resBody);
    }
  }

  Future<LiveMeeting> createMeeting(String name, String hostUserId) async {
    try {
      final endpoint = "/meetings";
      Uri? uri = Uri.tryParse("$_apiBase$endpoint");
      if (uri == null) throw Exception("Invalid or Empty API");

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': name, 'host_id': hostUserId}),
      );

      final resBody = jsonDecode(response.body) as Map<String, dynamic>;

      log("LiveSource<createUser> DATA: $resBody");

      if (resBody.containsKey("meetingId")) {
        return LiveMeeting.fromJson(resBody);
      } else {
        throw WebRTCServerException.fromJson(resBody);
      }
    } catch (e, s) {
      log("LiveSource<createMeeting>: $e\n$s");
      rethrow;
    }
  }

  Future<List<LiveMeeting>> getMeetings() async {
    final endpoint = "/meetings";
    Uri? uri = Uri.tryParse("$_apiBase$endpoint");
    if (uri == null) throw Exception("Invalid or Empty API");

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final resBody = jsonDecode(response.body);

    log("LiveSource<getMeetings> DATA: $resBody");
    if (resBody is List) {
      return resBody.map((e) => LiveMeeting.fromJson(e)).toList();
    } else {
      throw WebRTCServerException.fromJson(resBody);
    }
  }

  Future<WebSocketChannel> connectToWebsocket() async {
    try {
      Uri? uri = Uri.tryParse("$_wsUrl");
      if (uri == null) throw Exception("Invalid or Empty API");

      return WebSocketChannel.connect(uri);
    } catch (e, s) {
      log("LiveSource<connectToWebsocket>: $e\n$s");
      rethrow;
    }
  }
}
