import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart' show RTCIceCandidate;
import 'package:utilities/communication/models/live_message.dart';

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
        (json['candidates'] as List).map<RTCIceCandidate>(
          (x) => _rtcIceCandidatefromMap(x),
        ),
      ),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserCandidates.fromJson(String source) =>
      UserCandidates.fromMap(jsonDecode(source));
}
