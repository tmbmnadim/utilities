import 'dart:convert';
import 'dart:developer';
import 'package:utilities/live_communication/models/live_message.dart';
import 'package:utilities/live_communication/sources/live_source.dart';
import 'package:utilities/utils/data_state.dart';
import 'package:utilities/utils/repository_error_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/live_user.dart';
import '../models/live_meeting.dart';

class LiveRepository {
  final LiveSource _liveSource = LiveSource();
  late WebSocketChannel _channel;

  Future<DataState<LiveUser>> createUser(String name) async {
    log("LiveRepository<createUser> Called");
    return RepositoryErrorHandler.call(
      network: () async {
        return _liveSource.createUser(name);
      },
      proxyMessage: "Failed to create users!",
    );
  }

  Future<DataState<List<LiveUser>>> getUsers() async {
    return RepositoryErrorHandler.call(
      network: _liveSource.listUsers,
      proxyMessage: "Failed to get users!",
    );
  }

  Future<DataState<LiveMeeting>> createMeeting(
    String name,
    String hostUserId,
  ) async {
    return RepositoryErrorHandler.call(
      network: () async {
        return _liveSource.createMeeting(name, hostUserId);
      },
      proxyMessage: "Failed to create meeting!",
    );
  }

  Future<DataState<List<LiveMeeting>>> getMeetings() async {
    return RepositoryErrorHandler.call(
      network: () async {
        return _liveSource.getMeetings();
      },
      proxyMessage: "Failed to get meetings!",
    );
  }

  Future<DataState<Stream>> connectWebSocket() async {
    return RepositoryErrorHandler.call<Stream>(
      network: () async {
        _channel = await _liveSource.connectToWebsocket();
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

  Future<DataState> sendWS(LiveMessage message) async {
    return RepositoryErrorHandler.call<void>(
      network: () async {
        log("LiveRepository<sendWS>: ${message.toJson()}");
        _channel.sink.add(message.toJson());
      },
      proxyMessage: "Failed to send socket message!",
    );
  }
}
