// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart' show RTCIceCandidate;

class LiveMessage {
  final LiveMessageType type;
  final String? userId;
  final String? targetId;
  final String? meetingId;
  final String? message;
  final String? sdp;
  final String? sdpType;
  final RTCIceCandidate? candidate;
  final Map<String, List<RTCIceCandidate>>? candidates;

  LiveMessage({
    required this.type,
    this.userId,
    this.targetId,
    this.meetingId,
    this.message,
    this.sdp,
    this.sdpType,
    this.candidate,
    this.candidates,
  });

  Map<String, dynamic> toMap() {
    final json = {
      if (userId != null) 'userId': userId,
      if (targetId != null) 'targetId': targetId,
      if (sdp != null) 'sdp': sdp,
      if (sdpType != null) 'sdpType': sdpType,
      if (meetingId != null) 'meetingId': meetingId,
      if (message != null) 'message': message,
    };
    if (candidate != null) {
      json.addAll(candidate!.toMap());
    }
    return <String, dynamic>{'type': type.toMap(), 'data': json};
  }

  factory LiveMessage.fromMap(Map<String, dynamic> map) {
    RTCIceCandidate rtcIceFrom(dynamic map) {
      Map<String, dynamic> mappedMap = {};
      if (map is String) {
        mappedMap = jsonDecode(map);
      } else {
        mappedMap = map;
      }
      return RTCIceCandidate(
        mappedMap['candidate'],
        mappedMap['sdpMid'],
        mappedMap['sdpMLineIndex'],
      );
    }

    Map<String, dynamic>? iceCandidates;
    Map<String, List<RTCIceCandidate>>? candidates = {};
    if (map['type'] == 'ice-sync') {
      iceCandidates = map['data']['iceCandidates'];
      for (var item in (iceCandidates ?? {}).entries) {
        candidates.addAll({item.key: item.value.map(rtcIceFrom)});
      }
    }
    return LiveMessage(
      type: LiveMessageType.fromMap(map['type']),
      userId: map['data']['userId'],
      targetId: map['data']['targetId'],
      meetingId: map['data']['meetingId'],
      message: map['data']['message'],
      candidate: rtcIceFrom(map['data']),
      candidates: candidates,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory LiveMessage.fromJson(String source) =>
      LiveMessage.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

enum LiveMessageType {
  register,
  registered,
  join,
  participantJoined,
  participants,
  webICECandidate,
  webrtcOffer,
  webrtcAnswer,
  iceSync,
  meetingState,
  leave,
  participantLeft,
  error;

  String toMap() {
    switch (this) {
      case LiveMessageType.register:
        return 'register';
      case LiveMessageType.registered:
        return 'registered';
      case LiveMessageType.join:
        return 'join';
      case LiveMessageType.participantJoined:
        return 'participant-joined';
      case LiveMessageType.participants:
        return 'participants';
      case LiveMessageType.leave:
        return 'leave';
      case LiveMessageType.participantLeft:
        return 'participant-left';
      case LiveMessageType.iceSync:
        return 'ice-sync';
      case LiveMessageType.error:
        return 'error';
      case LiveMessageType.webICECandidate:
        return 'webrtc-ice-candidate';
      case LiveMessageType.meetingState:
        return 'meeting-state';
      case LiveMessageType.webrtcOffer:
        return 'webrtc-offer';
      case LiveMessageType.webrtcAnswer:
        return 'webrtc-answer';
    }
  }

  factory LiveMessageType.fromMap(String map) {
    switch (map) {
      case 'register':
        return LiveMessageType.register;
      case 'registered':
        return LiveMessageType.registered;
      case 'join':
        return LiveMessageType.join;
      case 'participant-joined':
        return LiveMessageType.participantJoined;
      case 'participants':
        return LiveMessageType.participants;
      case 'leave':
        return LiveMessageType.leave;
      case 'participant-left':
        return LiveMessageType.participantLeft;
      case 'error':
        return LiveMessageType.error;
      case 'webrtc-ice-candidate':
        return LiveMessageType.webICECandidate;
      case 'meeting-state':
        return LiveMessageType.meetingState;
      case 'ice-sync':
        return LiveMessageType.iceSync;
      case 'webrtc-offer':
        return LiveMessageType.webrtcOffer;
      case 'webrtc-answer':
        return LiveMessageType.webrtcAnswer;
      default:
        throw Exception("Unsupported Status type: $map");
    }
  }
}
