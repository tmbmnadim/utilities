import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:get/get.dart' hide navigator;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:utilities/live_communication/models/live_meeting.dart';
import 'package:utilities/live_communication/models/live_message.dart';
import 'package:utilities/live_communication/models/live_user.dart';
import 'package:utilities/live_communication/repository/live_repository.dart';
import 'package:utilities/live_communication/view/live_screen.dart';
import 'package:utilities/utils/data_state.dart';

part 'live_state.dart';

class LiveController extends GetxController {
  LiveState state = LiveState();
  final LiveRepository _repository = LiveRepository();

  StreamSubscription? _streamSubscription;
  final Rx<LiveUser?> _selectedUser = Rx(null);
  LiveUser? get selectedUser => _selectedUser.value;
  set selectedUser(LiveUser? user) => _selectedUser.value = user;

  final Rx<LiveMeeting?> _selectedMeeting = Rx(null);
  LiveMeeting? get selectedMeeting => _selectedMeeting.value;
  set selectedMeeting(LiveMeeting? meeting) => _selectedMeeting.value = meeting;

  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, List<RTCIceCandidate>> _pendingCandidates = {};

  // ---------------------- USER REGISTRATION ----------------------

  Future<void> createUser(
    String name, {
    VoidCallback? onSuccess,
    Function(String error)? onFailure,
  }) async {
    try {
      state = state.copyWith(status: LiveSessionStatus.loading);
      update();

      final datastate = await _repository.createUser(name);

      if (datastate is DataSuccess) {
        state = state.copyWith(
          user: datastate.getData(),
          status: LiveSessionStatus.success,
        );
        update();
        await registerUser();
        onSuccess?.call();
      } else {
        throw datastate.getMessage("Failed to create user!");
      }
    } catch (e, s) {
      _handleErrors("createUser", e, s);
      onFailure?.call(e.toString());
    }
  }

  Future<void> registerUser() async {
    try {
      final message = LiveMessage(
        type: LiveMessageType.register,
        userId: state.user!.id,
      );
      await _repository.sendWS(message);
    } catch (e, s) {
      _handleErrors("registerUser", e, s);
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

      if (datastate is DataSuccess<List<LiveUser>>) {
        final users = datastate.getData();

        state = state.copyWith(
          availableUsers: users,
          status: LiveSessionStatus.success,
        );
        update();
        onSuccess?.call();
      } else {
        final message = datastate.getMessage("Failed to load users!");
        throw Exception(message);
      }
    } catch (e, s) {
      _handleErrors("loadUsers", e, s);
      onFailure?.call(e.toString());
    }
  }

  // ---------------------- MEETINGS ----------------------

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
        onSuccess?.call();
      } else {
        throw datastate.getMessage("Failed to create meeting!");
      }
    } catch (e, s) {
      _handleErrors("createMeeting", e, s);
      onFailure?.call(e.toString());
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
        onSuccess?.call();
      } else {
        throw datastate.getMessage("Failed to load meetings!");
      }
    } catch (e, s) {
      _handleErrors("getMeetings", e, s);
      onFailure?.call(e.toString());
    }
  }

  // ---------------------- SOCKET CONNECTION ----------------------

  void connectWS({
    required Function(String) onSuccess,
    Function(String)? onFailure,
  }) async {
    try {
      final datastate = await _repository.connectWebSocket();
      if (datastate is! DataSuccess) throw "Failed to connect WebSocket";

      final stream = datastate.getData();
      if (stream == null) throw "WebSocket stream is empty";

      _streamSubscription = stream.listen((event) async {
        log(
          "LiveController<WS Message>: ${jsonDecode(event)['type']}\nData:${jsonDecode(event)['data'].keys.toList()}",
        );
        final message = LiveMessage.fromJson(event);

        switch (message.type) {
          case LiveMessageType.registered:
            state = state.copyWith(
              isUserRegistered: true,
              status: LiveSessionStatus.registered,
            );
            update();
            break;

          case LiveMessageType.participantJoined:
            await _handleParticipantJoined(message);
            break;

          case LiveMessageType.webrtcOffer:
            log("RECEIVED WEB RTC OFFER");
            await _handleOffer(message);
            break;

          case LiveMessageType.webrtcAnswer:
            await _handleAnswer(message);
            break;

          case LiveMessageType.webICECandidate:
            await _handleRemoteCandidate(message);
            break;

          default:
            log("Unhandled message type: ${message.type}");
        }
      });

      state = state.copyWith(isConnectedToWS: true);
      update();
      onSuccess("Connected to WebSocket!");
    } catch (e, s) {
      _handleErrors("connectWS", e, s);
      onFailure?.call(e.toString());
    }
  }

  // ---------------------- WEBRTC HANDLERS ----------------------

  Future<void> joinMeeting({required VoidCallback onSuccess}) async {
    try {
      final meetingId = _selectedMeeting.value?.id;
      if (meetingId == null) throw "Select a meeting first";

      final joinMsg = LiveMessage(
        type: LiveMessageType.join,
        meetingId: meetingId,
      );
      await _repository.sendWS(joinMsg);

      final renderer = RTCVideoRenderer();
      await renderer.initialize();

      final localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {'facingMode': 'user'},
      });

      renderer.srcObject = localStream;

      state = state.copyWith(
        currentMeeting: _selectedMeeting.value,
        localRenderer: renderer,
      );

      onSuccess();
    } catch (e, s) {
      _handleErrors("joinMeeting", e, s);
    }
  }

  Future<void> callUser({
    VoidCallback? onSuccess,
    Function(String error)? onFailure,
  }) async {
    try {
      final targetId = _selectedUser.value?.id;
      if (targetId == null) throw Exception("Please Select a user");

      final localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {'facingMode': 'user'},
      });

      final renderer = RTCVideoRenderer();
      await renderer.initialize();

      renderer.srcObject = localStream;

      state = state.copyWith(localRenderer: renderer);

      // Peer connection
      RTCPeerConnection pc;
      if (!_peerConnections.containsKey(targetId) ||
          _peerConnections[targetId] == null) {
        pc = await _createPeerConnection(targetId);
        _peerConnections[targetId] = pc;
      } else {
        pc = _peerConnections[targetId]!;
      }

      // Add local tracks
      for (var track in localStream.getTracks()) {
        pc.addTrack(track, localStream);
      }

      // Create offer
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);

      // Send offer
      await _repository.sendWS(
        LiveMessage(
          type: LiveMessageType.webrtcOffer,
          fromId: state.user!.id,
          targetId: targetId,
          sdp: offer.sdp,
          sdpType: offer.type,
        ),
      );
      onSuccess?.call();
    } catch (e, s) {
      _handleErrors("callUser", e, s);
      onFailure?.call(e.toString());
    }
  }

  Future<void> _handleParticipantJoined(LiveMessage msg) async {
    final remoteUserId = msg.userId!;
    if (remoteUserId == state.user!.id) return;
    if (_peerConnections.containsKey(remoteUserId)) return;

    // Peer connection
    final pc = await _createPeerConnection(remoteUserId);
    _peerConnections[remoteUserId] = pc;

    // Add local tracks
    for (var track in state.localRenderer!.srcObject!.getTracks()) {
      pc.addTrack(track, state.localRenderer!.srcObject!);
    }

    // Create offer
    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    // Send offer
    await _repository.sendWS(
      LiveMessage(
        type: LiveMessageType.webrtcOffer,
        sdp: offer.sdp,
        sdpType: offer.type,
        meetingId: state.currentMeeting!.id,
      ),
    );
    _peerConnections[remoteUserId] = pc;
    _joinedParticipantId = remoteUserId;

    update();
  }

  String? _joinedParticipantId;

  Future<void> _handleOffer(LiveMessage msg) async {
    String? remoteUserId = msg.fromId;
    if (msg.sdp == null ||
        msg.sdpType == null ||
        remoteUserId == null ||
        remoteUserId == state.user!.id) {
      return;
    }

    RTCVideoRenderer renderer;
    if (state.remoteRenderers[remoteUserId] == null) {
      renderer = RTCVideoRenderer();
      await renderer.initialize();
      state.remoteRenderers[remoteUserId] = renderer;
      update();
    } else {
      renderer = state.remoteRenderers[remoteUserId]!;
    }

    RTCPeerConnection pc;
    if (_peerConnections[remoteUserId] == null) {
      pc = await _createPeerConnection(remoteUserId);
      _peerConnections[remoteUserId] = pc;
    } else {
      pc = _peerConnections[remoteUserId]!;
    }

    await pc.setRemoteDescription(RTCSessionDescription(msg.sdp, msg.sdpType));

    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);

    await _repository.sendWS(
      LiveMessage(
        type: LiveMessageType.webrtcAnswer,
        sdp: answer.sdp,
        sdpType: answer.type,
        targetId: remoteUserId,
        meetingId: msg.meetingId,
      ),
    );
  }

  Future<void> _handleAnswer(LiveMessage msg) async {
    final remoteUserId = msg.fromId;
    if (msg.sdp == null ||
        msg.sdpType == null ||
        remoteUserId == null ||
        remoteUserId == state.user!.id) {
      return;
    }

    RTCPeerConnection? pc = _peerConnections[remoteUserId];
    pc ??= await _createPeerConnection(remoteUserId);
    await pc.setRemoteDescription(RTCSessionDescription(msg.sdp, msg.sdpType));
  }

  Future<void> _handleRemoteCandidate(LiveMessage msg) async {
    log("_handleRemoteCandidate: Received Remote Candidate");
    final candidate = msg.candidate;
    if (candidate == null) return;
    log("_handleRemoteCandidate: Remote Candidate is Ok");

    RTCPeerConnection? pc = _peerConnections[msg.userId];
    pc ??= await _createPeerConnection(msg.fromId!);

    await pc.addCandidate(candidate);

    log("_handleRemoteCandidate: Remote candidate is added to peerConnection");

    log("_handleRemoteCandidate: Redirecting to StreamScreen");
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Get.to(LiveStreamScreen()),
    );
  }

  Future<RTCPeerConnection> _createPeerConnection(String id) async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan',
    };

    final pc = await createPeerConnection(config);

    pc.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        state.remoteRenderers[id]?.srcObject = event.streams[0];
      }
    };

    pc.onIceCandidate = (RTCIceCandidate candidate) {
      _repository.sendWS(
        LiveMessage(
          type: LiveMessageType.webICECandidate,
          candidate: candidate,
          fromId: state.user!.id,
          targetId: id,
          meetingId: _selectedMeeting.value?.id,
        ),
      );
      log("_createPeerConnection: Candidate is sent");
    };

    if (_pendingCandidates.containsKey(id)) {
      for (var candidate in _pendingCandidates[id]!) {
        await pc.addCandidate(candidate);
      }
      _pendingCandidates.remove(id);
    }

    return pc;
  }

  // ---------------------- CLEANUP ----------------------

  void disconnectWS({
    VoidCallback? onSuccess,
    Function(String)? onFailure,
  }) async {
    try {
      final datastate = await _repository.disconnectWebSocket();
      if (datastate is DataSuccess) {
        _streamSubscription?.cancel();
        _streamSubscription = null;

        for (var pc in _peerConnections.values) {
          await pc.close();
        }
        _peerConnections.clear();

        state = state.copyWith(status: LiveSessionStatus.localReady);
        update();
        onSuccess?.call();
      } else {
        throw datastate.getMessage("Failed to disconnect from ws!");
      }
    } catch (e, s) {
      _handleErrors("disconnectWS", e, s);
      onFailure?.call(e.toString());
    }
  }

  Future<void> disconnectMeeting() async {
    try {
      for (var pc in _peerConnections.values) {
        await pc.close();
      }
      _peerConnections.clear();

      for (var renderer in state.remoteRenderers.values) {
        await renderer.dispose();
      }
      state.remoteRenderers.clear();

      state = state.copyWith(
        currentMeeting: null,
        status: LiveSessionStatus.localReady,
      );
      update();
    } catch (e, s) {
      _handleErrors("disconnectMeeting", e, s);
    }
  }

  void _handleErrors(String methodName, Object? error, StackTrace s) {
    log("LiveController<$methodName>: $error", error: error, stackTrace: s);
    state = state.copyWith(
      status: LiveSessionStatus.failed,
      errorMessage: "$error",
    );
    update();
  }
}
