// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'live_controller.dart';

class LiveState {
  RTCVideoRenderer? localRenderer;
  MediaStream? localStream;
  Map<String, RTCVideoRenderer> remoteRenderers;
  Map<String, RTCPeerConnection> peerConnections;
  List<OfferOrAnswer> participants;
  Map<String, List<RTCIceCandidate>> pendingCandidates;
  bool isCandidateComplete = false;
  List<UserCandidates> collectedCandidates;
  List<OfferOrAnswer> generatedAnswers;
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
  String message;

  LiveState({
    this.localRenderer,
    this.localStream,
    Map<String, RTCVideoRenderer>? remoteRenderers,
    Map<String, RTCPeerConnection>? peerConnections,
    Map<String, List<RTCIceCandidate>>? pendingCandidates,
    List<UserCandidates>? collectedCandidates,
    List<OfferOrAnswer>? toBeSentAnswers,
    List<OfferOrAnswer>? participants,
    this.isStreaming = false,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isConnectedToWS = false,
    this.isUserOnline = false,
    this.isCandidateComplete = false,
    this.status = LiveSessionStatus.online,
    this.user,
    List<LiveUser> availableUsers = const [],
    this.availableMeetings = const [],
    this.currentMeeting,
    this.message = "",
  }) : _availableUsers = availableUsers,
       remoteRenderers = remoteRenderers ?? {},
       peerConnections = peerConnections ?? {},
       pendingCandidates = pendingCandidates ?? {},
       participants = participants ?? [],
       generatedAnswers = toBeSentAnswers ?? [],
       collectedCandidates = collectedCandidates ?? [];

  List<LiveUser> get availableUsers {
    List<LiveUser> listWithoutCurrent = [];
    for (var item in _availableUsers) {
      listWithoutCurrent.addIf(user?.id != item.id, item);
    }
    return listWithoutCurrent;
  }
}

enum LiveSessionStatus {
  intial,
  loading,
  success,
  failed,
  offline,
  online,
  calling,
  onACall,
  incomingCall,
  ended,
  denied,
}
