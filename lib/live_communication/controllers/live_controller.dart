import 'dart:async';
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

  // ---------------------- USER REGISTRATION ----------------------

  Future<void> createUser(
    String name, {
    VoidCallback? onSuccess,
    Function(String error)? onFailure,
  }) async {
    try {
      state.status = LiveSessionStatus.loading;
      update();

      final datastate = await _repository.createUser(name);

      if (datastate is DataSuccess) {
        state.status = LiveSessionStatus.success;
        state.message = "Successfuly created account!";
        state.user = datastate.getData()!;
        update();
        state.status = LiveSessionStatus.offline;
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
      final message = LiveMessage.register(
        LiveMessageData.register(from: state.user!.id),
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
      state.status = LiveSessionStatus.loading;
      update();

      final datastate = await _repository.getUsers();

      if (datastate is DataSuccess<List<LiveUser>>) {
        final users = datastate.getData();
        if (users != null && users.isNotEmpty) {
          state._availableUsers = users;
        }
        state.status = LiveSessionStatus.success;
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
      state.status = LiveSessionStatus.loading;
      update();

      final datastate = await _repository.createMeeting(name, state.user!.id);
      if (datastate is DataSuccess) {
        state.currentMeeting = datastate.getData();
        state.status = LiveSessionStatus.success;
        update();

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
      state.status = LiveSessionStatus.loading;
      update();

      final datastate = await _repository.getMeetings();
      if (datastate is DataSuccess) {
        state.status = LiveSessionStatus.success;
        state.availableMeetings = datastate.getData()!;
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

  Future<void> sendMeetingJoinRequest({required VoidCallback onSuccess}) async {
    try {
      final meetingId = _selectedMeeting.value?.id;
      if (meetingId == null) throw "Select a meeting first";

      final joinMsg = LiveMessage.meetingJoinRequest(
        LiveMessageData.meetingJoinRequest(
          from: state.user!.id,
          meetingId: meetingId,
        ),
      );
      await _repository.sendWS(joinMsg);

      await _createLocalRenderer();

      state.currentMeeting = _selectedMeeting.value;
      state.status = LiveSessionStatus.calling;
      update();
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
      state.status = LiveSessionStatus.calling;
      update();
      final to = _selectedUser.value?.id;
      if (to == null) throw Exception("Please Select a user");

      // We create a renderer for local user
      await _createLocalRenderer();

      // Peer connection:
      // Creating peer connection for Local User <--> One Remote User
      await _createPeerConnection(to);

      // The peer connection was created and assigned to this map
      RTCPeerConnection pc = state.peerConnections[to]!;

      // Create offer
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);

      // Send offer
      // We send one offer in the list because this is a one to one
      // call. Incase of meetings multiple offers might be required.
      await _repository.sendWS(
        LiveMessage.offer(
          LiveMessageData.offer(
            offers: [
              OfferOrAnswer(
                from: state.user!.id,
                to: to,
                sdpDetails: SDPDetails(sdp: offer.sdp!, type: offer.type!),
              ),
            ],
          ),
        ),
      );
      onSuccess?.call();
    } catch (e, s) {
      _handleErrors("callUser", e, s);
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

      _streamSubscription = stream.listen(
        (event) async {
          final message = LiveMessage.fromJson(event);

          switch (message.type) {
            case LiveMessageType.register:
            case LiveMessageType.joinRequest:
            case LiveMessageType.leave:
              break;
            case LiveMessageType.registered:
              state.isUserOnline = true;
              state.status = LiveSessionStatus.online;
              update();
              break;

            case LiveMessageType.participants:
              await _handleParticipants(message);
              break;

            case LiveMessageType.offer:
              await _handleOffers(message);
              break;

            case LiveMessageType.participantJoined:
            case LiveMessageType.answer:
              await _handleAnswer(message);
              break;

            case LiveMessageType.iceCandidate:
              await _handleRemoteCandidate(message);
              break;
            case LiveMessageType.denied:
              await _handleParticipantsLeft();
              break;
            case LiveMessageType.participantLeft:
              await _handleParticipantsLeft();
              break;
            case LiveMessageType.error:
              log("❌ WebSocket error: ${message.data.errorMessage}");
              _handleErrors(
                "${message.data.errorMessage}",
                message.data.errorMessage,
              );
              break;
          }
        },
        onError: (error, stackTrace) {
          log("❌ WebSocket error: $error");
          _handleErrors("WebSocket Error", error, stackTrace);
          onFailure?.call("WebSocket Error: $error");
          return;
        },
        onDone: () {
          log("⚠️ WebSocket connection closed by server");
          state.isConnectedToWS = false;
          state.message = "WebSocket connection closed by server";
          update();
          return;
        },
      );

      state.isConnectedToWS = true;
      update();
      onSuccess("Connected to WebSocket!");
    } catch (e, s) {
      _handleErrors("connectWS", e, s);
      onFailure?.call(e.toString());
    }
  }

  // ---------------------- WEBRTC HANDLERS ----------------------

  Future<void> _handleParticipants(LiveMessage msg) async {
    final participants = msg.data.participants ?? [];
    List<OfferOrAnswer> offers = [];
    for (var participant in participants) {
      // Peer connection:
      // Creating peer connection for Local User <--> One Remote User
      await _createPeerConnection(participant);

      // The peer connection was created and assigned to this map
      RTCPeerConnection pc = state.peerConnections[participant]!;

      // Create offer
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);

      offers.add(
        OfferOrAnswer(
          from: state.user!.id,
          to: participant,
          sdpDetails: SDPDetails(sdp: offer.sdp!, type: offer.type!),
        ),
      );
    }
    // Send offer
    // We send one offer in the list because this is a one to one
    // call. Incase of meetings multiple offers might be required.
    await _repository.sendWS(
      LiveMessage.offer(LiveMessageData.offer(offers: offers)),
    );
  }

  Future<void> _handleOffers(LiveMessage msg) async {
    Get.to(LiveStreamScreen(isNewCall: false));
    List<OfferOrAnswer> offers = msg.data.offers ?? [];

    for (var offer in offers) {
      final sdpDetails = offer.sdpDetails;
      final remoteUserId = offer.from;
      if (remoteUserId == state.user!.id) {
        throw Exception("Invalid data!");
      }
      await _createLocalRenderer();
      await _createRemoteRenderer(remoteUserId);

      if (!state.peerConnections.containsKey(remoteUserId) ||
          state.peerConnections[remoteUserId] == null) {
        await _createPeerConnection(remoteUserId);
        log("_handleOffer: Added new peer connection");
      }

      if (state.peerConnections[remoteUserId] == null) {
        throw Exception("Peer connection not found!");
      }

      // Checking if our peer connection for remote user is
      // available: (Previously Created). If it was not created
      // maybe something went wrong. We recreate one for our
      // remote user.
      RTCPeerConnection pc = state.peerConnections[remoteUserId]!;
      if (state.localStream != null) {
        for (var track in state.localStream!.getTracks()) {
          await pc.addTrack(track, state.localStream!);
        }
      }
      log("_handleOffer: $state.peerConnections");

      // Setting remote description for remote user.
      await pc.setRemoteDescription(
        RTCSessionDescription(sdpDetails.sdp, sdpDetails.type),
      );

      // creating an answer to send against the offer
      // that the remote sent.
      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);
      await _processPendingCandidates(remoteUserId);
      state.toBeSentAnswers.add(
        OfferOrAnswer(
          from: state.user!.id,
          to: remoteUserId,
          sdpDetails: SDPDetails(sdp: answer.sdp!, type: answer.type!),
        ),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => update());
  }

  Future<void> _handleAnswer(LiveMessage msg) async {
    final answers = msg.data.answers ?? [];

    for (var answer in answers) {
      String? remoteUserId = answer.from;
      if (remoteUserId == state.user!.id) {
        throw Exception("Invalid data!");
      }

      // retrieving remote users peer connection
      RTCPeerConnection? pc = state.peerConnections[remoteUserId];

      if (pc == null) {
        throw Exception("Peer details for this user was not found!");
      }

      // Setting peer details for remote user.
      await pc.setRemoteDescription(
        RTCSessionDescription(answer.sdpDetails.sdp, answer.sdpDetails.type),
      );
      await _processPendingCandidates(remoteUserId);
    }

    // for meetings we might receive list of candidates for each answer
    if (msg.data.candidates != null) {
      await _handleRemoteCandidate(msg);
    }
  }

  Future<void> _handleRemoteCandidate(LiveMessage msg) async {
    String? remoteUserId = msg.data.from;
    if (remoteUserId == null) {
      throw Exception("Candidate is empty or invalid");
    }
    List<UserCandidates> candidateDetails = msg.data.candidates ?? [];
    for (var candidateDetail in candidateDetails) {
      for (var candidate in candidateDetail.candidates) {
        if (!state.peerConnections.containsKey(remoteUserId) ||
            state.peerConnections[remoteUserId] == null) {
          if (!state.peerConnections.containsKey(remoteUserId) ||
              state.peerConnections[remoteUserId] == null) {
            await _createPeerConnection(remoteUserId);

            state.pendingCandidates
                .putIfAbsent(remoteUserId, () => [])
                .add(candidate);
            return;
          }
          throw Exception("Peer details for this user was not found!");
        }

        RTCPeerConnection pc = state.peerConnections[remoteUserId]!;

        await pc.addCandidate(candidate);
      }
    }
  }

  /// Creates a renderer for user and initializes it. Fetches Stream from Device
  ///  assigns it to the renderer. Stores the Local Stream. and then updates the
  ///  UI.
  Future<void> _createLocalRenderer() async {
    // Initializing Local Renderer
    final renderer = RTCVideoRenderer();
    await renderer.initialize();
    state.localRenderer = renderer;

    // Getting Device Media Tracks
    final localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'},
    });

    // Assiging media stream to local renderer
    state.localRenderer!.srcObject = localStream;

    // Storing Stream for later use
    state.localStream = localStream;
    update();
  }

  /// Creates a renderer for remote user with id. Stores it. But here
  ///  we don't add any streams as we don't yet have remote users camera
  ///  and audio streams. So we don't update the UI yet.
  Future<void> _createRemoteRenderer(String id) async {
    if (state.remoteRenderers.containsKey(id) ||
        state.remoteRenderers[id] != null) {
      return;
    }
    // Initializing Local Renderer
    final renderer = RTCVideoRenderer();
    await renderer.initialize();
    state.remoteRenderers[id] = renderer;
  }

  /// Create a peer connection per remote user. Create renderer for each of
  /// them. When stream for that user is received, we assign that to the
  /// renderer and update the UI.
  Future<void> _createPeerConnection(String id) async {
    if (state.localStream == null) {
      log(
        "Local setup must be done before creating a peer. Local Renderer+ Local Stream",
      );
      throw Exception("Local setup not complete");
    }
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
    await _createRemoteRenderer(id);

    // Add local tracks

    for (var track in state.localStream!.getTracks()) {
      pc.addTrack(track, state.localStream!);
    }

    // When ever a new track is added by someone on this
    // peer we take the event and add the stream to remote
    // users renderer
    pc.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        final stream = event.streams[0];

        // Set the stream to the renderer
        state.remoteRenderers[id]!.srcObject = stream;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          update();
        });
      } else {
        log("onTrack: No streams in event");
      }
    };

    // Our Ice Candidate was retrieved.
    // we send it to remote user for them to
    // use it to make the connection
    state.collectedCandidates.add(UserCandidates(userId: id, candidates: []));
    final userCandidate = state.collectedCandidates.firstWhere(
      (uc) => uc.userId == id,
    );

    pc.onIceCandidate = userCandidate.candidates.add;

    pc.onIceGatheringState = (RTCIceGatheringState gatheringState) {
      if (gatheringState == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        // Sending our answer through our WS
        _repository.sendWS(
          LiveMessage.answer(
            LiveMessageData.meetingAnswer(
              from: state.user!.id,
              meetingId: state.currentMeeting!.id,
              answers: state.toBeSentAnswers,
              candidates: state.collectedCandidates,
            ),
          ),
        );
      }
    };

    state.peerConnections[id] = pc;
    log("_createPeerConnection: All callbacks set for $id");
  }

  Future<void> _processPendingCandidates(String remoteUserId) async {
    if (state.pendingCandidates.containsKey(remoteUserId)) {
      final candidates = state.pendingCandidates[remoteUserId]!;
      final pc = state.peerConnections[remoteUserId];

      if (pc != null) {
        for (var candidate in candidates) {
          await pc.addCandidate(candidate);
          log("Added pending candidate");
        }
        state.pendingCandidates.remove(remoteUserId);
      }
    }
  }

  Future<void> _handleParticipantsLeft() async {}

  // ---------------------- CLEANUP ----------------------

  Future<void> disconnectMeeting() async {
    try {
      _repository.sendWS(
        LiveMessage.leave(LiveMessageData.leave(from: state.user!.id)),
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

      state.currentMeeting = null;
      state.status = LiveSessionStatus.online;
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

        state.status = LiveSessionStatus.offline;
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

  void _handleErrors(String methodName, [Object? error, StackTrace? s]) {
    final border =
        "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
    log(
      "$border\nLiveController<$methodName>: $error\n$border",
      error: error,
      stackTrace: s,
    );
    state.status = LiveSessionStatus.failed;
    state.message = error.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) => update());
  }
}
