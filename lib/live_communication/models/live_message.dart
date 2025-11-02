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
  /// item. but for meeting it'll contain 1 to multiple items.
  LiveMessage.sendOffers(this.data) : type = LiveMessageType.offer;

  /// The answer for an incoming offer
  LiveMessage.answer(this.data) : type = LiveMessageType.answers;

  /// Joining a meeting
  LiveMessage.meeting(this.data) : type = LiveMessageType.join;

  LiveMessage.candidate(this.data) : type = LiveMessageType.iceCandidate;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'type': type.toMap(), 'data': data.toJson()};
  }

  factory LiveMessage.fromMap(Map<String, dynamic> map) {
    return LiveMessage._(
      type: LiveMessageType.fromMap(map['type']),
      data: LiveMessageData.fromJson(map['data']),
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
  List<Offer>? offers;
  List<Offer>? answer;
  List<RTCIceCandidate>? candidates;
  String? errorMessage;

  // This private constructor will be used to
  // transform data received from server.
  LiveMessageData._({
    this.from,
    this.to,
    this.meetingId,
    this.sdpDetails,
    this.participants,
    this.answer,
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
  LiveMessageData.offer({required List<Offer> offers});

  LiveMessageData.answer({
    required String this.from,
    required String this.to,
    required this.sdpDetails,
  });

  LiveMessageData.candidates({
    required String this.from,
    required String this.to,
    required List<RTCIceCandidate> this.candidates,
  });

  LiveMessageData.meetingAnswer({
    required String this.from,
    required String this.meetingId,
    required this.sdpDetails,
    required List<RTCIceCandidate> this.candidates,
  });

  Map<String, dynamic> toMap() {
    final json = {
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (sdpDetails != null) 'sdp_details': sdpDetails,
      if (meetingId != null) 'meeting_id': meetingId,
      if (candidates != null) 'candidates': candidates!.map((c) => c.toMap()),
      if (errorMessage != null) 'message': errorMessage,
    };
    return json;
  }

  factory LiveMessageData.fromMap(Map<String, dynamic> map) {
    RTCIceCandidate? rtcIceFrom(dynamic map) {
      if (map == null) return null;
      return RTCIceCandidate(
        map['candidate'],
        map['sdpMid'],
        map['sdpMLineIndex'],
      );
    }

    return LiveMessageData._(
      from: map['from'],
      to: map['to'],
      meetingId: map['meeting_id'],
      sdpDetails: SDPDetails.fromJson(map['sdp_details']),
      participants: map['participants'].map((item) => item['user_id']).toList(),
      answer: map['participant_answers']
          .map((item) => Answer.fromJson(item))
          .toList(),
      candidates: map['candidates'].map((c) => rtcIceFrom(c)).toList(),
      errorMessage: map['message'],
    );
  }

  String toJson() => jsonEncode(toMap());

  factory LiveMessageData.fromJson(String source) =>
      LiveMessageData.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

class Offer {
  final String from;
  final String to;
  final SDPDetails sdpDetails;

  Offer({required this.from, required this.to, required this.sdpDetails});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'from': from, 'sdp_details': sdpDetails.toMap()};
  }

  factory Offer.fromMap(Map<String, dynamic> map) {
    return Offer(
      from: map['from'] as String,
      to: map['to'] as String,
      sdpDetails: SDPDetails.fromMap(
        map['sdp_details'] as Map<String, dynamic>,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Offer.fromJson(String source) =>
      Offer.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Answer {
  final String from;
  final String to;
  final SDPDetails sdpDetails;

  Answer({required this.from, required this.to, required this.sdpDetails});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'from': from,
      'to': to,
      'sdp_details': sdpDetails.toMap(),
    };
  }

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      from: map['from'] as String,
      to: map['to'] as String,
      sdpDetails: SDPDetails.fromMap(
        map['sdp_details'] as Map<String, dynamic>,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Answer.fromJson(String source) =>
      Answer.fromMap(json.decode(source) as Map<String, dynamic>);
}

class SDPDetails {
  final String sdp;
  final String sdpType;

  SDPDetails({required this.sdp, required this.sdpType});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'sdp': sdp, 'sdpType': sdpType};
  }

  factory SDPDetails.fromMap(Map<String, dynamic> map) {
    return SDPDetails(
      sdp: map['sdp'] as String,
      sdpType: map['sdpType'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SDPDetails.fromJson(String source) =>
      SDPDetails.fromMap(json.decode(source) as Map<String, dynamic>);
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

  /// User sends their sdp.
  ///
  /// {from, meeting_id, sdpDetails:{sdp, sdpType}}
  join,

  /// User receives who are already on
  /// the meeting.
  /// {
  ///   offers:{
  ///     {user_id:sdp_details},
  ///     {user_id:sdp_details},
  ///     ...
  ///     ...
  ///   }
  /// }
  offers,

  /// When other users join the meeting
  /// user is in.
  ///
  /// {participants:{user_id, sdp_details:{sdp,sdpType}}}
  /// when some one joins an existing meeting, their
  /// details is sent to all existing participants and
  /// they receives all remaining participants sdp_details
  participantJoined,

  /// User sends an connection offer to
  /// another user to connect through
  /// Web RTC.
  ///
  /// {from,to,sdp_details:{sdp,sdpType}}
  offer,

  /// When an Web RTC offer is received from other user
  /// user sends an answer
  ///
  /// [{from,to,sdp_details:{sdp,sdpType}}]
  answers,

  /// The users media connection details is sent thourgh
  /// the Web Socket
  ///
  /// In case of 1 to 1 call this will be:
  /// {from,to,candidate}
  ///
  /// and In case of a meeting:
  /// {from,meeting_id,candidate}
  iceCandidate,

  /// What are the diff between iceSync and meetingState?
  iceSync,
  meetingState,

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
      case LiveMessageType.join:
        return 'join';
      case LiveMessageType.participants:
        return 'participants';
      case LiveMessageType.offers:
        return 'offers';
      case LiveMessageType.offer:
        return 'offer';
      case LiveMessageType.participantJoined:
        return 'participant_joined';
      case LiveMessageType.answers:
        return 'answers';
      case LiveMessageType.iceCandidate:
        return 'ice_candidate';
      case LiveMessageType.iceSync:
        return 'ice_sync';
      case LiveMessageType.meetingState:
        return 'meeting_state';
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
      case 'join':
        return LiveMessageType.join;
      case 'participants':
        return LiveMessageType.participants;
      case 'offers':
        return LiveMessageType.offers;
      case 'offer':
        return LiveMessageType.offer;
      case 'participant_joined':
        return LiveMessageType.participantJoined;
      case 'answers':
        return LiveMessageType.answers;
      case 'ice_candidate':
        return LiveMessageType.iceCandidate;
      case 'ice_sync':
        return LiveMessageType.iceSync;
      case 'meeting_state':
        return LiveMessageType.meetingState;
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
