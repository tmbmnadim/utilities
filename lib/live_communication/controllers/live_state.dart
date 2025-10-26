// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'live_controller.dart';

class LiveState {
  final RTCVideoRenderer? localRenderer;
  final Map<String, RTCVideoRenderer> remoteRenderers = {};
  final Map<String, RTCPeerConnection> peerConnections = {};
  final bool isStreaming;
  final bool isMuted;
  final bool isCameraOff;
  final LiveSessionStatus status;
  final List<LiveUser> users;
  final LiveMeeting? currentMeeting;
  final String errorMessage;

  LiveState({
    this.localRenderer,
    this.isStreaming = false,
    this.isMuted = false,
    this.isCameraOff = false,
    this.status = LiveSessionStatus.idle,
    this.users = const [],
    this.currentMeeting,
    this.errorMessage = "",
  });

  final Map<String, dynamic> iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  LiveState copyWith({
    RTCVideoRenderer? localRenderer,
    bool? isStreaming,
    bool? isMuted,
    bool? isCameraOff,
    LiveSessionStatus? status,
    List<LiveUser>? users,
    LiveMeeting? currentMeeting,
    String? errorMessage,
  }) {
    return LiveState(
      localRenderer: localRenderer ?? this.localRenderer,
      isStreaming: isStreaming ?? this.isStreaming,
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      status: status ?? this.status,
      users: users ?? this.users,
      currentMeeting: currentMeeting ?? this.currentMeeting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum LiveSessionStatus {
  idle,
  success,
  localReady,
  connecting,
  live,
  failed,
  ended,
}
