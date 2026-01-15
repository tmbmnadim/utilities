import 'dart:convert';

import 'package:utilities/communication/models/live_message_data.dart';
import 'package:utilities/communication/models/live_message_type.dart';

class LiveMessage {
  final LiveMessageType type;
  final LiveMessageData data;

  LiveMessage._({required this.type, required this.data});

  // --- 2. Add Chat Constructor ---
  LiveMessage.chat(this.data) : type = LiveMessageType.chat;

  LiveMessage.register(this.data) : type = LiveMessageType.register;
  LiveMessage.meetingJoinRequest(this.data) : type = LiveMessageType.joinRequest;
  LiveMessage.offer(this.data) : type = LiveMessageType.offer;
  LiveMessage.answer(this.data) : type = LiveMessageType.answer;
  LiveMessage.candidate(this.data) : type = LiveMessageType.iceCandidate;
  LiveMessage.leave(this.data) : type = LiveMessageType.leave;
  LiveMessage.pong() : type = LiveMessageType.pong, data = LiveMessageData.pong();

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'type': type.toMap(), 'data': data.toMap()};
  }

  factory LiveMessage.fromMap(Map<String, dynamic> map) {
    return LiveMessage._(
      type: LiveMessageType.fromMap(map['type']),
      data: map['data'] != null
          ? LiveMessageData.fromMap(map['data'])
          : LiveMessageData.pong(),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory LiveMessage.fromJson(String source) => LiveMessage.fromMap(jsonDecode(source));
}