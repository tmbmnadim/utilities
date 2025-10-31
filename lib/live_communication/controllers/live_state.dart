// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'live_controller.dart';

class LiveState {
  RTCVideoRenderer? localRenderer;
  MediaStream? localStream;
  Map<String, RTCVideoRenderer> remoteRenderers;
  Map<String, RTCPeerConnection> peerConnections;
  bool isStreaming;
  bool isMuted;
  bool isCameraOff;
  bool isConnectedToWS;
  bool isUserOnline;
  LiveSessionStatus status;
  LiveUser? user;
  List<LiveUser> _availableUsers;
  LiveMeeting? currentMeeting;
  List<LiveMeeting> availableMeetings;
  String errorMessage;

  LiveState({
    this.localRenderer,
    this.localStream,
    Map<String, RTCVideoRenderer>? remoteRenderers,
    Map<String, RTCPeerConnection>? peerConnections,
    this.isStreaming = false,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isConnectedToWS = false,
    this.isUserOnline = false,
    this.status = LiveSessionStatus.idle,
    this.user,
    List<LiveUser> availableUsers = const [],
    this.availableMeetings = const [],
    this.currentMeeting,
    this.errorMessage = "",
  }) : _availableUsers = availableUsers,
       remoteRenderers = remoteRenderers ?? {},
       peerConnections = peerConnections ?? {};

  List<LiveUser> get availableUsers {
    List<LiveUser> listWithoutCurrent = [];
    for (var item in _availableUsers) {
      listWithoutCurrent.addIf(user?.id != item.id, item);
    }
    return listWithoutCurrent;
  }

  // LiveState copyWith({
  //   RTCVideoRenderer? localRenderer,
  //   Map<String, RTCVideoRenderer>? remoteRenderers,
  //   Map<String, RTCPeerConnection>? peerConnections,
  //   bool? isStreaming,
  //   bool? isMuted,
  //   bool? isCameraOff,
  //   bool? isConnectedToWS,
  //   bool? isUserOnline,
  //   LiveSessionStatus? status,
  //   LiveUser? user,
  //   List<LiveUser>? availableUsers,
  //   LiveMeeting? currentMeeting,
  //   List<LiveMeeting>? availableMeetings,
  //   String? errorMessage,
  // }) {
  //   return LiveState(
  //     localRenderer: localRenderer ?? this.localRenderer,
  //     remoteRenderers: remoteRenderers ?? this.remoteRenderers,
  //     peerConnections: peerConnections ?? this.peerConnections,
  //     isStreaming: isStreaming ?? this.isStreaming,
  //     isMuted: isMuted ?? this.isMuted,
  //     isCameraOff: isCameraOff ?? this.isCameraOff,
  //     isConnectedToWS: isConnectedToWS ?? this.isConnectedToWS,
  //     isUserOnline: isUserOnline ?? this.isUserOnline,
  //     status: status ?? this.status,
  //     user: user ?? this.user,
  //     availableUsers: availableUsers ?? this.availableUsers,
  //     currentMeeting: currentMeeting ?? this.currentMeeting,
  //     availableMeetings: availableMeetings ?? this.availableMeetings,
  //     errorMessage: errorMessage ?? this.errorMessage,
  //   );
  // }
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
