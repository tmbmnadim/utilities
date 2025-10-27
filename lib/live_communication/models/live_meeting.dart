class LiveMeeting {
  final String id;
  final String hostUserId;
  final List<String> participantIds;
  final String name;
  final String type;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final List<String> participants;

  LiveMeeting({
    required this.id,
    required this.hostUserId,
    this.participantIds = const [],
    required this.name,
    this.type = 'conference',
    required this.startedAt,
    required this.endedAt,
    required this.participants,
  });

  factory LiveMeeting.fromJson(Map<String, dynamic> json) {
    List<dynamic> participants = json['participantIds'];
    participants.removeWhere((e) => e == null);
    List<String> participantIds = List<String>.from(participants);
    participantIds.removeWhere((e) => e.isEmpty);
    return LiveMeeting(
      id: json['meetingId'],
      hostUserId: json['hostUserId']??"N/A",
      participantIds: participantIds,
      name: json['name']??"N/A",
      type: json['type']??"N/A",
      startedAt: DateTime.tryParse(json['startedAt']??"N/A"),
      endedAt: DateTime.tryParse(json['endedAt']??"N/A"),
      participants: List<String>.from(json['participants'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    // 'meetingId': id,
    'name': name,
    'hostUserId': hostUserId,
    'participantIds': participantIds,
    'type': type,
    'startedAt': startedAt,
    'endedAt': endedAt,
    'participants': participants,
  };
}
