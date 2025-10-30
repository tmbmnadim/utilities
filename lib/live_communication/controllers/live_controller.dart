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
        final message = LiveMessage.fromJson(event);
        log("RECEIVED MESSAGE: $message");

        switch (message.type) {
          case LiveMessageType.registered:
            state = state.copyWith(
              isUserOnline: true,
              status: LiveSessionStatus.registered,
            );
            update();
            break;

          case LiveMessageType.participantJoined:
            await _handleParticipantJoined(message);
            break;

          case LiveMessageType.webrtcOffer:
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

  // Planning to use it for initiating connection whenever a user
  // joins a meeting.
  String? _joinedParticipantId;

  Future<void> callUser({
    VoidCallback? onSuccess,
    Function(String error)? onFailure,
  }) async {
    try {
      final remoteUser = _selectedUser.value?.id;
      if (remoteUser == null) throw Exception("Please Select a user");

      // Initializing Local Renderer
      final renderer = RTCVideoRenderer();
      await renderer.initialize();

      // Getting Device Media Tracks
      final localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {'facingMode': 'user'},
      });

      // Assiging media stream to local renderer
      renderer.srcObject = localStream;

      // Peer connection:
      // Creating peer connection for Local User <--> Remote User
      RTCPeerConnection pc = await _createPeerConnection(remoteUser);
      state.peerConnections[remoteUser] = pc;

      // Adding Local Tracks (Audio + Video)
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
          targetId: remoteUser,
          sdp: offer.sdp,
          sdpType: offer.type,
        ),
      );

      // Storing Renderer for later use
      state.localRenderer = renderer;
      update();
      onSuccess?.call();
    } catch (e, s) {
      _handleErrors("callUser", e, s);
      onFailure?.call(e.toString());
    }
  }

  Future<void> _handleParticipantJoined(LiveMessage msg) async {
    final remoteUserId = msg.userId!;
    if (remoteUserId == state.user!.id) return;
    if (state.peerConnections.containsKey(remoteUserId)) return;

    // Peer connection
    final pc = await _createPeerConnection(remoteUserId);
    state.peerConnections[remoteUserId] = pc;

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
        fromId: state.user!.id,
        meetingId: state.currentMeeting!.id,
      ),
    );
    state.peerConnections[remoteUserId] = pc;
    _joinedParticipantId = remoteUserId;

    update();
  }

  Future<void> _handleOffer(LiveMessage msg) async {
    String remoteUserId = msg.fromId!;
    log("RECEIVED WEB RTC OFFER: $msg");
    // And Offer must have sdp, sdpType and the id of
    // remote user.
    if (msg.sdp == null ||
        msg.sdpType == null ||
        remoteUserId == state.user!.id) {
      throw Exception("Invalid data!");
    }

    log("_handle Offer: DATA IS OK");

    // Checking if our peer connection for remote user is
    // available: (Previously Created). If it was not created
    // maybe something went wrong. We recreate one for our
    // remote user.
    RTCPeerConnection? pc;
    if (state.peerConnections[remoteUserId] == null) {
      pc = await _createPeerConnection(remoteUserId);
      state.peerConnections[remoteUserId] = pc;
      log("_handleOffer: Added new peer connection");
    }
    pc = state.peerConnections[remoteUserId]!;
    log("_handleOffer: $state.peerConnections");

    // Setting remote description for remote user.
    await pc.setRemoteDescription(RTCSessionDescription(msg.sdp, msg.sdpType));

    // creating an answer to send against the offer
    // that the remote sent.
    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);
    _processPendingCandidates(remoteUserId);

    // Sending our answer through our WS
    _repository.sendWS(
      LiveMessage(
        type: LiveMessageType.webrtcAnswer,
        sdp: answer.sdp,
        fromId: state.user!.id,
        sdpType: answer.type,
        targetId: remoteUserId,
        meetingId: _selectedMeeting.value?.id,
      ),
    );
    update();
  }

  Future<void> _handleAnswer(LiveMessage msg) async {
    String? remoteUserId = msg.fromId;
    if (msg.sdp == null ||
        msg.sdpType == null ||
        remoteUserId == null ||
        remoteUserId == state.user!.id) {
      throw Exception("Invalid data!");
    }

    // retrieving remote users peer connection
    RTCPeerConnection? pc = state.peerConnections[remoteUserId];

    if (pc == null) {
      throw Exception("Peer details for this user was not found!");
    }

    // Setting peer details for remote user.
    await pc.setRemoteDescription(RTCSessionDescription(msg.sdp, msg.sdpType));
    _processPendingCandidates(remoteUserId);
  }

  Future<void> _handleRemoteCandidate(LiveMessage msg) async {
    String? remoteUserId = msg.fromId;
    log("_handleRemoteCandidate: Received Remote Candidate");
    final candidate = msg.candidate;
    if (candidate == null || remoteUserId == null) {
      throw Exception("Candidate is empty or invalid");
    }
    log("_handleRemoteCandidate: Remote Candidate is Ok");

    if (!state.peerConnections.containsKey(remoteUserId) ||
        state.peerConnections[remoteUserId] == null) {
      if (!state.peerConnections.containsKey(remoteUserId) ||
          state.peerConnections[remoteUserId] == null) {
        log(
          "_handleRemoteCandidate: Peer connection not found, queueing candidate",
        );
        _pendingCandidates.putIfAbsent(remoteUserId, () => []).add(candidate);
        return;
      }
      throw Exception("Peer details for this user was not found!");
    }

    RTCPeerConnection pc = state.peerConnections[remoteUserId]!;

    await pc.addCandidate(candidate);

    log("_handleRemoteCandidate: Remote candidate is added to peerConnection");

    log("_handleRemoteCandidate: Redirecting to StreamScreen");
  }

  Future<RTCPeerConnection> _createPeerConnection(String id) async {
    // Server details for web rtc connection
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {
          "urls": "turn:openrelay.metered.ca:80",
          "username": "openrelayproject",
          "credential": "openrelayproject",
        },
      ],
      'sdpSemantics': 'unified-plan',
    };

    // generate a new peer connection
    final pc = await createPeerConnection(config);

    // Retriving remote renderer for user
    RTCVideoRenderer renderer = RTCVideoRenderer();
    renderer.initialize();
    state.remoteRenderers[id] = renderer;

    // When ever a new track is added by someone on this
    // peer we take the event and add the stream to remote
    // users renderer
    pc.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        log("_createPeerConnection: GOT TRACKS");
        renderer.srcObject = event.streams[0];
        update();
      }
    };

    // Our Ice Candidate was retrieved.
    // we send it to remote user for them to
    // use it to make the connection
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

    return pc;
  }

  Future<void> _processPendingCandidates(String remoteUserId) async {
    if (_pendingCandidates.containsKey(remoteUserId)) {
      final candidates = _pendingCandidates[remoteUserId]!;
      final pc = state.peerConnections[remoteUserId];

      if (pc != null) {
        for (var candidate in candidates) {
          await pc.addCandidate(candidate);
          log("Added pending candidate");
        }
        _pendingCandidates.remove(remoteUserId);
      }
    }
  }

  // ---------------------- CLEANUP ----------------------

  Future<void> disconnectMeeting() async {
    try {
      _repository.sendWS(
        LiveMessage(type: LiveMessageType.leave, fromId: state.user!.id),
      );
      for (var pc in state.peerConnections.values) {
        await pc.close();
      }
      state.peerConnections.clear();

      for (var renderer in state.remoteRenderers.values) {
        await renderer.dispose();
      }
      state.remoteRenderers.clear();
      state.localRenderer?.dispose();

      state = state.copyWith(
        currentMeeting: null,
        status: LiveSessionStatus.idle,
      );
      update();
    } catch (e, s) {
      _handleErrors("disconnectMeeting", e, s);
    }
  }

  void disconnectWS({
    VoidCallback? onSuccess,
    Function(String)? onFailure,
  }) async {
    try {
      final datastate = await _repository.disconnectWebSocket();
      if (datastate is DataSuccess) {
        _streamSubscription?.cancel();
        _streamSubscription = null;

        for (var pc in state.peerConnections.values) {
          await pc.close();
        }
        state.peerConnections.clear();

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

  void _handleErrors(String methodName, Object? error, StackTrace s) {
    log("LiveController<$methodName>: $error", error: error, stackTrace: s);
    state = state.copyWith(
      status: LiveSessionStatus.failed,
      errorMessage: "$error",
    );
    update();
  }
}
