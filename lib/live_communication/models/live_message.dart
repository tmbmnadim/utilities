// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class LiveMessage {
  final StatusType type;
  final String? userId;
  final String? meetingId;
  final String? message;

  LiveMessage({required this.type, this.userId, this.meetingId, this.message});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type.toMap(),
      'data': {
        if (userId != null) 'userId': userId,
        if (meetingId != null) 'meetingId': meetingId,
        if (message != null) 'message': message,
      },
    };
  }

  factory LiveMessage.fromMap(Map<String, dynamic> map) {
    return LiveMessage(
      type: StatusType.fromMap(map['type']),
      userId: map['data']['userId'],
      meetingId: map['data']['meetingId'],
      message: map['data']['message'],
    );
  }

  String toJson() => jsonEncode(toMap());

  factory LiveMessage.fromJson(String source) =>
      LiveMessage.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

enum StatusType {
  register,
  registered,
  join,
  participantJoined,
  leave,
  participantLeft,
  error;

  String toMap() {
    switch (this) {
      case StatusType.register:
        return 'register';
      case StatusType.registered:
        return 'registered';
      case StatusType.join:
        return 'join';
      case StatusType.participantJoined:
        return 'participant-joined';
      case StatusType.leave:
        return 'leave';
      case StatusType.participantLeft:
        return 'participant-left';
      case StatusType.error:
        return 'error';
    }
  }

  factory StatusType.fromMap(String map) {
    switch (map) {
      case 'register':
        return StatusType.register;
      case 'registered':
        return StatusType.registered;
      case 'join':
        return StatusType.join;
      case 'participant-joined':
        return StatusType.participantJoined;
      case 'leave':
        return StatusType.leave;
      case 'participant-left':
        return StatusType.participantLeft;
      case 'error':
        return StatusType.error;
      default:
        throw Exception("Unsupported Status type: $map");
    }
  }
}
