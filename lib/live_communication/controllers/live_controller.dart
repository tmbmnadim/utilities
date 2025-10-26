import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:utilities/live_communication/models/live_meeting.dart';
import 'package:utilities/live_communication/models/live_user.dart';
import 'package:utilities/live_communication/repository/live_repository.dart';
import 'package:utilities/utils/data_state.dart';

part 'live_state.dart';

class LiveController extends GetxController {
  LiveState state = LiveState();
  final LiveRepository repository = LiveRepository();

  Future<void> loadUsers() async {
    try {
      final datastate = await repository.getUsers();
      if (datastate is DataSuccess) {
        state = state.copyWith(users: datastate.getData());
      } else {
        throw datastate.getMessage("Failed to load users!");
      }
    } catch (e, s) {
      _handleErrors("loadUsers", e, s);
    }
  }

  Future<void> createMeeting(String name) async {
    try {
      final datastate = await repository.createMeeting(name);
      if (datastate is DataSuccess) {
        state = state.copyWith(currentMeeting: datastate.getData());
      } else {
        throw datastate.getMessage("Failed to load users!");
      }
    } catch (e, s) {
      _handleErrors("createMeeting", e, s);
    }
  }

  void connectWS() async {
    try {
      final datastate = await repository.connectWebSocket();
      if (datastate is DataSuccess) {
        final stream = datastate.getData();
        if(stream == null) throw "Stream is empty";
        stream.listen((event) {});
      } else {
        throw datastate.getMessage("Failed to load users!");
      }
    } catch (e, s) {
      _handleErrors("createMeeting", e, s);
    }
  }

  void disconnectWS() => repository.disconnectWebSocket();

  void _handleErrors(String methodName, Object? error, StackTrace s) {
    log("LiveController<$methodName>: $error", error: error, stackTrace: s);
    state = state.copyWith(
      status: LiveSessionStatus.failed,
      errorMessage: "$error",
    );
  }
}
