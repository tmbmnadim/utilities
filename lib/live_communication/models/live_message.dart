import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart' show RTCIceCandidate;

class LiveMessage {
  final LiveMessageType type;
  final LiveMessageData data;

  LiveMessage._({required this.type, required this.data});

  /// Register user as online
  LiveMessage.register(this.data) : type = LiveMessageType.register;

  /// Send a request to get available participants and then send offer.
  ///  This is not needed for 1 to 1 call, as offer can be sent directly.
  LiveMessage.meetingJoinRequest(this.data)
    : type = LiveMessageType.joinRequest;

  /// Send offers to users. For 1 to 1 call the list will have only one
  /// item. but for meeting it might contain multiple items.
  LiveMessage.offer(this.data) : type = LiveMessageType.offer;

  LiveMessage.answer(this.data) : type = LiveMessageType.answer;

  LiveMessage.candidate(this.data) : type = LiveMessageType.iceCandidate;

  LiveMessage.leave(this.data) : type = LiveMessageType.leave;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'type': type.toMap(), 'data': data.toMap()};
  }

  factory LiveMessage.fromMap(Map<String, dynamic> map) {
    return LiveMessage._(
      type: LiveMessageType.fromMap(map['type']),
      data: LiveMessageData.fromMap(map['data']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory LiveMessage.fromJson(String source) =>
      LiveMessage.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

class LiveMessageData {
  String? from;
  String? to;
  String? meetingId;
  SDPDetails? sdpDetails;
  List<String>? participants;
  List<OfferOrAnswer>? offers;
  List<OfferOrAnswer>? answers;
  List<UserCandidates>? candidates;
  String? errorMessage;

  // This private constructor will be used to
  // transform data received from server.
  LiveMessageData._({
    this.from,
    this.to,
    this.meetingId,
    this.sdpDetails,
    this.participants,
    this.answers,
    this.candidates,
    this.errorMessage,
  });

  /// User is registered as online
  LiveMessageData.register({required String this.from});

  LiveMessageData.meetingJoinRequest({
    required String this.from,
    required String this.meetingId,
  });

  /// Required data to send an offer
  /// to another user on 1 to 1 call or a meeting
  LiveMessageData.offer({required List<OfferOrAnswer> offers});

  LiveMessageData.answers({required List<OfferOrAnswer> this.answers});

  LiveMessageData.candidates({
    required String this.from,
    required String this.to,
    required List<UserCandidates> this.candidates,
  });

  LiveMessageData.meetingOffer({
    required String this.from,
    required String this.meetingId,
    required this.sdpDetails,
    required List<UserCandidates> this.candidates,
  });

  LiveMessageData.meetingAnswer({
    required String this.from,
    required String this.meetingId,
    required List<OfferOrAnswer> this.answers,
    required List<UserCandidates> this.candidates,
  });

  /// User is registered as online
  LiveMessageData.leave({required String this.from});

  Map<String, dynamic> toMap() {
    final json = {
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (meetingId != null) 'meeting_id': meetingId,
      if (sdpDetails != null) 'sdp_details': sdpDetails?.toMap(),
      if (participants != null) 'participants': participants,
      if (offers != null) 'offers': offers!.map((e) => e.toMap()).toList(),
      if (answers != null) 'answers': answers!.map((e) => e.toMap()).toList(),
      if (candidates != null)
        'candidates': candidates!.map((c) => c.toMap()).toList(),
      if (errorMessage != null) 'message': errorMessage,
    };
    return json;
  }

  factory LiveMessageData.fromMap(Map<String, dynamic> map) {
    return LiveMessageData._(
      from: map['from'],
      to: map['to'],
      meetingId: map['meeting_id'],
      sdpDetails: map['sdp_details'] == null
          ? null
          : SDPDetails.fromMap(map['sdp_details']),
      participants: map['participants'] != null
          ? List<String>.from(map['participants'])
          : null,
      answers: map['answers'] != null
          ? (map['answers'] as List)
                .map((item) => OfferOrAnswer.fromMap(item))
                .toList()
          : null,
      candidates: map['candidates'] != null
          ? (map['candidates'] as List)
                .map((c) => UserCandidates.fromMap(c))
                .toList()
          : null,
      errorMessage: map['message'],
    );
  }
}

class OfferOrAnswer {
  final String from;
  final String to;
  final SDPDetails sdpDetails;

  OfferOrAnswer({
    required this.from,
    required this.to,
    required this.sdpDetails,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'from': from, 'sdp_details': sdpDetails.toMap()};
  }

  factory OfferOrAnswer.fromMap(Map<String, dynamic> map) {
    return OfferOrAnswer(
      from: map['from'] as String,
      to: map['to'] as String,
      sdpDetails: SDPDetails.fromMap(
        map['sdp_details'] as Map<String, dynamic>,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory OfferOrAnswer.fromJson(String source) =>
      OfferOrAnswer.fromMap(json.decode(source) as Map<String, dynamic>);
}

RTCIceCandidate _rtcIceCandidatefromMap(Map<String, dynamic> map) {
  return RTCIceCandidate(map['candidate'], map['sdpMid'], map['sdpMLineIndex']);
}

class UserCandidates {
  String userId;
  List<RTCIceCandidate> candidates;

  UserCandidates({required this.userId, required this.candidates});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': userId,
      'candidates': candidates.map((x) => x.toMap()).toList(),
    };
  }

  factory UserCandidates.fromMap(Map<String, dynamic> json) {
    return UserCandidates(
      userId: json['user_id'] as String,
      candidates: List<RTCIceCandidate>.from(
        (json['candidates'] as List<Map<String, dynamic>>).map<RTCIceCandidate>(
          (x) => _rtcIceCandidatefromMap(x),
        ),
      ),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserCandidates.fromJson(String source) =>
      UserCandidates.fromMap(jsonDecode(source));
}

class SDPDetails {
  final String sdp;
  final String type;

  SDPDetails({required this.sdp, required this.type});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'sdp': sdp, 'sdpType': type};
  }

  factory SDPDetails.fromMap(Map<String, dynamic> map) {
    return SDPDetails(
      sdp: map['sdp'] as String,
      type: map['sdpType'] as String,
    );
  }
}

enum LiveMessageType {
  /// User sends register request.
  /// This is not to sign up. It's
  /// more like saying I'm online.
  ///
  /// {from}
  register,

  /// Succesfully 'onlined' user
  registered,

  /// User sends meeting joining request
  /// the server should return the existing participants
  /// list. with sdp_details empty. No sharing untill
  /// joined.
  ///
  /// {from, meeting_id}
  joinRequest,

  /// User receives who are already on
  /// the meeting.
  /// {
  ///   participants:[{user_id},{user_id}]
  /// }
  participants,

  /// User receives who are already on
  /// the meeting.
  /// {
  ///   offers:{
  ///     {from,to,sdp_details:{sdp,sdpType}},
  ///     {from,to,sdp_details:{sdp,sdpType}},
  ///     ...
  ///     ...
  ///   }
  /// }
  offer,

  /// When other users join the meeting
  /// user is in.
  ///
  /// {participants:{user_id, sdp_details:{sdp,sdpType}}}
  /// when some one joins an existing meeting, their
  /// details is sent to all existing participants and
  /// they receives all remaining participants sdp_details
  participantJoined,

  /// When an Web RTC offer is received from other user
  /// user sends an answer
  ///
  /// [{from,to,sdp_details:{sdp,sdpType}}]
  answer,

  /// The users media connection details is sent thourgh
  /// the Web Socket
  ///
  /// In case of 1 to 1 call this will be:
  /// {from,to,candidate}
  ///
  /// and In case of a meeting:
  /// {from,meeting_id,candidate}
  iceCandidate,

  /// User leaves call or meeting
  /// {from}
  leave,

  /// If call was not receied
  /// from the other side.
  ///
  /// Hellooooo, It's m..
  ///
  /// I am busy
  denied,

  /// Some left the meeting user is in.
  /// {from}
  participantLeft,

  /// Something went wrong
  /// {message}
  error;

  String toMap() {
    switch (this) {
      case LiveMessageType.register:
        return 'register';
      case LiveMessageType.registered:
        return 'registered';
      case LiveMessageType.joinRequest:
        return 'join_request';
      case LiveMessageType.participants:
        return 'participants';
      case LiveMessageType.offer:
        return 'offers';
      case LiveMessageType.participantJoined:
        return 'participant_joined';
      case LiveMessageType.answer:
        return 'answer';
      case LiveMessageType.iceCandidate:
        return 'ice_candidate';
      case LiveMessageType.leave:
        return 'leave';
      case LiveMessageType.denied:
        return 'denied';
      case LiveMessageType.participantLeft:
        return 'participant_left';
      case LiveMessageType.error:
        return 'error';
    }
  }

  static LiveMessageType fromMap(String s) {
    switch (s) {
      case 'register':
        return LiveMessageType.register;
      case 'registered':
        return LiveMessageType.registered;
      case 'join_request':
        return LiveMessageType.joinRequest;
      case 'participants':
        return LiveMessageType.participants;
      case 'offers':
        return LiveMessageType.offer;
      case 'participant_joined':
        return LiveMessageType.participantJoined;
      case 'answers':
        return LiveMessageType.answer;
      case 'ice_candidate':
        return LiveMessageType.iceCandidate;
      case 'leave':
        return LiveMessageType.leave;
      case 'denied':
        return LiveMessageType.denied;
      case 'participant_left':
        return LiveMessageType.participantLeft;
      case 'error':
        return LiveMessageType.error;
      default:
        throw Exception('Unsupported LiveMessageType: $s');
    }
  }
}
