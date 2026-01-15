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
