import 'package:utilities/communication/models/live_message.dart';
import 'package:utilities/communication/models/s_d_p_details.dart';

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
    return <String, dynamic>{
      'from': from,
      'to': to,
      'sdp_details': sdpDetails.toMap(),
    };
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
}
