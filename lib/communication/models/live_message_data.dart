import 'package:utilities/communication/models/live_message_type.dart';
import 'package:utilities/communication/models/offer_or_answer.dart';
import 'package:utilities/communication/models/s_d_p_details.dart';
import 'package:utilities/communication/models/user_candidates.dart';

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
  // --- CHAT SPECIFIC FIELDS (Merged from message_model) ---
  String? chatId;
  String? content;
  MessageMediaType? contentType;
  DateTime? timestamp;

  // This private constructor will be used to
  // transform data received from server.
  LiveMessageData._({
    this.from,
    this.to,
    this.meetingId,
    this.sdpDetails,
    this.participants,
    this.offers,
    this.answers,
    this.candidates,
    this.errorMessage,
    this.chatId,
    this.content,
    this.contentType,
    this.timestamp,
  });

  // Constructor for Chat Payload
  LiveMessageData.chat({
    required String this.from,
    required String this.to,
    required String this.chatId,
    required String this.content,
    MessageMediaType this.contentType = MessageMediaType.text,
    this.timestamp,
  });

  /// User is registered as online
  LiveMessageData.register({required String this.from});

  LiveMessageData.meetingJoinRequest({
    required String this.from,
    required String this.meetingId,
  });

  /// Required data to send an offer
  /// to another user on 1 to 1 call or a meeting
  LiveMessageData.offer({required this.offers, this.chatId});

  LiveMessageData.answers({required this.answers, this.chatId});

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

  /// Empty data for heartbeat
  LiveMessageData.pong();

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
      if (content != null) 'content': content,
      if (contentType != null) 'content_type': contentType!.name,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
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
      offers: map['offers'] != null
          ? (map['offers'] as List)
                .map((item) => OfferOrAnswer.fromMap(item))
                .toList()
          : null,
      candidates: map['candidates'] != null
          ? (map['candidates'] as List)
                .map((c) => UserCandidates.fromMap(c))
                .toList()
          : null,
      errorMessage: map['message'],
      content: map['content'],
      contentType: map['content_type'] != null
          ? MessageMediaType.values.firstWhere(
              (e) => e.name == map['content_type'],
              orElse: () => MessageMediaType.text,
            )
          : null,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'])
          : null,
    );
  }
}
