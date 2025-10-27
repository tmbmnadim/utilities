// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'live_controller.dart';

class LiveState {
  final RTCVideoRenderer? localRenderer;
  final Map<String, RTCVideoRenderer> remoteRenderers = {};
  final Map<String, RTCPeerConnection> peerConnections = {};
  final bool isStreaming;
  final bool isMuted;
  final bool isCameraOff;
  final bool isConnectedToWS;
  final bool isUserRegistered;
  final LiveSessionStatus status;
  final LiveUser? user;
  final List<LiveUser> _availableUsers;
  final LiveMeeting? currentMeeting;
  final List<LiveMeeting> availableMeetings;
  final String errorMessage;

  LiveState({
    this.localRenderer,
    this.isStreaming = false,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isConnectedToWS = false,
    this.isUserRegistered = false,
    this.status = LiveSessionStatus.idle,
    this.user,
    List<LiveUser> availableUsers = const [],
    this.availableMeetings = const [],
    this.currentMeeting,
    this.errorMessage = "",
  }) : _availableUsers = availableUsers;

  List<LiveUser> get availableUsers {
    List<LiveUser> listWithoutCurrent = [];
    for (var item in _availableUsers) {
      listWithoutCurrent.addIf(user?.id != item.id, item);
    }
    return listWithoutCurrent;
  }

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
    bool? isConnectedToWS,
    bool? isUserRegistered,
    LiveSessionStatus? status,
    LiveUser? user,
    List<LiveUser>? availableUsers,
    LiveMeeting? currentMeeting,
    List<LiveMeeting>? availableMeetings,
    String? errorMessage,
  }) {
    return LiveState(
      localRenderer: localRenderer ?? this.localRenderer,
      isStreaming: isStreaming ?? this.isStreaming,
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      isConnectedToWS: isConnectedToWS ?? this.isConnectedToWS,
      isUserRegistered: isUserRegistered ?? this.isUserRegistered,
      status: status ?? this.status,
      user: user ?? this.user,
      availableUsers: availableUsers ?? this.availableUsers,
      currentMeeting: currentMeeting ?? this.currentMeeting,
      availableMeetings: availableMeetings ?? this.availableMeetings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum LiveSessionStatus {
  intial,
  loading,
  idle,
  success,
  localReady,
  connected,
  registered,
  live,
  failed,
  ended,
}
