import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:utilities/live_communication/models/live_meeting.dart';
import 'package:utilities/live_communication/models/live_message.dart';
import 'package:utilities/live_communication/models/live_user.dart';
import 'package:utilities/live_communication/repository/live_repository.dart';
import 'package:utilities/utils/data_state.dart';

part 'live_state.dart';

class LiveController extends GetxController {
  LiveState state = LiveState();
  final LiveRepository _repository = LiveRepository();

  StreamSubscription? _streamSubscription;

  final Rx<LiveUser?> _selectedUser = Rx(null);
  LiveUser? get selectedUser => _selectedUser.value;
  set selectedUser(LiveUser? user) {
    _selectedUser.value = user;
  }

  final Rx<LiveMeeting?> _selectedMeeting = Rx(null);
  LiveMeeting? get selectedMeeting => _selectedMeeting.value;
  set selectedMeeting(LiveMeeting? meeting) {
    _selectedMeeting.value = meeting;
  }

  Future<void> createUser(
    String name, {
    VoidCallback? onSuccess,
    Function(String error)? onFailure,
  }) async {
    try {
      log("LiveController<createUser> Called");
      state = state.copyWith(status: LiveSessionStatus.loading);
      update();

      final datastate = await _repository.createUser(name);

      if (datastate is DataSuccess) {
        state = state.copyWith(
          user: datastate.getData(),
          status: LiveSessionStatus.success,
        );
        update();
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        throw datastate.getMessage("Failed to create user!");
      }
    } catch (e, s) {
      _handleErrors("createUser", e, s);
      update();
      if (onFailure != null) {
        onFailure(e.toString());
      }
    }
  }

  Future<void> loadUsers({
    VoidCallback? onSuccess,
    Function(String error)? onFailure,
  }) async {
    try {
      state = state.copyWith(status: LiveSessionStatus.loading);
      update();
      final datastate = await _repository.getUsers();
      if (datastate is DataSuccess) {
        state = state.copyWith(
          availableUsers: datastate.getData(),
          status: LiveSessionStatus.success,
        );
        update();
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        throw datastate.getMessage("Failed to load users!");
      }
    } catch (e, s) {
      _handleErrors("loadUsers", e, s);
      update();
      if (onFailure != null) {
        onFailure(e.toString());
      }
    }
  }

  Future<void> createMeeting(
    String name, {
    VoidCallback? onSuccess,
    Function(String error)? onFailure,
  }) async {
    try {
      final datastate = await _repository.createMeeting(name, state.user!.id);
      if (datastate is DataSuccess) {
        state = state.copyWith(
          currentMeeting: datastate.getData(),
          status: LiveSessionStatus.success,
        );
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        throw datastate.getMessage("Failed to load users!");
      }
    } catch (e, s) {
      _handleErrors("loadUsers", e, s);
      update();
      if (onFailure != null) {
        onFailure(e.toString());
      }
    }
  }

  Future<void> getMeetings({
    VoidCallback? onSuccess,
    Function(String error)? onFailure,
  }) async {
    try {
      state = state.copyWith(status: LiveSessionStatus.loading);
      update();
      final datastate = await _repository.getMeetings();
      if (datastate is DataSuccess) {
        state = state.copyWith(
          availableMeetings: datastate.getData(),
          status: LiveSessionStatus.success,
        );
        update();
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        throw datastate.getMessage("Failed to load meetings!");
      }
    } catch (e, s) {
      _handleErrors("getMeetings", e, s);
      update();
      if (onFailure != null) {
        onFailure(e.toString());
      }
    }
  }

  void connectWS({
    required Function(String error) onSuccess,
    Function(String error)? onFailure,
  }) async {
    try {
      state = state.copyWith(status: LiveSessionStatus.loading);
      update();
      final datastate = await _repository.connectWebSocket();
      if (datastate is DataSuccess) {
        final stream = datastate.getData();
        if (stream == null) throw "Stream is empty";
        _streamSubscription = stream.listen((event) {
          log("LiveController<connectWS>:$event");
          final status = LiveMessage.fromJson(event);
          switch (status.type) {
            case StatusType.register:
              state = state.copyWith(status: LiveSessionStatus.loading);
              update();
            case StatusType.registered:
              onSuccess("User is online");

              state = state.copyWith(
                status: LiveSessionStatus.registered,
                isUserRegistered: true,
              );
              update();
            case StatusType.join:
              state = state.copyWith(status: LiveSessionStatus.loading);
              update();
            case StatusType.participantJoined:
              onSuccess("${status.userId} Joined the meeting");
              state = state.copyWith(status: LiveSessionStatus.live);
              update();
            case StatusType.leave:
              state = state.copyWith(status: LiveSessionStatus.loading);
              update();
            case StatusType.participantLeft:
              onSuccess("${status.userId} left the meeting");
            case StatusType.error:
              onSuccess(status.message ?? "Something went wrong");
          }
        });

        state = state.copyWith(
          status: LiveSessionStatus.connected,
          isConnectedToWS: true,
        );
        update();
        onSuccess("Connected to socket!");
      } else {
        throw datastate.getMessage("Failed to connect to ws!");
      }
    } catch (e, s) {
      _handleErrors("connectWS", e, s);
      update();
      if (onFailure != null) {
        onFailure(e.toString());
      }
    }
  }

  Future<void> registerUser() async {
    try {
      state = state.copyWith(status: LiveSessionStatus.loading);
      update();

      final message = LiveMessage(
        type: StatusType.register,
        userId: state.user!.id,
      );

      final datastate = await _repository.sendWS(message);

      if (datastate is DataFailed) {
        throw datastate.getMessage("Failed to join meetings!");
      }
    } catch (e, s) {
      _handleErrors("registerUser", e, s);
      update();
    }
  }

  Future<void> joinMeeting() async {
    try {
      if (_selectedMeeting.value?.id == null) {
        throw Exception("Select a meeting first");
      }
      state = state.copyWith(status: LiveSessionStatus.loading);
      update();

      final message = LiveMessage(
        type: StatusType.join,
        meetingId: _selectedMeeting.value!.id,
      );

      final datastateMeeting = await _repository.sendWS(message);

      if (datastateMeeting is DataFailed) {
        throw datastateMeeting.getMessage("Failed to join meetings!");
      }
    } catch (e, s) {
      _handleErrors("joinMeeting", e, s);
      update();
    }
  }

  void disconnectWS({
    VoidCallback? onSuccess,
    Function(String error)? onFailure,
  }) async {
    try {
      final datastate = await _repository.disconnectWebSocket();
      if (datastate is DataSuccess) {
        _streamSubscription?.cancel();
        _streamSubscription = null;
        state = state.copyWith(status: LiveSessionStatus.localReady);
        update();
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        throw datastate.getMessage("Failed to disconnect from ws!");
      }
    } catch (e, s) {
      if (onFailure != null) {
        onFailure(e.toString());
      }
      _handleErrors("disconnectWS", e, s);
    }
  }

  void _handleErrors(String methodName, Object? error, StackTrace s) {
    log("LiveController<$methodName>: $error", error: error, stackTrace: s);
    state = state.copyWith(
      status: LiveSessionStatus.failed,
      errorMessage: "$error",
    );
  }
}
