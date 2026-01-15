// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_controller.dart';

class LiveState {
  // ... Existing WebRTC fields ...
  RTCVideoRenderer? localRenderer;
  MediaStream? localStream;
  Map<String, RTCVideoRenderer> remoteRenderers;
  Map<String, RTCPeerConnection> peerConnections;
  List<OfferOrAnswer> participants;
  Map<String, List<RTCIceCandidate>> pendingCandidates;
  bool isCandidateComplete = false;
  List<UserCandidates> collectedCandidates;
  List<OfferOrAnswer> generatedAnswers;

  // ... Status fields ...
  bool isStreaming;
  bool isMuted;
  bool isCameraOff;
  bool isConnectedToWS;
  bool isUserOnline;
  LiveSessionStatus status;
  LiveUser? user;
  String message;

  // ... Meeting fields ...
  LiveMeeting? currentMeeting;
  List<LiveMeeting> availableMeetings;
  List<LiveUser> _availableUsers;

  // --- NEW CHAT STATES ---
  List<ChatModel> chats;
  // Maps ChatID -> List of Messages
  Map<String, List<ChatMessageModel>> messages;

  ChatModel? selectedChat;

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
    // New params
    List<ChatModel>? chats,
    Map<String, List<ChatMessageModel>>? messages,
  }) : _availableUsers = availableUsers,
       remoteRenderers = remoteRenderers ?? {},
       peerConnections = peerConnections ?? {},
       pendingCandidates = pendingCandidates ?? {},
       participants = participants ?? [],
       generatedAnswers = toBeSentAnswers ?? [],
       collectedCandidates = collectedCandidates ?? [],
       chats = chats ?? [],
       messages = messages ?? {};

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
