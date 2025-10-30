// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:ui';
// import 'package:flutter/widgets.dart' show WidgetsBinding;
// import 'package:get/get.dart' hide navigator;
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:utilities/live_communication/models/live_meeting.dart';
// import 'package:utilities/live_communication/models/live_message.dart';
// import 'package:utilities/live_communication/models/live_user.dart';
// import 'package:utilities/live_communication/repository/live_repository.dart';
// import 'package:utilities/live_communication/view/live_screen.dart';
// import 'package:utilities/utils/data_state.dart';

// part 'live_state.dart';

// class LiveController extends GetxController {
//   LiveState state = LiveState();
//   final LiveRepository _repository = LiveRepository();

//   StreamSubscription? _streamSubscription;
//   final Rx<LiveUser?> _selectedUser = Rx(null);
//   LiveUser? get selectedUser => _selectedUser.value;
//   set selectedUser(LiveUser? user) => _selectedUser.value = user;

//   final Rx<LiveMeeting?> _selectedMeeting = Rx(null);
//   LiveMeeting? get selectedMeeting => _selectedMeeting.value;
//   set selectedMeeting(LiveMeeting? meeting) => _selectedMeeting.value = meeting;

//   final Map<String, RTCPeerConnection> _peerConnections = {};
  
//   // CHANGED: Added queue for ICE candidates that arrive before remote description is set
//   final Map<String, List<RTCIceCandidate>> _pendingCandidates = {};

//   // ---------------------- USER REGISTRATION ----------------------

//   Future<void> createUser(
//     String name, {
//     VoidCallback? onSuccess,
//     Function(String error)? onFailure,
//   }) async {
//     try {
//       log("createUser: Starting user creation for name: $name");
//       state = state.copyWith(status: LiveSessionStatus.loading);
//       update();

//       final datastate = await _repository.createUser(name);

//       if (datastate is DataSuccess) {
//         log("createUser: User created successfully: ${datastate.getData()}");
//         state = state.copyWith(
//           user: datastate.getData(),
//           status: LiveSessionStatus.success,
//         );
//         update();
//         await registerUser();
//         onSuccess?.call();
//       } else {
//         throw datastate.getMessage("Failed to create user!");
//       }
//     } catch (e, s) {
//       _handleErrors("createUser", e, s);
//       onFailure?.call(e.toString());
//     }
//   }

//   Future<void> registerUser() async {
//     try {
//       log("registerUser: Registering user with ID: ${state.user!.id}");
//       final message = LiveMessage(
//         type: LiveMessageType.register,
//         userId: state.user!.id,
//       );
//       await _repository.sendWS(message);
//       log("registerUser: Registration message sent");
//     } catch (e, s) {
//       _handleErrors("registerUser", e, s);
//     }
//   }

//   Future<void> loadUsers({
//     VoidCallback? onSuccess,
//     Function(String error)? onFailure,
//   }) async {
//     try {
//       log("loadUsers: Loading available users");
//       state = state.copyWith(status: LiveSessionStatus.loading);
//       update();

//       final datastate = await _repository.getUsers();

//       if (datastate is DataSuccess<List<LiveUser>>) {
//         final users = datastate.getData();
//         log("loadUsers: Loaded ${users.length} users");

//         state = state.copyWith(
//           availableUsers: users,
//           status: LiveSessionStatus.success,
//         );
//         update();
//         onSuccess?.call();
//       } else {
//         final message = datastate.getMessage("Failed to load users!");
//         throw Exception(message);
//       }
//     } catch (e, s) {
//       _handleErrors("loadUsers", e, s);
//       onFailure?.call(e.toString());
//     }
//   }

//   // ---------------------- MEETINGS ----------------------

//   Future<void> createMeeting(
//     String name, {
//     VoidCallback? onSuccess,
//     Function(String error)? onFailure,
//   }) async {
//     try {
//       log("createMeeting: Creating meeting with name: $name");
//       final datastate = await _repository.createMeeting(name, state.user!.id);
//       if (datastate is DataSuccess) {
//         log("createMeeting: Meeting created successfully: ${datastate.getData()}");
//         state = state.copyWith(
//           currentMeeting: datastate.getData(),
//           status: LiveSessionStatus.success,
//         );
//         onSuccess?.call();
//       } else {
//         throw datastate.getMessage("Failed to create meeting!");
//       }
//     } catch (e, s) {
//       _handleErrors("createMeeting", e, s);
//       onFailure?.call(e.toString());
//     }
//   }

//   Future<void> getMeetings({
//     VoidCallback? onSuccess,
//     Function(String error)? onFailure,
//   }) async {
//     try {
//       log("getMeetings: Loading available meetings");
//       state = state.copyWith(status: LiveSessionStatus.loading);
//       update();

//       final datastate = await _repository.getMeetings();
//       if (datastate is DataSuccess) {
//         log("getMeetings: Loaded ${datastate.getData().length} meetings");
//         state = state.copyWith(
//           availableMeetings: datastate.getData(),
//           status: LiveSessionStatus.success,
//         );
//         update();
//         onSuccess?.call();
//       } else {
//         throw datastate.getMessage("Failed to load meetings!");
//       }
//     } catch (e, s) {
//       _handleErrors("getMeetings", e, s);
//       onFailure?.call(e.toString());
//     }
//   }

//   // ---------------------- SOCKET CONNECTION ----------------------

//   void connectWS({
//     required Function(String) onSuccess,
//     Function(String)? onFailure,
//   }) async {
//     try {
//       log("connectWS: Attempting to connect to WebSocket");
//       final datastate = await _repository.connectWebSocket();
//       if (datastate is! DataSuccess) throw "Failed to connect WebSocket";

//       final stream = datastate.getData();
//       if (stream == null) throw "WebSocket stream is empty";

//       log("connectWS: WebSocket connected, listening for messages");

//       _streamSubscription = stream.listen((event) async {
//         final message = LiveMessage.fromJson(event);
//         log("connectWS: RECEIVED MESSAGE - Type: ${message.type}");

//         switch (message.type) {
//           case LiveMessageType.registered:
//             log("connectWS: User registered successfully");
//             state = state.copyWith(
//               isUserRegistered: true,
//               status: LiveSessionStatus.registered,
//             );
//             update();
//             break;

//           case LiveMessageType.participantJoined:
//             log("connectWS: Participant joined - UserID: ${message.userId}");
//             await _handleParticipantJoined(message);
//             break;

//           case LiveMessageType.webrtcOffer:
//             log("connectWS: Received WebRTC offer from: ${message.fromId}");
//             await _handleOffer(message);
//             break;

//           case LiveMessageType.webrtcAnswer:
//             log("connectWS: Received WebRTC answer from: ${message.fromId}");
//             await _handleAnswer(message);
//             break;

//           case LiveMessageType.webICECandidate:
//             log("connectWS: Received ICE candidate from: ${message.fromId}");
//             await _handleRemoteCandidate(message);
//             break;

//           default:
//             log("connectWS: Unhandled message type: ${message.type}");
//         }
//       });

//       state = state.copyWith(isConnectedToWS: true);
//       update();
//       log("connectWS: Connection established successfully");
//       onSuccess("Connected to WebSocket!");
//     } catch (e, s) {
//       _handleErrors("connectWS", e, s);
//       onFailure?.call(e.toString());
//     }
//   }

//   // ---------------------- WEBRTC HANDLERS ----------------------

//   Future<void> joinMeeting({required VoidCallback onSuccess}) async {
//     try {
//       log("joinMeeting: Attempting to join meeting");
//       final meetingId = _selectedMeeting.value?.id;
//       if (meetingId == null) throw "Select a meeting first";

//       log("joinMeeting: Sending join message for meeting: $meetingId");
//       final joinMsg = LiveMessage(
//         type: LiveMessageType.join,
//         meetingId: meetingId,
//       );
//       await _repository.sendWS(joinMsg);

//       log("joinMeeting: Initializing local video renderer");
//       final renderer = RTCVideoRenderer();
//       await renderer.initialize();

//       log("joinMeeting: Requesting user media (audio + video)");
//       final localStream = await navigator.mediaDevices.getUserMedia({
//         'audio': true,
//         'video': {'facingMode': 'user'},
//       });

//       renderer.srcObject = localStream;
//       log("joinMeeting: Local stream assigned to renderer");

//       state = state.copyWith(
//         currentMeeting: _selectedMeeting.value,
//         localRenderer: renderer,
//       );

//       log("joinMeeting: Successfully joined meeting");
//       onSuccess();
//     } catch (e, s) {
//       _handleErrors("joinMeeting", e, s);
//     }
//   }

//   // Planning to use it for initiating connection whenever a user
//   // joins a meeting.
//   String? _joinedParticipantId;

//   Future<void> callUser({
//     VoidCallback? onSuccess,
//     Function(String error)? onFailure,
//   }) async {
//     try {
//       log("callUser: Starting call process");
//       final remoteUser = _selectedUser.value?.id;
//       if (remoteUser == null) throw Exception("Please Select a user");

//       log("callUser: Calling user: $remoteUser");

//       // Initializing Local Renderer
//       log("callUser: Initializing local video renderer");
//       final renderer = RTCVideoRenderer();
//       await renderer.initialize();

//       // Getting Device Media Tracks
//       log("callUser: Requesting user media (audio + video)");
//       final localStream = await navigator.mediaDevices.getUserMedia({
//         'audio': true,
//         'video': {'facingMode': 'user'},
//       });

//       // Assiging media stream to local renderer
//       renderer.srcObject = localStream;
//       log("callUser: Local stream assigned to renderer");

//       // Peer connection:
//       // Creating peer connection for Local User <--> Remote User
//       log("callUser: Creating peer connection for user: $remoteUser");
//       RTCPeerConnection pc;
//       if (!_peerConnections.containsKey(remoteUser) ||
//           _peerConnections[remoteUser] == null) {
//         pc = await _createPeerConnection(remoteUser);
//         _peerConnections[remoteUser] = pc;
//         log("callUser: New peer connection created");
//       } else {
//         pc = _peerConnections[remoteUser]!;
//         log("callUser: Using existing peer connection");
//       }

//       // Adding Local Tracks (Audio + Video)
//       log("callUser: Adding local tracks to peer connection");
//       for (var track in localStream.getTracks()) {
//         pc.addTrack(track, localStream);
//       }

//       // Create offer
//       log("callUser: Creating WebRTC offer");
//       final offer = await pc.createOffer();
//       await pc.setLocalDescription(offer);
//       log("callUser: Local description set");

//       // Send offer
//       log("callUser: Sending offer to remote user");
//       await _repository.sendWS(
//         LiveMessage(
//           type: LiveMessageType.webrtcOffer,
//           fromId: state.user!.id,
//           targetId: remoteUser,
//           sdp: offer.sdp,
//           sdpType: offer.type,
//         ),
//       );

//       // Storing Renderer for later use
//       state = state.copyWith(localRenderer: renderer);
//       update();
//       log("callUser: Call initiated successfully");
//       onSuccess?.call();
//     } catch (e, s) {
//       _handleErrors("callUser", e, s);
//       onFailure?.call(e.toString());
//     }
//   }

//   Future<void> _handleParticipantJoined(LiveMessage msg) async {
//     log("_handleParticipantJoined: Processing participant joined event");
//     final remoteUserId = msg.userId!;
    
//     if (remoteUserId == state.user!.id) {
//       log("_handleParticipantJoined: Ignoring self join event");
//       return;
//     }
    
//     if (_peerConnections.containsKey(remoteUserId)) {
//       log("_handleParticipantJoined: Peer connection already exists for user: $remoteUserId");
//       return;
//     }

//     log("_handleParticipantJoined: Creating peer connection for: $remoteUserId");
    
//     // Peer connection
//     final pc = await _createPeerConnection(remoteUserId);
//     _peerConnections[remoteUserId] = pc;

//     // Add local tracks
//     log("_handleParticipantJoined: Adding local tracks to peer connection");
//     for (var track in state.localRenderer!.srcObject!.getTracks()) {
//       pc.addTrack(track, state.localRenderer!.srcObject!);
//     }

//     // Create offer
//     log("_handleParticipantJoined: Creating offer for new participant");
//     final offer = await pc.createOffer();
//     await pc.setLocalDescription(offer);

//     // CHANGED: Added fromId and targetId to properly identify sender and receiver
//     log("_handleParticipantJoined: Sending offer to participant: $remoteUserId");
//     await _repository.sendWS(
//       LiveMessage(
//         type: LiveMessageType.webrtcOffer,
//         fromId: state.user!.id,
//         targetId: remoteUserId,
//         sdp: offer.sdp,
//         sdpType: offer.type,
//         meetingId: state.currentMeeting!.id,
//       ),
//     );
    
//     _joinedParticipantId = remoteUserId;
//     log("_handleParticipantJoined: Offer sent successfully");

//     update();
//   }

//   Future<void> _handleOffer(LiveMessage msg) async {
//     log("_handleOffer: Processing WebRTC offer");
//     String remoteUserId = msg.fromId!;
    
//     // And Offer must have sdp, sdpType and the id of
//     // remote user.
//     if (msg.sdp == null ||
//         msg.sdpType == null ||
//         remoteUserId == state.user!.id) {
//       log("_handleOffer: Invalid offer data received");
//       throw Exception("Invalid data!");
//     }

//     log("_handleOffer: Offer data validated for user: $remoteUserId");

//     // Initializing an renderer for Remote User
//     log("_handleOffer: Checking remote renderer availability for: $remoteUserId");
//     RTCVideoRenderer? renderer;
//     if (state.remoteRenderers[remoteUserId] == null) {
//       log("_handleOffer: Creating new remote renderer");
//       renderer = RTCVideoRenderer();
//       await renderer.initialize();
//       state.remoteRenderers[remoteUserId] = renderer;
//       log("_handleOffer: Remote renderer created and initialized");
//     } else {
//       renderer = state.remoteRenderers[remoteUserId]!;
//       log("_handleOffer: Using existing remote renderer");
//     }

//     // Checking if our peer connection for remote user is
//     // available: (Previously Created). If it was not created
//     // maybe something went wrong. We recreate one for our
//     // remote user.
    
//     log("_handleOffer: Retrieving/creating peer connection");
//     RTCPeerConnection? pc;
//     if (_peerConnections[remoteUserId] == null) {
//       log("_handleOffer: Creating new peer connection for: $remoteUserId");
//       pc = await _createPeerConnection(remoteUserId);
//       _peerConnections[remoteUserId] = pc;
//     } else {
//       log("_handleOffer: Using existing peer connection");
//     }
//     pc = _peerConnections[remoteUserId]!;

//     // Setting remote description for remote user.
//     log("_handleOffer: Setting remote description");
//     await pc.setRemoteDescription(RTCSessionDescription(msg.sdp, msg.sdpType));
//     log("_handleOffer: Remote description set successfully");

//     // CHANGED: Process any pending ICE candidates that arrived before remote description
//     await _processPendingCandidates(remoteUserId);

//     // creating an answer to send against the offer
//     // that the remote sent.
//     log("_handleOffer: Creating answer");
//     final answer = await pc.createAnswer();
//     await pc.setLocalDescription(answer);
//     log("_handleOffer: Local description (answer) set");

//     // Sending our answer through our WS
//     log("_handleOffer: Sending answer to: $remoteUserId");
//     await _repository.sendWS(
//       LiveMessage(
//         type: LiveMessageType.webrtcAnswer,
//         fromId: state.user!.id, // CHANGED: Added fromId
//         sdp: answer.sdp,
//         sdpType: answer.type,
//         targetId: remoteUserId,
//         meetingId: msg.meetingId,
//       ),
//     );
    
//     // CHANGED: Added state update after modifying remoteRenderers
//     update();
//     log("_handleOffer: Answer sent successfully");
//   }

//   Future<void> _handleAnswer(LiveMessage msg) async {
//     log("_handleAnswer: Processing WebRTC answer");
    
//     // CHANGED: Fixed remoteUserId assignment - was overwriting fromId with userId
//     String? remoteUserId = msg.fromId ?? msg.userId;
    
//     if (msg.sdp == null ||
//         msg.sdpType == null ||
//         remoteUserId == null ||
//         remoteUserId == state.user!.id) {
//       log("_handleAnswer: Invalid answer data received");
//       throw Exception("Invalid data!");
//     }

//     log("_handleAnswer: Answer data validated from user: $remoteUserId");

//     // retrieving remote users peer connection
//     RTCPeerConnection? pc = _peerConnections[remoteUserId];

//     if (pc == null) {
//       log("_handleAnswer: ERROR - Peer connection not found for: $remoteUserId");
//       throw Exception("Peer details for this user was not found!");
//     }

//     log("_handleAnswer: Setting remote description from answer");
//     // Setting peer details for remote user.
//     await pc.setRemoteDescription(RTCSessionDescription(msg.sdp, msg.sdpType));
//     log("_handleAnswer: Remote description set successfully");
    
//     // CHANGED: Process any pending ICE candidates that arrived before remote description
//     await _processPendingCandidates(remoteUserId);
//   }

//   // CHANGED: Complete rewrite of ICE candidate handling with proper validation and queuing
//   Future<void> _handleRemoteCandidate(LiveMessage msg) async {
//     log("_handleRemoteCandidate: Processing ICE candidate");
    
//     String? remoteUserId = msg.fromId;
//     final candidate = msg.candidate;
    
//     // CHANGED: Improved validation - check both userId and candidate
//     if (remoteUserId == null) {
//       log("_handleRemoteCandidate: ERROR - Remote user ID is null");
//       throw Exception("Remote user ID is missing");
//     }
    
//     if (candidate == null) {
//       log("_handleRemoteCandidate: ERROR - Candidate is null for user: $remoteUserId");
//       throw Exception("Candidate is empty or invalid");
//     }

//     log("_handleRemoteCandidate: Candidate validated from user: $remoteUserId");
//     log("_handleRemoteCandidate: Candidate details - ${candidate.candidate}");

//     // Check if peer connection exists
//     if (!_peerConnections.containsKey(remoteUserId) ||
//         _peerConnections[remoteUserId] == null) {
//       log("_handleRemoteCandidate: Peer connection not found, queueing candidate");
//       _pendingCandidates.putIfAbsent(remoteUserId, () => []).add(candidate);
//       return;
//     }

//     RTCPeerConnection pc = _peerConnections[remoteUserId]!;

//     // CHANGED: Check if remote description is set before adding candidate
//     if (pc.getRemoteDescription() == null) {
//       log("_handleRemoteCandidate: Remote description not set yet, queueing candidate");
//       _pendingCandidates.putIfAbsent(remoteUserId, () => []).add(candidate);
//       return;
//     }

//     // Add candidate to peer connection
//     try {
//       await pc.addCandidate(candidate);
//       log("_handleRemoteCandidate: ICE candidate added successfully");
//     } catch (e) {
//       log("_handleRemoteCandidate: ERROR adding candidate: $e");
//       throw Exception("Failed to add ICE candidate: $e");
//     }

//     // CHANGED: Removed automatic navigation - should be handled by onTrack event
//     // The connection is not necessarily ready just because we received a candidate
//     log("_handleRemoteCandidate: Waiting for connection to establish via onTrack event");
//   }

//   // CHANGED: New method to process queued ICE candidates after remote description is set
//   Future<void> _processPendingCandidates(String remoteUserId) async {
//     if (!_pendingCandidates.containsKey(remoteUserId)) {
//       log("_processPendingCandidates: No pending candidates for: $remoteUserId");
//       return;
//     }

//     final candidates = _pendingCandidates[remoteUserId]!;
//     log("_processPendingCandidates: Processing ${candidates.length} pending candidates for: $remoteUserId");
    
//     final pc = _peerConnections[remoteUserId];
    
//     if (pc == null) {
//       log("_processPendingCandidates: ERROR - Peer connection not found");
//       return;
//     }

//     for (var candidate in candidates) {
//       try {
//         await pc.addCandidate(candidate);
//         log("_processPendingCandidates: Added pending candidate");
//       } catch (e) {
//         log("_processPendingCandidates: ERROR adding candidate: $e");
//       }
//     }
    
//     _pendingCandidates.remove(remoteUserId);
//     log("_processPendingCandidates: All pending candidates processed for: $remoteUserId");
//   }

//   Future<RTCPeerConnection> _createPeerConnection(String id) async {
//     log("_createPeerConnection: Creating peer connection for: $id");
    
//     // Server details for web rtc connection
//     final config = {
//       'iceServers': [
//         {'urls': 'stun:stun.l.google.com:19302'},
//         {
//           "urls": "turn:openrelay.metered.ca:80",
//           "username": "openrelayproject",
//           "credential": "openrelayproject",
//         },
//       ],
//       'sdpSemantics': 'unified-plan',
//     };

//     // generate a new peer connection
//     final pc = await createPeerConnection(config);
//     log("_createPeerConnection: Peer connection created");

//     // Retriving remote renderer for user
//     RTCVideoRenderer? renderer = state.remoteRenderers[id];
//     if (renderer == null) {
//       // If not found we initialize it again!
//       log("_createPeerConnection: Initializing new renderer for: $id");
//       renderer = RTCVideoRenderer();
//       await renderer.initialize();
//       state.remoteRenderers[id] = renderer;
//     }

//     // When ever a new track is added by someone on this
//     // peer we take the event and add the stream to remote
//     // users renderer
//     pc.onTrack = (RTCTrackEvent event) {
//       log("_createPeerConnection: onTrack event fired for: $id");
//       if (event.streams.isNotEmpty) {
//         log("_createPeerConnection: Assigning remote stream to renderer");
//         renderer!.srcObject = event.streams[0];
//         update();
        
//         // CHANGED: Navigate to stream screen when track is received (connection is ready)
//         log("_createPeerConnection: Remote stream received, navigating to LiveStreamScreen");
//         WidgetsBinding.instance.addPostFrameCallback(
//           (_) => Get.to(LiveStreamScreen()),
//         );
//       }
//     };

//     // Our Ice Candidate was retrieved.
//     // we send it to remote user for them to
//     // use it to make the connection
//     pc.onIceCandidate = (RTCIceCandidate candidate) {
//       log("_createPeerConnection: ICE candidate generated, sending to: $id");
//       _repository.sendWS(
//         LiveMessage(
//           type: LiveMessageType.webICECandidate,
//           candidate: candidate,
//           fromId: state.user!.id,
//           targetId: id,
//           meetingId: _selectedMeeting.value?.id,
//         ),
//       );
//       log("_createPeerConnection: ICE candidate sent successfully");
//     };

//     // CHANGED: Added additional peer connection event listeners for debugging
//     pc.onIceConnectionState = (RTCIceConnectionState state) {
//       log("_createPeerConnection: ICE connection state changed to: $state for user: $id");
//     };

//     pc.onConnectionState = (RTCPeerConnectionState state) {
//       log("_createPeerConnection: Peer connection state changed to: $state for user: $id");
//     };

//     log("_createPeerConnection: Peer connection setup complete for: $id");
//     return pc;
//   }

//   // ---------------------- CLEANUP ----------------------

//   Future<void> disconnectMeeting() async {
//     try {
//       log("disconnectMeeting: Disconnecting from meeting");
//       _repository.sendWS(
//         LiveMessage(type: LiveMessageType.leave, fromId: state.user!.id),
//       );
      
//       log("disconnectMeeting: Closing ${_peerConnections.length} peer connections");
//       for (var pc in _peerConnections.values) {
//         await pc.close();
//       }
//       _peerConnections.clear();

//       log("disconnectMeeting: Disposing ${state.remoteRenderers.length} remote renderers");
//       for (var renderer in state.remoteRenderers.values) {
//         await renderer.dispose();
//       }
//       state.remoteRenderers.clear();
      
//       log("disconnectMeeting: Disposing local renderer");
//       state.localRenderer?.dispose();
      
//       // CHANGED: Clear pending candidates on disconnect
//       _pendingCandidates.clear();

//       state = state.copyWith(
//         currentMeeting: null,
//         status: LiveSessionStatus.idle,
//       );
//       update();
//       log("disconnectMeeting: Disconnected successfully");
//     } catch (e, s) {
//       _handleErrors("disconnectMeeting", e, s);
//     }
//   }

//   void disconnectWS({
//     VoidCallback? onSuccess,
//     Function(String)? onFailure,
//   }) async {
//     try {
//       log("disconnectWS: Disconnecting from WebSocket");
//       final datastate = await _repository.disconnectWebSocket();
//       if (datastate is DataSuccess) {
//         log("disconnectWS: Cancelling stream subscription");
//         _streamSubscription?.cancel();
//         _streamSubscription = null;

//         log("disconnectWS: Closing all peer connections");
//         for (var pc in _peerConnections.values) {
//           await pc.close();
//         }
//         _peerConnections.clear();
        
//         // CHANGED: Clear pending candidates on disconnect
//         _pendingCandidates.clear();

//         state = state.copyWith(status: LiveSessionStatus.localReady);
//         update();
//         log("disconnectWS: Disconnected successfully");
//         onSuccess?.call();
//       } else {
//         throw datastate.getMessage("Failed to disconnect from ws!");
//       }
//     } catch (e, s) {
//       _handleErrors("disconnectWS", e, s);
//       onFailure?.call(e.toString());
//     }
//   }

//   void _handleErrors(String methodName, Object? error, StackTrace s) {
//     log("ERROR in LiveController.$methodName: $error", 
//         error: error, 
//         stackTrace: s);
//     state = state.copyWith(
//       status: LiveSessionStatus.failed,
//       errorMessage: "$error",
//     );
//     update();
//   }
  
//   @override
//   void onClose() {
//     log("LiveController: onClose called, cleaning up resources");
//     _streamSubscription?.cancel();
//     for (var pc in _peerConnections.values) {
//       pc.close();
//     }
//     _peerConnections.clear();
//     _pendingCandidates.clear();
//     super.onClose();
//   }
// }